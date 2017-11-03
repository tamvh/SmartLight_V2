#include "commonfunction.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDataStream>
#include <QByteArray>
#include <QCryptographicHash>
#include <QMessageAuthenticationCode>
#include <QDebug>

Cmnfunc::Cmnfunc()
{
}

QString Cmnfunc::gVPOS1()
{
    QString s;
    s.reserve(32);

    // 7VShsAFE3S4pS3lijpCkIxCDpzi7ljdS

    s.append('7');
    s.append('V');
    s.append('S');
    s.append('h');
    s.append('s');
    s.append('A');
    s.append('F');
    s.append('E');

    s.append('3');
    s.append('S');
    s.append('4');
    s.append('p');
    s.append('S');
    s.append('3');
    s.append('l');
    s.append('i');

    s.append('j');
    s.append('p');
    s.append('C');
    s.append('k');
    s.append('I');
    s.append('x');
    s.append('C');
    s.append('D');

    s.append('p');
    s.append('z');
    s.append('i');
    s.append('7');
    s.append('l');
    s.append('j');
    s.append('d');
    s.append('S');

    return s;
}

QString Cmnfunc::formatWsSession(const QString& merchantCode, const QString& devId)
{
    QJsonObject jso;
    jso["merchant_code"] = merchantCode;
    jso["devid"] = devId;

    QJsonDocument jsd(jso);

    return QString::fromUtf8(jsd.toJson().data());
}

int Cmnfunc::parseWssid(const QString &respone, QString *sid)
{
    int err = -1;

    QJsonDocument   jsd = QJsonDocument::fromJson(respone.toUtf8());
    QJsonObject     jso = jsd.object();

    if (jso.contains("err")) {
        err = jso["err"].toInt();
    }

    if( (err == 0) && (jso.contains("dt") == true) )
    {
        QJsonObject jdt = jso["dt"].toObject();

        if (sid && jdt.contains("ws_session") == true) {
            *sid = jdt["ws_session"].toString();
        }
    }
    else {
        err = -1;
    }

    return err;
}

QString Cmnfunc::formatWSConnectString( const QString& url,
                                    const QString& merchantCode,
                                    const QString& deviceId,
                                    const QString& wsSession)
{
    QString request, token;

    token = QMessageAuthenticationCode::hash(QString(merchantCode + deviceId + wsSession).toUtf8(), gVPOS1().toUtf8(), QCryptographicHash::Sha256).toHex();
    request = url + "?appuser=" + merchantCode + "&devid=" + deviceId + "&ws_session=" + wsSession + "&tk=" + token;

    return request;
}

int Cmnfunc::parseErrMsg(const QString &data, QString &msg)
{
    int err = -1;

    QJsonDocument   jsd = QJsonDocument::fromJson(QByteArray(data.toUtf8()));
    QJsonObject     jso = jsd.object();

    if (jso.contains("err")) {
        err = jso["err"].toInt();
    }

    if (jso.contains("msg")) {
        msg = jso["msg"].toString();
    }

    return err;
}

int Cmnfunc::parseKeyValueInt(const QString &data, const QString &key)
{
    int iRet = -1;

    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(data.toUtf8()));
    QJsonObject jso = jdoc.object();

    if (jso.contains(key)) {
        iRet = jso[key].toInt();
    }

    return iRet;
}

QString Cmnfunc::formatLoginkey(const QString &u)
{
    QJsonObject jso;
    jso["acn"] = u;

    QJsonDocument jsd(jso);
    return QString::fromUtf8(jsd.toJson().data());
}

int Cmnfunc::parseLoginkey(const QString &data, QString &key, QString &code)
{
    int err = -1;

    QJsonDocument   jsd = QJsonDocument::fromJson(QByteArray(data.toUtf8()));
    QJsonObject     jso = jsd.object();

    if (jso.contains("err")) {
        err = jso["err"].toInt();
    }

    if (err == 0)
    {
        if (jso.contains("dt"))
        {
            QJsonObject jdt = jso["dt"].toObject();

            if (jdt.contains("keyLoginFirst")) {
                code = jdt["keyLoginFirst"].toString();
            }

            if (jdt.contains("keyLoginSecond")) {
                key = jdt["keyLoginSecond"].toString();
            }
        }
    }

    return err;
}

