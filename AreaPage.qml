import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQml.Models 2.1

Page {
    property int itemHeight: 60

    Connections {
        target: mainController

        onRefreshRoomList: {
            listmodelAreas.clear();

            var count = 0;
            var rooms = JSON.parse(listRoom);
            for (var room in rooms.dt) {
                listmodelAreas.append({ areaid: rooms.dt[room].area_id,
                                          areaname: rooms.dt[room].name,
                                          roomid: rooms.dt[room].id,
                                          idx: count});
                count++;
            }
        }

        onRefreshAreaList2: {
            var count = listmodelAreas.count;

            var areas = JSON.parse(listArea);
            for (var area in areas.dt.areas) {
                listmodelAreas.append({ areaid: areas.dt.areas[area].area_id,
                                          areaname: areas.dt.areas[area].area_name,
                                          roomid: (100+count),
                                          idx: count})
                count++;
            }
        }

    }

    ListModel {
        id: listmodelAreas
    }

    Component {
        id: componentAreas

        MouseArea {
            id: dragArea
            anchors { left: parent.left; right: parent.right; }
            height: content.height

            onClicked: {
                officeRoom = areaname
                mainController.setConfigRoomArea(roomid, areaid, officeRoom)
                if( stackView.depth > 1 )
                {
                    // cập nhật cho LightControl-Page
                    //??? mainController.callGetLightsOnArea();
                }
                stackView.pop();
            }

            Rectangle {
                id: content
                anchors { left: parent.left; right: parent.right }
                width: parent.width
                height: itemHeight
                border.color: "lightsteelblue"
                border.width: 1
                radius: 5

                Row {
                    anchors.fill:parent
                    spacing: 5
                    anchors.margins: 5
                    width: parent.width
                    height: parent.height

                    Text {
                        text: "   room-id :  " + roomid
                        width: 150
                        verticalAlignment: Qt.AlignVCenter
                        height: parent.height
                    }
                    Text {
                        text: "   area-id :  " + areaid;
                        width: 150
                        verticalAlignment: Qt.AlignVCenter
                        height: parent.height
                    }
                    Text {
                        text: "   " + areaname;
                        width: parent.width - 100
                        verticalAlignment: Qt.AlignVCenter
                        height: parent.height
                    }
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

            Column {
                id: column
                width: parent.width
                spacing: 20

                RowLayout {
                    width: parent.width
                    height: 50
                    spacing: 20

                    Button {
                        height: parent.height
                        text: "Thoát"
                        onClicked: mainController.appQuit()
                    }

                    Label {
                        Layout.fillWidth: true
                        height: parent.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignHCenter
                        font.pointSize: 18
                        text: "Build date: " + mainController.appBuildDate() + "   "
                    }
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right }
                    width: parent.width
                    height: itemHeight
                    color: idWindows.color

                    CheckBox {
                        text: "Cho phép điều khiển đèn ngoài giờ họp"
                        font.pointSize: 18
                        checked: mainController.getConfigAllowLightControl()
                        onCheckedChanged: {
                            mainController.setConfigAllowLightControl(checked)
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#f99014"
                }

                Label {
                    width: parent.width
                    text: "Chọn phòng họp"
                    font.pointSize: 20
                }

                ListView {
                    id: listviewAreas
                    width: parent.width
                    height: contentHeight
                    model: listmodelAreas
                    spacing: 2
                    delegate: componentAreas
                }
            }
        }
    }
}
