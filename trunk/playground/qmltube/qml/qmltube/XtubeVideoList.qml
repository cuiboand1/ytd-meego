import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/xtube.js" as Xtube

ListView {
    id: videoList

    property string site
    property variant checkList : []
    property string videoFeed
    property bool loaded : false
    property bool loading : true

    signal goToVideo(variant video)
    signal playVideo(variant video)

    function setVideoFeed(feed) {
        if (site == "pornhub") {
            Xtube.getPornHubVideos(feed);
        }
        else if (site == "youporn") {
            Xtube.getYouPornVideos(feed);
        }
        else if (site == "tube8") {
            Xtube.getTubeEightVideos(feed);
        }
        else if (site == "redtube") {
            Xtube.getRedTubeVideos(feed);
        }
    }

    function getVideoUrl(index) {
        if (site == "pornhub") {
            Xtube.getPornHubUrl(index);
        }
        else if (site == "youporn") {
            Xtube.getYouPornUrl(index);
        }
        else if (site == "tube8") {
            Xtube.getTubeEightUrl(index);
        }
        else if (site == "redtube") {
            Xtube.getRedTubeUrl(index);
        }
    }

    boundsBehavior: Flickable.DragOverBounds
    highlightMoveDuration: 500
    preferredHighlightBegin: 0
    preferredHighlightEnd: 100
    highlightRangeMode: ListView.StrictlyEnforceRange
    cacheBuffer: 2500
    interactive: visibleArea.heightRatio < 1
    clip: true
    model: ListModel {
        id: videoListModel
    }
    onCurrentIndexChanged: {
        if ((videoList.count - videoList.currentIndex == 1) && (!videoList.loading)) {
            videoList.loading = true;
            var pos = videoFeed.lastIndexOf("=") + 1;
            var feed = videoFeed.slice(0, pos);
            var page = parseInt(videoFeed.substr(pos)) + 1;
            setVideoFeed(feed + page);
        }
    }

    delegate: XListDelegate {
        id: delegate

        checked: Scripts.indexInCheckList(index)
        onDelegateClicked: goToVideo(videoListModel.get(index))
        onPlayClicked: getVideoUrl(index)
    }

    ScrollBar {}

    Text {
        anchors.centerIn: videoList
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No videos found")
        visible: (!videoList.loading) && (videoList.count == 0)
    }
}