QString Cmnfunc::formatLoginverify(const QString &u, const QString &p, const QString &key, const QString &code)
{
    QJsonObject jso;
    jso["username"] = u;
    jso["password"] = key + p + code;

    QJsonDocument jsd(jso);
    return QString::fromUtf8(jsd.toJson().data());

}

QString Cmnfunc::formatDimhub(int areaId, int dimValue, const QString &sesid)
{
    QJsonObject jso;
    jso["area_id"]      = areaId;
    jso["brightness"]   = dimValue;
    jso["session_id"]   = sesid;
    jso["userLogin"]    = "appMrmCtrl";

    QJsonDocument jsd( jso );
    return QString::fromUtf8( jsd.toJson(QJsonDocument::Compact).data() );
}

QString Cmnfunc::formatRequestLightsOnArea(int areaID, int brightness, int onoff, const QString &sesid)
{
    QJsonObject jso;
    jso["area_id"]      = areaID;
    jso["brightness"]   = brightness;
    jso["on_off"]       = onoff;
    jso["session_id"]   = sesid;
    jso["userLogin"]    = "appMrmCtrl";

    QJsonDocument jsd( jso );
    return QString::fromUtf8( jsd.toJson(QJsonDocument::Compact).data() );
}

QString Cmnfunc::formatRequestArea(int areaID)
{
    QJsonObject jsonObj;
    jsonObj["area_id"] = areaID;

    QJsonDocument jsonDoc(jsonObj);
    return QString::fromUtf8(jsonDoc.toJson().data());
}

QString Cmnfunc::formatRequestSwitchLight(int areaId, int lightId, QString lightCode, int on_off, int dim, const QString &sesid)
{
    QJsonObject jslight;
    jslight["area_id"]      = areaId;
    jslight["light_id"]     = lightId;
    jslight["light_code"]   = lightCode;
    jslight["on_off"]       = on_off;
    jslight["brightness"]   = QString::number(dim);
    jslight["userLogin"]    = "appMrmCtrl";

    QJsonObject jso;
    jso["light"]        = jslight;
    jso["session_id"]   = sesid;
    jso["userLogin"]    = "appMrmCtrl";

    QJsonDocument jsd( jso );
    return QString::fromUtf8( jsd.toJson(QJsonDocument::Compact).data() );
}

QString Cmnfunc::formatDimArea(int area_id, int brightness) {
    QJsonObject jsonDim;
    jsonDim["brightness"] = brightness;
    jsonDim["area_id"] = area_id;
    jsonDim["userLogin"] = "appMrmCtrl";
    QJsonDocument jsonDoc( jsonDim );
    return QString::fromUtf8( jsonDoc.toJson(QJsonDocument::Compact).data() );
}

QString Cmnfunc::formatDim(int areaId, int lightId, QString lightCode, int dim255, const QString &sesid)
{
    QJsonObject jsonLight;
    jsonLight["area_id"]    = areaId;
    jsonLight["light_id"]   = lightId;
    jsonLight["light_code"] = lightCode;
    jsonLight["on_off"]     = dim255 > 10 ? 1 : 0;
    jsonLight["brightness"] = dim255;
    jsonLight["userLogin"]  = "appMrmCtrl";

    QJsonObject jso;
    jso["light"]        = jsonLight;
    jso["session_id"]   = sesid;
    jso["userLogin"]    = "appMrmCtrl";

    QJsonDocument jsonDoc( jso );
    return QString::fromUtf8( jsonDoc.toJson(QJsonDocument::Compact).data() );
}

QString Cmnfunc::formatMettingRoom(int areaId)
{
    QJsonObject jso;
    jso["id"] = areaId;

    QJsonDocument jdoc(jso);
    return QString::fromUtf8(jdoc.toJson().data());
}

