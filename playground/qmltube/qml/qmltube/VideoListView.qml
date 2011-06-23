import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property string videoFeed
    property alias checkList: videoList.checkList

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setVideoFeed(feed) {
        videoFeed = feed;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var xml = doc.responseText;
                videoListModel.setXml(xml);

                videoListModel.loading = false;
                videoList.positionViewAtIndex(0, ListView.Beginning);
            }
        }
        doc.open("GET", feed);
        if ((feed == _FAVOURITES_FEED) || (feed == _UPLOADS_FEED) || (feed == _NEW_SUB_VIDEOS_FEED)) {
            doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken); // Set 'Authorization' header if viewing the favourites/uploads feed
        }
        doc.send();
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
        /* Add/remove videos from favourites */

        if (videoFeed == _FAVOURITES_FEED) {
            Scripts.deleteVideosFromFavourites();
        }
        else {
            Scripts.addVideosToFavourites();
        }
    }

    function onMenuButtonThreeClicked() {
        if (videoList.checkList.length > 0) {
            Scripts.showPlaylistDialog();
        }
    }

    function onMenuButtonFourClicked() {
        if (Controller.isSymbian) {
            Scripts.addVideosToDownloads(false);
        }
        else {
            Scripts.addVideosToPlaybackQueue();
        }
    }

    function onMenuButtonFiveClicked() {
        Scripts.addVideosToDownloads(false);
    }


    Connections {
        target: YouTube
        onDeletedFromFavourites: {
            if (videoFeed == _FAVOURITES_FEED) {
                messages.displayMessage(qsTr("Video(s) deleted from favourites"));
                setVideoFeed(videoFeed);
            }
        }
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

            anchors { fill: dimmer; topMargin: 50 }
            boundsBehavior: Flickable.DragOverBounds
            highlightMoveDuration: 500
            preferredHighlightBegin: 0
            preferredHighlightEnd: 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            cacheBuffer: 2500
            interactive: visibleArea.heightRatio < 1
            onCurrentIndexChanged: {
                if ((videoList.count - videoList.currentIndex == 1)
                        && (videoList.count < videoListModel.totalResults)
                        && (videoListModel.status == XmlListModel.Ready)) {
                    Scripts.appendVideoFeed();
                }
            }

            footer: Item {
                id: footer

                width: videoList.width
                height: 100
                visible: ((videoListModel.loading) || (videoListModel.status == XmlListModel.Loading))
                opacity: footer.visible ? 1 : 0

                BusyDialog {
                    anchors.centerIn: footer
                    opacity: footer.opacity
                }
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

            model: VideoListModel {
                id: videoListModel

                property bool loading : true
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
                    videoList.checkList = [];
                    goToVideo(videoListModel.get(index));
                }
                onDelegatePressed: addOrRemoveFromCheckList(index)
                onPlayClicked: playVideos([videoListModel.get(index)])
            }

            ScrollBar {}
        }

        MouseArea {
            id: mouseArea

            anchors { fill: dimmer; topMargin: 50 }
            enabled: false
            onClicked: Scripts.closeDialogs()
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
