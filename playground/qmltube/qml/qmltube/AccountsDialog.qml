import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal close

    function getAccounts() {
        /* Retrieve the user's accounts and populate the model */

        accountsModel.clear();
        var sites = ["YouTube", "Dailymotion", "vimeo"];
        var accounts = [];
        var acc = [];
        for (var i = 0; i < sites.length; i++) {
            acc = Settings.getAllAccounts(sites[i]);
            if (acc.length > 0) {
                for (var ii = 0; ii < acc.length; ii++) {
                    accounts.push(acc[ii]);
                }
            }
        }
        for (var i = 0; i < accounts.length; i++) {
            var username = accounts[i].username;
            var site = accounts[i].site;
            var accessToken = accounts[i].accessToken
            accountsModel.append({ "username": username, "site": site, "accessToken": accessToken });
        }
        accountsList.currentIndex = -1;
    }

    function deleteAccount() {
        /* Delete the account from the database and revoke access */

        var account = accountsModel.get(accountsList.currentIndex);
        var username = account.username;
        var site = account.site;
        var accessToken = account.accessToken;
        if (Settings.deleteAccount(username, site)) {
            accountsModel.remove(accountsList.currentIndex);
            if (site == "YouTube") {
                revokeYouTubeAccess(accessToken);
                YouTube.setUserCredentials("", "");
            }
            else if (site == "Dailymotion") {
                revokeDailymotionAccess(accessToken);
                DailyMotion.setUserCredentials("", "", "", 0);
            }
            else if (site == "vimeo") {
                messages.displayMessage(qsTr("Vimeo account deleted. Visit vimeo website to revoke access"));
                Vimeo.setUserCredentials("", "", "");
            }
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to delete account"));
        }
    }

    function revokeYouTubeAccess(accessToken) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.status;
                if (response == 200) {
                    messages.displayMessage(qsTr("Access to your YouTube account has been revoked"));
                }
                else {
                    messages.displayMessage(qsTr("Unable to revoke access to your YouTube account"));
                }
            }
        }
        doc.open("GET", "https://www.google.com/accounts/AuthSubRevokeToken");
        doc.setRequestHeader("Authorization", "AuthSub token=" + accessToken);
        doc.send();
    }

    function revokeDailymotionAccess(accessToken) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var response = doc.status;
                if (response == 200) {
                    messages.displayMessage(qsTr("Access to your Dailymotion account has been revoked"));
                }
                else {
                    messages.displayMessage(qsTr("Unable to revoke access to your Dailymotion account"));
                }
            }
        }
        doc.open("GET", "https://api.dailymotion.com/logout");
        doc.setRequestHeader("Authorization", "OAuth " + accessToken);
        doc.send();
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Component.onCompleted: getAccounts()

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Loader {
        id: accountLoader

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

        Connections {
            target: accountLoader.item
            onClose: dialog.state = "show"
            onAccountSaved: {
                dialog.state = "show"
                getAccounts();
            }
        }
    }

    Rectangle {
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Accounts")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Column {
        id: buttonColumn

        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        spacing: 10

        PushButton {
            id: newButton

            width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
            icon: (cuteTubeTheme == "light") ? "ui-images/addiconlight.png" : "ui-images/addicon.png"
            onButtonClicked: {
                accountLoader.source = "AccountDetailsDialog.qml";
                dialog.state = "showChild";
            }
        }

        PushButton {
            id: deleteButton

            width: newButton.width
            icon: (cuteTubeTheme == "light") ? "ui-images/deleteiconlight.png" : "ui-images/deleteicon.png"
            disabled: (accountsList.count == 0) || (accountsList.currentIndex < 0)
            onButtonClicked: deleteAccount()
        }
    }

    ListView {
        id: accountsList

        anchors { fill: dialog; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10;
            topMargin: 50; bottomMargin: (dialog.width > dialog.height) ? 10 : 260 }
        clip: true
        interactive: visibleArea.heightRatio < 1

        model: ListModel {
            id: accountsModel
        }

        delegate: AccountDelegate {
            id: delegate

            onDelegateClicked: accountsList.currentIndex = index
        }

        ScrollBar {}
    }

    Text {
        anchors.centerIn: dialog
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No accounts found")
        visible: accountsList.count == 0
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

    states: [
        State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        },

        State {
            name: "showChild"
            AnchorChanges { target: dialog; anchors { left: parent.right; right: undefined } }
        }
    ]

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
