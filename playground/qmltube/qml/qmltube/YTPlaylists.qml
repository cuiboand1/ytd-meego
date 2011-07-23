import QtQuick 1.0
import "scripts/youtube.js" as YT

Item {

    signal goToPlaylist(variant playlistData)
    signal showPlaylistInfo(variant playlist)

    ListView {
        id: playlists

        anchors.fill: parent
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
                onDelegateClicked: goToPlaylist(YT.createPlaylistObject(playlistModel.get(index)))
                onDelegatePressed: showPlaylistInfo(YT.createPlaylistObject(playlistModel.get(index)))
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
            visible: (!playlistModel.loading) && (playlistModel.count === 0)
        }

        ScrollBar {}
    }
}
