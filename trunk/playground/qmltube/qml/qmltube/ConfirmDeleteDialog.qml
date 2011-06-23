import QtQuick 1.0

Item {
    id: dialog

    signal archiveClicked
    signal deviceClicked
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
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Confirm Delete")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Text {
        id: description

        anchors { fill: dialog; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10; topMargin: 140; bottomMargin: 10 }
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        wrapMode: TextEdit.WordWrap
        text: qsTr("Please choose from where you wish to delete the selected videos")
    }

    Column {
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        spacing: 10

        PushButton {
            id: archiveButton

            width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
            showIcon: false
            showText: true
            name: qsTr("Archive")
            onButtonClicked: archiveClicked()
        }

        PushButton {
            id: deviceButton

            width: archiveButton.width
            showIcon: false
            showText: true
            name: qsTr("Device")
            onButtonClicked: deviceClicked();
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
