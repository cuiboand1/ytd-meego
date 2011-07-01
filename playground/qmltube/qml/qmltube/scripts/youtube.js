Qt.include("createobject.js")
Qt.include("videolistscripts.js")

function getYouTubeSearch(query, order) {

    var encodedQuery = encodeURIComponent(query.replace(/\s.\s/gi, " "));
    var safe = Settings.getSetting("safeSearch");
    var videoFeed = "http://gdata.youtube.com/feeds/api/videos?v=2&max-results=50&safeSearch=" + safe + "&q=%22"
                     + encodedQuery + "%22%7C" + encodedQuery.replace(/\s/g, "+") + "&orderby=" + order;
    return videoFeed;
}

function getYouTubeVideos() {
    videoListModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            videoListModel.setXml(xml);

            videoListModel.loading = false;
            videoList.positionViewAtIndex(0, ListView.Beginning);
        }
    }
    doc.open("GET", videoFeed);
    if ((videoFeed == _FAVOURITES_FEED) || (videoFeed == _UPLOADS_FEED) || (videoFeed == _NEW_SUB_VIDEOS_FEED)) {
        doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken); // Set 'Authorization' header if viewing the favourites/uploads feed
    }
    doc.send();
}

function appendYouTubeVideos() {
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
        doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    }
    doc.send();
}

function getYouTubeSubscriptions() {
    /* Retrieve the user's subscriptions and
      populate the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            subscriptionsModel.setXml(xml);
        }
    }
    doc.open("GET", _SUBSCRIPTIONS_FEED);
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function appendYouTubeSubscriptions() {
    /* Append subscriptions to the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            subscriptionsModel.appendXml(xml);
        }
    }
    doc.open("GET", _SUBSCRIPTIONS_FEED + "&start-index=" + (subscriptionsModel.count + 1).toString());
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function getYouTubePlaylists() {
    /* Retrieve the user's playlists and
      populate the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            playlistModel.setXml(xml);
        }
    }
    doc.open("GET", _PLAYLISTS_FEED);
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function appendYouTubePlaylists() {
    /* Append playlists to the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            playlistModel.appendXml(xml);
        }
    }
    doc.open("GET", _PLAYLISTS_FEED + "&start-index=" + (playlistModel.count + 1).toString());
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function showPlaylistDialog() {
    if (!(YouTube.currentUser == "")) {
        if (dimmer.state == "") {
            toggleControls(false);
            var playlistDialog = createObject("AddToPlaylistDialog.qml", window);
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

function addVideosToPlaylist(playlistId) {
    closeDialogs();
    toggleBusy(true);
    var videoId;
    for (var i = 0; i < videoList.checkList.length; i++) {
        videoId = videoListModel.get(videoList.checkList[i]).videoId;
        YouTube.addToPlaylist(videoId, playlistId);
    }
    videoList.checkList = [];
}

function deleteVideosFromPlaylist() {
    if (!(YouTube.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var splitId;
            var playlistId;
            var playlistVideoId;
            for (var i = 0; i < videoList.checkList.length; i++) {
                splitId = videoListModel.get(videoList.checkList[i]).id.split(":");
                playlistId = splitId[3];
                playlistVideoId = splitId[4];
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
    if (!(YouTube.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var videoId;
            for (var i = 0; i < videoList.checkList.length; i++) {
                videoId = videoListModel.get(videoList.checkList[i]).videoId;
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
    if (!(YouTube.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var favouriteId;
            for (var i = 0; i < videoList.checkList.length; i++) {
                favouriteId = videoListModel.get(videoList.checkList[i]).id.split(":")[3];
                YouTube.deleteFromFavourites(favouriteId);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function setSubscription() {
    if (!(YouTube.currentUser== "")) {
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

function getCurrentLiveStreams() {
    videoListModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var res;
            var title;
            var videoId;
            var playerUrl;
            var author;
            var thumbnail;
            var page = doc.responseText;
            var results = page.split('live-now-list-container')[1].split('live-upcoming-list-container')[0].split('live-browse-thumb');
            for (var i = 1; i < results.length; i++) {
                res = results[i];
                title = res.split('"nofollow">')[1].split('<')[0];
                playerUrl = "http://www.youtube.com" + res.split('<a href="')[1].split('"')[0];
                videoId = playerUrl.split('/').pop();
                author = res.split('<a title="')[1].split('"')[0];
                thumbnail = res.split('src="')[1].split('"')[0];
                if (thumbnail.slice(0, 2) == "//") {
                    thumbnail = "http:" + thumbnail;
                }

                videoListModel.append({ "title": title, "videoId": videoId, "playerUrl": playerUrl,
                                      "author": author, "thumbnail": thumbnail, "live": true });
            }

            videoListModel.loading = false;
        }
    }
    doc.open("GET", "http://www.youtube.com/live");
    doc.send();
}
