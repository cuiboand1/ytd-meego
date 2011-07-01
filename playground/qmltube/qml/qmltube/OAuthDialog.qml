import QtQuick 1.0
import QtWebKit 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property string title : qsTr("Authorisation For ") + dialog.service
    property string service
    property variant urls

    signal authorised(variant credentials)
    signal close

    function setService(site) {
        service = site;
        if (site == "vimeo") {
            webView.url = "http://vimeo.com/oauth/authorize?oauth_token=" + dialog.parent.vimeoToken + "&permission=delete";
        }
        else {
            webView.url = urls[site];
        }
    }

    function checkUrlForToken() {
        if (service == "Facebook") {
            checkFacebookToken();
        }
        else if (service == "YouTube") {
            checkYouTubeToken();
        }
        else if (service == "Dailymotion") {
            checkDailymotionToken();
        }
        else if (service == "vimeo") {
            checkVimeoToken();
        }
    }

    function checkFacebookToken() {
        var url = webView.url.toString();
        if (url.split("=")[0] == "http://www.facebook.com/connect/login_success.html#access_token") {
            var facebookToken = url.split("=")[1].split("&")[0];
            if ((facebookToken != "") && (Settings.saveAccessToken("Facebook", facebookToken, ""))) {
                authorised();
            }
            else {
                messages.displayMessage(qsTr("Error obtaining facebook authorisation"));
            }
        }
    }

    function checkYouTubeToken() {
        var url = webView.url.toString();
        if (/token=/i.test(url)) {
            var token = url.split("=").pop().replace(/\s|\n/, '');
            var credentials = { "site": "YouTube", "accessToken": token };
            authorised(credentials);
        }
    }

    function checkDailymotionToken() {
        var url = webView.url.toString();
        if (/code=/i.test(url)) {
            var code = url.split("code=")[1].split("&")[0];
            var credentials = { "site": "Dailymotion", "authorisationCode": code };
            authorised(credentials);
        }
    }

    function checkVimeoToken() {
        var url = webView.url.toString();
        if (/oauth_verifier=/i.test(url)) {
            var accessToken = url.split("oauth_token=")[1].split("&")[0];
            var verifier = url.split("oauth_verifier=")[1].replace(/\s|\n/, '');
            var credentials = { "site": "vimeo", "accessToken": accessToken, "verifier": verifier };
            authorised(credentials);
        }
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }
    Component.onCompleted: {
        urls = { "Facebook": "https://graph.facebook.com/oauth/authorize?"
                + "client_id=" + Sharing.facebookId
                + "&redirect_uri=http://www.facebook.com/connect/login_success.html"
                + "&type=user_agent&display=popup&scope=publish_stream,offline_access",

                "Dailymotion": "https://api.dailymotion.com/oauth/authorize?response_type=code&"
                + "client_id=" + DailyMotion.clientId + "&redirect_uri=http://cutetube.com&scope=read+write+delete",

                "YouTube": "https://www.google.com/accounts/AuthSubRequest?next=http://www.cutetube.com&scope=http://gdata.youtube.com&session=1&secure=0"
    }
    }

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Rectangle {
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: title
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Flickable {
        id: webFlicker

        anchors { fill: dialog; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: pinGrid.visible ? 60 : 10 }
        contentWidth: webView.width
        contentHeight: webView.height
        boundsBehavior: Flickable.DragOverBounds
        clip: true

        WebView {
            id: webView

            width: 1000
            height: 1000
            preferredWidth: parent.width - 20
            preferredHeight: parent.height - 60
            opacity:(webView.progress == 1) ? 1 : 0
            onUrlChanged: checkUrlForToken()

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
    }

    BusyDialog {
        id: busyDialog

        anchors.centerIn: dialog
        opacity: (webView.progress < 1) ? 1 : 0
    }

    Grid {
        id: pinGrid

        anchors { left: dialog.left; right: dialog.right; bottom: dialog.bottom; margins: 10 }
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
                color: (pinInput.text == qsTr("Enter pin code")) ? "grey" : "black"
                text: qsTr("Enter pin code")
            }
        }

        ToolButton {
            id: confirmButton

            icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
            //                onButtonClicked: {}
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
