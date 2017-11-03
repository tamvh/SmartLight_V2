import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Popup {
    id: loginPage

    width: 300
    height: 250
    x: (parent.width - width)/2
    y: (parent.height - height)/4
    closePolicy: Popup.NoAutoClose
    modal: true
    focus: true

    property bool firstLogin: false
    property int iAccClick: 0
    property int iPwdClick: 0

    onVisibleChanged: {
        if (visible) {
            idusrName.focus = idusrName.text === "" ? true : false
            idPassword.focus = idusrName.text === "" ? false : true
        }
    }

    contentItem: ColumnLayout {
        id: appOptionColumn
        Layout.alignment: Qt.AlignHCenter

        Label {
            text: "Đăng Nhập"
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
            font.pixelSize: fntsize + 4
        }

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                width: 80
                text: "Tên: "

                //    MouseArea {
                //        anchors.fill: parent
                //        onClicked: {
                //            iAccClick++;
                //            idPassword.echoMode = TextInput.Password;
                //        }
                //    }
            }

            TextField {
                id: idusrName
                width: 180
                text: mainController.getConfigUsername()
                onDisplayTextChanged: loginErrorMsg.text = ""
            }
        }

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                width: 80
                text: "Mật khẩu: "

                //    MouseArea {
                //        anchors.fill: parent
                //        onClicked: {
                //            if( iAccClick == 3 )
                //            {
                //                iPwdClick++;
                //                if( iPwdClick == 3 ) {
                //                    idPassword.echoMode = TextInput.Normal
                //                    idPassword.text = Qt.atob(mainController.getConfigUserpwd())
                //                }
                //                else {
                //                    idPassword.echoMode = TextInput.Password;
                //                }
                //            }
                //            else {
                //                iAccClick = 0;
                //                iPwdClick = 0;
                //                idPassword.echoMode = TextInput.Password;
                //            }
                //        }
                //    }
            }

            TextField {
                id: idPassword
                width: 180
                text: mainController.isDebugmode() ? Qt.atob(mainController.getConfigUserpwd()) : ""
                echoMode: TextInput.Password
                onDisplayTextChanged: loginErrorMsg.text = ""
            }
        }

        Label {
            id: loginErrorMsg
            Layout.alignment: Qt.AlignHCenter
            text: " "
        }

        Row {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "Đồng Ý"
                width: 100
                onClicked: {
                    firstLogin = true;
                    mainController.userLogin(idusrName.text, Qt.btoa(idPassword.text));
                }
            }

            Button {
                id: cancelButton
                text: "Hủy"
                width: 100
                onClicked: {
                    idPassword.echoMode = TextInput.Password
                    if (!mainController.isDebugmode()) {
                        idPassword.text = ""
                    }
                    loginErrorMsg.text = ""
                    idPageLogin.close()
                }
            }
        }
    }

    Connections {
        target: mainController
        onLogin: {
            if (err == 0) {
                if (!mainController.isDebugmode()) {
                    idPassword.text = ""
                }
                loginErrorMsg.text = ""
                idPageLogin.close()
            }
            else {
                if( firstLogin !== false ) {
                    loginErrorMsg.text = msg;
                }
            }
        }
    }
}
