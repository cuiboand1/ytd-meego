import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal close

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

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
            onAccountSaved: close()
        }
    }

    Item {
        id: background

        anchors.fill: dialog

        Rectangle {
            anchors.fill: background
            color: _BACKGROUND_COLOR
            opacity: 0.5
        }

        Image {
            id: icon

            width: 120
            height: 120
            anchors { top: background.top; left: background.left; margins: 10 }
            smooth: true
            source: (cuteTubeTheme == "nightred") ? "ui-images/cutetubered.png" : "ui-images/cutetubehires.png"

            Text {
                id: title

                anchors { bottom: icon.bottom; left: icon.right; margins: 10 }
                color: _TEXT_COLOR
                font { pixelSize: 48; bold: true }
                text: qsTr("Hi there!")
            }
        }

        Text {
            id: description

            anchors { fill: background; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10; topMargin: 140; bottomMargin: 10 }
            color: _TEXT_COLOR
            font.pixelSize: _STANDARD_FONT_SIZE
            wrapMode: TextEdit.WordWrap
            text: qsTr("My name's Cutey. My buddy Clippy tells me it's the first time you've used cuteTube. Would you like to add a YouTube account?")
        }

        Column {
            anchors { right: background.right; bottom: background.bottom; margins: 10 }
            spacing: 10

            PushButton {
                id: yesButton

                width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
                showIcon: false
                showText: true
                name: qsTr("Yes")
                onButtonClicked: {
                    Settings.setSetting("noAccountDialog", "raised");
                    accountLoader.source = "AccountDetailsDialog.qml";
                    dialog.state = "showChild";
                }
            }

            PushButton {
                id: noButton

                width: yesButton.width
                showIcon: false
                showText: true
                name: qsTr("Go Away")
                onButtonClicked: {
                    Settings.setSetting("noAccountDialog", "raised");
                    close();
                }
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
