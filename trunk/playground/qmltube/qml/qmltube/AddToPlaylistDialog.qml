import QtQuick 1.0

Item {
    id: dialog

    signal playlistClicked(string playlistId)
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
        id: playlistLoader

        signal dialogClose

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }
        onLoaded: playlistLoader.item.state = "show"

        Connections {
            target: playlistLoader.item
            onClose: dialog.state = "show"
        }
    }

    Rectangle {
        id: background

        color: _BACKGROUND_COLOR
        radius: 10
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Add To Playlist")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    ListView {
        id: playlists

        anchors { fill: dialog; topMargin: 50; bottomMargin: (dialog.width > dialog.height) ? 10 : 90; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10 }
        clip: true
        snapMode: ListView.SnapToItem
        interactive: visibleArea.heightRatio < 1

        model: playlistModel

        delegate: PlaylistDelegate {
            id: delegate

            onDelegateClicked: {
                var playlistId = playlistModel.get(index).playlistId;
                playlistClicked(playlistId);
            }
        }

        ScrollBar {}
    }

    CloseButton {
        onButtonClicked: close()
    }

    PushButton {
        id: newPlaylistButton

        width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
        anchors { bottom: dialog.bottom; right: dialog.right; margins: 10 }
        icon: "ui-images/addicon.png"
        onButtonClicked: {
            playlistLoader.source = "NewPlaylistDialog.qml";
            dialog.state = "showChild";
        }
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
