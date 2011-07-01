import QtQuick 1.0
import "scripts/settings.js" as Settings
import "scripts/createobject.js" as ObjectCreator
import "scripts/OAuth.js" as OAuth

Item {
    id: dialog

    property string site : "YouTube"
    property variant sites : ["YouTube", "Dailymotion", "vimeo"]
    property string vimeoToken
    property string vimeoSecret

    signal close
    signal dialogClose
    signal accountSaved

    property string title : qsTr("New Account")

    function getAccountDetails(username, siteName) {
        /* Retrieve the username and password */

        title = qsTr("Edit Account")
        var account = Settings.getAccount(username, siteName);
        usernameInput.text = account[0];
        checkbox.checked = (account[1] == 1);
    }

    function resetDialog() {
        /* Reset title and text input fields */

        title = qsTr("New Account");
        usernameInput.text = "";
        passwordInput.text = "";
        checkbox.checked = true;
    }

    function saveAccount(credentials) {
        /* Save the account to the database */

        closeOAuthDialog();
        busyDialog.visible = true;
        if (credentials.site == "YouTube") {
            getYouTubeSessionToken(credentials.accessToken);
        }
        else if (credentials.site == "Dailymotion") {
            getDailymotionAccessToken(credentials.authorisationCode);
        }
        else if (credentials.site == "vimeo") {
            getVimeoAccessToken(credentials.accessToken, credentials.verifier);
        }
    }

    function getYouTubeSessionToken(tempToken) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/token/i.test(response)) {
                    var sessionToken = response.split("=")[1].split(/\s|\n/)[0];
                    saveYouTubeAccount(sessionToken);
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain YouTube session token"));
                }
                busyDialog.visible = false;
            }
        }
        doc.open("GET", "https://www.google.com/accounts/AuthSubSessionToken");
        doc.setRequestHeader("Authorization", "AuthSub token=" + tempToken);
        doc.send();
    }

    function saveYouTubeAccount(sessionToken) {
        var username = usernameInput.text;
        var isDefault = 0;
        if (checkbox.checked) {
            isDefault = 1;
        }
        if (isDefault) {
            YouTube.setUserCredentials(username, sessionToken);
        }
        if (Settings.addYouTubeAccount(username, sessionToken, isDefault)) {
            messages.displayMessage(qsTr("YouTube account added"));
            accountSaved();
        }
        else {
            close();
            messages.displayMessage(qsTr("Database error - unable to save account"));
        }
    }

    function getDailymotionAccessToken(authorisationCode) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = eval("(" + doc.responseText + ")");
                if (response.access_token) {
                    var accessToken = response.access_token;
                    var refreshToken = response.refresh_token;
                    var date = new Date();
                    var tokenExpiry = date.valueOf() + parseInt(response.expires_in);
                    saveDailymotionAccount(accessToken, refreshToken, tokenExpiry);
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain Dailymotion access token"));
                }
                busyDialog.visible = false;
            }
        }
        var data = "grant_type=authorization_code" +
            "&client_id=" + DailyMotion.clientId +
            "&client_secret=" + DailyMotion.clientSecret +
            "&redirect_uri=http://cutetube.com" +
            "&code=" + authorisationCode;
        doc.open("POST", "https://api.dailymotion.com/oauth/token");
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.send(data);
    }

    function saveDailymotionAccount(accessToken, refreshToken, tokenExpiry) {
        var username = usernameInput.text;
        var isDefault = 0;
        if (checkbox.checked) {
            isDefault = 1;
        }
        if (isDefault) {
            DailyMotion.setUserCredentials(username, accessToken, refreshToken, tokenExpiry);
        }
        if (Settings.addDailymotionAccount(username, accessToken, refreshToken, tokenExpiry, isDefault)) {
            messages.displayMessage(qsTr("Dailymotion account added"));
            accountSaved();
        }
        else {
            close();
            messages.displayMessage(qsTr("Database error - unable to save account"));
        }
    }

    function getVimeoRequestToken() {
        busyDialog.visible = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('=');
                    vimeoToken = tSplit[1].split('&')[0];
                    vimeoSecret = tSplit[2].split('&')[0];
                    showOAuthDialog();
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain vimeo request token"));
                }
                busyDialog.visible = false;
            }
        }
        var credentials = { "callback": "oob" };
        var oauthData = OAuth.createOAuthHeader("GET", "http://vimeo.com/oauth/request_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    function getVimeoAccessToken(token, verifier) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('=');
                    var token = tSplit[1].split('&')[0];
                    var secret = tSplit[2].replace(/\s|\n/, '');
                    saveVimeoAccount(token, secret);
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain vimeo access token"));
                }
                busyDialog.visible = false;
            }
        }
        var credentials = { "token": token, "secret": vimeoSecret, "verifier": verifier };
        var oauthData = OAuth.createOAuthHeader("GET", "http://vimeo.com/oauth/access_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    function saveVimeoAccount(token, secret) {
        var username = usernameInput.text;
        var isDefault = 0;
        if (checkbox.checked) {
            isDefault = 1;
        }
        if (isDefault) {
            Vimeo.setUserCredentials(username, token, secret);
        }
        if (Settings.addVimeoAccount(username, token, secret, isDefault)) {
            messages.displayMessage(qsTr("Vimeo account added"));
            accountSaved();
        }
        else {
            close();
            messages.displayMessage(qsTr("Database error - unable to save account"));
        }
    }

    function showOAuthDialog() {
        oauthLoader.opacity = 0;
        var oauthDialog = ObjectCreator.createObject("OAuthDialog.qml", dialog);
        oauthDialog.setService(site);
        oauthDialog.authorised.connect(saveAccount);
        oauthDialog.close.connect(closeOAuthDialog);
        dialog.state = "showChild";
    }

    function closeOAuthDialog() {
        dialog.state = "show";
        dialogClose();
    }

    function showSiteList() {
        oauthLoader.opacity = 1;
        oauthLoader.source = "SettingsListDialog.qml";
        oauthLoader.item.setSettingsList(qsTr("Choose Site"), sites, site);
        oauthLoader.item.settingChosen.connect(setSite);
        dialog.state = "showChild";
    }

    function setSite(siteName) {
        site = siteName;
    }

    anchors.fill: parent

    Loader {
        id: oauthLoader

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

        Connections {
            target: oauthLoader.item
            onClose: dialog.state = "show"
        }
    }

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: title
    }

    Column {
        id: column

        anchors { left: dialog.left; leftMargin: 10; right: dialog.right; rightMargin: (dialog.width > dialog.height) ? 180 : 10; top: dialog.top; topMargin: 50 }
        spacing: 10
        opacity: busyDialog.visible ? 0.5 : 1

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Site")
        }

        Text {
            id: siteText

            width: column.width
            font.pixelSize: _STANDARD_FONT_SIZE
            color: siteMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
            text: site
            smooth: true

            MouseArea {
                id: siteMouseArea

                anchors.fill: parent
                onClicked: showSiteList()
            }
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Username")
        }

        LineEdit {
            id: usernameInput

            width: column.width
            Keys.onEnterPressed: {
                if (!(usernameInput.text == "")) {
                    if (site == "vimeo") {
                        getVimeoRequestToken();
                    }
                    else {
                        showOAuthDialog();
                    }
                }
            }
            Keys.onReturnPressed: {
                if (!(usernameInput.text == "")) {
                    if (site == "vimeo") {
                        getVimeoRequestToken();
                    }
                    else {
                        showOAuthDialog();
                    }
                }
            }
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Default?")

            CheckBox {
                id: checkbox

                anchors { left: parent.right; leftMargin: 10 }
            }
        }
    }

    PushButton {
        id: saveButton

        width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
        disabled: busyDialog.visible
        onButtonClicked: {
            if (!(usernameInput.text == "")) {
                if (site == "vimeo") {
                    getVimeoRequestToken();
                }
                else {
                    showOAuthDialog();
                }
            }
        }
    }

    CloseButton {
        onButtonClicked: close()
    }

    BusyDialog {
        id: busyDialog

        anchors.centerIn: dialog
        message: qsTr("Saving")
        visible: false
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

    states: [
        State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        },

        State {
            name: "showChild"
            AnchorChanges { target: dialog.parent; anchors { right: dialog.parent.parent.right } }
        }
    ]

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
