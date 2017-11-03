import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as OldCtrl
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import MainController 1.0

Rectangle {
    id: mainView
    border.width: borderWidth
    border.color: mainViewBorderColor

    // mainView property
    property color textcolor: "white"
    property string strDevId: ""                // device-id
    property string strGwId: ""                 // gateway-id
    property string strHaveperson: ""
    property string strTemperature: "26"
    property string strHumidity: "62"
    property int sensorFontsize: 72
    property int sensorFontsize2: 20 //24
    property double lastAction;

    property int dimMax: 100

    Connections {
        target: mainController

        onUpdateLights: {

            var lights = JSON.parse(data);
            iLightGroupOnOff    = lights.dt.lightgroup.on_off;
            strLightBrightness  = lights.dt.lightgroup.brightness;
            iLightBrightness    = lights.dt.lightgroup.brightness;
            strLights   = lights.dt.light_count // tổng số bóng đèn
            strLightOn  = lights.dt.light_on    // số bóng đèn sáng
            strLightOff = lights.dt.light_off   // số bóng đèn tắt
            console.log('strLights: ' + strLights);
        }

        onRefreshLightList2: {
            var lights = JSON.parse(listLight);

            var lightCount = 0;
            var lightOn = 0;
            var lightOff = 0;

            for (var light in lights.dt.lightsOnFloor)
            {
                lightCount++;
                if( lights.dt.lightsOnFloor[light].on_off === 1 ) {
                    lightOn++;
                } else {
                    lightOff++;
                }
            }

            iAreaId = lights.dt.lightsOnFloor[0].area_id;

            strLights = lightCount.toString();
            strLightOn = lightOn.toString();
            strLightOff = lightOff.toString();
        }

        onRefreshBrightness: { // brightness
            var brtnss = JSON.parse(brightness);
            iLightGroupOnOff = brtnss.dt.area.area_on_off;
            strLightBrightness = brtnss.dt.area.area_brightness;
            iLightBrightness = brtnss.dt.area.area_brightness;
            console.log("onRefreshBrightness, value: " + iLightBrightness);
        }

        onRefreshSensors2: {
            var sensor = JSON.parse(sensors);
            if( sensor.err === 0 ) {
                if( sensor.dt.haveperson > 0 ) {
                    strHaveperson = sensor.dt.haveperson;
                }
                if( sensor.dt.temperature > 0 ) {
                    strTemperature = sensor.dt.temperature;
                }
                if( sensor.dt.humidity > 0 ) {
                    strHumidity = sensor.dt.humidity;
                }
            }
        }

        onRefreshAreaBrightness: {
            if( iAreaId === areaId ) {
                iLightGroupOnOff = onoff;
                strLightBrightness = brightness;
                iLightBrightness = brightness;
                console.log("onRefreshAreaBrightness, value: " + iLightBrightness);
            }
        }

        onRefreshSensors: {
            if( temperature >= 0 ) {
                strTemperature = temperature;
            }
            if( humidity >= 0 ) {
                strHumidity = humidity;
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

    Rectangle {
        id: idrectParent
        anchors.fill: parent
        anchors.margins: borderWidth
        height: parent.height
        width: parent.width
        border.width: borderWidth
        border.color: mainViewBorderColor
        color: mainViewBorderColor

        Column {
            width: parent.width
            height: parent.height
            anchors {left:parent.left; right: parent.right}
            spacing: borderWidth

            // sensor
            Row {
                width: parent.width
                height: Math.min(parent.width/3, parent.height/3*2)

                Item {
                    width: parent.width/3
                    height: parent.height

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "qrc:/image/bkimg01.png"
                    }

                    Column {
                        width: parent.width
                        height: parent.height
                        //spacing: borderWidth

                        Rectangle {
                            width: parent.width
                            height: borderWidth
                            opacity: 0
                        }

                        Label {
                            width: parent.width
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 20
                            color: textcolor
                            text: "Nhiệt Độ"
                        }

                        Image {
                            id: idImg01
                            fillMode: Image.Pad
                            width: parent.width
                            height: parent.height*2/5
                            verticalAlignment: Image.AlignVCenter
                            horizontalAlignment: Image.AlignHCenter
                            source: "qrc:/image/frimg01.png"
                        }

                        Row {
                            width: parent.width
                            height: parent.parent.height*2/5

                            Row {
                                width: parent.width
                                height: parent.parent.height

                                Rectangle {
                                    //width: parent.width/3.5
                                    width: (parent.width - (idlabelTemperature.width+idlabelOo.width+idlabelOc.width))/2
                                    height: parent.height
                                    opacity: 0
                                }

                                Label {
                                    id: idlabelTemperature
                                    width: contentWidth
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: sensorFontsize
                                    color: textcolor
                                    text: strTemperature
                                }
                                Label {
                                    id: idlabelOo
                                    width: contentWidth
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: 16
                                    color: textcolor
                                    text: "o"
                                }
                                Label {
                                    id: idlabelOc
                                    width: contentWidth
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: sensorFontsize
                                    color: textcolor
                                    text: "C"
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width/3
                    height: parent.height

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "qrc:/image/bkimg02.png"
                    }

                    Column {
                        width: parent.width
                        height: parent.height
                        //spacing: borderWidth

                        Rectangle {
                            width: parent.width
                            height: borderWidth
                            opacity: 0
                        }

                        Label {
                            width: parent.width
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 20
                            color: textcolor
                            text: "Độ Ẩm"
                        }

                        Image {
                            id: idImg02
                            fillMode: Image.Pad
                            width: parent.width
                            height: parent.height*2/5
                            verticalAlignment: Image.AlignVCenter
                            horizontalAlignment: Image.AlignHCenter
                            source: "qrc:/image/frimg02.png"
                        }

                        Row {
                            width: parent.width
                            height: parent.parent.height*2/5

                            Row {
                                width: parent.width
                                height: parent.parent.height

                                Label {
                                    id: idlabelHumidity
                                    width: parent.width
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: sensorFontsize
                                    color: textcolor
                                    text: strHumidity + "%"
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width/3
                    height: parent.height

                    Image {
                        width: parent.width
                        height: parent.height
                        source: "qrc:/image/bkimg03.png"
                    }

                    Column {
                        width: parent.width
                        height: parent.height
                        //spacing: borderWidth

                        Rectangle {
                            width: parent.width
                            height: borderWidth
                            opacity: 0
                        }

                        Label {
                            width: parent.width
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pointSize: 20
                            color: textcolor
                            text: "Đèn"
                        }

                        Image {
                            id: idImg03
                            fillMode: Image.Pad
                            width: parent.width
                            height: parent.height*2/5
                            verticalAlignment: Image.AlignVCenter
                            horizontalAlignment: Image.AlignHCenter
                            source: "qrc:/image/frimg03.png"
                        }

                        Row {
                            width: parent.width
                            height: parent.parent.height*2/5

                            Column {
                                width: parent.width
                                spacing: 5

                                Label {
                                    width: parent.width
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: sensorFontsize2
                                    color: textcolor
                                    text: "Đang mở: " + strLightOn
                                }

                                Label {
                                    width: parent.width
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: sensorFontsize2
                                    color: textcolor
                                    text: "Đang tắt: " + strLightOff
                                }
                            }
                        }
                    }
                }
            }

            // option icon layout
            Row {
                width: parent.width
                height: 30
                spacing: borderWidth

                Row {
                    id: idRow111
                    height: 30
                    width: parent.width
                    spacing: borderWidth
                    Image {
                        id: idImageConfig
                        width: parent.height
                        height: parent.height
                        source: "qrc:/image/icon_controls.svg"
                    }
                    Label {
                        id: idlabelopt
                        text: "Điều khiển phòng họp"
                        width: contentWidth
                        height: parent.height
                        font.pointSize: 25
                        color: "#BFBFBF"
                        verticalAlignment: Qt.AlignVCenter
                    }
                    Rectangle {
                        y: parent.height/2
                        width: idrectParent.width -  idlabelopt.width - borderWidth*4
                        height: 1
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        iTitleClick++;
                        if( iTitleClick > 2 )
                        {
                            iTitleClick = 0;
                            iDateClick = 0;
                        }
                    }
                }
            }

            // điều khiển
            Row {
                width: parent.width
                height: (idrectParent.height - y)
                anchors {left:parent.left; right: parent.right}
                spacing: (borderWidth)

                // điều khiển đèn
                Rectangle {
                    id: rectAreaLight
                    width: (parent.width - borderWidth)/2
                    height: (idrectParent.height - parent.y)
                    color: "#4A4A4A"

                    Row {
                        height: rectAreaLight.height
                        width: rectAreaLight.width

                        Rectangle {
                            width: rectAreaLight.width/4
                            height: rectAreaLight.height
                            color: "#FF363636"
                            ToolButton {
                                anchors.centerIn: parent
                                contentItem: Image {
                                    fillMode: Image.Pad
                                    horizontalAlignment: Image.AlignHCenter
                                    verticalAlignment: Image.AlignVCenter
                                    source: iLightGroupOnOff? "qrc:/image/icon-light-on.png":"qrc:/image/icon-light-off.png"
                                    scale: 0.5
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if( (mainController.getConfigAllowLightControl() === true) || (iControlEnable === 1) )
                                    {
                                        iPageLightShow = 1;
                                        iLightGroupOnOff = !iLightGroupOnOff
                                        // gửi thông điệp lên máy chủ
                                        mainController.callSwitchGroup(iLightGroupOnOff, iLightBrightness)
                                        if(iLightGroupOnOff === 0) {
                                            sliderDimGroup.value = 0;
                                        } else {
                                            if(iLightBrightness === 0) {
                                                iLightBrightness = 100;
                                            }
                                            sliderDimGroup.value = iLightBrightness;
                                        }
                                        lightsUpdate(iLightGroupOnOff, iLightBrightness)

                                    }
                                    else
                                    {
                                        iTimeoutType = 0;
                                        dialogAlert.open();
                                    }
                                }
                                function lightsUpdate(onoff, dim) {
                                    strLightOn  = onoff ? strLights : 0
                                    strLightOff = onoff ? 0 : strLights
                                }

                            }
                        }
                        Rectangle {
                            id: rectBrightness_Color
                            width: (rectAreaLight.width*3)/4 - 40
                            height: rectAreaLight.height
                            color: "red"
                            Column {
                                Rectangle {
                                    id: rectControl
                                    width: rectBrightness_Color.width
                                    height: rectBrightness_Color.height
                                    color:"#4A4A4A"
                                    Column {
                                        Rectangle {
                                            width: rectControl.width
                                            height: rectControl.height/2
                                            color: "#4A4A4A"

                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 20
                                                anchors.top: parent.top
                                                anchors.topMargin: rectControl.height/3 - 13
                                                text: qsTr("Độ sáng")
                                                color: "#FF9B9B9B"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                            OldCtrl.Slider {
                                                id: sliderDimGroup
                                                anchors.right: parent.right
                                                anchors.rightMargin: 35
                                                anchors.top: parent.top
                                                anchors.topMargin: rectControl.height/3 - 13
                                                maximumValue: 100
                                                minimumValue: 0
                                                value: (iLightGroupOnOff === 1 ? iLightBrightness : 0)
                                                style: SliderStyle {
                                                    groove:Image {
                                                       fillMode: Image.Pad
                                                       horizontalAlignment: Image.AlignHCenter
                                                       verticalAlignment: Image.AlignVCenter
                                                       source: "qrc:/image/slidebar-light.svg"
                                                    }
                                                    handle: Rectangle {
                                                        anchors.centerIn: parent
                                                        color: control.pressed ? "lightgray" : "#FFFFFFFF"
                                                        implicitWidth: 20
                                                        implicitHeight: 20
                                                        radius: 10
                                                    }
                                                }
                                                onValueChanged: {
                                                    if (pressed) {
                                                        var v = Math.round(value)
                                                        if( v != iLightBrightness )
                                                        {
                                                            iLightBrightness = v
                                                            iLightGroupOnOff = v > 0
                                                            console.log("change action, brighness: " + iLightBrightness);
                                                            // gửi thông điệp lên máy chủ
                                                            mainController.callSetDimGroup(v)
                                                            lightKeyPress();
                                                        }
                                                    }

                                                }
                                            }
                                        }
                                        Rectangle {
                                            width: rectControl.width
                                            height: rectControl.height/2
                                            color: "#4A4A4A"
                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 20
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: rectControl.height/3 - 13
                                                text: qsTr("Màu sắc")
                                                color: "#FF9B9B9B"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                            OldCtrl.Slider {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 35
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: rectControl.height/3 - 13
                                                style: SliderStyle {
                                                    groove:Image {
                                                       fillMode: Image.Pad
                                                       horizontalAlignment: Image.AlignHCenter
                                                       verticalAlignment: Image.AlignVCenter
                                                       source: "qrc:/image/slidebar-color.svg"
                                                    }
                                                    handle: Rectangle {
                                                        anchors.centerIn: parent
                                                        color: control.pressed ? "lightgray" : "#FFFFFFFF"
                                                        implicitWidth: 20
                                                        implicitHeight: 20
                                                        radius: 10
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 40
                            height: rectAreaLight.height
                            color: "#4A4A4A"
                            ToolButton {
                                anchors.centerIn: parent
                                contentItem: Image {
                                    fillMode: Image.Pad
                                    horizontalAlignment: Image.AlignHCenter
                                    verticalAlignment: Image.AlignVCenter
                                    source: "qrc:/image/icon-link-arrow.svg"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("go to details");
                                    stackView.push(idPageLightHubOnArea)
                                }
                            }
                        }

                    }
                }

                // điều khiển máy chiếu
                Rectangle {
                    width: (parent.width - borderWidth)/2
                    height: (idrectParent.height - parent.y)
                    color: "#4A4A4A"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push(idGridViewInQML)
                            if( (mainController.getConfigAllowLightControl() === true) || (iControlEnable === 1) )
                            {
                                mainController.callGetRemoteList()
                                iPageLightShow = 1;
                                stackView.push(idPageRemoteCtrller)
                            }
                            else
                            {
                                iTimeoutType = 0;
                                dialogAlert.open();
                            }
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: borderWidth
                        Image {
                            source: "qrc:/image/icon-projector.svg"
                        }

                        Label {
                            text: "ĐIỀU KHIỂN MÁY CHIẾU"
                            font.pixelSize: 25
                            color: "#BFBFBF"
                        }
                    }
                }

            }
        }
    }
}
