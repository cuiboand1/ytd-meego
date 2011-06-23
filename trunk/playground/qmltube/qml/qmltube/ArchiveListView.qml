import QtQuick 1.0
import "scripts/settings.js" as Settings
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property string orderColumn : "date"
    property string dateOrder : "ASC"
    property string titleOrder : "DESC"
    property alias checkList: videoList.checkList

    signal playVideos(variant videos)
    signal dialogClose

    function getArchiveVideos(column, ascOrDesc) {
        /* Retrieve archive videos and populate the list model */
        orderColumn = column;

        var videos = Settings.getAllArchiveVideos(column, ascOrDesc);
        for (var i = 0; i < videos.length ; i++) {
            var archiveItem = { "filePath": videos[i][0], "title": videos[i][1],
                "thumbnail": videos[i][2], "quality": videos[i][3],
                "isNew": videos[i][4], "date": videos[i][5] };
            archiveModel.insert(0, archiveItem);
        }
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
        if (Controller.isSymbian) {
            showDeleteDialog();
        }
        else {
            playArchiveVideos();
        }
    }

    function onMenuButtonThreeClicked() {
        if (Controller.isSymbian) {
            sortByDate();
        }
        else showDeleteDialog();
    }

    function onMenuButtonFourClicked() {
        if(Controller.isSymbian) {
            sortByTitle();
        }
        else {
            sortByDate();
        }
    }

    function onMenuButtonFiveClicked() {
        sortByTitle();
    }

    function playArchiveVideos() {
        /* Play the chosen videos */

        if (videoList.checkList.length > 0) {
            if (Controller.getMediaPlayer() == "cutetubeplayer") {
                var list = [];
                var video;
                for (var i = 0; i < videoList.checkList.length; i++) {
                    video = archiveModel.get(videoList.checkList[i]);
                    if ((!Controller.isSymbian) && ((video.quality == "360p") || (video.quality == "480p") || (video.quality == "720p"))) {
                        messages.displayMessage(messages._UNABLE_TO_PLAY);
                    }
                    else {
                        list.push({ "title": video.title, "filePath": video.filePath, "quality": video.quality,
                                  "thumbnail": video.thumbnail, "date": video.date, "archive": true });
                    }
                }
                playVideos(list);
            }
            else {
                messages.displayMessage(messages._USE_CUTETUBE_PLAYER);
            }
            videoList.checkList = [];
        }
    }

    function showDeleteDialog() {
        /* Show the delete dialog */

        if (videoList.checkList.length > 0) {
            toggleControls(false);
            var deleteDialog = ObjectCreator.createObject("ConfirmDeleteDialog.qml", window);
            deleteDialog.archiveClicked.connect(deleteFromArchive);
            deleteDialog.deviceClicked.connect(deleteFromDevice);
            deleteDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            deleteDialog.state = "show";
        }

    }

    function deleteFromArchive() {
        /* Delete chosen videos from the archive */

        closeDialogs();
        if (videoList.checkList.length > 0) {
            for (var i = 0; i < videoList.checkList.length; i++) {
                var video = archiveModel.get(videoList.checkList[i]);
                if (Settings.deleteVideoFromArchive(video.filePath)) {
                    messages.displayMessage(qsTr("Video(s) deleted from archive"));
                }
                else {
                    messages.displayMessage(qsTr("Unable to delete video(s) from archive"))
                }
            }
            videoList.checkList = [];
            archiveModel.clear();
            getArchiveVideos(orderColumn, "ASC");
        }
    }

    function deleteFromDevice() {
        /* Delete chosen videos from both the archive and the device */

        closeDialogs();
        if (videoList.checkList.length > 0) {
            for (var i = 0; i < videoList.checkList.length; i++) {
                var video = archiveModel.get(videoList.checkList[i]);
                if (Settings.deleteVideoFromArchive(video.filePath)) {
                    Controller.deleteVideo(video.filePath);
                }
                else {
                    messages.displayMessage(qsTr("Unable to delete video(s) from archive"))
                }
            }
            videoList.checkList = [];
            archiveModel.clear();
            getArchiveVideos(orderColumn, "ASC");
        }
    }

    function sortByDate() {
        /* Sort the archive list by date */

        archiveModel.clear();
        if (orderColumn == "date") {
            if (dateOrder == "ASC") {
                dateOrder = "DESC";
                getArchiveVideos("date", "DESC");
            }
            else {
                dateOrder = "ASC";
                getArchiveVideos("date", "ASC");
            }
        }
        else {
            getArchiveVideos("date", dateOrder);
        }
    }

    function sortByTitle() {
        /* Sort the archive list by title */

        archiveModel.clear();
        if (orderColumn == "title") {
            if (titleOrder == "ASC") {
                titleOrder = "DESC";
                getArchiveVideos("title", "DESC");
            }
            else {
                titleOrder = "ASC";
                getArchiveVideos("title", "ASC");
            }
        }
        else {
            getArchiveVideos("title", titleOrder);
        }
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        dimmer.state = "";
        toggleControls(true);
    }

    Connections {
        target: Controller

        onAlert: messages.displayMessage(message)
        onPlaybackStarted: archiveModel.markItemAsOld(url)
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Text {
            anchors.centerIn: dimmer
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "No videos in archive"
            visible: videoList.count == 0
        }

        ListView {
            id: videoList

            property variant checkList : []

            anchors { fill: dimmer; topMargin: 50 }
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.DragOverBounds
            highlightMoveDuration: 500
            preferredHighlightBegin: 0
            preferredHighlightEnd: 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            cacheBuffer: 2500
            interactive: visibleArea.heightRatio < 1

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

            model: archiveModel

            onCountChanged: positionViewAtIndex(0, ListView.Beginning)

            delegate: ArchiveDelegate {
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

                Connections {
                    onDelegateClicked: {
                        var video = archiveModel.get(index);
                        if ((!Controller.isSymbian) && ((video.quality == "360p") || (video.quality == "480p") || (video.quality == "720p"))) {
                            messages.displayMessage(messages._UNABLE_TO_PLAY);
                        }
                        else {
                            var list = [];
                            list.push({ "title": video.title, "filePath": video.filePath, "quality": video.quality,
                                      "thumbnail": video.thumbnail, "date": video.date, "archive": true });
                            playVideos(list);
                        }
                    }
                    onDelegatePressed: addOrRemoveFromCheckList()
                }

                checked: Scripts.indexInCheckList(index)
            }

            ScrollBar {}
        }

        MouseArea {
            id: mouseArea

            anchors { fill: dimmer; topMargin: 50 }
            enabled: false
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
