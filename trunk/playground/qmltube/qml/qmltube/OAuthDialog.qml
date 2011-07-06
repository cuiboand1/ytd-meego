import QtQuick 1.0
import QtWebKit 1.0
import "scripts/settings.js" as Settings
import "scripts/OAuth.js" as OAuth

Item {
    id: dialog

    property string title : qsTr("Authorisation For ") + dialog.service
    property string service
    property variant urls
    property string twitterToken
    property string twitterSecret

    signal authorised(variant credentials)
    signal close

    function setService(site) {
        service = site;
        if (site == "vimeo") {
            webView.url = "http://vimeo.com/oauth/authorize?oauth_token=" + dialog.parent.vimeoToken + "&permission=delete";
        }
        if (site == "Twitter") {
            getTwitterRequestToken();
        }
        else {
            webView.url = urls[site];
        }
    }

    function checkUrlForToken() {
        if (service == "Facebook") {
            checkFacebookToken();
        }
        else if (service == "Twitter") {
            checkTwitterToken();
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
            if (!(facebookToken == "") && (Settings.saveAccessToken("Facebook", facebookToken, ""))) {
                authorised("");
            }
            else {
                messages.displayMessage(qsTr("Error obtaining facebook authorisation"));
            }
        }
    }

    function checkTwitterToken() {
        var url = webView.url.toString();
        if (/oauth_verifier=/.test(url)) {
            var twitterVerifier = url.split("=")[2].split("&")[0];
            console.log(twitterVerifier)
            getTwitterAccessToken(twitterVerifier);
        }
        else if (/error/.test(url)) {
            messages.displayMessage(qsTr("Error obtaining twitter authorisation"));
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

    function getTwitterRequestToken() {
        busyDialog.show = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('=');
                    twitterToken = tSplit[1].split('&')[0];
                    twitterSecret = tSplit[2].split('&')[0];
                    webView.url = urls["Twitter"] + twitterToken;
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain twitter request token"));
                }
                busyDialog.show = false;
            }
        }
        var credentials = { "callback": "http://cutetube.com" };
        var oauthData = OAuth.createOAuthHeader("twitter", "GET", "http://api.twitter.com/oauth/request_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    function getTwitterAccessToken(verifier) {
        busyDialog.show = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.responseText;
//                console.log(response)
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('=');
                    var token = tSplit[1].split('&')[0];
                    var secret = tSplit[2].split('&')[0];
                    Settings.saveAccessToken("Twitter", token, secret);
                    authorised("");
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain twitter access token"));
                }
                busyDialog.show = false;
            }
        }
        var credentials = { "token": twitterToken, "secret": twitterSecret, "verifier": verifier };
        var oauthData = OAuth.createOAuthHeader("twitter", "GET", "http://api.twitter.com/oauth/access_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
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

                "YouTube": "https://www.google.com/accounts/AuthSubRequest?next=http://www.cutetube.com&scope=http://gdata.youtube.com&session=1&secure=0",

                "Twitter": "http://api.twitter.com/oauth/authorize?oauth_token="
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

        anchors { fill: dialog; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
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
            opacity:(webView.progress < 1) ? 0 : 1
            onUrlChanged: {
//                console.log(webView.url.toString());
                checkUrlForToken();
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
    }

    BusyDialog {
        id: busyDialog

        property bool show : false

        anchors.centerIn: dialog
        opacity: (busyDialog.show) || (webView.progress < 1) ? 1 : 0
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
