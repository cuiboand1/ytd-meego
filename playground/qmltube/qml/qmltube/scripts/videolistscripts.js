/* Video list functions */

function appendVideoFeed() {
    videoListModel.loading = true;

    var startIndex = videoListModel.count + 1;
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            videoListModel.appendXml(xml);
        }

        videoListModel.loading = false;
    }
    doc.open("GET", videoFeed + "&start-index=" + startIndex.toString());
    if ((videoFeed == _FAVOURITES_FEED) || (videoFeed == _UPLOADS_FEED) || (videoFeed == _NEW_SUB_VIDEOS_FEED)) {
        doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
    }
    doc.send();
}

function showVideoDialog(index) {
    if (dimmer.state == "") {
        toggleControls(false);
        var video = videoListModel.get(index);
        var videoDialog = ObjectCreator.createObject("VideoListDialog.qml", window);
        videoDialog.setVideo(video);
        videoDialog.infoClicked.connect(goToVideo);
        videoDialog.playClicked.connect(playVideo);
        videoDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        videoDialog.state = "show";
    }
}

function showPlaylistDialog() {
    if (userIsSignedIn()) {
        if (dimmer.state == "") {
            toggleControls(false);
            var playlistDialog = ObjectCreator.createObject("AddToPlaylistDialog.qml", window);
            playlistDialog.playlistClicked.connect(addVideosToPlaylist);
            playlistDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            playlistDialog.state = "show";
        }
        else {
            messages.displayMessage(messages._NOT_SIGNED_IN);
        }
    }
}

function addVideosToPlaybackQueue() {
    if (videoList.checkList.length > 0) {
        if (Controller.getMediaPlayer() == "cutetubeplayer") {
            var list = [];
            for (var i = 0; i < videoList.checkList.length; i++) {
                list.push(videoListModel.get(videoList.checkList[i]));
            }
            playVideos(list);
        }
        else {
            messages.displayMessage(messages._USE_CUTETUBE_PLAYER);
        }
        videoList.checkList = [];
    }
}

function addVideosToDownloads(convertToAudio) {
    for (var i = 0; i < videoList.checkList.length; i++) {
        var video = videoListModel.get(videoList.checkList[i]);
        if (convertToAudio) {
            addAudioDownload(video);
        }
        else {
            addDownload(video);
        }
    }
    videoList.checkList = [];
}

function addVideosToPlaylist(playlistId) {
    closeDialogs();
    toggleBusy(true);
    for (var i = 0; i < videoList.checkList.length; i++) {
        var videoId = videoListModel.get(videoList.checkList[i]).videoId;
        YouTube.addToPlaylist(videoId, playlistId);
    }
    videoList.checkList = [];
}

function deleteVideosFromPlaylist() {
    if (userIsSignedIn()) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            for (var i = 0; i < videoList.checkList.length; i++) {
                var splitId = videoListModel.get(videoList.checkList[i]).id.split(":");
                var playlistId = splitId[3];
                var playlistVideoId = splitId[4];
                YouTube.deleteFromPlaylist(playlistId, playlistVideoId);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function addVideosToFavourites() {
    if (userIsSignedIn()) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            for (var i = 0; i < videoList.checkList.length; i++) {
                var videoId = videoListModel.get(videoList.checkList[i]).videoId;
                YouTube.addToFavourites(videoId);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function deleteVideosFromFavourites() {
    if (userIsSignedIn()) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            for (var i = 0; i < videoList.checkList.length; i++) {
                var favouriteId = videoListModel.get(videoList.checkList[i]).id.split(":")[3];
                YouTube.deleteFromFavourites(favouriteId);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function copyVideosToClipboard() {
    var urls = "";
    for (var i = 0; i < videoList.checkList.length; i++) {
        var url = videoListModel.get(videoList.checkList[i]).playerUrl.split("&")[0];
        urls = urls + url + "\n";
    }
    Controller.copyToClipboard(urls);
    videoList.checkList = [];
}

function closeDialogs() {
    /* Close any open dialogs and return the window to its default state */

    dialogClose();
    dimmer.state = "";
    toggleControls(true);
}

function setSubscription() {
    if (userIsSignedIn()) {
        toggleBusy(true);
        if (isSubscribed) {
            YouTube.unsubscribeToChannel(subscriptionId);
        }
        else {
            YouTube.subscribeToChannel(username);
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    closeDialogs();
}

function indexInCheckList(index) {
    var result = false;
    for (var i = 0; i < videoList.checkList.length; i ++) {
        if (videoList.checkList[i] == index) {
            result = true;
        }
    }
    return result;
}

function showOrHideFilter() {
    if (listFilter.source == "") {
        if ((event.key != Qt.Key_Left)
                && (event.key != Qt.Key_Right)
                && (event.key != Qt.Key_Up)
                && (event.key != Qt.Key_Down)
                && (event.key != Qt.Key_Control)
                && (event.key != Qt.Key_Shift)
                && (event.key != Qt.Key_Enter)
                && (event.key != Qt.Key_Return)
                && (event.key != Qt.Key_Backspace)) {
            listFilter.source = "ListFilter.qml";
            listFilter.item.filterString = event.text;
        }
    }
}
