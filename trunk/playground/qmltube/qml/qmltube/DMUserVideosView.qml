import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/dailymotion.js" as DM

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : true
    property bool showMenuButtonFour : !Controller.isSymbian
    property bool showMenuButtonFive : true

    property string videoFeed
    property alias checkList: videoList.checkList
    property bool itemsSelected : videoList.checkList.length > 0

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setVideoFeed(username) {
        videoFeed = "https://api.dailymotion.com/videos?limit=50&family_filter=false&fields=" + _DM_FIELDS + "&user=" + username;
        DM.getDailymotionVideos()
    }

    function onMenuButtonOneClicked() {
        /* Toggle select all/none */

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

    function onMenuButtonTwoClicked() {
        DM.addVideosToFavourites();
    }

    function onMenuButtonThreeClicked() {
        DM.addVideosToPlaybackQueue();
    }

    function onMenuButtonFourClicked() {
        Scripts.addVideosToDownloads(false);
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Text {
            id: noResultsText

            anchors.centerIn: dimmer
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No videos found")
            visible: false

            Timer {
                interval: 5000
                running: (!videoListModel.loading) && (videoListModel.count == 0)
                onTriggered: {
                    if (videoListModel.count == 0) {
                        noResultsText.visible = true;
                    }
                }
            }
        }

        ListView {
            id: videoList

            property variant checkList : []

            anchors { fill: parent; topMargin: 50 }
            boundsBehavior: Flickable.DragOverBounds
            highlightMoveDuration: 500
            preferredHighlightBegin: 0
            preferredHighlightEnd: 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            cacheBuffer: 2500
            interactive: visibleArea.heightRatio < 1
            onCurrentIndexChanged: {
                if ((videoList.count - videoList.currentIndex == 1)
                        && (videoListModel.moreResults)
                        && (!videoListModel.loading)) {
                    DM.getDailymotionVideos();
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

                property bool loading : true
                property bool moreResults : true
                property int page : 1
            }

            delegate: DMListDelegate {
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
                    videoList.checkList = [];
                    goToVideo(videoListModel.get(index));
                }
                onDelegatePressed: addOrRemoveFromCheckList()
                onPlayClicked: {
                    var video = DM.createVideoObject(videoListModel.get(index));
                    playVideos([video]);
                }
            }

            ScrollBar {}
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1}
        }

    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
