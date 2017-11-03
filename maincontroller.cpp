#include "maincontroller.h"
#include "commonfunction.h"
#include "configsetting.h"
#include <QDebug>
#include <QUrl>
#include <QThread>
#include <QMessageBox>
#include <QtConcurrent>
#include <QDateTime>
#include <QGuiApplication>

MainController::MainController(QObject *parent) :
    QObject(parent)
  ,m_httpLogin(NULL)
  ,m_keepwake(Q_NULLPTR)
{
    slSrvurl = SL_URLSECURE;

    setting = new ConfigSetting(this);

    QString deviceId = QString(QUuid::createUuid().toRfc4122().toHex());

    QStringList sesids;
    sesids << "1498725857468-625" << "1498725857468-381" << "1498725857468-326" << "1498725857468-598" <<
              "1498725857468-623" << "1498725857468-115" << "1498725857468-932" << "1498725857468-025" << "1498725857468-352";

#ifdef Q_OS_ANDROID
//    m_sesid = "1498725857468-512"; // meeting room Danube
    m_sesid = "1498725857468-519"; // meeting room 'Phòng họp test'
#else
    m_sesid = sesids.at( QDateTime::currentMSecsSinceEpoch() % sesids.size() );
#endif

    m_wsClient = new WSClient(QUrl(QString("%1%2").arg(SL_WEBSOCKET).arg(m_sesid)), true, 0);
    QObject::connect(m_wsClient, SIGNAL(textMessageReceived(QString)), this, SLOT(onNotify(const QString&)));
    m_wsClient->start();

    m_keepwake = new KeepWake();

    qDebug() << "area id: " << setting->areaId << ", name=" << setting->roomName;

    onGetSensorOnArea(setting->areaId);
    onMeetingRoom(setting->roomId);
    onGetRoomList();

    onGetBrightness(setting->areaId);

    refreshRoomname(setting->roomName);
}

MainController::~MainController()
{
    if (m_httpLogin) delete m_httpLogin;
}

// onoff=true: turn screen on; onoff=false: turn screen off (saver)
void MainController::screenSave(bool onoff)
{
    m_keepwake->onChange(onoff);
}

bool MainController::isDebugmode()
{
#ifdef QT_DEBUG
    return true;
#endif
    return false;
}

bool MainController::isAndroid()
{
#ifdef Q_OS_ANDROID
    return true;
#endif
    return false;
}

void MainController::appQuit()
{
    qApp->quit();
}

QString MainController::appBuildDate()
{
    return QString::fromUtf8("%1 - %2").arg(__DATE__).arg(__TIME__);
}

QString MainController::getConfigUsername()
{
    return setting->userName;
}

QString MainController::getConfigUserpwd()
{
    return setting->userPwd;
}

QString MainController::getConfigRoomname()
{
    return setting->roomName;
}

int MainController::getConfigRoomid()
{
    return setting->roomId;
}

int MainController::getConfigAreaid()
{
    return setting->areaId;
}

int MainController::getConfigCurrentAreaIndex()
{
    return setting->currentAreaIdx;
}

void MainController::setConfigCurrentAreaIndex(int idx, int areaId)
{
    setting->setCurrentAreaIdx(idx);
    setting->setAreaid(areaId);

    onGetAreaList();
}

bool MainController::getConfigAllowLightControl()
{
    return setting->allowLightControl;
}

void MainController::setConfigAllowLightControl(bool allow)
{
    setting->setAllowLightControl(allow);
}

void MainController::setConfigRoomArea(int roomid, int areaid, const QString &roomname)
{
    setting->setRoomId(roomid, areaid);
    setting->setRoomname(roomname);

    onGetBrightness(areaid);
    onGetLightsOnArea(areaid);
}

void MainController::onError(const int &err, const QString &msg)
{
    qDebug() << "onError, err:" << err << ", msg:" << msg;
    emit login(err, msg);
}

