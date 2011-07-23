import QtQuick 1.0
import "scripts/dailymotion.js" as DM

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
        model: dailymotionPlaylistModel

        delegate: PlaylistDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    var playlist = DM.createPlaylistObject(dailymotionPlaylistModel.get(index));
                    goToPlaylist(playlist);
                }
                onDelegatePressed: {
                    var playlist = DM.createPlaylistObject(dailymotionPlaylistModel.get(index));
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
            visible: (!dailymotionPlaylistModel.loading) && (dailymotionPlaylistModel.count === 0)
        }

        ScrollBar {}
    }
}
