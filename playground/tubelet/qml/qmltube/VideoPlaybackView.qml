import QtQuick 1.0
import MeeGo.Components 0.1 as MeeGo //need at least stuff like theme_fontColorMediaHighlight from meego-ux-components/src/kernel/Theme.qml
import MeeGo.Media 0.1 as Media	//NPM for Media.MediaToolbar
import QtMultimediaKit 1.1
import "scripts/settings.js" as Settings
import "scripts/dateandtime.js" as GetDate

Item {
    id: videoWindow

    property variant currentVideo
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
            YouTube.getVideoUrl(currentVideo.videoId);
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

    onCurrentVideoChanged: {
        commentsList.loaded = false;
        if ((tabView.currentIndex == 1) && (currentVideo.videoId)) {
            commentsModel.loadComments();
        }
        else {
            commentsModel.xml = "";
            commentsModel.reload;
        }
        setDoNotDisturb();
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
                YouTube.getVideoUrl(nextVideo.videoId);
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

    Timer {
        id: controlsTimer

        running: (videoWindow.state == "") && (controls.showControls) && (!controls.showExtraControls)
        interval: 3000
        onTriggered: controls.showControls = false
    }    

    Video {
        id: videoPlayer

        function setVideo(videoUrl) {
            videoPlayer.source = videoUrl;
            videoPlayer.play()
            if (currentVideo.filePath) {
                archiveModel.markItemAsOld(currentVideo.filePath);
            }
        }

        z: (currentVideo) && (seekBar.position > 0) && !((currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a"))) ? 0 : -1
        anchors.fill: videoWindow
        onPositionChanged: {
            if (videoPlayer.position > 0) {
                seekBar.position = videoPlayer.position;
            }
            if ((videoPlayer.duration > 0) && ((videoPlayer.duration - videoPlayer.position) < 500)) {
                if (playlistPosition == (playbackModel.count - 1)) {
                    videoPlayer.stop();
                    videoPlayer.source = "";
                    playbackStopped();
                }
                else {
                    playlistPosition++;
                }
            }
        }        
    }

    Media.MediaToolbar {	// NPM
            id: playbar;
            visible: true
            width: videoPlayer.width
            anchors.horizontalCenter: videoPlayer.horizontalCenter
            anchors.verticalCenter: videoPlayer.verticalCenter
            height: 55
            showplay: true
            ispause: videoPlayer.paused
            showprev: true
            shownext: true
//	    showfavourite: true
//	    showunfavourite: false
//	    showrmfromqueue: true
//	    showrmfromplaylist: true
//	    showaddtoqueue: true
//	    showaddtoplaylist: true
//	    showdelete: true
            onPlayPressed: videoPlayer.paused = false
            onPausePressed:videoPlayer.paused = true
            onPrevPressed: videoPlayer.position -= 5000;
            onNextPressed: videoPlayer.position += 5000;
    }


    Item {
        id: controls

        property bool showControls : false
        property bool showExtraControls : false
        property bool audioMode : false

        function getLikeIcon() {

        }

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
            opacity: (controls.showExtraControls) && (currentVideo) && (currentVideo.videoId) ? 1 : 0

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
                    source: (likeMouseArea.pressed) || ((currentVideo) && (currentVideo.rating == "like")) ? (cuteTubeTheme == "nightred") ? "ui-images/likeiconred.png" : "ui-images/likeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/likeiconlight.png" : "ui-images/likeicon.png"
                    sourceSize.width: likeButton.width
                    sourceSize.height: likeButton.height
                    smooth: true

                    MouseArea {
                        id: likeMouseArea

                        anchors.fill: likeButton
                        onClicked: {
                            if (videoWindow.state == "") {
                                controls.showControls = false;
                            }
                            if ((!currentVideo.rating) && (userIsSignedIn())) {
                                ytBar.likeOrDislike = "like";
                                YouTube.rateVideo(currentVideo.videoId, "like");
                            }
                        }
                    }
                }

                Image {
                    id: dislikeButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (dislikeMouseArea.pressed) || ((currentVideo) && (currentVideo.rating == "dislike")) ? (cuteTubeTheme == "nightred") ? "ui-images/dislikeiconred.png" : "ui-images/dislikeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/dislikeiconlight.png" : "ui-images/dislikeicon.png"
                    sourceSize.width: dislikeButton.width
                    sourceSize.height: dislikeButton.height
                    smooth: true

                    MouseArea {
                        id: dislikeMouseArea

                        anchors.fill: dislikeButton
                        onClicked: {
                            if (videoWindow.state == "") {
                                controls.showControls = false;
                            }
                            if ((!currentVideo.rating) && (userIsSignedIn())) {
                                ytBar.likeOrDislike = "dislike";
                                YouTube.rateVideo(currentVideo.videoId, "dislike");
                            }
                        }
                    }
                }

                Image {
                    id: favButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (favMouseArea.pressed) || ((currentVideo) && (currentVideo.favourite)) ? (cuteTubeTheme == "nightred") ? "ui-images/favouritesiconred.png" : "ui-images/favouritesiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/favouritesiconlight.png" : "ui-images/favouritesicon.png"
                    sourceSize.width: favButton.width
                    sourceSize.height: favButton.height
                    smooth: true

                    MouseArea {
                        id: favMouseArea

                        anchors.fill: favButton
                        onClicked: {
                            if (videoWindow.state == "") {
                                controls.showControls = false;
                            }
                            if ((!currentVideo.favourite) && (userIsSignedIn())) {
                                YouTube.addToFavourites(currentVideo.videoId);
                            }
                        }
                    }
                }

                Image {
                    id: videoDownloadButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (videoDownloadMouseArea.pressed) || ((currentVideo) && (currentVideo.videoDownload)) ? (cuteTubeTheme == "nightred") ? "ui-images/videodownloadiconred.png" : "ui-images/videodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                    sourceSize.width: videoDownloadButton.width
                    sourceSize.height: videoDownloadButton.height
                    smooth: true

                    MouseArea {
                        id: videoDownloadMouseArea

                        anchors.fill: videoDownloadButton
                        onClicked: {
                            if (videoWindow.state == "") {
                                controls.showControls = false;
                            }
                            if (!currentVideo.videoDownload) {
                                var cv = currentVideo;
                                cv["videoDownload"] = true;
                                cv["status"] = "paused";
                                addDownload(cv);
                                currentVideo = cv;
                            }
                        }
                    }
                }

                Image {
                    id: audioDownloadButton

                    width: ytBar.height
                    height: ytBar.height
                    source: (audioDownloadMouseArea.pressed) || ((currentVideo) && (currentVideo.audioDownload)) ? (cuteTubeTheme == "nightred") ? "ui-images/audiodownloadiconred.png" : "ui-images/audiodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/audiodownloadiconlight.png" : "ui-images/audiodownloadicon.png"
                    sourceSize.width: audioDownloadButton.width
                    sourceSize.height: audioDownloadButton.height
                    smooth: true
                    visible: !Controller.isSymbian

                    MouseArea {
                        id: audioDownloadMouseArea

                        anchors.fill: audioDownloadButton
                        onClicked: {
                            if (videoWindow.state == "") {
                                controls.showControls = false;
                            }
                            if (!currentVideo.audioDownload) {
                                var cv = currentVideo;
                                cv["audioDownload"] = true;
                                cv["status"] = "paused";
                                addAudioDownload(cv);
                                currentVideo = cv;
                            }
                        }
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
                icon: controls.audioMode ? (cuteTubeTheme == "light") ? "ui-images/videosiconlight.png" : "ui-images/videosicon.png" :
                                                                                                        (cuteTubeTheme == "light") ? "ui-images/infoiconlight.png" : "ui-images/infoicon.png"
                onButtonClicked: controls.audioMode = !controls.audioMode
            }

            Text {
                id: titleText

                anchors { left: titleBar.left; leftMargin: Controller.isSymbian ? 60 : 110; right: titleBar.right; rightMargin: 200; verticalCenter: titleBar.verticalCenter }
                font.pixelSize: _STANDARD_FONT_SIZE
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: _TEXT_COLOR
                smooth: true
                text: !currentVideo ? "" : currentVideo.title

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
                onClicked: {
                    if (!((playbackQuality == "mobile") ||(currentVideo.quality == "mobile"))) {
                        videoPlayer.position = Math.floor((mouseX / seekRect.width) * videoPlayer.duration);
                    }
                }
            }
        }

        Row {
            id: toolButtonRow

            spacing: 10
            anchors { bottom: tabItem.top; bottomMargin: 10; right: tabItem.right }
            visible: false

            ToolButton {
                id: favToolButton

                icon: (currentVideo) && (currentVideo.favourite) ? (cuteTubeTheme == "nightred") ? "ui-images/favouritesiconred.png" : "ui-images/favouritesiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/favouritesiconlight.png" : "ui-images/favouritesicon.png"
                onButtonClicked: {
                    if ((!currentVideo.favourite) && (userIsSignedIn())) {
                        YouTube.addToFavourites(currentVideo.videoId);
                    }
                }
            }

            ToolButton {
                id: videoDownloadToolButton

                icon: (currentVideo) && (currentVideo.videoDownload) ? (cuteTubeTheme == "nightred") ? "ui-images/videodownloadiconred.png" : "ui-images/videodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                onButtonClicked: {
                    if (!currentVideo.videoDownload) {
                        var cv = currentVideo;
                        cv["videoDownload"] = true;
                        cv["status"] = "paused";
                        addDownload(cv);
                        currentVideo = cv;
                    }
                }
            }

            ToolButton {
                id: audioDownloadToolButton

                icon: (currentVideo) && (currentVideo.audioDownload) ? (cuteTubeTheme == "nightred") ? "ui-images/audiodownloadiconred.png" : "ui-images/audiodownloadiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/audiodownloadiconlight.png" : "ui-images/audiodownloadicon.png"
                visible: !Controller.isSymbian
                onButtonClicked: {
                    if (!currentVideo.audioDownload) {
                        var cv = currentVideo;
                        cv["audioDownload"] = true;
                        cv["status"] = "paused";
                        addAudioDownload(cv);
                        currentVideo = cv;
                    }
                }
            }
        }

        Item {
            id: tabItem

            anchors { left: frame.right; leftMargin: 10; right: controls.right; rightMargin: 10; top: frame.top; bottom: frame.bottom }
            visible: false

            Row {
                id: tabRow

                Item {
                    id: infoTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: infoTab
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 0
                    }

                    Text {
                        anchors.fill: infoTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 0 ? _TEXT_COLOR : "grey"
                        text: qsTr("Info")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: infoTab.bottom; left: infoTab.left; right: infoTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 0)
                    }

                    MouseArea {
                        id: infoMouseArea

                        anchors.fill: infoTab
                        onClicked: tabView.currentIndex = 0
                    }
                }

                Item {
                    id: commentsTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 1
                    }

                    Text {
                        anchors.fill: commentsTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 1 ? _TEXT_COLOR : "grey"
                        text: qsTr("Comments")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: commentsTab.bottom; left: commentsTab.left; right: commentsTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 1)
                    }

                    MouseArea {
                        id: commentsMouseArea

                        anchors.fill: commentsTab
                        onClicked: tabView.currentIndex = 1
                    }
                }

                Item {
                    id: playlistTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 2
                    }

                    Text {
                        anchors.fill: playlistTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 2 ? _TEXT_COLOR : "grey"
                        text: qsTr("Playlist")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: playlistTab.bottom; left: playlistTab.left; right: playlistTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 2)
                    }

                    MouseArea {
                        id: playlistMouseArea

                        anchors.fill: playlistTab
                        onClicked: tabView.currentIndex = 2
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
                    if ((tabView.currentIndex == 1) && (currentVideo) && (currentVideo.comments) && !(currentVideo.comments == "0") && (!commentsList.loaded)) {
                        commentsModel.loadComments();
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
                        text: !currentVideo ? "" : !currentVideo.title ? "" : currentVideo.title
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
                            if (currentVideo) {
                                if (currentVideo.author) {
                                    qsTr("By ") + currentVideo.author + qsTr(" on ") + currentVideo.uploadDate.split("T")[0];
                                }
                                else if (currentVideo.date) {
                                    qsTr("Added on ") + GetDate.getDate(currentVideo.date);
                                }
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
                        source: !currentVideo ? "" : !currentVideo.quality ? "" : !(/[amh347]/.test(currentVideo.quality.charAt(0))) ? "" : (cuteTubeTheme == "light") ? "ui-images/" + currentVideo.quality + "iconlight.png" : "ui-images/" + currentVideo.quality + "icon.png";
                        sourceSize.width: qualityIcon.width
                        sourceSize.height: qualityIcon.height
                        smooth: true
                        visible: qualityIcon.source != ""
                    }

                    Row {
                        id: infoButtonRow
                        x: 2
                        spacing: 10
                        visible: (currentVideo) && (currentVideo.videoId) ? true : false

                        ToolButton {
                            id: likeToolButton

                            icon: ((currentVideo) && (currentVideo.rating == "like")) ? (cuteTubeTheme == "nightred") ? "ui-images/likeiconred.png" : "ui-images/likeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/likeiconlight.png" : "ui-images/likeicon.png"
                            onButtonClicked: {
                                if ((!currentVideo.rating) && (userIsSignedIn())) {
                                    ytBar.likeOrDislike = "like";
                                    YouTube.rateVideo(currentVideo.videoId, "like");
                                }
                            }
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo ? "" : !currentVideo.likes ? "0" : currentVideo.likes
                        }

                        ToolButton {
                            id: dislikeToolButton

                            icon: (currentVideo) && (currentVideo.rating == "dislike") ? (cuteTubeTheme == "nightred") ? "ui-images/dislikeiconred.png" : "ui-images/dislikeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/dislikeiconlight.png" : "ui-images/dislikeicon.png"
                            onButtonClicked: {
                                if ((!currentVideo.rating) && (userIsSignedIn())) {
                                    ytBar.likeOrDislike = "dislike";
                                    YouTube.rateVideo(currentVideo.videoId, "dislike");
                                }
                            }
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo ? "" : !currentVideo.dislikes ? "0" : currentVideo.dislikes
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Views")
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: !currentVideo ? "" : !currentVideo.views ? "0" : currentVideo.views
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
                        text: !currentVideo ? "" : (!currentVideo.description) || (currentVideo.description == "") ? qsTr("No description") : currentVideo.description
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                        visible: (currentVideo) && (currentVideo.videoId) ? true : false
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
                            visible: (currentVideo) && (currentVideo.videoId) ? true : false
                            icon: (currentVideo) && (currentVideo.commentAdded) ? (cuteTubeTheme == "nightred") ? "ui-images/commenticonred.png" : "ui-images/commenticonblue.png" : (cuteTubeTheme == "light") ? "ui-images/commenticonlight.png" : "ui-images/commenticon.png"
                            onSubmitText: {
                                if (userIsSignedIn()) {
                                    YouTube.addComment(currentVideo.videoId, text);
                                }
                            }
                        }

                        Text {
                            y: commentButton.visible ? 20 : 0
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: !currentVideo ? "" : (!currentVideo.comments) || (currentVideo.comments == "0") ? qsTr("No comments") : currentVideo.comments + qsTr(" comments")
                            visible: commentButton.state == ""
                        }
                    }                    

                    ListView {
                        id: commentsList

                        property bool loaded : false // True if comments have been loaded
                        property string commentsFeed : !currentVideo ? "" : !currentVideo.videoId ? "" : "http://gdata.youtube.com/feeds/api/videos/" + currentVideo.videoId + "/comments?v=2&max-results=50"

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

                        model: CommentsModel {
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

                        onCurrentIndexChanged: {
                            if ((commentsList.count - commentsList.currentIndex == 1)
                                    && (commentsModel.count < commentsModel.totalResults)
                                    && (commentsModel.status == XmlListModel.Ready)) {
                                commentsModel.appendComments();
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
        when: (controls.audioMode) || ((currentVideo) && (currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a")))
        PropertyChanges { target: window; color: _BACKGROUND_COLOR }
        ParentChange { target: videoPlayer; parent: frame }
        PropertyChanges { target: videoPlayer; anchors { fill: frame; margins: 2 } }
        PropertyChanges { target: playlistView; visible: false }
        PropertyChanges { target: titleText; anchors { leftMargin: Controller.isSymbian ? 10 : 60; rightMargin: 80 } }
        PropertyChanges { target: modeButton; visible: false }
        PropertyChanges { target: ytBar; visible: false }
        PropertyChanges { target: toolButtonRow; visible: (currentVideo) && (currentVideo.videoId) ? true : false }
        PropertyChanges { target: tabItem; visible: true }
        PropertyChanges { target: coverArt; source: !currentVideo ? "" : (currentVideo.archive) ? currentVideo.thumbnail.replace("default", "hqdefault") : "" }
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
        PropertyChanges { target: frameMouseArea; enabled: (currentVideo) && (currentVideo.archive) && ((currentVideo.quality == "audio") || (currentVideo.filePath.slice(-4) == ".m4a")) ? false : true }
    }
}

