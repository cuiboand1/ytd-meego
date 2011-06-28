import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal close

    function getAccounts() {
        /* Retrieve the user's accounts and populate the model */

        accountsModel.clear();
        var accounts = Settings.getAllAccounts();
        if (accounts != "unknown") {
            for (var i = 0; i < accounts.length; i++) {
                var username = accounts[i][0];
                accountsModel.append({ "username": username });
                if (username == YouTube.currentUser) {
                    accountsList.currentIndex = i;
                }
            }
        }
    }

    function deleteAccount() {
        /* Delete the account from the database and the list */

        var username = accountsModel.get(accountsList.currentIndex).username;
        var result = Settings.deleteAccount(username);
        if (result == "OK") {
            accountsModel.remove(accountsList.currentIndex);
            messages.displayMessage("Account '" + username + "' deleted");
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to delete account"));
        }
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
            onAccountSaved: getAccounts()
        }
    }

    Rectangle {
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("YouTube Accounts")
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
            id: editButton

            width: newButton.width
            icon: (cuteTubeTheme == "light") ? "ui-images/penciliconlight.png" : "ui-images/pencilicon.png"
            disabled: true
            onButtonClicked: {
                accountLoader.source = "AccountDetailsDialog.qml";
                accountLoader.item.getAccountDetails(accountsModel.get(accountsList.currentIndex).username);
                dialog.state = "showChild";
            }
        }

        PushButton {
            id: deleteButton

            width: newButton.width
            icon: (cuteTubeTheme == "light") ? "ui-images/deleteiconlight.png" : "ui-images/deleteicon.png"
            disabled: true
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

            onDelegateClicked: {
                accountsList.currentIndex = index;
                editButton.disabled = false;
                deleteButton.disabled = false;
            }
        }

        ScrollBar {}
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
