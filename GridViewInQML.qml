import QtQuick 2.0
import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
Item {
    ListModel {
        id: panelsModel
        ListElement {
            name: "P1.qml lightpink"
            rowspan: 2
            ecolor: "lightpink"
            h:200
        }
        ListElement {
            name: "P2.qml lightgreen"
            rowspan: 2
            ecolor: "lightgreen"
            h:100
        }
        ListElement {
            name: "P2.qml orange"
            rowspan: 2
            ecolor: "orange"
            h:100
        }
        ListElement {
            name: "P2.qml yellow"
            rowspan: 2
            ecolor: "yellow"
            h:100
        }
        ListElement {
            name: "P2.qml gray"
            rowspan: 2
            ecolor: "gray"
            h:100
        }
    }


    Rectangle {
        id: container
        width: parent.width
        height: parent.height
        Component {
            id: idDelegate
            Rectangle {
                height: h
                width: container.width/2
                color: ecolor
                Text {
                    anchors.centerIn: parent
                    text: name
                }
            }
        }
        GridView {
            id: grid
            width: parent.width;
            height: parent.height;
            cellWidth: container.width/2
//            cellHeight: parent.height
            model: panelsModel
            delegate: idDelegate
        }
    }
}
