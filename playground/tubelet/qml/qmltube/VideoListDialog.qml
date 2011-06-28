import QtQuick 1.0

Item {
    id: dialog

    property variant video
    property string title

    signal playClicked(string playerUrl)
    signal infoClicked(variant video)
    signal close

    function setVideo(videoObject) {
        /* Set the dialog properties */

        video = videoObject;
        title = video.title;
    }

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

        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    PushButton {
        id: playButton

        width: (dialog.width / 8)
        height: playButton.width
        icon: "ui-images/playicon.png"
        anchors { verticalCenter: dialog.verticalCenter; left: dialog.left; margins: 25 }

        Connections {
            onButtonClicked: {
                playClicked(video.playerUrl); //playClicked([video]);
                close();
            }
        }
    }

    PushButton {
        id: downloadButton

        width: playButton.width
        height: playButton.height
        icon: "ui-images/downloadicon.png"
        iconWidth: 60
        iconHeight: 60
        anchors { horizontalCenter: dialog.horizontalCenter; verticalCenter: dialog.verticalCenter }

        Connections {
            onButtonClicked: {
                addDownload(video);
                close();
            }
        }
    }

    PushButton {
        id: infoButton

        width: playButton.width
        height: playButton.height
        icon: "ui-images/infoicon.png"
        iconWidth: 68
        iconHeight: 68
        anchors { verticalCenter: dialog.verticalCenter; right: dialog.right; margins: 25 }

        Connections {
            onButtonClicked: {
                infoClicked(video);
                close();
            }
        }
    }

    Text {
        id: titleText

        width: dialog.width
        anchors { top: dialog.top; left: dialog.left; right: dialog.right; margins: 10 }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: title
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