void MainController::userLogin(const QString &u, const QString &p)
{
    setting->setUsername(u, p);
    doLogingetkey(u, p);
}

void MainController::doLogingetkey(const QString &u, const QString &p)
{
    m_usrname = u;
    m_usrpwd = p;

    if (m_httpLogin == NULL)
    {
        m_httpLogin = new HttpBase2(QString(""), this);
        QObject::connect(m_httpLogin, SIGNAL(done(QVariant)), this, SLOT(onLogingetkeyDone(QVariant)));
        QObject::connect(m_httpLogin, SIGNAL(error(int,QString)), this, SLOT(onError(int,QString)));

        m_httpLogin->setUrl(QString(slSrvurl + SL_LNKLOGIN));
        m_httpLogin->addParameter("cm", "getKeyLogin", true);
        m_httpLogin->addParameter("dt", Cmnfunc::formatLoginkey(m_usrname));

        m_httpLogin->process();
    }
}

void MainController::onLogingetkeyDone(const QVariant &data)
{    
    m_httpLogin->deleteLater();
    m_httpLogin = NULL;

    if (Cmnfunc::parseLoginkey(data.toString(), m_loginKey, m_loginCode) == 0)
    {
        doLogin(m_usrname, m_usrpwd, m_loginKey, m_loginCode);
    }
    else
    {
        QString msg;
        int err = Cmnfunc::parseErrMsg(data.toString(), msg);
        emit login(err, msg);
    }
}

void MainController::doLogin(const QString &u, const QString &p, const QString &key, const QString &code)
{
    if (m_httpLogin == NULL)
    {
        m_httpLogin = new HttpBase2(QString(""), this);
    }
    else
    {
        QObject::disconnect(m_httpLogin, SIGNAL(done(QVariant)), this, SLOT(onLogingetkeyDone(QVariant)));
        QObject::disconnect(m_httpLogin, SIGNAL(error(int,QString)), this, SLOT(onError(int, QString)));
    }

    QObject::connect(m_httpLogin, SIGNAL(done(QVariant)), this, SLOT(onLoginDone(QVariant)));
    QObject::connect(m_httpLogin, SIGNAL(error(int,QString)), this, SLOT(onError(int,QString)));

    m_httpLogin->setUrl(QString(slSrvurl + SL_LNKLOGIN));
    m_httpLogin->addParameter("cm", "verifyLogin", true);
    m_httpLogin->addParameter("dt", Cmnfunc::formatLoginverify(u, p, key, code));

    m_httpLogin->process();
}

void MainController::onLoginDone(const QVariant &data)
{
    QString msg;
    int err = Cmnfunc::parseErrMsg(data.toString(), msg);
    if (err == 0)
    {
        QObject::disconnect(m_httpLogin, SIGNAL(done(QVariant)), this, SLOT(onLoginDone(QVariant)));
        QObject::disconnect(m_httpLogin, SIGNAL(error(int,QString)), this, SLOT(onError(int, QString)));

        // lấy danh sách area để lấy areaId
        onGetRoomList();
    }
    else
    {
        m_httpLogin->deleteLater();
        m_httpLogin = NULL;
    }

    if( !msg.isEmpty() ) {
        emit login(err, msg);
    }
    else {
        emit login(err, "Đăng nhập lỗi!");
    }
}

void MainController::callGetAreaList()
{
    onGetAreaList();
}

void MainController::callGetLightsOnArea(long areaId)
{
    qDebug() << "callGetLightsOnArea, area id=" << areaId;

    if( m_lights.size() > 0 )
    {
        emit refreshLightList2( jsonLights() );
        return;
    }

    if( areaId >= 0) {
        setting->setAreaid(areaId);
    }
    else {
        areaId = setting->areaId;
    }

    onGetLightsOnArea(areaId);
}

void MainController::callGetSensorOnArea(long areaId)
{
    if( areaId >= 0) {
        setting->setAreaid(areaId);
    }
    else {
        areaId = setting->areaId;
    }

    onGetSensorOnArea(areaId);
}