QString Cmnfunc::formatRemoteCtrl(int areaId, const QString &devcode, int devtype, int devbutton, int devvalue)
{
    QJsonObject jso;
    jso["area_id"]              = areaId;
    jso["remote_device_code"]   = devcode;
    jso["remote_type"]          = devtype;
    jso["remote_button_type"]   = devbutton;
    jso["new_value_num"]        = devvalue;
    jso["new_vaule_string"]     = QString::number(devvalue);
    jso["userLogin"]            = "appMrmCtrl";

    QJsonDocument jdoc(jso);
    return QString::fromUtf8(jdoc.toJson(QJsonDocument::Compact).data());
}

bool Cmnfunc::parseRoomnameArea(const QString &msg, int &areaId, QString &roomname)
{
    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();
    if( jso.contains("dt") )
    {
        QJsonObject jdt = jso["dt"].toObject();
        if( jdt.contains("areas") )
        {
            QJsonArray jarr = jdt["areas"].toArray();

            for( int i=0; i<jarr.size(); i++ )
            {
                QJsonObject jarea = jarr[i].toObject();
                if( jarea.contains("area_id") && (jarea["area_id"].toInt() == areaId) )
                {
                    roomname = jarea["area_name"].toString();
                    return true;
                }
            }

            // do not have any roomId match areaId, may be this room is deleted, so get the 1st room for default.
            if( jarr.size() > 0 )
            {
                QJsonObject jarea = jarr[0].toObject();
                if( jarea.contains("area_id") )
                {
                    areaId = jarea["area_id"].toInt();
                    roomname = jarea["area_name"].toString();
                    return true;
                }
            }
        }
    }

    return false;
}

bool Cmnfunc::parseRoomnameList(const QString &msg, int &areaId, QString &roomname, int &roomId)
{
    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();
    if( jso.contains("dt") )
    {
        QJsonArray jarr = jso["dt"].toArray();

        for( int i=0; i<jarr.size(); i++ )
        {
            QJsonObject jroom = jarr[i].toObject();
            if( jroom.contains("id") && (jroom["id"].toInt() == roomId) )
            {
                if( jroom.contains("name") ) {
                    roomname    = jroom["name"].toString();
                }

                if( jroom.contains("area_id") ) {
                    areaId      = jroom["area_id"].toInt();
                }

                return true;
            }
        }

        // do not have any roomId match areaId, may be this room is deleted, so get the 1st room for default.
        if( jarr.size() > 0 )
        {
            QJsonObject jroom = jarr[0].toObject();
            if( jroom.contains("area_id") && jroom["area_id"].toInt() == areaId )
            {
                if( jroom.contains("id") ) {
                    roomId      = jroom["id"].toInt();
                }

                if( jroom.contains("name") ) {
                    roomname    = jroom["name"].toString();
                }

                if( jroom.contains("area_id") ) {
                    areaId      = jroom["area_id"].toInt();
                }

                return true;
            }
        }
    }

    return false;
}

void Cmnfunc::parseDataAreas(const QString &msg, QList<AREA> &listArea)
{
    QJsonDocument jsonDoc;
    QJsonObject jsonObjMain;
    QJsonArray  jsonArrayItem;
    QJsonObject jsonObjSub;
    int i, nNumItem;
    long id;
    QString name;

    jsonDoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    jsonObjMain = jsonDoc.object();
    jsonArrayItem = jsonObjMain["dt"].toObject()["areas"].toArray();

    nNumItem = jsonArrayItem.count();
    for (i = 0; i < nNumItem; i++)
    {
        jsonObjSub = jsonArrayItem[i].toObject();
        id = jsonObjSub["area_id"].toDouble();
        name = jsonObjSub["area_name"].toString();
        listArea.push_back(AREA(id, name));
    }
}

