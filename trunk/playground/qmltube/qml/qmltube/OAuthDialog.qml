import QtQuick 1.0
import QtWebKit 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property string title : qsTr("Authorisation For ") + dialog.service
    property string service

    signal authorised
    signal close

    function setService(site) {
        dialog.service = site;
    }

    function checkUrlForToken() {
        var url = webView.url.toString();
        if (url.split("=")[0] == "http://www.facebook.com/connect/login_success.html#access_token") {
            var facebookToken = url.split("=")[1].split("&")[0];
            if ((facebookToken != "") && (Settings.saveAccessToken("Facebook", facebookToken, ""))) {
                background.opacity = 0;
                authorised();
            }
            else {
                messages.displayMessage(qsTr("Error obtaining facebook authorisation"));
            }
        }
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Item {
        id: background

        anchors.fill: dialog

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Rectangle {
            anchors.fill: background
            color: _BACKGROUND_COLOR
            opacity: 0.5
        }

        Text {
            id: titleText

            anchors { horizontalCenter: background.horizontalCenter; top: background.top; topMargin: 10 }
            text: title
            font.pixelSize: _SMALL_FONT_SIZE
            color: _TEXT_COLOR
        }

        WebView {
            id: webView

            anchors { fill: background; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: pinGrid.visible ? 60 : 10 }
            preferredWidth: dialog.width - 20
            preferredHeight: dialog.height - (60 + pinGrid.height)
            url: "https://graph.facebook.com/oauth/authorize?"
                 + "client_id=" + Sharing.getFacebookId() + "&"
                 + "redirect_uri=http://www.facebook.com/connect/login_success.html&"
                 + "type=user_agent&display=popup&scope=publish_stream,offline_access"

            opacity:(webView.progress == 1) ? 1 : 0
            //focus: true
            onUrlChanged: checkUrlForToken()

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }

        BusyDialog {
            id: busyDialog

            anchors.centerIn: background
            opacity: (webView.progress < 1) ? 1 : 0
        }

        Grid {
            id: pinGrid

            anchors { left: background.left; right: background.right; bottom: background.bottom; margins: 10 }
            columns: 2
            spacing: 10
            visible: dialog.service == "Twitter"

            Rectangle {
                id: pinRect

                height: 40
                width: 530
                color:  "white"
                border.width: 2
                border.color: _ACTIVE_COLOR_LOW
                radius: 5

                TextInput {
                    id: pinInput

                    anchors { fill: parent; margins: 2 }
                    font.pixelSize: _STANDARD_FONT_SIZE
                    selectByMouse: true
                    selectionColor: _ACTIVE_COLOR_LOW
                    color: (pinInput.text == "Enter pin code") ? "grey" : "black"
                    text: qsTr("Enter pin code")
                }
            }

            ToolButton {
                id: confirmButton

                icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
                //                onButtonClicked: {}
            }
        }
    }

    CloseButton {
        onButtonClicked: close()
    }

    MouseArea {

        property real xPos

        z: -1
        anchors.fill: dialog
        onPressed: xPos = mouseX
        onReleased: {
            if (xPos - mouseX > 100) {
                close();
            }
        }
    }

    states: State {
        name: "show"
        AnchorChanges { target: dialog; anchors.right: parent.right }
    }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
