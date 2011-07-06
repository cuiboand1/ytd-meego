import QtQuick 1.0
import QtMultimediaKit 1.1
import "scripts/settings.js" as Settings
import "scripts/dateandtime.js" as GetDate
import "scripts/vimeo.js" as VM

Rectangle {
    id: videoWindow

    property bool showMenuButtonOne : false
    property bool showMenuButtonTwo : false
    property bool showMenuButtonThree : false
    property bool showMenuButtonFour : false
    property bool showMenuButtonFive : false

    property variant currentVideo : []
    property int playlistPosition : 0
    property bool gettingVideoUrl : false
    property string playbackQuality

    signal playbackStopped

    function setPlaylist(videoList) {
        for (var i = 0; i < videoList.length; i++) {
            playbackModel.append(videoList[i]);
        }
        currentVideo = playbackModel.get(0);
        if (currentVideo.archive) {
            videoPlayer.setVideo(currentVideo.filePath);
        }
        else if (currentVideo.xtube) {
            videoPlayer.setVideo(currentVideo.url);
        }
        else {
            gettingVideoUrl = true;
            if (currentVideo.dailymotion) {
                DailyMotion.getVideoUrl(currentVideo.id);
            }
            else if (currentVideo.vimeo) {
                Vimeo.getVideoUrl(currentVideo.id);
            }
            else if (currentVideo.live) {
                YouTube.getLiveVideoUrl(currentVideo.videoId);
            }
            else {
                YouTube.getVideoUrl(currentVideo.videoId);
            }
        }
        setDoNotDisturb();
    }

    function setDoNotDisturb() {
        if ((currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a"))) {
            Controller.doNotDisturb(false);
        }
        else {
            Controller.doNotDisturb(true);
        }
    }

    function getTime(msecs) {
        /* Convert seconds to HH:MM:SS format */

        var secs = Math.floor(msecs / 1000);
        var hours = Math.floor(secs / 3600);
        var minutes = Math.floor(secs / 60) - (hours * 60);
        var seconds = secs - (hours * 3600) - (minutes * 60);
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        var duration = minutes + ":" + seconds;
        if (hours > 0) {
            duration = hours + ":" + duration;
        }
        return duration;
    }

    function previous() {
        /* Play the previous item in the playlist */

        if (playlistPosition > 0) {
            playlistPosition--;
        }
    }

    function next() {
        /* Play the next item in the playlist */

        if (playlistPosition < playbackModel.count - 1) {
            playlistPosition++;
        }
    }

    function addVideoToDownloads(convertToAudio) {
        if (videoWindow.state == "") {
            controls.showControls = false;
        }
        if (!currentVideo.videoDownload) {
            var cv = currentVideo;
            cv["status"] = "paused";
            if (convertToAudio) {
                cv["audioDownload"] = true;
                addAudioDownload(cv);
            }
            else {
                cv["videoDownload"] = true;
                addDownload(cv);
                currentVideo = cv;
            }
        }
    }

    function addVideoToFavourites() {
        if (videoWindow.state == "") {
            controls.showControls = false;
        }
        if (!currentVideo.favourite) {
            if ((currentVideo.youtube) && !(YouTube.currentUser == "")) {
                YouTube.addToFavourites(currentVideo.videoId);
            }
            else if ((currentVideo.dailymotion) && !(DailyMotion.currentUser == "")) {
                DailyMotion.addToFavourites(currentVideo.id);
            }
            else if ((currentVideo.vimeo) && !(Vimeo.currentUser == "")) {
                VM.setLike(true, currentVideo.id);
            }
        }
    }

    function rateVideo(likeOrDislike) {
        if (videoWindow.state == "") {
            controls.showControls = false;
        }
        if (!((currentVideo.rating) || (YouTube.currentUser == ""))) {
            ytBar.likeOrDislike = likeOrDislike;
            YouTube.rateVideo(currentVideo.videoId, likeOrDislike);
        }
    }

    color: "black"
    onCurrentVideoChanged: {
        commentsList.loaded = false;
        if (tabView.currentIndex == 1) {
            if (currentVideo.youtube) {
                commentsModel.loadComments();
            }
            else {
                commentsModel.xml = "";
            }
            if (currentVideo.vimeo) {
                VM.getComments();
            }
            else {
                vimeoCommentsModel.clear();
            }
            setDoNotDisturb();
        }
    }
    onPlaylistPositionChanged: {
        if (playlistPosition < playbackModel.count) {
            var nextVideo = playbackModel.get(playlistPosition);
            if (nextVideo.archive) {
                videoPlayer.setVideo(nextVideo.filePath);
            }
            else if (nextVideo.xtube) {
                videoPlayer.setVideo(nextVideo.url);
            }
            else if (nextVideo.videoUrl) {
                videoPlayer.setVideo(nextVideo.videoUrl);
            }
            else {
                gettingVideoUrl = true;
                if (nextVideo.dailymotion) {
                    DailyMotion.getVideoUrl(nextVideo.id);
                }
                else if (nextVideo.vimeo) {
                    Vimeo.getVideoUrl(nextVideo.id);
                }
                else {
                    YouTube.getVideoUrl(nextVideo.videoId);
                }
            }
            currentVideo = nextVideo;
            if (videoWindow.state == "audio") {
                tabPlaylistView.positionViewAtIndex(playlistPosition, ListView.Beginning);
            }
        }
    }
    onStateChanged: {
        tabView.currentIndex = 0;
        setDoNotDisturb();
    }

    Component.onCompleted: {
        playbackQuality = Settings.getSetting("playbackQuality");
    }

    Connections {
        target: YouTube
        onGotVideoUrl: {
            gettingVideoUrl = false;
            videoPlayer.setVideo(videoUrl);
            var cv = currentVideo;
            cv["videoUrl"] = videoUrl;
            currentVideo = cv;
        }
        onVideoUrlError: {
            gettingVideoUrl = false;
            playlistPosition++;
        }
        onVideoRated: {
            var cv = currentVideo;
            cv["rating"] = ytBar.likeOrDislike;
            currentVideo = cv;
        }
        onAddedToFavourites: {
            var cv = currentVideo;
            cv["favourite"] = true;
            currentVideo = cv;
        }
        onCommentAdded: {
            var cv = currentVideo;
            cv["commentAdded"] = true;
            currentVideo = cv;
            commentsModel.loadComments();
        }
    }

    Connections {
        target: DailyMotion
        onGotVideoUrl: {
            gettingVideoUrl = false;
            videoPlayer.setVideo(videoUrl);
            var cv = currentVideo;
            cv["videoUrl"] = videoUrl;
            currentVideo = cv;
        }
        onVideoUrlError: {
            gettingVideoUrl = false;
            playlistPosition++;
        }
        onAddedToFavourites: {
            var cv = currentVideo;
            cv["favourite"] = true;
            currentVideo = cv;
        }
    }

    Connections {
        target: Vimeo
        onGotVideoUrl: {
            gettingVideoUrl = false;
            videoPlayer.setVideo(videoUrl);
            var cv = currentVideo;
            cv["videoUrl"] = videoUrl;
            currentVideo = cv;
        }
        onVideoUrlError: {
            gettingVideoUrl = false;
            playlistPosition++;
        }
        onAddedToFavourites: {
            var cv = currentVideo;
            cv["favourite"] = true;
            currentVideo = cv;
        }
        onCommentAdded: {
            var cv = currentVideo;
            cv["commentAdded"] = true;
            currentVideo = cv;
            commentsModel.loadComments();
        }
    }

    Timer {
        id: controlsTimer

        running: (videoWindow.state == "") && (controls.showControls) && (!controls.showExtraControls)
        interval: 3000
        onTriggered: controls.showControls = false
    }    

    Video {
        id: videoPlayer

        property bool repeat : false // True if playback of the current video is to be repeated

        function setVideo(videoUrl) {
            if ((Controller.isSymbian) && (currentVideo.archive)) {
                videoUrl = "file:///" + videoUrl;
            }
            videoPlayer.source = videoUrl;
            videoPlayer.play();
            if (currentVideo.archive) {
                archiveModel.markItemAsOld(currentVideo.filePath);
            }
        }

        z: (seekBar.position > 0) && !((currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a"))) ? 0 : -1
        anchors.fill: videoWindow
        onStatusChanged: {
            if (videoPlayer.status == Video.EndOfMedia) {
                if (videoPlayer.repeat) {
                    videoPlayer.position = 0;
                    videoPlayer.play();
                }
                else {
                    playlistPosition++;
                }
            }
        }
        onPositionChanged: {
            if (videoPlayer.position > 1000) {
                seekBar.position = videoPlayer.position;
                if ((!videoPlayer.repeat) && (playlistPosition == (playbackModel.count - 1)) && ((videoPlayer.duration - videoPlayer.position) < 500)) {
                    videoPlayer.stop();
                    videoPlayer.source = "";
                    playbackStopped();
                }
            }
        }
    }

    Item {
        id: controls

        property bool showControls : false
        property bool showExtraControls : false
        property bool audioMode : false

        anchors.fill: videoWindow
        onShowControlsChanged: {
            if (!controls.showControls) {
                controls.showExtraControls = false;
            }
        }

        MouseArea {
            id: controlsMouseArea

            property real xPos

            anchors.fill: controls
            onClicked: {
                if (videoWindow.state == "") {
                    controls.showControls = !controls.showControls;
                }
            }
            onPressAndHold: videoPlayer.paused = !videoPlayer.paused
            onPressed: xPos = mouseX
            onReleased: {
                if (xPos - mouseX > 100) {
                    next();
                }
                else if (mouseX - xPos > 100) {
                    previous();
                }
            }
        }

        Image {
            id: pauseIcon

            width: 80
            height: 80
            anchors.centerIn: controls
            source: "ui-images/pauseicon.png"
            smooth: true
            visible: (videoPlayer.paused) && (playlistView.opacity == 0)
        }

        Text {
            id: loadingText

            anchors.centerIn: controls
            font.pixelSize: _LARGE_FONT_SIZE
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            smooth: true
            text: qsTr("Loading...")
            visible: (!videoPlayer.paused) && ((gettingVideoUrl) || (videoPlayer.status == Video.Loading) || (videoPlayer.status == Video.Buffering) || (videoPlayer.status == Video.Stalled))
        }

        Item {
            id: ytBar

            property string likeOrDislike

            height: 50
            anchors { top: playlistView.top; left: playlistView.right; leftMargin: -1; right: titleBar.right }
            opacity: (controls.showExtraControls) && !(currentVideo.archive) ? 1 : 0

            Rectangle {
                anchors.fill: ytBar
                color: _BACKGROUND_COLOR
                smooth: true
                opacity: (videoWindow.state == "audio") ? 0 : 1
            }

            Row {
                anchors.fill: ytBar
                spacing: 10

                Image {
                    id: likeButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (likeMouseArea.pressed) || (currentVideo.rating == "like") ? (cuteTubeTheme == "nightred") ? "ui-images/likeiconred.png" : "ui-images/likeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/likeiconlight.png" : "ui-images/likeicon.png"
                    sourceSize.width: likeButton.width
                    sourceSize.height: likeButton.height
                    smooth: true
                    visible: currentVideo.youtube ? true : false

                    MouseArea {
                        id: likeMouseArea

                        anchors.fill: likeButton
                        onClicked: rateVideo("like")
                    }
                }

                Image {
                    id: dislikeButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (dislikeMouseArea.pressed) || (currentVideo.rating == "dislike") ? (cuteTubeTheme == "nightred") ? "ui-images/dislikeiconred.png" : "ui-images/dislikeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/dislikeiconlight.png" : "ui-images/dislikeicon.png"
                    sourceSize.width: dislikeButton.width
                    sourceSize.height: dislikeButton.height
                    smooth: true
                    visible: currentVideo.youtube ? true : false

                    MouseArea {
                        id: dislikeMouseArea

                        anchors.fill: dislikeButton
                        onClicked: rateVideo("dislike")
                    }
                }

                Image {
                    id: favButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (favMouseArea.pressed) || (currentVideo.favourite) ? (cuteTubeTheme == "nightred") ? "ui-images/favouritesiconred.png" : "ui-images/favouritesiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/favouritesiconlight.png" : "ui-images/favouritesicon.png"
                    sourceSize.width: favButton.width
                    sourceSize.height: favButton.height
                    smooth: true
                    visible: (currentVideo.youtube) || (currentVideo.dailymotion) || (currentVideo.vimeo) ? true : false

                    MouseArea {
                        id: favMouseArea

                        anchors.fill: favButton
                        onClicked: addVideoToFavourites()
                    }
                }

                Image {
                    id: videoDownloadButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (videoDownloadMouseArea.pressed) || (currentVideo.videoDownload) ? (cuteTubeTheme == "nightred") ? "ui-images/videodownloadiconred.png" : "ui-images/videodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                    sourceSize.width: videoDownloadButton.width
                    sourceSize.height: videoDownloadButton.height
                    smooth: true

                    MouseArea {
                        id: videoDownloadMouseArea

                        anchors.fill: videoDownloadButton
                        onClicked: addVideoToDownloads(false)
                    }
                }

                Image {
                    id: audioDownloadButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (audioDownloadMouseArea.pressed) || (currentVideo.audioDownload) ? (cuteTubeTheme == "nightred") ? "ui-images/audiodownloadiconred.png" : "ui-images/audiodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/audiodownloadiconlight.png" : "ui-images/audiodownloadicon.png"
                    sourceSize.width: audioDownloadButton.width
                    sourceSize.height: audioDownloadButton.height
                    smooth: true
                    visible: !Controller.isSymbian

                    MouseArea {
                        id: audioDownloadMouseArea

                        anchors.fill: audioDownloadButton
                        onClicked: addVideoToDownloads(true)
                    }
                }
            }
        }

        Rectangle {
            id: frame

            width: Math.floor(controls.width / 2.5)
            height: Math.floor(frame.width / (4 / 3))
            anchors { left: controls.left; leftMargin: 10; top: controls.top; topMargin: Controller.isSymbian ? 60 : 120 }
            color: "black"
            border.width: 2
            border.color: frameMouseArea.pressed ? _ACTIVE_COLOR_LOW : (cuteTubeTheme == "light") ? "grey" : "white"
            smooth: true
            visible: false

            Image {
                id: coverArt

                anchors { fill: frame; margins: 2 }
                sourceSize.width: coverArt.width
                sourceSize.height: coverArt.height
                smooth: true
                visible: videoPlayer.z == -1
                onStatusChanged: {
                    if (coverArt.status == Image.Error) {
                        coverArt.source = "ui-images/error.jpg";
                    }
                }
            }

            Text {
                anchors.centerIn: frame
                font.pixelSize: _STANDARD_FONT_SIZE
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                smooth: true
                text: qsTr("Loading...")
                visible: (coverArt.status == Image.Loading) ? true : false
            }

            MouseArea {
                id: frameMouseArea

                anchors.fill: frame
                enabled: false
                onClicked: controls.audioMode = false;
            }
        }

        Row {
            id: buttonRow

            spacing: 10
            anchors { top: frame.bottom; topMargin: 10; horizontalCenter: frame.horizontalCenter }
            visible: false

            PushButton {
                id: prevButton

                width: Math.floor((frame.width / 3) - 7)
                icon: (cuteTubeTheme == "light") ? "ui-images/previousiconlight.png" : "ui-images/previousicon.png"
                onButtonClicked: {
                    if (videoPlayer.position > 5000) {
                        videoPlayer.position = 1;
                    }
                    else {
                        previous();
                    }
                }
            }

            PushButton {
                id: playButton

                width: prevButton.width
                icon: videoPlayer.paused ? (cuteTubeTheme == "light") ? "ui-images/playiconlight.png" : "ui-images/playicon.png" :
                                                                                                      (cuteTubeTheme == "light") ? "ui-images/pauseiconlight.png" : "ui-images/pauseicon.png"
                onButtonClicked: videoPlayer.paused = !videoPlayer.paused
            }

            PushButton {
                id: nextButton

                width: prevButton.width
                icon: (cuteTubeTheme == "light") ? "ui-images/nexticonlight.png" : "ui-images/nexticon.png"
                onButtonClicked: next()
            }
        }

        ListView {
            id: playlistView

            width: titleText.width
            height: (playlistView.count <= 4) ? (playlistView.count * 50) : 200
            anchors { top: titleBar.bottom; topMargin: -1; left: controls.left }
            clip: true
            interactive: playlistView.count > 4
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapToItem
            opacity: (controls.showExtraControls) && (playbackModel.count > 1) ? 1 : 0
            onOpacityChanged: playlistView.positionViewAtIndex(playlistPosition, ListView.Beginning)
            delegate: Rectangle {
                id: delegate

                width: delegate.parent.width
                height: 50
                color: _BACKGROUND_COLOR

                ListHighlight {
                    visible: (delegateMouseArea.pressed) || (playlistPosition == index)
                }

                Text {
                    anchors { fill: delegate; leftMargin: 10 }
                    font.pixelSize: _STANDARD_FONT_SIZE
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    color: _TEXT_COLOR
                    smooth: true
                    text: (index + 1).toString() + " - " + title
                }

                MouseArea {
                    id: delegateMouseArea

                    z: 100
                    anchors.fill: delegate
                    onClicked: {
                        if (videoWindow.state == "") {
                            controls.showControls = false;
                        }
                        playlistPosition = index;
                    }
                }
            }

            model: ListModel {
                id: playbackModel
            }
        }

        Item {
            id: titleBar

            anchors.top: controls.top
            width: controls.width
            height: 50
            opacity: controls.showControls ? 1 : 0

            Rectangle {
                anchors.fill: titleBar
                color: _BACKGROUND_COLOR
                smooth: true
                opacity: (videoWindow.state == "audio") ? 0.8 : 1
            }

            ToolButton {
                id: minimizeButton

                anchors { left: titleBar.left; leftMargin: 10; verticalCenter: titleBar.verticalCenter }
                icon: (cuteTubeTheme == "light") ? "ui-images/minimizeiconlight.png" : "ui-images/minimizeicon.png"
                visible: !Controller.isSymbian
                onButtonClicked: Controller.minimize()
            }

            ToolButton {
                id: modeButton

                anchors { left: titleBar.left; leftMargin: Controller.isSymbian ? 10 : 60; verticalCenter: titleBar.verticalCenter }
                visible: !Controller.isSymbian
                icon: controls.audioMode ? (cuteTubeTheme == "light") ? "ui-images/videosiconlight.png" : "ui-images/videosicon.png" :
                                                                                                        (cuteTubeTheme == "light") ? "ui-images/infoiconlight.png" : "ui-images/infoicon.png"
                onButtonClicked: controls.audioMode = !controls.audioMode
            }

            ToolButton {
                id: repeatButton

                anchors { left: titleBar.left; leftMargin: Controller.isSymbian ? 60 : 110; verticalCenter: titleBar.verticalCenter }
                icon: (videoPlayer.repeat) ? (cuteTubeTheme == "nightred") ? "ui-images/repeaticonred.png" : "ui-images/repeaticonblue.png" :
                                                                                                           (cuteTubeTheme == "light") ? "ui-images/repeaticonlight.png" : "ui-images/repeaticon.png"
                onButtonClicked: videoPlayer.repeat = !videoPlayer.repeat
            }

            Text {
                id: titleText

                anchors { left: titleBar.left; leftMargin: Controller.isSymbian ? 110 : 160; right: titleBar.right; rightMargin: 200; verticalCenter: titleBar.verticalCenter }
                font.pixelSize: _STANDARD_FONT_SIZE
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: _TEXT_COLOR
                smooth: true
                text: !currentVideo.title ? "" : currentVideo.title

                MouseArea {
                    id: titleMouseArea

                    z: 100
                    anchors.fill: titleText
                    onClicked: controls.showExtraControls = !controls.showExtraControls
                }
            }

            CloseButton {
                id: closeButton

                anchors { right: titleBar.right; rightMargin: 10; verticalCenter: titleBar.verticalCenter }
                onButtonClicked: {
                    videoPlayer.stop();
                    videoPlayer.source = "";
                    playbackStopped();
                }
            }

            Rectangle {
                height: 1
                anchors { left: titleBar.left; leftMargin: 10; right: titleBar.right; rightMargin: 10; bottom: titleBar.bottom }
                color: _ACTIVE_COLOR_HIGH
                opacity: (videoWindow.state == "audio") ? 0.5 : 0
            }
        }

        Text {
            id: time

            anchors { right: titleBar.right; rightMargin: 70; verticalCenter: titleBar.verticalCenter; top: undefined }
            height: titleBar.height
            font.pixelSize: _STANDARD_FONT_SIZE
            verticalAlignment: Text.AlignVCenter
            color: _TEXT_COLOR
            smooth: true
            opacity: titleBar.opacity
            text: !currentVideo ? "0:00/0:00" : getTime(seekBar.position) + "/" + getTime(videoPlayer.duration)
        }

        Rectangle {
            id: seekRect

            height: 20
            anchors { bottom: controls.bottom; left: controls.left; right: controls.right; verticalCenter: undefined }
            color: _BACKGROUND_COLOR
            opacity: controls.showControls ? 0.7 : 0
            smooth: true

            Rectangle {
                id: seekBar

                property int position : 0

                width: !currentVideo ? 0 : Math.floor(seekRect.width * (seekBar.position / videoPlayer.duration))
                height: seekRect.height
                anchors.bottom: seekRect.bottom
                color: _ACTIVE_COLOR_LOW
                smooth: true

                Behavior on width { SmoothedAnimation { velocity: 1200 } }
            }

            MouseArea {
                id: seekMouseArea

                width: parent.width
                height: 50
                anchors.bottom: parent.bottom
                enabled: !(((currentVideo.youtube) && (playbackQuality == "mobile")) || (currentVideo.dailymotion) || (currentVideo.live))
                onClicked: videoPlayer.position = Math.floor((mouseX / seekRect.width) * videoPlayer.duration);
            }
        }

        Row {
            id: toolButtonRow

            spacing: 10
            anchors { bottom: tabItem.top; bottomMargin: 10; right: tabItem.right }
            visible: false

            ToolButton {
                id: favToolButton

                icon: currentVideo.favourite ? (cuteTubeTheme == "nightred") ? "ui-images/favouritesiconred.png" : "ui-images/favouritesiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/favouritesiconlight.png" : "ui-images/favouritesicon.png"
                onButtonClicked: addVideoToFavourites()
            }

            ToolButton {
                id: videoDownloadToolButton

                icon: currentVideo.videoDownload ? (cuteTubeTheme == "nightred") ? "ui-images/videodownloadiconred.png" : "ui-images/videodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                onButtonClicked: addVideoToDownloads(false)
            }

            ToolButton {
                id: audioDownloadToolButton

                icon: currentVideo.audioDownload ? (cuteTubeTheme == "nightred") ? "ui-images/audiodownloadiconred.png" : "ui-images/audiodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/audiodownloadiconlight.png" : "ui-images/audiodownloadicon.png"
                visible: !Controller.isSymbian
                onButtonClicked: addVideoToDownloads(true)
            }
        }

        Item {
            id: tabItem

            property variant tabs : [ qsTr("Info"), qsTr("Comments"), qsTr("Playlist") ]

            anchors { left: frame.right; leftMargin: 10; right: controls.right; rightMargin: 10; top: frame.top; bottom: frame.bottom }
            visible: false

            Row {
                id: tabRow

                Repeater {
                    model: tabItem.tabs

                    Item {
                        width: tabItem.width / tabItem.tabs.length
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
                    if ((tabView.currentIndex == 1) && (currentVideo.comments) && !(currentVideo.comments == "0") && (!commentsList.loaded)) {
                        if (currentVideo.youtube) {
                            commentsModel.loadComments();
                        }
                        else if (currentVideo.vimeo) {
                            VM.getComments();
                        }
                    }
                }
            }
        }

        VisualItemModel {
            id: tabModel

            Flickable {
                id: scrollArea

                width: tabView.width
                height: tabView.height
                clip: true
                contentWidth: textColumn.width
                contentHeight: textColumn.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.DragOverBounds
                interactive: visibleArea.heightRatio < 1
                opacity: (tabView.currentIndex == 0) ? 1 : 0

                Column {
                    id: textColumn

                    spacing: 10
                    width: tabView.width
                    height: childrenRect.height

                    Text {
                        id: tabTitleText

                        width: textColumn.width
                        text: !currentVideo.title ? "" : currentVideo.title
                        color: _TEXT_COLOR
                        font.pixelSize: _STANDARD_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                    }

                    Text {
                        id: authorText

                        width: textColumn.width
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        textFormat: Text.StyledText
                        wrapMode: TextEdit.WordWrap
                        text: {
                            if ((currentVideo.youtube) || (currentVideo.vimeo)) {
                                qsTr("By ") + currentVideo.author + qsTr(" on ") + currentVideo.uploadDate.split(/\s|T/)[0];
                            }
                            else if (currentVideo.live) {
                                qsTr("By ") + currentVideo.author;
                            }
                            else if (currentVideo.archive) {
                                qsTr("Added on ") + GetDate.getDate(currentVideo.date);
                            }
                            else {
                                "";
                            }
                        }
                    }

                    Image {
                        id: qualityIcon

                        width: 50
                        height: 30
                        source: !currentVideo.quality ? "" : !(/[amh347]/.test(currentVideo.quality.charAt(0))) ? "" : (cuteTubeTheme == "light") ? "ui-images/" + currentVideo.quality + "iconlight.png" : "ui-images/" + currentVideo.quality + "icon.png";
                        sourceSize.width: qualityIcon.width
                        sourceSize.height: qualityIcon.height
                        smooth: true
                        visible: qualityIcon.source != ""
                    }

                    Row {
                        id: infoButtonRow
                        x: 2
                        spacing: 10
                        visible: (currentVideo.youtube) || (currentVideo.dailymotion) || (currentVideo.vimeo) ? true : false

                        ToolButton {
                            id: likeToolButton

                            icon: (currentVideo.rating == "like") ? (cuteTubeTheme == "nightred") ? "ui-images/likeiconred.png" : "ui-images/likeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/likeiconlight.png" : "ui-images/likeicon.png"
                            visible: currentVideo.youtube ? true : false
                            onButtonClicked: rateVideo("like")
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo.likes ? "0" : currentVideo.likes
                            visible: currentVideo.youtube ? true : false
                        }

                        ToolButton {
                            id: dislikeToolButton

                            icon: (currentVideo.rating == "dislike") ? (cuteTubeTheme == "nightred") ? "ui-images/dislikeiconred.png" : "ui-images/dislikeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/dislikeiconlight.png" : "ui-images/dislikeicon.png"
                            visible: currentVideo.youtube ? true : false
                            onButtonClicked: rateVideo("dislike")
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo.dislikes ? "0" : currentVideo.dislikes
                            visible: currentVideo.youtube ? true : false
                        }

                        Text {
                            y: currentVideo.youtube ? 20 : 0
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Views")
                        }

                        Text {
                            y: currentVideo.youtube ? 20 : 0
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo.views ? "" : currentVideo.views
                        }
                    }

                    Text {
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: _TEXT_COLOR
                        text: qsTr("Description")
                        visible: descriptionText.visible
                    }

                    Text {
                        id: descriptionText

                        width: textColumn.width
                        text: (!currentVideo.description) || (currentVideo.description == "") ? qsTr("No description") : currentVideo.description
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                        visible: (currentVideo.youtube) || (currentVideo.dailymotion) || (currentVideo.vimeo) ? true : false
                    }
                }
            }

            Item {
                id: commentsItem

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0

                Column {
                    y: 10
                    spacing: 10

                    Row {
                        x: 2
                        spacing: 10

                        TextEntryButton {
                            id: commentButton

                            textEntryWidth: commentsList.width - 5
                            textEntryHeight: commentsList.height
                            visible: (currentVideo.youtube) || (currentVideo.vimeo) ? true : false
                            icon: currentVideo.commentAdded ? (cuteTubeTheme == "nightred") ? "ui-images/commenticonred.png" : "ui-images/commenticonblue.png" : (cuteTubeTheme == "light") ? "ui-images/commenticonlight.png" : "ui-images/commenticon.png"
                            onSubmitText: {
                                if ((currentVideo.youtube) && !(YouTube.currentUser == "")) {
                                    YouTube.addComment(currentVideo.videoId, text);
                                }
                                else if ((currentVideo.vimeo) && !(Vimeo.currentUser == "")) {
                                    VM.addComment(text, currentVideo.id)
                                }
                            }
                        }

                        Text {
                            y: commentButton.visible ? 20 : 0
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: (!currentVideo.comments) || (currentVideo.comments == "0") ? qsTr("No comments") : currentVideo.comments + qsTr(" comments")
                            visible: commentButton.state == ""
                        }
                    }

                    ListView {
                        id: commentsList

                        property bool loaded : false // True if comments have been loaded
                        property string commentsFeed : !currentVideo.youtube ? "" : "http://gdata.youtube.com/feeds/api/videos/" + currentVideo.videoId + "/comments?v=2&max-results=50"

                        width: commentsItem.width
                        height: commentsItem.height - 40
                        clip: true
                        interactive: visibleArea.heightRatio < 1
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        footer: Text {
                            id: footer

                            width: commentsList.width
                            height: 50
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: _STANDARD_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Loading...")
                            visible: ((commentsModel.loading) || (commentsModel.status == XmlListModel.Loading))
                        }

                        delegate: CommentsDelegate {
                            id: commentDelegate
                        }

                        model: currentVideo.youtube ? commentsModel : vimeoCommentsModel

                        CommentsModel {
                            id: commentsModel

                            property bool loading : false

                            function loadComments() {
                                commentsModel.loading = true;

                                var doc = new XMLHttpRequest();
                                doc.onreadystatechange = function() {
                                    if (doc.readyState == XMLHttpRequest.DONE) {
                                        var xml = doc.responseText;
                                        commentsModel.setXml(xml);

                                        commentsModel.loading = false;
                                        commentsList.loaded = true;
                                        commentsList.positionViewAtIndex(0, ListView.Beginning);
                                    }
                                }
                                doc.open("GET", commentsList.commentsFeed);
                                doc.send();
                            }

                            function appendComments() {
                                commentsModel.loading = true;

                                var doc = new XMLHttpRequest();
                                doc.onreadystatechange = function() {
                                    if (doc.readyState == XMLHttpRequest.DONE) {
                                        var xml = doc.responseText;
                                        commentsModel.appendXml(xml);

                                        commentsModel.loading = false;
                                    }
                                }
                                doc.open("GET", commentsList.commentsFeed + "&start-index=" + (commentsModel.count + 1).toString());
                                doc.send();
                            }
                        }

                        ListModel {
                            id: vimeoCommentsModel

                            property bool loading : false
                            property bool moreResults : false
                            property int page : 1
                        }

                        onCurrentIndexChanged: {
                            if (commentsList.count - commentsList.currentIndex == 1) {
                                if ((currentVideo.youtube)
                                        && (commentsModel.count < commentsModel.totalResults)
                                        && (commentsModel.status == XmlListModel.Ready)) {
                                    commentsModel.appendComments();
                                }
                                else if ((currentVideo.vimeo)
                                         && (vimeoCommentsModel.moreResults)
                                         && (!vimeoCommentsModel.loading)) {
                                    VM.getComments();
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: tabPlaylistView

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 2) ? 1 : 0
                clip: true
                interactive: tabPlaylistView.count > 5
                boundsBehavior: Flickable.StopAtBounds
                snapMode: ListView.SnapToItem
                highlightMoveDuration: 500
                delegate: Item {
                    id: tabDelegate

                    width: tabDelegate.parent.width
                    height: 50

                    ListHighlight {
                        visible: (tabDelegateMouseArea.pressed) || (playlistPosition == index)
                    }

                    Text {
                        anchors { fill: tabDelegate; leftMargin: 10 }
                        font.pixelSize: _STANDARD_FONT_SIZE
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        color: _TEXT_COLOR
                        smooth: true
                        text: (index + 1).toString() + " - " + title
                    }

                    MouseArea {
                        id: tabDelegateMouseArea

                        z: 100
                        anchors.fill: tabDelegate
                        onClicked: playlistPosition = index
                    }
                }
                model: playbackModel
            }
        }
    }

    states: State {
        name: "audio"
        when: (controls.audioMode) || ((currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a")))
        PropertyChanges { target: window; color: _BACKGROUND_COLOR }
        ParentChange { target: videoPlayer; parent: frame }
        PropertyChanges { target: videoPlayer; anchors { fill: frame; margins: 2 } }
        PropertyChanges { target: playlistView; visible: false }
        PropertyChanges { target: titleText; anchors { leftMargin: Controller.isSymbian ? 60 : 110; rightMargin: 80 } }
        PropertyChanges { target: modeButton; visible: false }
        PropertyChanges { target: repeatButton; anchors.leftMargin: Controller.isSymbian ? 10 : 60 }
        PropertyChanges { target: ytBar; visible: false }
        PropertyChanges { target: toolButtonRow; visible: (currentVideo.youtube) || (currentVideo.dailymotion) || (currentVideo.vimeo)  ? true : false }
        PropertyChanges { target: tabItem; visible: true }
        PropertyChanges { target: coverArt; source: currentVideo.archive ? currentVideo.thumbnail.replace("default", "hqdefault") : "" }
        PropertyChanges { target: controlsMouseArea; enabled: false }
        PropertyChanges { target: titleMouseArea; enabled: false }
        PropertyChanges { target: controls; showControls: true; showExtraControls: true }
        PropertyChanges { target: frame; visible: true }
        PropertyChanges { target: buttonRow; visible: true }
        ParentChange { target: loadingText; parent: videoPlayer }
        PropertyChanges { target: loadingText; anchors.centerIn: videoPlayer; font.pixelSize: _STANDARD_FONT_SIZE }
        PropertyChanges { target: pauseIcon; visible: false }
        AnchorChanges { target: seekRect; anchors { left: tabItem.left; right: tabItem.right; verticalCenter: buttonRow.verticalCenter; bottom: undefined } }
        AnchorChanges { target: time; anchors { right: controls.right; top: seekRect.bottom; verticalCenter: undefined } }
        PropertyChanges { target: time; anchors { topMargin: 10; rightMargin: 10 } }
        PropertyChanges { target: frameMouseArea; enabled: (currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a")) ? false : true }
    }
}

