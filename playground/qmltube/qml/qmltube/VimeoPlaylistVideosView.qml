import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator
import "scripts/vimeo.js" as VM

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : !Controller.isSymbian
    property bool showMenuButtonFour : true
    property bool showMenuButtonFive : true

    property variant playlist
    property variant videoFeed
    property alias checkList: videoList.checkList

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setPlaylist(playlistItem) {
        playlist = playlistItem;
        videoFeed = [["method", "vimeo.albums.getVideos"], ["album_id", playlist.id]];
        VM.getVimeoVideos();
    }

    function setPlaylistVideos(playlistItem) {
        /* This function is used to pass the videos of
          a fully loaded ListModel */

        playlist = playlistItem.info;
        for (var i = 0; i < playlistItem.videos.length; i++) {
            videoListModel.append(playlistItem.videos[i]);
        }
        videoListModel.loading = false;
        videoList.positionViewAtIndex(0, ListView.Beginning);
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
        VM.setLikes(true);
    }

    function onMenuButtonThreeClicked() {
        VM.deleteVideosFromPlaylist(playlist.id);
    }

    function onMenuButtonFourClicked() {
        VM.addVideosToPlaybackQueue();
    }

    function onMenuButtonFiveClicked() {
        Scripts.addVideosToDownloads(false);
    }

    function showPlaylistInfoDialog() {
        toggleControls(false);
        var list = [];
        for (var i = 0; i < videoListModel.count; i++) {
            list.push(videoListModel.get(i));
        }
        var playlistDialog = ObjectCreator.createObject("VimeoPlaylistDialog.qml", window);
        playlistDialog.playlistVideosClicked.connect(Scripts.closeDialogs);
        playlistDialog.playClicked.connect(playPlaylist);
        playlistDialog.close.connect(Scripts.closeDialogs);
        playlistDialog.setPlaylistVideos({ "info": playlist, "videos": list });
        dimmer.state = "dim";
        playlistDialog.state = "show";
    }

    function playPlaylist(playlistVideos) {
        if (playlistVideos) {
            dialogClose();
            dimmer.state = "";
            playVideos(playlistVideos);

        }
        else {
            var list = [];
            for (var i = 0; i < videoListModel.count; i++) {
                list.push(VM.createVideoObject(videoListModel.get(i)));
            }
            playVideos(list);
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

        Item {
            id: infoBox

            z: 10
            width: dimmer.width
            height: 60
            anchors { top: dimmer.top; topMargin: 50 }

            Rectangle {
                id: frame

                width: 72
                height: 54
                anchors { left: infoBox.left; leftMargin: 3; verticalCenter: infoBox.verticalCenter }
                color: _BACKGROUND_COLOR
                border.width: 1
                border.color: playlistInfoMouseArea.pressed ? _ACTIVE_COLOR_LOW : (cuteTubeTheme == "light") ? "grey" : "white"

                Image {
                    id: thumb

                    anchors { fill: frame; margins: 1 }
                    source: !(playlist == undefined) ? playlist.largeThumbnail : ""
                    sourceSize.width: thumb.width
                    sourceSize.height: thumb.height
                    smooth: true
                }

                MouseArea {
                    id: playlistInfoMouseArea

                    anchors.fill: frame
                    onClicked: {
                        if ((videoListModel.count > 0) && (!videoListModel.moreResults)) {
                            showPlaylistInfoDialog()
                        }
                        else {
                            messages.displayMessage(qsTr("Loading playlist videos. Please wait"))
                            videoListModel.waitingForInfo = true;
                        }
                    }
                }

                Grid {
                    id: textColumn

                    anchors { left: frame.right; leftMargin: 8; top: frame.top }
                    width: dimmer.width - playButton.width
                    columns: 2
                    spacing: 5

                    Text {
                        text: qsTr("Videos")
                        color: _TEXT_COLOR
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: videoListModel.totalResults
                        color: "grey"
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: qsTr("Created")
                        color: _TEXT_COLOR
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: !(playlist == undefined) ? playlist.createdDate.split(" ")[0] : ""
                        color: "grey"
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }
                }
            }

            PushButton {
                id: playButton

                width: (playButton.textWidth > 120) ? playButton.textWidth + 12 : 120
                height: 54
                anchors { right: infoBox.right; rightMargin: 3; verticalCenter: infoBox.verticalCenter }
                showText: true
                showIcon: false
                name: qsTr("Play all")
                nameSize: 18
                visible: !Controller.isSymbian
                onButtonClicked: {
                    if (Controller.getMediaPlayer() == "cutetubeplayer") {
                        if ((!videoListModel.loading) && (videoListModel.count > 0) && !(videoListModel.count < videoListModel.totalResults)) {
                            playPlaylist()
                        }
                        else {
                            messages.displayMessage(qsTr("Loading playlist videos. Please wait"))
                            videoListModel.waitingForPlayback = true;
                        }
                    }
                    else {
                        messages.displayMessage(messages._USE_CUTETUBE_PLAYER);
                    }
                }
            }

            Rectangle {
                height: 1
                anchors { bottom: infoBox.bottom; left: infoBox.left; leftMargin: 10; right: infoBox.right; rightMargin: 10 }
                color: _ACTIVE_COLOR_HIGH
                opacity: 0.5
            }
        }

        ListView {
            id: videoList

            property variant checkList : []

            anchors { fill: dimmer; topMargin: 110 }
            boundsBehavior: Flickable.DragOverBounds
            highlightMoveDuration: 500
            preferredHighlightBegin: 0
            preferredHighlightEnd: 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            cacheBuffer: 2500
            clip: true
            interactive: visibleArea.heightRatio < 1
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
                property int totalResults
                property int page : 1
                property bool waitingForPlayback
                property bool waitingForInfo
            }

            Connections {
                target: videoListModel
                onLoadingChanged: {
                    if ((!videoListModel.loading) && (videoListModel.count > 0)) {
                        if (videoListModel.count < videoListModel.totalResults) {
                            if (videoListModel.waitingForPlayback) {
                                playPlaylist();
                            }
                            else if (videoListModel.waitingForInfo) {
                                showPlaylistInfoDialog();
                            }
                            else {
                                VM.getVimeoVideos();
                            }
                        }
                    }
                }
            }

            delegate: VimeoListDelegate {
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
                    var video = VM.createVideoObject(videoListModel.get(index));
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
