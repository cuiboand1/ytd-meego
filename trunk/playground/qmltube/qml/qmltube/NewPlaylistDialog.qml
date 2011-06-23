import QtQuick 1.0

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

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: title

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: qsTr("New Playlist")
    }

    Column {
        id: column

        anchors { left: dialog.left; leftMargin: 10; right: dialog.right; rightMargin: (dialog.width > dialog.height) ? 180 : 10; top: dialog.top; topMargin: 50 }
        spacing: 10

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Title")
        }

        LineEdit {
            id: titleInput

            width: column.width
            //focus: true
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Description (optional)")
        }

        LineEdit {
            id: descriptionInput

            width: column.width
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Private?")

            CheckBox {
                id: checkbox
                checked: false

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
            if (titleInput.text != "") {
                toggleBusy(true);
                YouTube.createNewPlaylist(titleInput.text, descriptionInput.text, checkbox.checked);
                close();
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
