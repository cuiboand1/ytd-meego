import QtQuick 1.0
import "scripts/vimeo.js" as VM

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
        model: vimeoPlaylistModel

        delegate: PlaylistDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    var playlist = VM.createPlaylistObject(vimeoPlaylistModel.get(index));
                    goToPlaylist(playlist);
                }
                onDelegatePressed: {
                    var playlist = VM.createPlaylistObject(vimeoPlaylistModel.get(index));
                    showPlaylistInfo(playlist);
                }
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
            visible: (!vimeoPlaylistModel.loading) && (playlists.count == 0)
        }

        ScrollBar {}
    }
}