void MainController::callSwitchLight(long lightId, QString lightCode, int on_off, int dim)
{
    switchLight(lightId, lightCode, on_off, dim);
}

void MainController::callDimLight(long lightId, QString lightCode, int dimValue)
{
    dimLight(lightId, lightCode, dimValue);
}

void MainController::callDimLightOnArea(int brightness) {
    dimLightArea(brightness);
}

void MainController::callSetDimGroup(int dimValue)
{
    //dimLightGroup(setting->areaId, dimValue);
    dimHub(setting->areaId, dimValue);
}

void MainController::callSwitchGroup(int on_off)
{
    m_light.onoff = on_off;
    //switchLightGroup(setting->areaId, on_off);
    dimHub(setting->areaId, on_off < 0.1 ? 0 : 100);
}

void MainController::callSwitchGroup(int on_off, int brightness) {
    m_light.onoff = on_off;
    int  v = brightness;
    qDebug() << "brightess: " << QString::number(v);
    if(v == 0) {
        v = 100;
    }
    dimHub(setting->areaId, on_off < 0.1 ? 0 : v);
}

void MainController::callGetRemoteList(long areaId)
{
    if( areaId >= 0 ) {
        onGetRemoteList(areaId);
    }
    else {
        onGetRemoteList(setting->areaId);
    }
}

void MainController::callMeetingRoom(int rooid)
{
    if( rooid >= 0 ) {
        onMeetingRoom(rooid);
    }
    else {
        onMeetingRoom(setting->roomId);
    }
}

void MainController::callRemoteCtrll(const QString &devcode, int devtype, int devbutton, int devvalue)
{
    onRemoteCtrll(setting->areaId, devcode, devtype, devbutton, devvalue);
}

// get all lights status
void MainController::getLightsStatus()
{
    qDebug() << "getLightsStatus";

    emit updateLights( jsonLights() );
}

void MainController::onGetRoomList()
{
    HttpBase *hbroomlist = new HttpBase(QString(""), this);
    QObject::connect(hbroomlist, SIGNAL(done(QVariant)), this, SLOT(onGetRoomListDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbroomlist, SIGNAL(done(QVariant)), hbroomlist, SLOT(deleteLater()));
    QObject::connect(hbroomlist, SIGNAL(error(int,QString)), hbroomlist, SLOT(deleteLater()));

    hbroomlist->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKROOMLIST)));
    hbroomlist->addParameter("cm", "getlist_mobile", true);
    hbroomlist->process();
}

void MainController::onGetRoomListDone(const QVariant &data)
{
    qDebug() << "room data:" << data.toString();

    QString msg;
    if( Cmnfunc::parseErrMsg(data.toString(), msg) == 0 )
    {
          emit refreshRoomList(data);

//        QString roomname;
//        int areaId = setting->areaId, roomId = setting->roomId;

//        if( Cmnfunc::parseRoomnameList(data.toString(), areaId, roomname, roomId) == true )
//        {
//            qDebug() << "room name=" << roomname << "area id=" << areaId << ", room id=" << roomId;
//            qDebug() << "setting roomname=" << setting->roomName << ", areaid=" << setting->areaId << ", roomid=" << setting->roomId;

//            if( (roomId != setting->roomId) || (areaId != setting->areaId) ) {
//                // set default areaId for room[0] for the 1st time setup app
//                setting->setRoomId(roomId, areaId);
//                setting->setRoomname(roomname);
//            }

//            m_roomname = roomname;

//            qDebug() << "Room name:" << m_roomname;

//            emit refreshRoomname( roomname );
//            emit refreshRoomList(data);

//            onGetAreaList();
//            //onGetLightsOnArea(setting->areaId);
//        }
    }
}

