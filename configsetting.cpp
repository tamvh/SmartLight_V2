#include <QMutex>
#include <QSettings>
#include <QDebug>
#include "configsetting.h"

ConfigSetting* ConfigSetting::m_instance = NULL;

ConfigSetting::ConfigSetting(QObject *parent) : QObject(parent)
{
    Load();
}

ConfigSetting::~ConfigSetting()
{
}

ConfigSetting *ConfigSetting::instance()
{
    static QMutex mutex;

    if (m_instance == NULL)
    {
        mutex.lock();

        if (m_instance == NULL) {
            m_instance = new ConfigSetting();
        }

        mutex.unlock();
    }

    return (m_instance);
}

#include <QStandardPaths>
void ConfigSetting::Load()
{
    QSettings sets("vng", "smartlight");

    userName        = sets.value(QString("option/username"), QString("")).toString();
    userPwd = "";
//#ifdef QT_DEBUG
    QString pwd128 = sets.value(QString("option/userpwd"), QString("")).toString();
    for( int i=0; i<pwd128.length(); i++ ) {
        userPwd += (pwd128[i].toLatin1() ^ 128);
    }
//#endif

    roomName        = sets.value(QString("option/roomname"), "").toString();
    roomId          = sets.value(QString("option/roomid"), -1).toInt();
    areaId          = sets.value(QString("option/areaid"), -1).toInt();
    currentAreaIdx  = sets.value(QString("option/currentareaidx"), 0).toInt();
    allowLightControl = sets.value(QString("option/allowlightcontrol"), false).toBool();
}

void ConfigSetting::setUsername(const QString &uname, const QString &upwd)
{
    if (userName != uname) {
        userName = uname;

        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/username"), userName);
        sets.sync();
    }

    if (userPwd != upwd) {
        userPwd = upwd;
//#ifdef QT_DEBUG
        QString pwd128 = userPwd;

        pwd128 = "";
        for( int i=0; i<userPwd.length(); i++ ) {
            pwd128 += (userPwd[i].toLatin1() ^ 128);
        }

        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/userpwd"), pwd128);
        sets.sync();
//#endif
    }
}

void ConfigSetting::setRoomId(int roomid, int areaid)
{
    if (roomId != roomid) {
        roomId = roomid;
        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/roomid"), roomId);
        sets.sync();
    }

    setAreaid(areaid);
}

void ConfigSetting::setRoomname(const QString &roomname)
{
    roomName = roomname;
    QSettings sets("vng", "smartlight");
    sets.setValue(QString("option/roomname"), roomName);
    sets.sync();
}

void ConfigSetting::setAreaid(int areaid)
{
    if (areaId != areaid) {
        areaId = areaid;
        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/areaid"), areaId);
        sets.sync();
    }
}

void ConfigSetting::setCurrentAreaIdx(int idx)
{
    if (currentAreaIdx != idx) {
        currentAreaIdx = idx;
        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/currentareaidx"), currentAreaIdx);
        sets.sync();
    }
}

void ConfigSetting::setAllowLightControl(bool allow)
{
    if (allowLightControl != allow) {
        allowLightControl = allow;
        QSettings sets("vng", "smartlight");
        sets.setValue(QString("option/allowlightcontrol"), allowLightControl);
        sets.sync();
    }
}
