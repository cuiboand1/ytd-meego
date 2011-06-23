import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    signal goToPlaylist(variant playlistData)
    signal playVideos(variant videos)
    signal dialogClose

    function showPlaylistDialog(index) {
        toggleControls(false);
        var playlistDialog = ObjectCreator.createObject("PlaylistDialog.qml", window);
        playlistDialog.playlistVideosClicked.connect(goToPlaylist);
        playlistDialog.playClicked.connect(playPlaylist);
        playlistDialog.close.connect(closeDialogs);
        playlistDialog.setPlaylist(playlistModel.get(index));
        playlists.state = "dim";
        playlistDialog.state = "show";
    }

    function playPlaylist(videos) {
        dialogClose();
        playlists.state = "";
        playVideos(videos);
    }

    function onMenuButtonOneClicked() {
        /* Show the new playlist dialog */

        toggleControls(false);
        var playlistDialog = ObjectCreator.createObject("NewPlaylistDialog.qml", window);
        playlistDialog.close.connect(closeDialogs);
        playlists.state = "dim";
        playlistDialog.state = "show";
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        playlists.state = "";
        toggleControls(true);
    }

    ListView {
        id: playlists

        anchors { fill: window; topMargin: 50 }
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: visibleArea.heightRatio < 1
        model: playlistModel

        delegate: PlaylistDelegate {
            id: delegate

            Connections {
                onDelegateClicked: goToPlaylist(playlistModel.get(index))
                onDelegatePressed: showPlaylistDialog(index)
            }
        }

        Text {
            anchors.centerIn: playlists
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No playlists found")
            visible: (playlistModel.status == XmlListModel.Ready) && (playlists.count == 0)
        }

        ScrollBar {}

        MouseArea {
            id: mouseArea
            anchors.fill: playlists
            enabled: false
            onClicked: closeDialogs()
        }

        states: State {
            name: "dim"
            PropertyChanges { target: playlists; opacity: 0.1 }
        }

        transitions: Transition {
            PropertyAnimation { properties: "opacity"; duration: 500 }
        }
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