void MainController::onGetAreaList()
{
    qDebug() << "onGetAreaList() ... ";

    HttpBase *hbarealist = new HttpBase(QString(""), this);
    QObject::connect(hbarealist, SIGNAL(done(QVariant)), this, SLOT(onGetAreaListDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbarealist, SIGNAL(done(QVariant)), hbarealist, SLOT(deleteLater()));
    QObject::connect(hbarealist, SIGNAL(error(int,QString)), hbarealist, SLOT(deleteLater()));

    hbarealist->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT)));
    hbarealist->addParameter("cm", "get_list_areas", true);
    hbarealist->addParameter("dt", "{}");
    hbarealist->process();
}

void MainController::onGetAreaListDone(const QVariant &data)
{
    qDebug() << "onGetAreaListDone:";// << data.toString();

    QString roomname;
    int areaId = setting->areaId;

    if( Cmnfunc::parseRoomnameArea(data.toString(), areaId, roomname) == true )
    {
        if( areaId != setting->areaId ) {
            // set default areaId for room[0] for the 1st time setup app
            setting->setAreaid(areaId);
            setting->setRoomname(roomname);
        }

        m_roomname = roomname;

        qDebug() << "onGetAreaListDone name:" << m_roomname;

        emit refreshRoomname( roomname );
        emit refreshAreaList2(data);

        onGetLightsOnArea(setting->areaId);
    }
}

// get light_group value
void MainController::onGetBrightness(long areaId)
{
    qDebug() << "GetBrightness areaId:" << areaId;

    HttpBase *hbgetbrightness = new HttpBase(QString(""), this);
    QObject::connect(hbgetbrightness, SIGNAL(done(QVariant)), this, SLOT(onGetBrightnessDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbgetbrightness, SIGNAL(done(QVariant)), hbgetbrightness, SLOT(deleteLater()));
    QObject::connect(hbgetbrightness, SIGNAL(error(int,QString)), hbgetbrightness, SLOT(deleteLater()));

    hbgetbrightness->setUrl(QUrl(QString("%1%2").arg(SL_URLSECURE).arg(SL_LNKLIGHT)));
    hbgetbrightness->addParameter("cm", "get_brightness_group", true);
    hbgetbrightness->addParameter("dt", Cmnfunc::formatRequestLightsOnArea(areaId, -1, -1, m_sesid));
    hbgetbrightness->process();
}

// get light_group value result
void MainController::onGetBrightnessDone(const QVariant &data)
{
    qDebug() << "onGetBrightnessDone:" << data.toString();

    QString msg;
    if( Cmnfunc::parseErrMsg(data.toString(), msg) == 0 )
    {
        m_light.parseArea( data.toString() );

        onGetLightsOnArea(setting->areaId);
    }
}

void MainController::dimHub(long areaId, int dimvalue)
{
    qDebug() << "dimHub() areaId:" << areaId << ", dim value:" << dimvalue;

    HttpBase *dumhup = new HttpBase(QString(""), this);
    QObject::connect(dumhup, SIGNAL(done(QVariant)),     dumhup, SLOT(deleteLater()), Qt::UniqueConnection);
    QObject::connect(dumhup, SIGNAL(error(int,QString)), dumhup, SLOT(deleteLater()), Qt::UniqueConnection);

    dumhup->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_HUB)));
    dumhup->addParameter("cm", "dim_all_in_area", true);
    dumhup->addParameter("dt", Cmnfunc::formatDimhub(areaId, dimvalue, m_sesid));
    dumhup->process();

    setLightGroupValue(dimvalue);

    emit refreshAreaBrightness(areaId, dimvalue, dimvalue==0?0:1);
}

void MainController::dimLightGroup(long areaId, int brightness)
{
    qDebug() << "dimLightGroup() areaId:" << areaId << ", brightness:" << brightness;

    HttpBase *hbsetbrightness = new HttpBase(QString(""), this);
    QObject::connect(hbsetbrightness, SIGNAL(done(QVariant)), hbsetbrightness, SLOT(deleteLater()), Qt::UniqueConnection);
    QObject::connect(hbsetbrightness, SIGNAL(error(int,QString)), hbsetbrightness, SLOT(deleteLater()));

    hbsetbrightness->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT2)));
    hbsetbrightness->addParameter("cm", "change_brightness_group", true);
    hbsetbrightness->addParameter("dt", Cmnfunc::formatRequestLightsOnArea(areaId, brightness, brightness==0?0:1, m_sesid));
    hbsetbrightness->process();

    setLightGroupValue(brightness);

    emit refreshAreaBrightness(areaId, brightness, brightness==0?0:1);
}

