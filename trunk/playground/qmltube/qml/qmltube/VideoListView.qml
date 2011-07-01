import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property bool showingFavourites : (youtubeList.videoFeed == _FAVOURITES_FEED)
    property bool canLoadYouTube : false
    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : !(tabView.currentIndex == 1)
    property bool showMenuButtonFour : !Controller.isSymbian
    property bool showMenuButtonFive : true

    property bool itemsSelected : tabView.currentItem.checkList.length > 0

    signal goToYTVideo(variant video)
    signal goToDMVideo(variant video)
    signal goToVimeoVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setVideoFeeds(feeds, site) {
        youtubeList.videoFeed = feeds.youtube;
        dailymotionList.videoFeed = feeds.dailymotion;
        vimeoList.videoFeed = feeds.vimeo;
        if (site == "YouTube") {
            youtubeList.getYouTubeVideos();
        }
        else if (site == "Dailymotion") {
            tabView.currentIndex = 1;
        }
        else if (site == "vimeo") {
            tabView.currentIndex = 2;
        }
    }

    function onMenuButtonOneClicked() {
        /* Toggle select all/none */

        if (tabView.currentIndex == 0) {
            youtubeList.toggleSelect();
        }
        else if (tabView.currentIndex == 1) {
            dailymotionList.toggleSelect();
        }
        else if (tabView.currentIndex == 2) {
            vimeoList.toggleSelect();
        }
    }

    function onMenuButtonTwoClicked() {
        /* Add/remove videos from favourites */

        if ((tabView.currentIndex == 0)) {
            if (youtubeList.videoFeed == _FAVOURITES_FEED) {
                youtubeList.deleteVideosFromFavourites();
            }
            else {
                youtubeList.addVideosToFavourites();
            }
        }
        else if ((tabView.currentIndex == 1)) {
            if (dailymotionList.videoFeed == _DM_FAVOURITES_FEED) {
                dailymotionList.deleteVideosFromFavourites();
            }
            else {
                dailymotionList.addVideosToFavourites();
            }
        }
        else if ((tabView.currentIndex == 2)) {
            if (youtubeList.videoFeed == _FAVOURITES_FEED) {
                vimeoList.deleteVideosFromFavourites();
            }
            else {
                vimeoList.addVideosToFavourites();
            }
        }
    }

    function onMenuButtonThreeClicked() {
        if (tabView.currentIndex == 0)
            youtubeList.showPlaylistDialog();
        else if (tabView.currentIndex == 2) {
            vimeoList.showPlaylistDialog();
        }
    }

    function onMenuButtonFourClicked() {
        if (tabView.currentIndex == 0) {
            youtubeList.addVideosToPlaybackQueue();
        }
        else if (tabView.currentIndex == 1) {
            dailymotionList.addVideosToPlaybackQueue();
        }
        else if (tabView.currentIndex == 2) {
            vimeoList.addVideosToPlaybackQueue();
        }
    }

    function onMenuButtonFiveClicked() {
        if (tabView.currentIndex == 0) {
            youtubeList.addVideosToDownloads();
        }
        else if (tabView.currentIndex == 1) {
            dailymotionList.addVideosToDownloads();
        }
        else if (tabView.currentIndex == 2) {
            vimeoList.addVideosToDownloads();
        }
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Item {
            id: tabItem

            property variant sites : [ "YouTube", "Dailymotion", "vimeo" ]

            anchors { fill: dimmer; topMargin: 60 }

            Row {
                id: tabRow

                Repeater {
                    model: tabItem.sites

                    Item {
                        width: tabItem.width / tabItem.sites.length
                        height: 40

                        BorderImage {
                            anchors.fill: parent
                            source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                            smooth: true
                            visible: tabView.currentIndex == index
                        }

                        Text {
                            anchors.fill: parent
                            font.pixelSize: _STANDARD_FONT_SIZE
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: tabView.currentIndex == index ? _TEXT_COLOR : "grey"
                            text: modelData
                        }

                        Rectangle {
                            height: 1
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            color: _ACTIVE_COLOR_HIGH
                            opacity: 0.5
                            visible: !(tabView.currentIndex == index)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: tabView.currentIndex = index
                        }
                    }
                }
            }

            ListView {
                id: tabView

                anchors { left: tabItem.left; right: tabItem.right; top: tabRow.bottom; bottom: tabItem.bottom }
                orientation: ListView.Horizontal
                highlightMoveDuration: 200
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapOneItem
                flickDeceleration: 500
                boundsBehavior: Flickable.StopAtBounds
                model: tabModel
                clip: true
                onCurrentIndexChanged: {
                    if (!(youtubeList.videoFeed == "none") && (tabView.currentIndex == 0) && (canLoadYouTube) && (!youtubeList.loaded)) {
                        youtubeList.getYouTubeVideos();
                    }
                    else if (!(dailymotionList.videoFeed == "none") && (tabView.currentIndex == 1) && (!dailymotionList.loaded)) {
                        canLoadYouTube = true;
                        dailymotionList.getDailymotionVideos();
                    }
                    else if (!(vimeoList.videoFeed == "none") && (tabView.currentIndex == 2) && (!vimeoList.loaded)) {
                        canLoadYouTube = true;
                        vimeoList.getVimeoVideos();
                    }
                }
            }
        }

        VisualItemModel {
            id: tabModel

            YTListView {
                id: youtubeList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 0) ? 1 : 0
                onGoToVideo: goToYTVideo(video)
                onPlay: playVideos(videos)
            }

            DMListView {
                id: dailymotionList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                onGoToVideo: goToDMVideo(video)
                onPlay: playVideos(videos)
            }

            VimeoListView {
                id: vimeoList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 2) ? 1 : 0
                onGoToVideo: goToVimeoVideo(video)
                onPlay: playVideos(videos)
            }
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1 }
        }

    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
