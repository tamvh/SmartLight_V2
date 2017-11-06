import QtQuick 2.0 as Quick20
import QtQuick 2.4
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4 as OldCtrl
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import QtQml.Models 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
Component {
    Pane {
        id: appContainer
        ListModel {
            id: listHubLeft
            ListElement {
                name: "P1.qml lightpink"
                rowspan: 4
                ecolor: "lightpink"
                h:200
                w:100
                listport: "[{\"id\":12},{\"id\":25},{\"id\":12},{\"id\":25}]"
            }
            ListElement {
                name: "P2.qml lightgreen"
                rowspan: 2
                ecolor: "lightgreen"
                h:50
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml orange"
                rowspan: 2
                ecolor: "orange"
                h:20
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml yellow"
                rowspan: 2
                ecolor: "yellow"
                h:50
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml gray"
                rowspan: 2
                ecolor: "gray"
                h:10
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
        }

        ListModel {
            id: listHubRight
            ListElement {
                name: "P1.qml lightpink 1"
                rowspan: 3
                ecolor: "lightpink"
                h:200
                w:100
                listport: "[{\"id\":12},{\"id\":25},{\"id\":12}]"
            }
            ListElement {
                name: "P2.qml lightgreen"
                rowspan: 2
                ecolor: "lightgreen"
                h:50
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml orange"
                rowspan: 2
                ecolor: "orange"
                h:20
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml yellow"
                rowspan: 2
                ecolor: "yellow"
                h:50
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
            ListElement {
                name: "P2.qml gray"
                rowspan: 2
                ecolor: "gray"
                h:10
                w:100
                listport: "[{\"id\":1},{\"id\":2}]"
            }
        }

        Rectangle {
            id: root
            width: parent.width
            height: parent.height
            Flickable {
                anchors.fill: parent
                contentHeight: column.height
                Column {
                    id: column
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    Row {
                        width: parent.width
                        spacing: 20

                        Column {
                            width: parent.width/2 - 10
                            Grid {
                                objectName: "sidebarView"
                                width: parent.width
                                columns: 1
                                spacing: 20
                                flow: Grid.TopToBottom
                                Repeater {
                                    model: listHubLeft
                                    delegate: Column {
                                        width: parent.width
                                        Rectangle {
                                            width: parent.width
                                            height: nameHubLeft.height
                                            Text {
                                                id: nameHubLeft
                                                text: name
                                                font.bold: true
                                                font.pixelSize: 20
                                            }
                                        }
                                        Rectangle {
                                            id: rectItemHubLeft
                                            width: parent.width
                                            height: 120
                                            color: "#FF4A4A4A"
                                            ColumnLayout {
                                                anchors.fill: parent
                                                RowLayout {
                                                    id: layout
                                                    Rectangle {
                                                        color: "#FF363636"
                                                        Layout.preferredWidth: rectItemHubLeft.width/4
                                                        Layout.preferredHeight: rectItemHubLeft.height
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
                                                        id: rectBrightness_Color_Left
                                                        Layout.preferredWidth: (rectItemHubLeft.width*3)/4 - 60
                                                        Layout.preferredHeight: rectItemHubLeft.height
                                                        Column {
                                                            Rectangle {
                                                                id: rectControlLeft
                                                                width: rectBrightness_Color_Left.width
                                                                height: rectBrightness_Color_Left.height
                                                                color:"#4A4A4A"
                                                                Column {
                                                                    Rectangle {
                                                                        width: rectControlLeft.width
                                                                        height: rectControlLeft.height/2
                                                                        color: "#4A4A4A"

                                                                        Text {
                                                                            anchors.left: parent.left
                                                                            anchors.leftMargin: 20
                                                                            anchors.top: parent.top
                                                                            anchors.topMargin: rectControlLeft.height/3 - 13
                                                                            text: qsTr("Độ sáng")
                                                                            color: "#FF9B9B9B"
                                                                            font.pixelSize: 18
                                                                            font.bold: true
                                                                        }
                                                                        OldCtrl.Slider {
                                                                            id: sliderDimGroupLeft
                                                                            anchors.right: parent.right
                                                                            anchors.rightMargin: 0
                                                                            anchors.top: parent.top
                                                                            anchors.topMargin: rectControlLeft.height/3 - 13
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
                                                                        width: rectControlLeft.width
                                                                        height: rectControlLeft.height/2
                                                                        color: "#4A4A4A"
                                                                        Text {
                                                                            anchors.left: parent.left
                                                                            anchors.leftMargin: 20
                                                                            anchors.bottom: parent.bottom
                                                                            anchors.bottomMargin: rectControlLeft.height/3 - 13
                                                                            text: qsTr("Màu sắc")
                                                                            color: "#FF9B9B9B"
                                                                            font.pixelSize: 18
                                                                            font.bold: true
                                                                        }
                                                                        OldCtrl.Slider {
                                                                            anchors.right: parent.right
                                                                            anchors.rightMargin: 0
                                                                            anchors.bottom: parent.bottom
                                                                            anchors.bottomMargin: rectControlLeft.height/3 - 13
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
                                                        Layout.preferredHeight: rectItemHubLeft.height
                                                        color: "#4A4A4A"
                                                        Image {
                                                            id: imgExpandingLeft
                                                            anchors.centerIn: parent
                                                            fillMode: Image.Pad
                                                            horizontalAlignment: Image.AlignHCenter
                                                            verticalAlignment: Image.AlignVCenter
                                                            source: "qrc:/image/remctrldown.png"
                                                            smooth: true
                                                            visible: false
                                                        }
                                                        ColorOverlay {
                                                            anchors.fill: imgExpandingLeft
                                                            source: imgExpandingLeft
                                                            color: "#FF9B9B9B"
                                                            scale: 0.5
                                                        }
                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: rectListPortLeft.visible = !rectListPortLeft.visible
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        ListModel
                                        {
                                            id: listPortInHubLeft

                                            Component.onCompleted:
                                            {
                                                console.log('f: ' + JSON.parse(listport).length);
                                                for (var i = 0; i < JSON.parse(listport).length; i++)
                                                {
                                                    append( { id: JSON.parse(listport)[i].id } )
                                                }
                                            }
                                        }
                                        Rectangle {
                                            width: parent.width
                                            height: 10
                                            visible: rectListPortLeft.visible
                                        }
                                        Rectangle {
                                            id: rectListPortLeft
                                            width: parent.width
                                            visible: false
                                            height: (rowspan * 120) + (JSON.parse(listport).length * 10)
                                            Column {
                                                width: parent.width
                                                spacing: 10
                                                Repeater {
                                                    model: listPortInHubLeft
                                                    delegate: Rectangle {
                                                        id: rectItemPortLeft
                                                        width: parent.width
                                                        height: 120
                                                        color: "#9E9E9E"
                                                        RowLayout {
                                                            anchors.fill: parent
                                                            Rectangle {
                                                                color: "#9E9E9E"
                                                                Layout.preferredWidth: rectItemPortLeft.width/4
                                                                Layout.preferredHeight: rectItemPortLeft.height
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
                                                                id: rectBrightness_Port_Color_Left
                                                                Layout.preferredWidth: (rectItemPortLeft.width*3)/4 - 60
                                                                Layout.preferredHeight: rectItemPortLeft.height
                                                                Column {
                                                                    Rectangle {
                                                                        id: rectControlPortLeft
                                                                        width: rectBrightness_Port_Color_Left.width
                                                                        height: rectBrightness_Port_Color_Left.height
                                                                        color:"#9E9E9E"
                                                                        Column {
                                                                            Rectangle {
                                                                                width: rectControlPortLeft.width
                                                                                height: rectControlPortLeft.height/2
                                                                                color: "#9E9E9E"

                                                                                Text {
                                                                                    anchors.left: parent.left
                                                                                    anchors.leftMargin: 0
                                                                                    anchors.top: parent.top
                                                                                    anchors.topMargin: rectControlPortLeft.height/3 - 13
                                                                                    text: qsTr("Độ sáng")
                                                                                    color: "#F5F5F5"
                                                                                    font.pixelSize: 18
                                                                                    font.bold: true
                                                                                }
                                                                                OldCtrl.Slider {
                                                                                    id: sliderDimPortLeft
                                                                                    anchors.right: parent.right
                                                                                    anchors.rightMargin: 0
                                                                                    anchors.top: parent.top
                                                                                    anchors.topMargin: rectControlPortLeft.height/3 - 13
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
                                                                                width: rectControlPortLeft.width
                                                                                height: rectControlPortLeft.height/2
                                                                                color: "#9E9E9E"
                                                                                Text {
                                                                                    anchors.left: parent.left
                                                                                    anchors.leftMargin: 0
                                                                                    anchors.bottom: parent.bottom
                                                                                    anchors.bottomMargin: rectControlPortLeft.height/3 - 13
                                                                                    text: qsTr("Màu sắc")
                                                                                    color: "#F5F5F5"
                                                                                    font.pixelSize: 18
                                                                                    font.bold: true
                                                                                }
                                                                                OldCtrl.Slider {
                                                                                    anchors.right: parent.right
                                                                                    anchors.rightMargin: 0
                                                                                    anchors.bottom: parent.bottom
                                                                                    anchors.bottomMargin: rectControlPortLeft.height/3 - 13
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
                                                                Layout.preferredHeight: rectItemPortLeft.height
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
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width/2 - 10
                            Grid {
                                objectName: "sidebarView"
                                width: parent.width
                                columns: 1
                                spacing: 20
                                flow: Grid.TopToBottom
                                Repeater {
                                    model: listHubRight
                                    delegate: Column {
                                        width: parent.width
                                        Rectangle {
                                            width: parent.width
                                            height: nameHubRight.height
                                            Text {
                                                id: nameHubRight
                                                text: name
                                                font.bold: true
                                                font.pixelSize: 20
                                            }
                                        }
                                        Rectangle {
                                            id: rectItemHubRight
                                            width: parent.width
                                            height: 120
                                            color: "#FF4A4A4A"
                                            ColumnLayout {
                                                anchors.fill: parent
                                                RowLayout {
                                                    Rectangle {
                                                        color: "#FF363636"
                                                        Layout.preferredWidth: rectItemHubRight.width/4
                                                        Layout.preferredHeight: rectItemHubRight.height
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
                                                        id: rectBrightness_Color_Right
                                                        Layout.preferredWidth: (rectItemHubRight.width*3)/4 - 60
                                                        Layout.preferredHeight: rectItemHubRight.height
                                                        Column {
                                                            Rectangle {
                                                                id: rectControlRight
                                                                width: rectBrightness_Color_Right.width
                                                                height: rectBrightness_Color_Right.height
                                                                color:"#4A4A4A"
                                                                Column {
                                                                    Rectangle {
                                                                        width: rectControlRight.width
                                                                        height: rectControlRight.height/2
                                                                        color: "#4A4A4A"

                                                                        Text {
                                                                            anchors.left: parent.left
                                                                            anchors.leftMargin: 20
                                                                            anchors.top: parent.top
                                                                            anchors.topMargin: rectControlRight.height/3 - 13
                                                                            text: qsTr("Độ sáng")
                                                                            color: "#FF9B9B9B"
                                                                            font.pixelSize: 18
                                                                            font.bold: true
                                                                        }
                                                                        OldCtrl.Slider {
                                                                            id: sliderDimGroupRight
                                                                            anchors.right: parent.right
                                                                            anchors.rightMargin: 0
                                                                            anchors.top: parent.top
                                                                            anchors.topMargin: rectControlRight.height/3 - 13
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
                                                                        width: rectControlRight.width
                                                                        height: rectControlRight.height/2
                                                                        color: "#4A4A4A"
                                                                        Text {
                                                                            anchors.left: parent.left
                                                                            anchors.leftMargin: 20
                                                                            anchors.bottom: parent.bottom
                                                                            anchors.bottomMargin: rectControlRight.height/3 - 13
                                                                            text: qsTr("Màu sắc")
                                                                            color: "#FF9B9B9B"
                                                                            font.pixelSize: 18
                                                                            font.bold: true
                                                                        }
                                                                        OldCtrl.Slider {
                                                                            anchors.right: parent.right
                                                                            anchors.rightMargin: 0
                                                                            anchors.bottom: parent.bottom
                                                                            anchors.bottomMargin: rectControlRight.height/3 - 13
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
                                                        Layout.preferredHeight: rectItemHubRight.height
                                                        color: "#4A4A4A"
                                                        Image {
                                                            id: imgExpandingRight
                                                            anchors.centerIn: parent
                                                            fillMode: Image.Pad
                                                            horizontalAlignment: Image.AlignHCenter
                                                            verticalAlignment: Image.AlignVCenter
                                                            source: "qrc:/image/remctrldown.png"
                                                            smooth: true
                                                            visible: false
                                                        }
                                                        ColorOverlay {
                                                            anchors.fill: imgExpandingRight
                                                            source: imgExpandingRight
                                                            color: "#FF9B9B9B"
                                                            scale: 0.5
                                                        }
                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: rectListPortRight.visible = !rectListPortRight.visible
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        ListModel
                                        {
                                            id: listPortInHubRight

                                            Component.onCompleted:
                                            {
                                                for (var i = 0; i < JSON.parse(listport).length; i++)
                                                {
                                                    append( { id: JSON.parse(listport)[i].id } )
                                                }
                                            }
                                        }
                                        Rectangle {
                                            width: parent.width
                                            height: 10
                                            visible: rectListPortRight.visible
                                        }
                                        Rectangle {
                                            id: rectListPortRight
                                            width: parent.width
                                            visible: false
                                            height: (rowspan * 120) + (JSON.parse(listport).length * 10)
                                            Column {
                                                width: parent.width
                                                spacing: 10
                                                Repeater {
                                                    model: listPortInHubRight
                                                    delegate: Rectangle {
                                                        id: rectItemPortRight
                                                        width: parent.width
                                                        height: 120
                                                        color: "#9E9E9E"
                                                        RowLayout {
                                                            anchors.fill: parent
                                                            Rectangle {
                                                                color: "#9E9E9E"
                                                                Layout.preferredWidth: rectItemPortRight.width/4
                                                                Layout.preferredHeight: rectItemPortRight.height
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
                                                                id: rectBrightness_Port_Color_Right
                                                                Layout.preferredWidth: (rectItemPortRight.width*3)/4 - 60
                                                                Layout.preferredHeight: rectItemPortRight.height
                                                                Column {
                                                                    Rectangle {
                                                                        id: rectControlPortRight
                                                                        width: rectBrightness_Port_Color_Right.width
                                                                        height: rectBrightness_Port_Color_Right.height
                                                                        color:"#9E9E9E"
                                                                        Column {
                                                                            Rectangle {
                                                                                width: rectControlPortRight.width
                                                                                height: rectControlPortRight.height/2
                                                                                color: "#9E9E9E"

                                                                                Text {
                                                                                    anchors.left: parent.left
                                                                                    anchors.leftMargin: 0
                                                                                    anchors.top: parent.top
                                                                                    anchors.topMargin: rectControlPortRight.height/3 - 13
                                                                                    text: qsTr("Độ sáng")
                                                                                    color: "#F5F5F5"
                                                                                    font.pixelSize: 18
                                                                                    font.bold: true
                                                                                }
                                                                                OldCtrl.Slider {
                                                                                    id: sliderDimPortRight
                                                                                    anchors.right: parent.right
                                                                                    anchors.rightMargin: 0
                                                                                    anchors.top: parent.top
                                                                                    anchors.topMargin: rectControlPortRight.height/3 - 13
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
                                                                                width: rectControlPortRight.width
                                                                                height: rectControlPortRight.height/2
                                                                                color: "#9E9E9E"
                                                                                Text {
                                                                                    anchors.left: parent.left
                                                                                    anchors.leftMargin: 0
                                                                                    anchors.bottom: parent.bottom
                                                                                    anchors.bottomMargin: rectControlPortRight.height/3 - 13
                                                                                    text: qsTr("Màu sắc")
                                                                                    color: "#F5F5F5"
                                                                                    font.pixelSize: 18
                                                                                    font.bold: true
                                                                                }
                                                                                OldCtrl.Slider {
                                                                                    anchors.right: parent.right
                                                                                    anchors.rightMargin: 0
                                                                                    anchors.bottom: parent.bottom
                                                                                    anchors.bottomMargin: rectControlPortRight.height/3 - 13
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
                                                                Layout.preferredHeight: rectItemPortRight.height
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
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
