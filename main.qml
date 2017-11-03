import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.0
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import MainController 1.0

ApplicationWindow {
    id: idWindows
    visible: true
    width: 1024
    height: 600
//    visibility: Qt.Window
    visibility: mainController.isDebugmode() ? Qt.Window : Window.FullScreen
    flags: mainController.isDebugmode() ? Qt.Window : Qt.FramelessWindowHint | Qt.Window
    title: qsTr("VNG Smart Light")

    property string mainViewBorderColor: "#606060"
    property int borderWidth: (width/60)
    property int fntsize: 14
    property bool timerswitch: true
    property int openLoginform: 0
    property string officeRoom: mainController.getConfigRoomname()
    property int iTitleClick: 0
    property int iDateClick: 0
    property int iLoginFrom: 0

    // global variable
    property int iAreaId: 0                     // area-id
    property int iLightGroupOnOff: 0            // trạng thái on/off đèn tổng
    property int iControlEnable: 0              // trạng thái điều khiển đèn (1: allow, 0: not-allow phụ thuộc vào giờ phòng họp)
    property int iLightBrightness: 0            // độ sáng tổng
    property string strLightBrightness: ""      // độ sáng tổng
    property string strLights: ""              // tổng số bóng đèn
    property int strLightOn: 0             // số bóng đèn sáng
    property int strLightOff: 0            // số bóng đèn tắt
    property int iTimeoutType: 0
    property int iPageLightShow: 0

    header: ToolBar {
        Rectangle {
            anchors.fill: parent
            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0)
                end: Qt.point(parent.width, parent.height)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#606060" }
                    GradientStop { position: 1.0; color: "#acacac" }
                }

                RowLayout {
                    anchors.fill: parent

                    FontLoader {
                        id: idFont
                        source: "qrc:/fonts/UnisectVnuBold.ttf"
                        name: "UnisectVnu"
                    }

                    Rectangle {
                        width: 20
                        height: 0
                        color: "#606060"
                    }

                    ToolButton {
                        id: toolButtonBack
                        visible: false

                        contentItem: Image {
                            fillMode: Image.Pad
                            horizontalAlignment: Image.AlignHCenter
                            verticalAlignment: Image.AlignVCenter
                            source: "qrc:/image/imgback.svg"
                        }
                        onClicked: {
                            iPageLightShow = 0;
                            stackView.pop()
                        }
                    }

                    Label {
                        id: titleLabel
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        width: contentWidth
                        height: parent.height
                        color: "white"
                        font.pixelSize: 20
                        text: officeRoom

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if( iDateClick > 1 )
                                {
                                    iTitleClick++;

                                    if( iTitleClick > 1 )
                                    {
                                        iTitleClick = 0;
                                        iDateClick = 0;
                                        stackView.push(idPageArea)
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        id: titleDate
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        width: contentWidth
                        height: parent.height
                        color: "white"
                        font.pixelSize: 20

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                iDateClick++;
                            }
                        }

                        Timer  {
                            id: elapsedTimer
                            interval: 1000;
                            running: true;
                            repeat: true;
                            onTriggered: {
                                var date = new Date();

                                if( timerswitch === true ) {
                                    titleDate.text = date.toLocaleDateString() + " - " + date.getHours() + ":" + ("0"+date.getMinutes()).slice(-2)
                                }
                                else {
                                    titleDate.text = date.toLocaleDateString() + " - " + date.getHours() + " " + ("0"+date.getMinutes()).slice(-2)
                                }

                                timerswitch = !timerswitch;
                            }
                        }
                    }

                    Rectangle {
                        width: 20
                        height: 0
                        color: "#acacac"
                    }
                }
            }
        }
    }
    ListModel {
        id: listmodelLights
    }
    MainController {
        id: mainController
    }

    AreaPage {
        id: idPageArea
    }

    Lightonareas {
        id: idPageLightOnArea
    }

    LightHubOnArea {
        id: idPageLightHubOnArea
    }

    GridViewInQML {
        id: idGridViewInQML
    }

    RemoteCtrller {
        id: idPageRemoteCtrller
    }

    LoginPage {
        id: idPageLogin
    }

    BlankPage {
        // KHÔNG ĐƯỢC XÓA BỎ DÒNG CODE NÀY
        // TRANG FIX LỖI AreaPage, Lightonareas page tác động bởi mouse click ...
        id: iPageBlank
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: MainView {
            onVisibleChanged: {
                toolButtonBack.visible = !visible

                mainController.getLightsStatus()

//                if( visible ) {
//                    // call to update light-info to main view
//                    mainController.callGetLightsOnArea()
//                }
            }
        }
    }

    Popup {
        id: dialogAlert
        modal: true
        focus: true
        x: (idWindows.width - width) / 2
        y: Math.abs(idWindows.height - dialogAlert.height) / 3
        closePolicy: Popup.NoAutoClose
        topPadding: borderWidth
        leftPadding: borderWidth
        rightPadding: borderWidth

        Material.accent: "#f99014"

        Column {
            id: billAlertColumn
            width: implicitWidth
            height: implicitHeight

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: borderWidth
                width: implicitWidth
                height: implicitHeight

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: fntsize + 4
                    font.weight: Font.DemiBold
                    text: (iTimeoutType ? "HẾT" : "NGOÀI") + " THỜI GIAN HỌP"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: childrenRect.width + 2
                    height: childrenRect.height + 2
                    Image {
                        x: 1
                        y: 1
                        width: 120
                        height: 120
                        source: "qrc:/image/timeout.png"
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (iTimeoutType ? "Đã hết" : "Ngoài") + " thời gian họp, xin lỗi bạn không thể điều khiển thiết bị"
                    font.pointSize: fntsize
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: implicitWidth
                    spacing: 5
                    Label {
                        id: labelTimerBillAlert
                        text: "Thời gian còn lại:   "
                        font.pointSize: fntsize
                    }

                    QrTimer {
                        id: getBillTimer
                        anchors.left: labelTimerBillAlert.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: billAlertColumn.width
                    height: 70
                    highlighted: true
                    font.pointSize: fntsize+4
                    text: "Đóng"
                    onClicked: {
                        dialogAlert.close()
                    }
                }
            }
        }

        onOpened: {
            getBillTimer.restartTimerCounter();
        }

        onClosed: {
            getBillTimer.stopTimerCounter();

            iPageLightShow = 0;
            while( stackView.depth > 1 ) {
                stackView.pop();
            }
        }
    }

    Component.onCompleted:
    {
        // app must choosen room for 1st time setup
        if( mainController.getConfigRoomid() < 0 ) {
            stackView.push(idPageArea)
        }
    }

    Timer  {
        id: elapsedTimerMeetingroom
        interval: 5000;
        running: true;
        repeat: true;
        onTriggered: {
            mainController.callMeetingRoom(-1)
        }
    }

    Connections {
        target: mainController

        onLogin: {
            if( (err !== 0) && (openLoginform === 0) )
            {
                openLoginform++;
                idPageLogin.open();
            }
        }

        onRefreshRoomname: {
            console.log("room name=" + name)
            officeRoom = name;
        }        

        onRefreshMettingRoomStatus: {
            if( (status === 0) &&
                ((iControlEnable === 1) ||
                 (mainController.getConfigAllowLightControl() === false)) )
            {
                if( (stackView.depth > 1) && (iPageLightShow === 1) ) {
                    iTimeoutType = 1;
                    dialogAlert.open();
                }
            }

            iControlEnable = (status == 1 ? 1 : 0)
        }
    }
}
