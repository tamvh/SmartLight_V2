#ifndef COMMONFUNCTION_H
#define COMMONFUNCTION_H
#include <QString>
#include "datatypes.h"

class Cmnfunc
{
public:
    Cmnfunc();

    static QString  gVPOS1();
    static QString  formatWsSession(const QString& merchantCode, const QString& devId);
    static int      parseWssid(const QString &respone, QString *sid);
    static QString  formatWSConnectString(const QString& url, const QString& merchantCode,
                                        const QString& deviceId, const QString& wsSession);

    static int      parseErrMsg(const QString &data, QString &msg);
    static int      parseKeyValueInt(const QString &data, const QString &key);
    static QString  formatLoginkey(const QString &u);
    static int      parseLoginkey(const QString &data, QString &key, QString &code);
    static QString  formatLoginverify(const QString &u, const QString &p, const QString &key, const QString &code);

    static QString  formatDimhub(int areaId, int dimValue, const QString &sesid);

    static QString  formatRequestLightsOnArea(int areaID, int brightness, int onoff, const QString &sesid);
    static QString  formatRequestArea(int areaID);
    static QString  formatRequestSwitchLight(int areaId, int lightId, QString lightCode, int on_off, int dim, const QString &sesid);
    static QString  formatDimArea(int area_id, int brightness);
    static QString  formatDim(int areaId, int lightId, QString lightCode, int dim255, const QString &sesid);
    static QString  formatMettingRoom(int areaId);
    static QString  formatRemoteCtrl(int areaId, const QString &devcode, int devtype, int devbutton, int devvalue);

    static bool parseRoomnameArea(const QString &msg, int &areaId, QString &roomname);
    static bool parseRoomnameList(const QString &msg, int &areaId, QString &roomname, int &roomId);
    static void parseDataAreas(const QString &msg, QList<AREA> &listArea);
    static void parseDataLights(const QString &msg, QList<LIGHT> &listLight);
    static int  parseMsgType(const QString& msg);
    static int  parseAreaBrightness(const QString &msg, int &areaBrightness);
    static bool parseBrightness(const QString& msg, int &areaId, int &brightness, int &onoff);
    static bool parseMsgLightStatus(const QString &msg, QString &lightCode, int &onoff, int &dim);
    static bool parseMsgSensors(const QString &msg, QString &areaId, QString &devId, QString &gatewayId, bool &havepersion, int &temperature, int &humidity);
};

#endif // COMMONFUNCTION_H
