import QtQuick 2.0 as Quick20
import QtQuick 2.7
import QtQuick.Controls 1.4 as OldCtrl
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import QtQml.Models 2.1
import QtGraphicalEffects 1.0

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


    Rectangle {
        id: container
        width: parent.width/2
        height: parent.height

        ListModel {
            id: animalsModel
            ListElement { name: "Ant"; size: "Tiny" }
            ListElement { name: "Flea"; size: "Tiny" }
            ListElement { name: "Parrot"; size: "Small" }
            ListElement { name: "Guinea pig"; size: "Small" }
            ListElement { name: "Rat"; size: "Small" }
            ListElement { name: "Butterfly"; size: "Small" }
            ListElement { name: "Dog"; size: "Medium" }
            ListElement { name: "Cat"; size: "Medium" }
            ListElement { name: "Pony"; size: "Medium" }
            ListElement { name: "Koala"; size: "Medium" }
            ListElement { name: "Horse"; size: "Large" }
            ListElement { name: "Tiger"; size: "Large" }
            ListElement { name: "Giraffe"; size: "Large" }
            ListElement { name: "Elephant"; size: "Huge" }
            ListElement { name: "Whale"; size: "Huge" }
        }

        Component {
            id: sectionHeading
            ColumnLayout {
                Rectangle {
                    width: container.width
                    height: 20
                }
                Rectangle {
                    width: container.width
                    height: childrenRect.height
                    Text {
                        text: section
                        font.bold: true
                        font.pixelSize: 20
                    }
                }
                Rectangle {
                    id: rectRootHub
                    width: container.width - 40
                    height: 120
                    color: "#FF4A4A4A"
                    ColumnLayout {
                        anchors.fill: parent
                        RowLayout {
                            id: layout
                            Rectangle {
                                color: "#FF363636"
                                Layout.preferredWidth: rectRootHub.width/4
                                Layout.preferredHeight: rectRootHub.height
                                Image {
                                    anchors.centerIn: parent
                                    fillMode: Image.Pad
                                    horizontalAlignment: Image.AlignHCenter
                                    verticalAlignment: Image.AlignVCenter
                                    source: iLightGroupOnOff? "qrc:/image/icon-light-on.png":"qrc:/image/icon-light-off.png"
                                    scale: 0.5
                                }
                            }
                            Rectangle {
                                id: rectBrightness_Color
                                Layout.preferredWidth: (rectRootHub.width*3)/4 - 60
                                Layout.preferredHeight: rectRootHub.height
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
                                                    anchors.rightMargin: 0
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
                                                    anchors.rightMargin: 0
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
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: rectRootHub.height
                                color: "#4A4A4A"
                                Image {
                                    id: imgDown
                                    anchors.centerIn: parent
                                    fillMode: Image.Pad
                                    horizontalAlignment: Image.AlignHCenter
                                    verticalAlignment: Image.AlignVCenter
                                    source: "qrc:/image/remctrldown.png"
                                    smooth: true
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: imgDown
                                    source: imgDown
                                    color: "#FF9B9B9B"
                                    scale: 0.5
                                }
                            }
                        }

                    }
                }
                Rectangle {
                    width: container.width
                    height: 10
                }
            }
        }

        Component {
            id: listPortInHub
            ColumnLayout {
                Rectangle {
                    id: rectRootPort
                    width: container.width - 40
                    height: 120
                    color: "#9E9E9E"
                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        Rectangle {
                            color: "#9E9E9E"
                            Layout.preferredWidth: rectRootPort.width/4
                            Layout.preferredHeight: rectRootPort.height
                            Image {
                                anchors.centerIn: parent
                                fillMode: Image.Pad
                                horizontalAlignment: Image.AlignHCenter
                                verticalAlignment: Image.AlignVCenter
                                source: iLightGroupOnOff? "qrc:/image/icon-light-on.png":"qrc:/image/icon-light-off.png"
                                scale: 0.5
                            }
                        }
                        Rectangle {
                            id: rectBrightness_Port_Color
                            Layout.preferredWidth: (rectRootPort.width*3)/4 - 60
                            Layout.preferredHeight: rectRootPort.height
                            Column {
                                Rectangle {
                                    id: rectControlPort
                                    width: rectBrightness_Port_Color.width
                                    height: rectBrightness_Port_Color.height
                                    color:"#9E9E9E"
                                    Column {
                                        Rectangle {
                                            width: rectControlPort.width
                                            height: rectControlPort.height/2
                                            color: "#9E9E9E"

                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 0
                                                anchors.top: parent.top
                                                anchors.topMargin: rectControlPort.height/3 - 13
                                                text: qsTr("Độ sáng")
                                                color: "#F5F5F5"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                            OldCtrl.Slider {
                                                id: sliderDimPort
                                                anchors.right: parent.right
                                                anchors.rightMargin: 0
                                                anchors.top: parent.top
                                                anchors.topMargin: rectControlPort.height/3 - 13
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

                                            }
                                        }
                                        Rectangle {
                                            width: rectControlPort.width
                                            height: rectControlPort.height/2
                                            color: "#9E9E9E"
                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 0
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: rectControlPort.height/3 - 13
                                                text: qsTr("Màu sắc")
                                                color: "#F5F5F5"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                            OldCtrl.Slider {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 0
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: rectControlPort.height/3 - 13
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
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: rectRootPort.height
                            color: "#9E9E9E"
                            Text {
                                anchors.centerIn: parent
                                color: "#FF8D8D8D"
                                font.pixelSize: 30
                                text: qsTr("01")
                            }

                        }

                    }

                }
                Rectangle {
                    width: container.width
                    height: 10
                }
            }
        }


        ListView {
            id: view
            anchors {
                top: parent.top
                topMargin: 20
                bottom: buttonBar.top
                left: parent.left
                leftMargin: 20

            }
            width: parent.width
            model: animalsModel
            delegate: listPortInHub

            section.property: "size"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading
        }

        Row {
            id: buttonBar
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            spacing: 1
        }
    }


//    Rectangle {
//        id: container
//        width: parent.width/2
//        height: parent.height


//        ListModel {
//            id: animalsModel
//            ListElement { name: "Ant"; size: "Tiny" }
//            ListElement { name: "Flea"; size: "Tiny" }
//            ListElement { name: "Parrot"; size: "Small" }
//            ListElement { name: "Guinea pig"; size: "Small" }
//            ListElement { name: "Rat"; size: "Small" }
//            ListElement { name: "Butterfly"; size: "Small" }
//            ListElement { name: "Dog"; size: "Medium" }
//            ListElement { name: "Cat"; size: "Medium" }
//            ListElement { name: "Pony"; size: "Medium" }
//            ListElement { name: "Koala"; size: "Medium" }
//            ListElement { name: "Horse"; size: "Large" }
//            ListElement { name: "Tiger"; size: "Large" }
//            ListElement { name: "Giraffe"; size: "Large" }
//            ListElement { name: "Elephant"; size: "Huge" }
//            ListElement { name: "Whale"; size: "Huge" }
//        }

//        Component {
//            id: sectionHeading
//            ColumnLayout {
//                width: container.width - 40
//                height: container.width/4
//                Rectangle {
//                    id: rectRootHub
//                    width: container.width - 40
//                    height: container.width/4
//                    color: "#FF4A4A4A"
//                    ColumnLayout {
//                        anchors.fill: parent
//                        RowLayout {
//                            id: layout
//                            Rectangle {
//                                color: "#FF363636"
//                                Layout.preferredWidth: rectRootHub.width/4
//                                Layout.preferredHeight: rectRootHub.height
//                                Image {
//                                    anchors.centerIn: parent
//                                    fillMode: Image.Pad
//                                    horizontalAlignment: Image.AlignHCenter
//                                    verticalAlignment: Image.AlignVCenter
//                                    source: iLightGroupOnOff? "qrc:/image/icon-light-on.png":"qrc:/image/icon-light-off.png"
//                                    scale: 0.5
//                                }
//                            }
//                            Rectangle {
//                                id: rectBrightness_Color
//                                Layout.preferredWidth: (rectRootHub.width*3)/4 - 60
//                                Layout.preferredHeight: rectRootHub.height
//                                Column {
//                                    Rectangle {
//                                        id: rectControl
//                                        width: rectBrightness_Color.width
//                                        height: rectBrightness_Color.height
//                                        color:"#4A4A4A"
//                                        Column {
//                                            Rectangle {
//                                                width: rectControl.width
//                                                height: rectControl.height/2
//                                                color: "#4A4A4A"

//                                                Text {
//                                                    anchors.left: parent.left
//                                                    anchors.leftMargin: 20
//                                                    anchors.top: parent.top
//                                                    anchors.topMargin: rectControl.height/3 - 13
//                                                    text: qsTr("Độ sáng")
//                                                    color: "#FF9B9B9B"
//                                                    font.pixelSize: 18
//                                                    font.bold: true
//                                                }
//                                                OldCtrl.Slider {
//                                                    id: sliderDimGroup
//                                                    anchors.right: parent.right
//                                                    anchors.rightMargin: 0
//                                                    anchors.top: parent.top
//                                                    anchors.topMargin: rectControl.height/3 - 13
//                                                    maximumValue: 100
//                                                    minimumValue: 0
//                                                    value: (iLightGroupOnOff === 1 ? iLightBrightness : 0)
//                                                    style: SliderStyle {
//                                                        groove:Image {
//                                                           fillMode: Image.Pad
//                                                           horizontalAlignment: Image.AlignHCenter
//                                                           verticalAlignment: Image.AlignVCenter
//                                                           source: "qrc:/image/slidebar-light.svg"
//                                                        }
//                                                        handle: Rectangle {
//                                                            anchors.centerIn: parent
//                                                            color: control.pressed ? "lightgray" : "#FFFFFFFF"
//                                                            implicitWidth: 20
//                                                            implicitHeight: 20
//                                                            radius: 10
//                                                        }
//                                                    }

//                                                }
//                                            }
//                                            Rectangle {
//                                                width: rectControl.width
//                                                height: rectControl.height/2
//                                                color: "#4A4A4A"
//                                                Text {
//                                                    anchors.left: parent.left
//                                                    anchors.leftMargin: 20
//                                                    anchors.bottom: parent.bottom
//                                                    anchors.bottomMargin: rectControl.height/3 - 13
//                                                    text: qsTr("Màu sắc")
//                                                    color: "#FF9B9B9B"
//                                                    font.pixelSize: 18
//                                                    font.bold: true
//                                                }
//                                                OldCtrl.Slider {
//                                                    anchors.right: parent.right
//                                                    anchors.rightMargin: 0
//                                                    anchors.bottom: parent.bottom
//                                                    anchors.bottomMargin: rectControl.height/3 - 13
//                                                    style: SliderStyle {
//                                                        groove:Image {
//                                                           fillMode: Image.Pad
//                                                           horizontalAlignment: Image.AlignHCenter
//                                                           verticalAlignment: Image.AlignVCenter
//                                                           source: "qrc:/image/slidebar-color.svg"
//                                                        }
//                                                        handle: Rectangle {
//                                                            anchors.centerIn: parent
//                                                            color: control.pressed ? "lightgray" : "#FFFFFFFF"
//                                                            implicitWidth: 20
//                                                            implicitHeight: 20
//                                                            radius: 10
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            Rectangle {
//                                Layout.preferredWidth: 40
//                                Layout.preferredHeight: rectRootHub.height
//                                color: "#4A4A4A"
//                                Image {
//                                    id: imgDown
//                                    anchors.centerIn: parent
//                                    fillMode: Image.Pad
//                                    horizontalAlignment: Image.AlignHCenter
//                                    verticalAlignment: Image.AlignVCenter
//                                    source: "qrc:/image/remctrldown.png"
//                                    smooth: true
//                                    visible: false
//                                }
//                                ColorOverlay {
//                                    anchors.fill: imgDown
//                                    source: imgDown
//                                    color: "#FF9B9B9B"
//                                    scale: 0.5
//                                }
//                            }
//                        }

//                    }
//                }

//            }
//         }

//        Component {
//            id: rectBodyPort
//            ColumnLayout {
//                width: container.width - 40
//                height: container.width/4 + 10
//                Rectangle {
//                    height: 10
//                    width: 100
//                }
//                Rectangle {
//                    id: rectRootPort
//                    width: container.width - 40
//                    height: container.width/4
//                    color: "#FF545454"
//                    RowLayout {
//                        id: layout
//                        anchors.fill: parent
//                        Rectangle {
//                            color: "#FF545454"
//                            Layout.preferredWidth: rectRootPort.width/4
//                            Layout.preferredHeight: rectRootPort.height
//                            Image {
//                                anchors.centerIn: parent
//                                fillMode: Image.Pad
//                                horizontalAlignment: Image.AlignHCenter
//                                verticalAlignment: Image.AlignVCenter
//                                source: iLightGroupOnOff? "qrc:/image/icon-light-on.png":"qrc:/image/icon-light-off.png"
//                                scale: 0.5
//                            }
//                        }
//                        Rectangle {
//                            id: rectBrightness_Port_Color
//                            Layout.preferredWidth: (rectRootPort.width*3)/4 - 60
//                            Layout.preferredHeight: rectRootPort.height
//                            Column {
//                                Rectangle {
//                                    id: rectControlPort
//                                    width: rectBrightness_Port_Color.width
//                                    height: rectBrightness_Port_Color.height
//                                    color:"#FF545454"
//                                    Column {
//                                        Rectangle {
//                                            width: rectControlPort.width
//                                            height: rectControlPort.height/2
//                                            color: "#FF545454"

//                                            Text {
//                                                anchors.left: parent.left
//                                                anchors.leftMargin: 20
//                                                anchors.top: parent.top
//                                                anchors.topMargin: rectControlPort.height/3 - 13
//                                                text: qsTr("Độ sáng")
//                                                color: "#FF9B9B9B"
//                                                font.pixelSize: 18
//                                                font.bold: true
//                                            }
//                                            OldCtrl.Slider {
//                                                id: sliderDimPort
//                                                anchors.right: parent.right
//                                                anchors.rightMargin: 0
//                                                anchors.top: parent.top
//                                                anchors.topMargin: rectControlPort.height/3 - 13
//                                                maximumValue: 100
//                                                minimumValue: 0
//                                                value: (iLightGroupOnOff === 1 ? iLightBrightness : 0)
//                                                style: SliderStyle {
//                                                    groove:Image {
//                                                       fillMode: Image.Pad
//                                                       horizontalAlignment: Image.AlignHCenter
//                                                       verticalAlignment: Image.AlignVCenter
//                                                       source: "qrc:/image/slidebar-light.svg"
//                                                    }
//                                                    handle: Rectangle {
//                                                        anchors.centerIn: parent
//                                                        color: control.pressed ? "lightgray" : "#FFFFFFFF"
//                                                        implicitWidth: 20
//                                                        implicitHeight: 20
//                                                        radius: 10
//                                                    }
//                                                }

//                                            }
//                                        }
//                                        Rectangle {
//                                            width: rectControlPort.width
//                                            height: rectControlPort.height/2
//                                            color: "#FF545454"
//                                            Text {
//                                                anchors.left: parent.left
//                                                anchors.leftMargin: 20
//                                                anchors.bottom: parent.bottom
//                                                anchors.bottomMargin: rectControlPort.height/3 - 13
//                                                text: qsTr("Màu sắc")
//                                                color: "#FF9B9B9B"
//                                                font.pixelSize: 18
//                                                font.bold: true
//                                            }
//                                            OldCtrl.Slider {
//                                                anchors.right: parent.right
//                                                anchors.rightMargin: 0
//                                                anchors.bottom: parent.bottom
//                                                anchors.bottomMargin: rectControlPort.height/3 - 13
//                                                style: SliderStyle {
//                                                    groove:Image {
//                                                       fillMode: Image.Pad
//                                                       horizontalAlignment: Image.AlignHCenter
//                                                       verticalAlignment: Image.AlignVCenter
//                                                       source: "qrc:/image/slidebar-color.svg"
//                                                    }
//                                                    handle: Rectangle {
//                                                        anchors.centerIn: parent
//                                                        color: control.pressed ? "lightgray" : "#FFFFFFFF"
//                                                        implicitWidth: 20
//                                                        implicitHeight: 20
//                                                        radius: 10
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }

//                    }

//                }

//            }
//             }
//        ListView {
//            id: view
//            anchors {
//                bottom: buttonBar.top
//                top: parent.top
//                topMargin: 20
//                right: parent.right
//                rightMargin: 20
//                left: parent.left
//                leftMargin: 20
//            }
//            width: parent.width
//            model: animalsModel
//            delegate: rectBodyPort

//            section.property: "size"
//            section.criteria: ViewSection.FullString
//            section.delegate: sectionHeading
//        }

//        Row {
//            id: buttonBar
//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: 1
//            spacing: 1
//        }
//    }



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
