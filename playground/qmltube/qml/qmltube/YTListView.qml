import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/youtube.js" as YT

Item {
    property string videoFeed
    property alias checkList: videoList.checkList
    property bool loaded : false

    signal goToVideo(variant video)
    signal play(variant videos)

    function getYouTubeVideos() {
        loaded = true;
        YT.getYouTubeVideos();
    }

    function toggleSelect() {
        var cl = videoList.checkList;
        if (cl.length == 0) {
            for (var i = 0; i < videoList.count; i++) {
                cl.push(i);
            }
            videoList.checkList = cl;
        }
        else {
            videoList.checkList = [];
        }
    }

    function addVideosToFavourites() {
        YT.addVideosToFavourites();
    }

    function deleteVideosFromFavourites() {
        YT.deleteVideosFromFavourites();
    }

    function showPlaylistDialog() {
        if (videoList.checkList.length > 0) {
            YT.showPlaylistDialog();
        }
    }

    function addVideosToPlaybackQueue() {
        YT.addVideosToPlaybackQueue();
    }

    function addVideosToDownloads() {
        Scripts.addVideosToDownloads(false);
    }

    Connections {
        target: YouTube
        onDeletedFromFavourites: {
            if (videoFeed == _FAVOURITES_FEED) {
                messages.displayMessage(qsTr("Video(s) deleted from favourites"));
                videoListTimer.restart();
            }
        }
    }

    Timer {
        id: videoListTimer

        interval: 3000
        onTriggered: YT.getYouTubeVideos()
    }

    ListView {
        id: videoList

        property variant checkList : []

        anchors.fill: parent
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        cacheBuffer: 2500
        interactive: visibleArea.heightRatio < 1
        onCurrentIndexChanged: {
            if ((videoList.count - videoList.currentIndex == 1)
                    && (videoListModel.count < videoListModel.totalResults)
                    && (!videoListModel.loading)) {
                YT.getYouTubeVideos();
            }
        }

        footer: Item {
            id: footer

            width: videoList.width
            height: 100
            visible: videoListModel.loading
            opacity: footer.visible ? 1 : 0

            BusyDialog {
                anchors.centerIn: footer
                opacity: footer.opacity
            }
        }

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        model: ListModel {
            id: videoListModel

            property bool loading : false
            property int totalResults
            property int page : 0
        }

        delegate: VideoListDelegate {
            id: delegate

            function addOrRemoveFromCheckList() {
                var cl = videoList.checkList;
                if (!delegate.checked) {
                    cl.push(index);
                }
                else {
                    for (var i = 0; i < cl.length; i++) {
                        if (cl[i] == index) {
                            cl.splice(i, 1);
                        }
                    }
                }
                videoList.checkList = cl;
            }

            checked: Scripts.indexInCheckList(index)
            onDelegateClicked: {
                if (videoList.checkList.length == 0) {
                    goToVideo(videoListModel.get(index));
                }
            }
            onDelegatePressed: addOrRemoveFromCheckList(index)
            onPlayClicked: {
                if (videoList.checkList.length == 0) {
                    var video = YT.createVideoObject(videoListModel.get(index));
                    play([video]);
                }
            }
        }

        ScrollBar {}

        Text {
            id: noResultsText

            anchors.centerIn: videoList
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No videos found")
            visible: (!videoListModel.loading) && (videoListModel.count == 0)
        }
    }
}