void MainController::switchLightGroup(long areaId, int onoff)
{
    qDebug() << "switchLightGroup areaId:" << areaId << ", onoff:" << onoff;

    HttpBase *hbswchonoff = new HttpBase(QString(""), this);
    QObject::connect(hbswchonoff, SIGNAL(done(QVariant)), hbswchonoff, SLOT(deleteLater()));
    QObject::connect(hbswchonoff, SIGNAL(error(int,QString)), hbswchonoff, SLOT(deleteLater()));

    hbswchonoff->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT2)));
    hbswchonoff->addParameter("cm", "switch_on_off_group", true);
    hbswchonoff->addParameter("dt", Cmnfunc::formatRequestLightsOnArea(areaId, -1, onoff, m_sesid));
    hbswchonoff->process();

    setLightGroupOnoff(onoff);

    emit refreshAreaBrightness(areaId, m_light.brightness, onoff);
}

void MainController::onGetLightsOnArea(long areaId)
{
    qDebug() << "onGetLightsOnArea() areaId:" << areaId;

    HttpBase *hblightonarea = new HttpBase(QString(""), this);
    QObject::connect(hblightonarea, SIGNAL(done(QVariant)), this, SLOT(onGetLightsOnAreaDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hblightonarea, SIGNAL(done(QVariant)), hblightonarea, SLOT(deleteLater()));
    QObject::connect(hblightonarea, SIGNAL(error(int,QString)), hblightonarea, SLOT(deleteLater()));

    hblightonarea->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT)));
    hblightonarea->addParameter("cm", "getlist_light_by_area_id", true);
    hblightonarea->addParameter("dt", Cmnfunc::formatRequestLightsOnArea(areaId, -1, -1, m_sesid));
    hblightonarea->process();
}

void MainController::onGetLightsOnAreaDone(const QVariant &data)
{
    qDebug() << "onGetLightsOnAreaDone:" << data.toString();

    QString msg;
    if( Cmnfunc::parseErrMsg(data.toString(), msg) == 0 )
    {
        Cmnfunc::parseDataLights(data.toString(), m_lights);

        //emit refreshLightList2(data);
        emit updateLights( jsonLights() );
    }
}

void MainController::onGetSensorOnArea(long areaId)
{
    HttpBase *hbgetsensor = new HttpBase(QString(""), this);
    QObject::connect(hbgetsensor, SIGNAL(done(QVariant)), this, SLOT(onGetSensorOnAreaDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbgetsensor, SIGNAL(done(QVariant)), hbgetsensor, SLOT(deleteLater()));
    QObject::connect(hbgetsensor, SIGNAL(error(int,QString)), hbgetsensor, SLOT(deleteLater()));

    hbgetsensor->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKSENSOR)));
    hbgetsensor->addParameter("cm", "get_area_info", true);
    hbgetsensor->addParameter("dt", Cmnfunc::formatRequestArea(areaId));
    hbgetsensor->process();
}

void MainController::onGetSensorOnAreaDone(const QVariant &data)
{
    qDebug() << "get sensors on done:" << data;

    QString msg;
    if( Cmnfunc::parseErrMsg(data.toString(), msg) == 0 )
    {
        emit refreshSensors2(data);
    }
}