void Cmnfunc::parseDataLights(const QString &msg, QList<LIGHT> &listLight)
{
    listLight.clear();

    QJsonDocument jsonDoc;
    QJsonObject jsonObjMain;
    QJsonArray  jsonArrayItem;
    QJsonObject jsonObjSub;
    int i, nNumItem, onoff, type, sts, brghtns, area;
    long id;
    QString code, name;

    jsonDoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    jsonObjMain = jsonDoc.object();
    jsonArrayItem = jsonObjMain["dt"].toObject()["lightsOnFloor"].toArray();

    nNumItem = jsonArrayItem.count();
    for (i = 0; i < nNumItem; i++)
    {
        jsonObjSub = jsonArrayItem[i].toObject();
        area    = jsonObjSub["area_id"].toInt();
        id      = jsonObjSub["light_id"].toDouble();
        code    = jsonObjSub["light_code"].toString();
        name    = jsonObjSub["light_name"].toString();
        type    = jsonObjSub["light_type"].toInt();
        sts     = jsonObjSub["status"].toInt();
        onoff   = jsonObjSub["on_off"].toInt();
        brghtns = jsonObjSub["brightness"].toInt();

        listLight.push_back(LIGHT(id, code, name, onoff, type, sts, brghtns, area));
    }
}

int Cmnfunc::parseMsgType(const QString& msg)
{
    QJsonObject jsonMain;
    QJsonDocument jsonDoc;

    jsonDoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    jsonMain = jsonDoc.object();

    return jsonMain["msg_type"].toInt();
}

int Cmnfunc::parseAreaBrightness(const QString &msg, int &areaBrightness)
{
    int err = -1;

    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();

    if( jso.contains("err") ) {
        err = jso["err"].toInt();
    }

    if( (err == 0) && jso.contains("dt") )
    {
        QJsonObject jdt = jso["dt"].toObject();

        if( jdt.contains("area") )
        {
            QJsonObject jarea = jdt["area"].toObject();
            if( jarea.contains("area_brightness") ) {
                areaBrightness = jarea["area_brightness"].toInt();
            }
        }
    }

    return err;
}

bool Cmnfunc::parseBrightness(const QString& msg, int &areaId, int &brightness, int &onoff)
{
    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();

    if( jso.contains("dt") )
    {
        QJsonObject jdt = jso["dt"].toObject();

        if( jdt.contains("area_id") ) {
            areaId = jdt["area_id"].toInt();
        }
        if( jdt.contains("brightness") ) {
            brightness = jdt["brightness"].toInt();
        }

        if( jdt.contains("on_off") ) {
            onoff = jdt["on_off"].toInt();
        } else {
            // trường hợp này chỉ có notify brightness, không có onoff - nên tự cập nhật onoff
            onoff = brightness > 0 ? 1 : 0;
        }

        return true;
    }

    return false;
}

bool Cmnfunc::parseMsgLightStatus(const QString &msg, QString &lightCode, int &onoff, int &dim)
{
    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();

    if( jso.contains("dt") )
    {
        QJsonObject jdt = jso["dt"].toObject();

        if( jdt.contains("light_code") ) {
            lightCode = jdt["light_code"].toString();
        }
        if( jdt.contains("on_off") ) {
            onoff = jdt["on_off"].toInt();
        }
        if( jdt.contains("brightness") ) {
            dim = jdt["brightness"].toInt();
        }

        return true;
    }

    return false;
}

bool Cmnfunc::parseMsgSensors(const QString &msg, QString &areaId, QString &devId, QString &gatewayId,
                              bool &havepersion, int &temperature, int &humidity)
{
    QJsonDocument jdoc = QJsonDocument::fromJson(QByteArray(msg.toUtf8()));
    QJsonObject jso = jdoc.object();

    if( jso.contains("dt"))
    {
        QJsonObject jdt = jso["dt"].toObject();

        if( jdt.contains("area_id")) {
            areaId = jdt["area_id"].toString();
        }

        if( jdt.contains("device_id")) {
            devId = jdt["device_id"].toString();
        }

        if( jdt.contains("gateway_id")) {
            gatewayId = jdt["gateway_id"].toString();
        }

        int sensor = -1;
        if( jdt.contains("sensor_data")) {
            sensor = jdt["sensor_data"].toInt();
        }

        QString cmd;
        if( jdt.contains("command")) {
            cmd = jdt["command"].toString();
        }

        if( cmd.compare("humidity_sensor") == 0 ) {
            humidity = sensor;
        }

        if( cmd.compare("temperature_sensor") == 0 ) {
            temperature = sensor;
        }

        return true;
    }

    return false;
}
