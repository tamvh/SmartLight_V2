import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQml.Models 2.1

Page {
    id: item1

    property string sensorHaveperson: "Trong phòng: không xác định"
    property int sensorTemperature: -1
    property int sensorHumidity: -1
    property int dimMax: 100
    property int rowHeight:80
    property int iLightonClick: 0
    property int iLightofClick: 0
    property bool firstUpdate: false
    property double lastAction;

    Connections {
        target: mainController

        onUpdateLights: {

            listmodelLights.clear();
            var lights = JSON.parse( data );
            for (var light in lights.dt.lightsOnFloor) {
                //listmodelLights.append({   lightid:lights.dt.lightsOnFloor[light].light_id,
                //                           lightcode:lights.dt.lightsOnFloor[light].light_code,
                //                           lightname:lights.dt.lightsOnFloor[light].light_name,
                //                           lightonoff:lights.dt.lightsOnFloor[light].on_off,
                //                           lightdim:lights.dt.lightsOnFloor[light].on_off ?
                //                               lights.dt.lightsOnFloor[light].brightness : 0})
            }

            iLightBrightness = lights.dt.lightgroup.brightness
            iLightGroupOnOff = lights.dt.lightgroup.on_off
            strLights        = lights.dt.light_count
            strLightOn       = lights.dt.light_on
            strLightOff      = lights.dt.light_off
        }

        onRefreshLightList2: {

            if( firstUpdate === false )
            {
                // nếu không update thì load UI không đúng
                // chỉ update lần đầu lúc UI load lên thôi
                // update nhiều gây hiện tượng giật lad

                listmodelLights.clear();
                var lights = JSON.parse(listLight);
                for (var light in lights.dt.lightsOnFloor) {
                    //listmodelLights.append({   lightid:lights.dt.lightsOnFloor[light].light_id,
                    //                           lightcode:lights.dt.lightsOnFloor[light].light_code,
                    //                           lightname:lights.dt.lightsOnFloor[light].light_name,
                    //                           lightonoff:lights.dt.lightsOnFloor[light].on_off,
                    //                           lightdim:lights.dt.lightsOnFloor[light].on_off ?
                    //                               lights.dt.lightsOnFloor[light].brightness : 0})
                }

                firstUpdate = true;
            }
        }

        onRefreshSensors2: {

            var sensor = JSON.parse(sensors);
            if( sensor.err === 0 ) {
                sensorHaveperson = sensor.dt.haveperson ? "Trong phòng: Có người" : "Trong phòng: Không có người"
                sensorTemperature = sensor.dt.temperature;
                sensorHumidity = sensor.dt.humidity;
            }
            else {
                sensorHaveperson = "Trong phòng: không xác định"
                sensorTemperature = -1
                sensorHumidity = -1
            }
        }

        onRefreshLightStatus: {

            for (var l = 0; l < listmodelLights.count; l++) {
                var light = listmodelLights.get(l);
                if (light.lightcode === lightCode) {
                    listmodelLights.setProperty(l, "lightonoff", on_off);
                    if( dim >=0 ) {
                        listmodelLights.setProperty(l, "lightdim", on_off ? dim : 0);
                    }
                }
            }
        }

        onRefreshSensors: {

            if( temperature >= 0 ) {
                sensorTemperature = temperature;
            }

            if( humidity >= 0 ) {
                sensorHumidity = humidity;
            }
        }

        onRefreshAreaBrightness: {

            if( iAreaId === areaId ) {
                lightsUpdate(onoff, brightness)
            }
        }

    }

    function lightKeyPress() {
        lastAction = new Date().getTime();
    }

    function lightUpdate(onoff, dim) {
        strLightOn = 0;
        strLightOff = 0;
        for (var l = 0; l < listmodelLights.count; l++)
        {
            strLightOn += listmodelLights.get(l).lightonoff ? 1 : 0
            strLightOff += listmodelLights.get(l).lightonoff ? 0 : 1
        }
    }

    function lightsUpdate(onoff, dim) {

        for (var l = 0; l < listmodelLights.count; l++) {
            var light = listmodelLights.get(l);
            listmodelLights.setProperty(l, "lightonoff", onoff);
            if( dim >= 0 ) {
                listmodelLights.setProperty(l, "lightdim", onoff ? dim : 0);
            }
        }

        strLightOn  = onoff ? listmodelLights.count : 0
        strLightOff = onoff ? 0 : listmodelLights.count
    }

    Component {
        id: componentLights

        Rectangle {
            id: content
            height: column.implicitHeight
            width: parent.width
            border.color: "lightsteelblue"
            border.width: 1
            radius: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: lightonoff ? "#f99014" : "grey"

            Row {
                id: column
                width: parent.width
                height: 50
                anchors.fill:parent
                spacing: 5

                Text {
                    text: " "
                    width: borderWidth
                    height: parent.height
                    color: "white"
                    verticalAlignment: Qt.AlignVCenter
                }

                Text {
                    id: textLightname
                    text: lightname
                    width: parent.width/4
                    height: parent.height
                    color: "white"
                    verticalAlignment: Qt.AlignVCenter
                }

                Image {
                    width: parent.height
                    height: parent.height
                    fillMode: Image.Pad
                    verticalAlignment: Image.AlignVCenter
                    horizontalAlignment: Image.AlignRight
                    source: "qrc:/image/imglightmask.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            lightKeyPress();
                            mainController.callSwitchLight(lightid, lightcode, lightdim>0 ? 0:1, lightdim);

                            lightUpdate(lightdim>0 ? 1:0, lightdim)
                        }
                    }
                }

                Slider {
                    id: control
                    width: parent.width-x-labelPercent.width-borderWidth*3
                    from: 0
                    to: dimMax
                    value: (!lightonoff ? 0 : lightdim)

                    onValueChanged: {
                        if (pressed) {
                            pressed = false
                            lightKeyPress();
                            mainController.callDimLight(lightid, lightcode, value);

                            lightUpdate(value>0 ? 1:0, value)


                        }
                    }

                    handle: Rectangle {
                        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                        y: control.topPadding + control.availableHeight / 2 - height / 2
                        implicitWidth: 26
                        implicitHeight: 26
                        radius: 13
                        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
                        border.color: "#bdbebf"
                    }
                }

                Label {
                    id: labelPercent
                    height: parent.height
                    width: contentWidth
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    font.pointSize: 16
                    color: "white"
                    text: lightdim + " %"
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: borderWidth
        height: parent.height
        width: parent.width
        border.width: borderWidth
        border.color: idWindows.color
        color: idWindows.color

        Flickable {
            anchors.fill: parent
            contentHeight: column.height

            MouseArea {
                // update lastAction time if touch on screen
                anchors.fill: parent
                onEntered: lastAction = new Date().getTime();
            }

            Column {
                id: column
                width: parent.width
                spacing: 20

                // Thông tin số lượng đèn
                Rectangle {
                    width: parent.width
                    height: rowHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: idWindows.color

                    Row {
                        width: parent.width
                        height: parent.height
                        spacing: 10

                        Label {
                            height: parent.height
                            width: contentWidth
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 20
                            font.bold: true
                            text: "Tùy chỉnh đèn"
                        }

                        Row {
                            width: parent.width-x
                            height: parent.height
                            layoutDirection: Qt.RightToLeft

                            Label {
                                height: parent.height
                                width: contentWidth
                                verticalAlignment: Qt.AlignVCenter
                                font.pointSize: 16
                                text: " đang tắt: " + strLightOff + " "
                            }
                            Image {
                                width: parent.height
                                height: parent.height
                                fillMode: Image.Pad
                                verticalAlignment: Image.AlignVCenter
                                horizontalAlignment: Image.AlignRight
                                source: "qrc:/image/imglightoff.png"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        iLightofClick++;
                                    }
                                }
                            }

                            Label {
                                height: parent.height
                                width: contentWidth
                                verticalAlignment: Qt.AlignVCenter
                                font.pointSize: 16
                                text: " đang mở: " + strLightOn + "   "
                            }
                            Image {
                                width: parent.height
                                height: parent.height
                                fillMode: Image.Pad
                                verticalAlignment: Image.AlignVCenter
                                horizontalAlignment: Image.AlignRight
                                source: "qrc:/image/imglighton.png"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if( iLightofClick == 2 )
                                        {
                                            iLightonClick++;
                                            if( iLightonClick == 2 ) {
                                                iLightofClick = 0;
                                                iLightonClick = 0;

                                                iLoginFrom = 1;
                                            }
                                        }
                                        else {
                                            iLightofClick = 0;
                                            iLightonClick = 0;
                                        }
                                    }
                                }
                            }

                            Label {
                                height: parent.height
                                width: contentWidth
                                verticalAlignment: Qt.AlignVCenter
                                font.pointSize: 16
                                text: "Số lượng đèn: " + strLights + " "
                            }
                        }
                    }
                }

                // Điều khiển chung
                Rectangle {
                    width: parent.width
                    height: rowHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: iLightGroupOnOff == 1 ? "#f99014" : "grey"

                    Row {
                        width: parent.width
                        height: parent.height
                        spacing: 10

                        Rectangle {
                            width: borderWidth
                            height: parent.height
                            color: iLightGroupOnOff == 1 ? "#f99014" : "grey"
                        }

                        Label {
                            height: parent.height
                            width: contentWidth
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 16
                            color: "white"
                            text: " ĐIỀU KHIỂN CHUNG"
                        }

                        Image {
                            width: parent.height
                            height: parent.height
                            fillMode: Image.Pad
                            verticalAlignment: Image.AlignVCenter
                            horizontalAlignment: Image.AlignRight
                            source: "qrc:/image/imglightmask.png"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {

                                    // switch đèn tổng
                                    iLightGroupOnOff = !iLightGroupOnOff

                                    // cập nhật giá trị cho các đèn con - muốn đổi ui liền
                                    lightsUpdate(iLightGroupOnOff, iLightBrightness)

                                    // gửi thông điệp lên máy chủ
                                    mainController.callSwitchGroup(iLightGroupOnOff)
                                    lightKeyPress();

                                }
                            }
                        }

                        Slider {
                            id: sliderRoom
                            width: parent.width-x-labelPercent.width-borderWidth*3
                            height: parent.height
                            from: 0
                            to: dimMax
                            value: (iLightGroupOnOff === 1 ? iLightBrightness : 0)
                            onValueChanged: {
                                if (pressed) {
                                    var v = Math.round(value)
                                    if( v != iLightBrightness )
                                    {
                                        iLightBrightness = v
                                        iLightGroupOnOff = v > 0

                                        // cập nhật giá trị cho các đèn con - muốn đổi ui liền
                                        lightsUpdate(iLightGroupOnOff, iLightBrightness)

                                        // gửi thông điệp lên máy chủ
                                        mainController.callSetDimGroup(v)
                                        lightKeyPress();
                                    }
                                }
                            }

                            handle: Rectangle {
                                x: sliderRoom.leftPadding + sliderRoom.visualPosition * (sliderRoom.availableWidth - width)
                                y: sliderRoom.topPadding + sliderRoom.availableHeight / 2 - height / 2
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 13
                                color: sliderRoom.pressed ? "#f0f0f0" : "#f6f6f6"
                                border.color: "#bdbebf"
                            }

                        }

                        Label {
                            id: labelPercent
                            height: parent.height
                            width: contentWidth
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 16
                            color: "white"
                            text: (iLightGroupOnOff === 1 ? strLightBrightness : "0") + " %"
                        }
                    }
                }

                Rectangle {
                    visible: listmodelLights.count > 0
                    width: parent.width
                    height: 1
                    color: "grey"
                }

                ListView {
                    id: listviewLights
                    width: parent.width
                    height: contentHeight
                    model: listmodelLights
                    spacing: 10
                    delegate: componentLights
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: idWindows.color
                }

                Row {
                    width: parent.width
                    height: 40

                    Rectangle {
                        width: 180
                        height: parent.height
                        radius: 10
                        border.width: 1
                        border.color: idWindows.color
                        color: idWindows.color

                        Row {
                            width: parent.width
                            height: parent.height

                            Image {
                                id: idBack
                                width: parent.height
                                height: parent.height

                                fillMode: Image.Pad
                                verticalAlignment: Image.AlignVCenter
                                horizontalAlignment: Image.AlignHCenter
                                source: "qrc:/image/imgback.png"
                            }

                            Text {
                                width: parent.width - idBack.width
                                height: parent.height
                                text: " Quay lại "
                                font.pointSize: 16
                                font.bold: true
                                color: "grey"
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stackView.pop();
                            }
                        }
                    }
                }
            }
        }
    }

    Timer  {
        id: idtimeTick
        interval: 10000;
        running: true;
        repeat: true;
        onTriggered: {
            // 300 second = 5 minute
            var freeHand = new Date().getTime() - lastAction;
            if( freeHand > 300000 ) {
                stackView.pop();
            }
        }
    }

    Component.onCompleted: {
        lastAction = new Date().getTime();
    }
}