void MainController::switchLight(long lightId, QString lightCode, int on_off, int dim)
{
    qDebug() << "switchLight() onoff:" << on_off;

    HttpBase *hbswchlight = new HttpBase(QString(""), this);
    QObject::connect(hbswchlight, SIGNAL(done(QVariant)), hbswchlight, SLOT(deleteLater()), Qt::UniqueConnection);
    QObject::connect(hbswchlight, SIGNAL(error(int,QString)), hbswchlight, SLOT(deleteLater()));

    hbswchlight->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT2)));
    hbswchlight->addParameter("cm", "switch_on_off", true);
    hbswchlight->addParameter("dt", Cmnfunc::formatRequestSwitchLight(setting->areaId, lightId, lightCode, on_off, dim, m_sesid));
    hbswchlight->process();

    setLightOnoff(lightCode, on_off);

    if( on_off == 1 )/* {
        // gán vào biến member để dành cho trường hợp bật sáng lên lại thì nhớ giá trị cũ
        setLightValue(lightCode, dim);
    }
    else */{
        // lấy giá trị bộ nhớ vì lúc này dim value = 0, cần nhớ giá trị cũ
        dim = getLightValue(lightCode);
    }

    emit refreshLightStatus(lightCode, on_off, dim);
}

void MainController::dimLightArea(int brightness) {
    qDebug() << "dimLightArea: " << setting->areaId ;

    HttpBase *hbdim = new HttpBase(QString(""), this);
    QObject::connect(hbdim, SIGNAL(done(QVariant)), this, SLOT(onGetDimLightArea(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbdim, SIGNAL(done(QVariant)), hbdim, SLOT(deleteLater()), Qt::UniqueConnection);
    QObject::connect(hbdim, SIGNAL(error(int,QString)), hbdim, SLOT(deleteLater()), Qt::UniqueConnection);

    int dim255 = brightness;

    hbdim->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_HUB)));
    hbdim->addParameter("cm", "dim_all_in_area", true);
    hbdim->addParameter("dt", Cmnfunc::formatDimArea(setting->areaId, dim255));
    hbdim->process();
}

void MainController::onGetDimLightArea(const QVariant &data) {
    qDebug() << "light area data response: " << data.toString();
}

void MainController::dimLight(long lightId, QString lightCode, int dimValue)
{
    qDebug() << "dimLight";

    HttpBase *hbdim = new HttpBase(QString(""), this);
    QObject::connect(hbdim, SIGNAL(done(QVariant)), hbdim, SLOT(deleteLater()), Qt::UniqueConnection);
    QObject::connect(hbdim, SIGNAL(error(int,QString)), hbdim, SLOT(deleteLater()), Qt::UniqueConnection);

    int dim255 = (int)(dimValue);

    hbdim->setUrl(QUrl(QString("%1%2").arg(SL_SERVERURL).arg(SL_LNKLIGHT2)));
    hbdim->addParameter("cm", "change_brightness", true);
    hbdim->addParameter("dt", Cmnfunc::formatDim(setting->areaId, lightId, lightCode, dim255, m_sesid));
    hbdim->process();

    setLightValue(lightCode, dimValue);

    emit refreshLightStatus(lightCode, dim255>0?1:0, dim255);
}

