#ifndef CONFIGSETTING_H
#define CONFIGSETTING_H

#include <QObject>

class ConfigSetting : public QObject
{
    Q_OBJECT
public:
    static ConfigSetting *instance();
    explicit ConfigSetting(QObject *parent = 0);
    ~ConfigSetting();

    void Load();
    void Save();

    void setUsername(const QString &uname, const QString &upwd);
    void setRoomId(int roomid, int areaid);
    void setRoomname(const QString &roomname);
    void setAreaid(int areaid);
    void setCurrentAreaIdx(int idx);
    void setAllowLightControl(bool allow);

    QString userName;           // đăng nhập usr
    QString userPwd;            // đăng nhập pwd
    QString roomName;           // room name
    int     roomId;             // room ID
    int     areaId;             // current area id
    int     currentAreaIdx;     // current area index
    bool    allowLightControl;  // allow control light out of meeting time

private:
    static ConfigSetting *m_instance;

signals:

public slots:
};

#endif // CONFIGSETTING_H
