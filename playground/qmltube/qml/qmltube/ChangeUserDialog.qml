import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property variant accounts : []

    signal close()

    function getAccounts() {
        /* Retrieve the user's accounts and populate the model */

        accounts = Settings.getAllAccounts();
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

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Change Current User")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    ListView {
        id: accountsList

        anchors { fill: dialog; leftMargin: 10; rightMargin: 10; topMargin: 50; bottomMargin: 10 }
        clip: true
        interactive: visibleArea.heightRatio < 1

        model: ListModel {
            id: accountsModel

        }

        delegate: AccountDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    toggleBusy(true);
                    accountsList.currentIndex = index;
                    YouTube.login(accounts[index][0], accounts[index][1]);
                    close();
                }
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

    states: State {
        name: "show"
        AnchorChanges { target: dialog; anchors.right: parent.right }
    }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
