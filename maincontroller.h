#ifndef MAINCONTROLLER_H
#define MAINCONTROLLER_H

#include <QObject>
#include "./network/httpbase.h"
#include "./network/httpbase2.h"
#include "./network/wsclient.h"
#include "datatypes.h"
#include "keepwake.h"

#define SL_LNKLOGIN         "/iot/be/api/login/?"
#define SL_LNKLIGHT         "/iot/be/api/light/?"
#define DEVMOD              ""

#define SL_LNKLIGHT2        "/cloud/api/light/?"
#define SL_LNKSENSOR        "/cloud/api/sensor/?"
#define SL_LINKMEETINGROOM  "/mrm/api/room/checkroom/?"
#define SL_LNKROOMLIST      "/mrm/api/room/?"

#define SL_SERVERURL        "https://gbcstaging.zing.vn"
#define SL_SRVREMOTE        "https://gbcstaging.zing.vn/cloud/api/remote/?"
#define SL_URLSECURE        "https://gbcstaging.zing.vn"
#define SL_WEBSOCKET        "ws://gbcstaging.zing.vn/cloud/ntf/?session_id="

#define SL_HUB              "/cloud/api/iot/?"

//#define SL_SERVERURL        "https://gbcstaging.zing.vn"
//#define SL_SRVREMOTE        "https://gbcstaging.zing.vn/cloud/api/remote/?"
//#define SL_URLSECURE        "https://gbcstaging.zing.vn"
//#define SL_WEBSOCKET        "ws://gbcstaging.zing.vn/cloud/ntf/?session_id="

//https://gbc.zing.vn/dev/mrm/
//https://gbc.zing.vn/mrm/api/room/checkroom?cm=checkroom&dt={"id":<room_id>}
//https://gbc.zing.vn/cloud/api/remote/?
// get_brightness_group - /iot/be/api/light/?
// change_brightness_group - /cloud/api/light/?

class ConfigSetting;
class MainController : public QObject
{
    Q_OBJECT
public:
    explicit MainController(QObject *parent = 0);
    ~MainController();

    Q_INVOKABLE void screenSave(bool onoff);
    Q_INVOKABLE bool isDebugmode();
    Q_INVOKABLE bool isAndroid();
    Q_INVOKABLE void    appQuit();
    Q_INVOKABLE QString appBuildDate();
    Q_INVOKABLE QString getConfigUsername();
    Q_INVOKABLE QString getConfigUserpwd();
    Q_INVOKABLE QString getConfigRoomname();
    Q_INVOKABLE int     getConfigRoomid();
    Q_INVOKABLE int     getConfigAreaid();
    Q_INVOKABLE int     getConfigCurrentAreaIndex();
    Q_INVOKABLE void    setConfigCurrentAreaIndex(int idx, int areaId);
    Q_INVOKABLE bool    getConfigAllowLightControl();
    Q_INVOKABLE void    setConfigAllowLightControl(bool allow);
    Q_INVOKABLE void    setConfigRoomArea(int roomid, int areaid, const QString &roomname);

    Q_INVOKABLE void userLogin(const QString &u, const QString &p);
    Q_INVOKABLE void callGetAreaList();
    Q_INVOKABLE void callGetLightsOnArea(long areaId=-1);
    Q_INVOKABLE void callGetSensorOnArea(long areaId=-1);
    Q_INVOKABLE void callSwitchLight(long lightId, QString lightCode, int on_off, int dim);
    Q_INVOKABLE void callDimLight(long lightId, QString lightCode, int dimValue);
    Q_INVOKABLE void callDimLightOnArea(int brightness);
    Q_INVOKABLE void callSetDimGroup(int dimValue);
    Q_INVOKABLE void callSwitchGroup(int on_off);
    Q_INVOKABLE void callSwitchGroup(int on_off, int brightness);
    Q_INVOKABLE void callGetRemoteList(long areaId=-1);
    Q_INVOKABLE void callMeetingRoom(int rooid=-1);
    Q_INVOKABLE void callRemoteCtrll(const QString &devcode, int devtype, int devbutton, int devvalue);

    Q_INVOKABLE void getLightsStatus();

signals:
    void login(int err, const QString& msg);

    void refreshRoomname(const QString name);
    void refreshAreaList(QList<AREA> &listArea);
    void refreshLightList(QList<LIGHT> &listLight);
    void refreshLightStatus(QString lightCode, int on_off, int dim);
    void refreshLightStatusInArea(int area_id, int brightness);
    void refreshSensors(QString devId, QString gwId, bool haveperson, int temperature, int humidity);

    void refreshRoomList(const QVariant &listRoom);
    void refreshAreaList2(const QVariant &listArea);
    void refreshLightList2(const QVariant &listLight);
    void refreshBrightness(const QVariant &brightness);
    void refreshAreaBrightness(int areaId, int brightness, int onoff);
    void refreshSensors2(const QVariant &sensors);
    void refreshMettingRoomStatus(int areaId, int status);
    void refreshDeviceList(const QVariant &data);

    void updateLights(const QString &data);

public slots:
    void onError(const int &err, const QString &msg);

    void doLogingetkey(const QString &u, const QString &p);
    void onLogingetkeyDone(const QVariant &data);
    void doLogin(const QString &u, const QString &p, const QString &key, const QString &code);
    void onLoginDone(const QVariant &data);

    void onGetRoomList();
    void onGetRoomListDone(const QVariant &data);

    void onGetAreaList();
    void onGetAreaListDone(const QVariant &data);

    void onGetBrightness(long areaId);
    void onGetBrightnessDone(const QVariant &data);

    void dimHub(long areaId, int dimvalue);

    void dimLightGroup(long areaId, int brightness);
    void switchLightGroup(long areaId, int onoff);

    void onGetLightsOnArea(long areaId);
    void onGetLightsOnAreaDone(const QVariant &data);

    void onGetSensorOnArea(long areaId);
    void onGetSensorOnAreaDone(const QVariant &data);

    void switchLight(long lightId, QString lightCode, int on_off, int dim);
    void dimLight(long lightId, QString lightCode, int dimValue);
    void dimLightArea(int brightness);

    void onGetRemoteList(long areaId);
    void onGetRemoteListDone(const QVariant &data);
    void onGetDimLightArea(const QVariant &data);

    void onRemoteCtrll(int areaId, const QString &devcode, int devtype, int devbutton, int devvalue);
    void onRemoteCtrllDone(const QVariant &data);

    void onMeetingRoom(int roomid);
    void onMeetingRoomDone(const QVariant &data);

    void onNotify(const QString &message);

private:

    void    setLightGroupValue(int value);
    void    setLightGroupOnoff(bool onoff);
    void    setLightOnoff(const QString lightcode, bool onoff);
    void    setLightValue(const QString lightcode, int value);
    int     getLightValue(const QString lightcode);
    QString jsonLights();

    ConfigSetting   *setting;
    HttpBase2       *m_httpLogin;
    WSClient        *m_wsClient;
    QString         m_sesid;

    int             m_gbrightness;  // group brightness
    LIGHT           m_light;        // light-group
    QList<LIGHT>    m_lights;       // light brightness

    QString         slSrvurl;       // smartlight server url
    QString         m_usrname, m_usrpwd, m_loginKey, m_loginCode;

    QString         m_roomname;
    KeepWake        *m_keepwake;
};

#endif // MAINCONTROLLER_H
