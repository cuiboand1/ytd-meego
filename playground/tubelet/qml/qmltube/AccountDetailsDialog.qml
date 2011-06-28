import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal close
    signal accountSaved

    property string title : qsTr("New Account")

    function getAccountDetails(username) {
        /* Retrieve the username and password */

        title = qsTr("Edit Account")
        var account = Settings.getAccount(username);
        usernameInput.text = account[0];
        passwordInput.text = account[1];
        checkbox.checked = (account[2] == 1);
    }

    function resetDialog() {
        /* Reset title and text input fields */

        if (dialog.opacity == 0) {
            title = qsTr("New Account");
            usernameInput.text = "";
            passwordInput.text = "";
            checkbox.checked = true;
        }
    }

    function saveAccount() {
        /* Save the account to the database and sign in to YouTube */

        var isDefault = checkbox.checked ? 1 : 0;
        var username = usernameInput.text;
        var password = passwordInput.text;
        var result = Settings.addOrEditAccount(username, password, isDefault);
        if (result == "OK") {
            toggleBusy(true);
            YouTube.login(username, password);
            accountSaved();
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to save account"));
        }
        dialog.opacity = 0;
        close();
    }

    anchors.fill: parent

    onOpacityChanged: resetDialog()

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

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Username")
        }

        LineEdit {
            id: usernameInput

            width: column.width
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Password")
        }

        LineEdit {
            id: passwordInput

            width: column.width
            echoMode: TextInput.Password
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
        onButtonClicked: {
            if (usernameInput.text != "" && passwordInput.text != "") {
                saveAccount();
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
}
