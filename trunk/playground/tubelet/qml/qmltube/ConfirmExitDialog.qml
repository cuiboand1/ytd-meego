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
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5

    }

    Image {
        id: icon

        width: 120
        height: 120
        anchors { top: dialog.top; left: dialog.left; margins: 10 }
        smooth: true
        source: (cuteTubeTheme == "nightred") ? "ui-images/cutetubered.png" : "ui-images/cutetubehires.png"

        Text {
            id: title

            anchors { bottom: icon.bottom; left: icon.right; margins: 10 }
            color: _TEXT_COLOR
            font { pixelSize: 48; bold: true }
            text: qsTr("Hold it!")
        }
    }

    Text {
        id: description

        anchors { fill: dialog; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10; topMargin: 140; bottomMargin: 10 }
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        wrapMode: TextEdit.WordWrap
        text: qsTr("cuteTube is currently downloading. Do you really want to exit?")
    }

    Column {
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        spacing: 10

        PushButton {
            id: yesButton

            width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
            showIcon: false
            showText: true
            name: qsTr("Yes")
            onButtonClicked: Qt.quit()
        }

        PushButton {
            id: noButton

            width: yesButton.width
            showIcon: false
            showText: true
            name: qsTr("No")
            onButtonClicked: close();
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
