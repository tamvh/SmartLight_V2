import QtQuick 2.4
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
Component {
    Pane {
        id: appContainer
        ListModel {
            id: panelsModel
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
            id: panelsModel1
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
                                spacing: 10
                                flow: Grid.TopToBottom
                                Repeater {
                                    model: panelsModel
                                    delegate: Column {
                                        width: parent.width -5
                                        Rectangle {
                                            width: parent.width
                                            color: ecolor
                                            height: 50
                                            Text {
                                                anchors.centerIn: parent
                                                text: name
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: listBox.visible = !listBox.visible
                                            }
                                        }
                                        ListModel
                                        {
                                            id: listModel

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
                                            id: listBox
                                            color: "gray"
                                            width: parent.width
                                            visible: false
                                            height: rowspan * 50
                                            Column {
                                                width: parent.width
                                                Repeater {
                                                    model: listModel
                                                    delegate: Rectangle {
                                                        width: parent.width
                                                        color: index % 2 ? "#C9D6DE" : "#E7F6FF"
                                                        height: 50
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: id
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
                                spacing: 10
                                flow: Grid.TopToBottom
                                Repeater {
                                    model: panelsModel1
                                    delegate: Column {
                                        width: parent.width -5
                                        Rectangle {
                                            width: parent.width
                                            color: ecolor
                                            height: 50
                                            Text {
                                                anchors.centerIn: parent
                                                text: name
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: listBox1.visible = !listBox1.visible
                                            }
                                        }
                                        ListModel
                                        {
                                            id: listModel1

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
                                            id: listBox1
                                            color: "gray"
                                            width: parent.width
                                            visible: false
                                            height: rowspan * 50
                                            Column {
                                                width: parent.width
                                                Repeater {
                                                    model: listModel1
                                                    delegate: Rectangle {
                                                        width: parent.width
                                                        color: index % 2 ? "#C9D6DE" : "#E7F6FF"
                                                        height: 50
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: id
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