void MainController::onGetRemoteList(long areaId)
{
    qDebug() << "onGetRemoteList()";

    HttpBase *hbremotelist = new HttpBase(QString(""), this);
    QObject::connect(hbremotelist, SIGNAL(done(QVariant)), this, SLOT(onGetRemoteListDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbremotelist, SIGNAL(done(QVariant)), hbremotelist, SLOT(deleteLater()));
    QObject::connect(hbremotelist, SIGNAL(error(int,QString)), hbremotelist, SLOT(deleteLater()));

    hbremotelist->setUrl(QUrl(QString(SL_SRVREMOTE)));
    hbremotelist->addParameter("cm", "get_list", true);
    hbremotelist->addParameter("dt", Cmnfunc::formatRequestArea(areaId));
    hbremotelist->process();
}

void MainController::onGetRemoteListDone(const QVariant &data)
{
    qDebug() << "onGetRemoteListDone:";// << data.toString();

    QString msg;
    if( Cmnfunc::parseErrMsg(data.toString(), msg) == 0 )
    {
        emit refreshDeviceList(data);
    }
}

void MainController::onRemoteCtrll(int areaId, const QString &devcode, int devtype, int devbutton, int devvalue)
{
    qDebug() << "onRemote press ... ";

    HttpBase *hbremctrl = new HttpBase(QString(""), this, true);
    QObject::connect(hbremctrl, SIGNAL(done(QVariant)), this, SLOT(onRemoteCtrllDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbremctrl, SIGNAL(done(QVariant)), hbremctrl, SLOT(deleteLater()));
    QObject::connect(hbremctrl, SIGNAL(error(int,QString)), hbremctrl, SLOT(deleteLater()));

    hbremctrl->setUrl(QUrl(QString(SL_SRVREMOTE)));
    hbremctrl->addParameter("cm", "control", true);
    hbremctrl->addParameter("dt", Cmnfunc::formatRemoteCtrl(areaId, devcode, devtype, devbutton, devvalue));
    hbremctrl->process();
}

void MainController::onRemoteCtrllDone(const QVariant &data)
{
    qDebug() << "onRemoteCtrllDone:";// << data.toString();
}

void MainController::onMeetingRoom(int roomid)
{
    HttpBase *hbmroom = new HttpBase(QString(""), this);
    QObject::connect(hbmroom, SIGNAL(done(QVariant)), this, SLOT(onMeetingRoomDone(QVariant)), Qt::UniqueConnection);
    QObject::connect(hbmroom, SIGNAL(done(QVariant)), hbmroom, SLOT(deleteLater()));
    QObject::connect(hbmroom, SIGNAL(error(int,QString)), hbmroom, SLOT(deleteLater()));

    hbmroom->setUrl(QString(slSrvurl + SL_LINKMEETINGROOM));
    hbmroom->addParameter("cm", "checkroom", true);
    hbmroom->addParameter("dt", Cmnfunc::formatMettingRoom(roomid));

    hbmroom->process();
}

void MainController::onMeetingRoomDone(const QVariant &data)
{
    qDebug() << "meeting respone:" << data.toString();

    if( Cmnfunc::parseKeyValueInt(data.toString(), "err") == 0 )
    {
        int roomStatus = Cmnfunc::parseKeyValueInt(data.toString(), "dt");

        screenSave(roomStatus == 1);

        emit refreshMettingRoomStatus(setting->areaId, roomStatus);
    }
}

void MainController::setLightGroupValue(int value)
{
    m_light.brightness = value;
    m_light.onoff = value > 0 ? 1 : 0;

    // set value to all-light
    setLightValue("", value);
}

void MainController::setLightGroupOnoff(bool onoff)
{
    m_light.onoff = onoff;

    // set status to all-light
    setLightOnoff("", onoff);
}

void MainController::setLightOnoff(const QString lightcode, bool onoff)
{
    if( lightcode.isEmpty() )
    {
        int size = m_lights.size();
        for( int i=0; i<size; i++ )
        {
            LIGHT l = m_lights.at(0);
            l.onoff = onoff;

            m_lights.removeAt(0);
            m_lights.push_back(l);
        }
    }
    else
    {   // set at light-code's
        for( int i=0; i<m_lights.size(); i++ )
        {
            if( m_lights.at(i).light_code == lightcode )
            {
                LIGHT l = m_lights.at(i);
                l.onoff = onoff;

                qDebug() << "found light:" << l.light_code << ", onoff:" << onoff;

                m_lights.removeAt(i);
                m_lights.insert(i, l);
                break;
            }
        }
    }
}

void MainController::setLightValue(const QString lightcode, int value)
{
    if( lightcode.isEmpty() )
    {
        int size = m_lights.size();
        for( int i=0; i<size; i++ )
        {
            LIGHT l = m_lights.at(0);
            l.brightness = value;
            l.onoff = value > 0 ? 1 : 0;

            m_lights.removeAt(0);
            m_lights.push_back(l);
        }
    }
    else
    {   // set at light-code's
        for( int i=0; i<m_lights.size(); i++ )
        {
            if( m_lights.at(i).light_code == lightcode )
            {
                LIGHT l = m_lights.at(i);
                l.brightness = value;
                l.onoff = value > 0 ? 1 : 0;

                qDebug() << "found light:" << l.light_code << ", dimvalue:" << value;

                m_lights.removeAt(i);
                m_lights.insert(i, l);
                break;
            }
        }
    }
}

int MainController::getLightValue(const QString lightcode)
{
    for( int i=0; i<m_lights.size(); i++ )
    {
        if( m_lights.at(i).light_code == lightcode ) {
            return m_lights.at(i).brightness;
        }
    }

    return 0;
}

QString MainController::jsonLights()
{
    int light_on = 0;
    int light_off = 0;
    QJsonArray jarr;
    for( int i=0; i<m_lights.size(); i++ ) {
        QJsonObject jsl;
        jsl["area_id"]      = m_lights.at(i).area_id;
        jsl["light_id"]     = int(m_lights.at(i).light_id);
        jsl["light_code"]   = m_lights.at(i).light_code;
        jsl["light_name"]   = m_lights.at(i).light_name;
        jsl["on_off"]       = m_lights.at(i).onoff;
        jsl["brightness"]   = m_lights.at(i).brightness;

        light_on  += m_lights.at(i).onoff == 1 ? 1 : 0;
        light_off += m_lights.at(i).onoff == 1 ? 0 : 1;

        jarr.append(jsl);
    }

    QJsonObject jlg; // light group
    jlg["on_off"]           = m_light.onoff;
    jlg["brightness"]       = m_light.brightness;

    QJsonObject jdt;
    jdt["lightsOnFloor"]    = jarr;
    jdt["lightgroup"]       = jlg;
    jdt["light_on"]         = light_on;
    jdt["light_off"]        = light_off;
    jdt["light_count"]      = m_lights.size();

    QJsonObject jso;
    jso["dt"]   = jdt;
    jso["err"]  = 0;
    jso["msg"]  = "";

    QJsonDocument jsd( jso );
    return QString::fromUtf8( jsd.toJson(QJsonDocument::Compact).data() );
}

void MainController::onNotify(const QString &message)
{    
    int msgType = Cmnfunc::parseMsgType(message);
    if( (msgType == 4) || (msgType == 5) )
    {
        qDebug() << "onNotify msgType=5, msg:" << message;

        QString lightCode = "";
        int onoff = 0, dim;

        if( Cmnfunc::parseMsgLightStatus(message, lightCode, onoff, dim) == true )
        {
            setLightOnoff(lightCode, onoff);
            setLightValue(lightCode, dim);

            //emit refreshLightStatus(lightCode, onoff, dim);
            emit updateLights( jsonLights() );
        }
    }
    else if( (msgType == 7) || (msgType == 8) )
    {
        qDebug() << "onNotify msg:" << message;

        int areaId=-1, brightness=-1, onoff=0;

        if( Cmnfunc::parseBrightness(message, areaId, brightness, onoff)
            && (areaId == setting->areaId) )
        {
            setLightGroupOnoff(onoff);
            setLightGroupValue(brightness);

            //emit refreshAreaBrightness(areaId, brightness, onoff);
            emit updateLights( jsonLights() );
        }
    }
    else if (msgType == 10)
    {
        //qDebug() << "onNotify sensor:" << message;

        bool haveperson;
        int temperature = -1, humidity = -1;
        QString areaId, devId, gwId;

        if( Cmnfunc::parseMsgSensors(message, areaId, devId, gwId, haveperson, temperature, humidity) )
        {
            if( (areaId.toInt() == setting->areaId) )
            {
                emit refreshSensors(devId, gwId, haveperson, temperature, humidity);
            }
        }
    }
    else {
        //qDebug() << "onNotify ..." << message;
    }
}
