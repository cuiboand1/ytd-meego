/* Main view functions */

var xTubeInstalled = false;

function restoreSettings() {
    /* Restore the user's settings from the database */

    if (Controller.xTubeInstalled()) {
        Qt.include("xtube.js");
        xTubeInstalled = true;
    }
    Settings.initialize();
    cuteTubeTheme = Settings.getSetting("theme");
    var catOne = Settings.getSetting("categoryFeedOne");
    var catTwo = Settings.getSetting("categoryFeedTwo");
    var catOrder = Settings.getSetting("categoryOrder");
    setCategoryFeeds(catOne, catTwo, catOrder);
    Controller.setOrientation(Settings.getSetting("screenOrientation"));
    if (Controller.isSymbian) {
        Controller.setMediaPlayer("Media Player");
    }
    else {
        Controller.setMediaPlayer(Settings.getSetting("mediaPlayer"));
    }
    YouTube.setPlaybackQuality(Settings.getSetting("playbackQuality"));
    DownloadManager.setDownloadQuality(Settings.getSetting("downloadQuality"));
    Sharing.setFacebookToken(Settings.getAccessToken("Facebook"));
    signInToDefaultAccount();
    getArchiveVideos();
    Settings.restoreDownloads();
}

function getArchiveVideos() {
    /* Retrieve archive videos and populate the list model */

    var videos = Settings.getAllArchiveVideos("date", "ASC");
    for (var i = 0; i < videos.length ; i++) {
        var archiveItem = { "filePath": videos[i][0], "title": videos[i][1],
            "thumbnail": videos[i][2], "quality": videos[i][3],
            "isNew": videos[i][4], "date": videos[i][5] };
        archiveModel.insert(0, archiveItem);
    }
}

function moveToArchive(video) {
    var date = new Date();
    video["date"] = date.valueOf();
    Settings.addVideoToArchive(video);
    archiveModel.insert(0, video);
    downloadModel.remove(downloadModel.currentDownload);
    downloadModel.getNextDownload();
}

function signInToDefaultAccount() {
    var defaultAccount = Settings.getDefaultAccount();
    if (defaultAccount != "unknown") {
        var username = defaultAccount[0];
        var password = defaultAccount[1];
        toggleBusy(true);
        YouTube.login(username, password);
    }
    else if (Settings.getSetting("noAccountDialog") != "raised") {
        homeView.showNoAccountDialog();
    }
}

function getSubscriptions() {
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
    doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
    doc.send();
}

function appendSubscriptions() {
    /* Append subscriptions to the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            subscriptionsModel.appendXml(xml);
        }
    }
    doc.open("GET", _SUBSCRIPTIONS_FEED + "&start-index=" + (subscriptionsModel.count + 1).toString());
    doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
    doc.send();
}

function getPlaylists() {
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
    doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
    doc.send();
}

function appendPlaylists() {
    /* Append playlists to the model */

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            playlistModel.appendXml(xml);
        }
    }
    doc.open("GET", _PLAYLISTS_FEED + "&start-index=" + (playlistModel.count + 1).toString());
    doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
    doc.send();
}

function goHome() {
    windowView.currentIndex = 0;
    notificationArea.titleList = ["cuteTube"];
    for (var i = 1; i < viewsModel.children.length; i++) {
        viewsModel.children[i].source = "";
    }
}

function goToPreviousView() {
    var i = windowView.currentIndex;
    windowView.decrementCurrentIndex();
    viewsModel.children[i].source = "";
    notificationArea.removeTitle();
    toggleBusy(false);
}

function loadAccountView() {

    if (userIsSignedIn()) {
        var loader = viewsModel.children[windowView.currentIndex + 1];
        windowView.currentItem.opacity = 0;
        loader.source = "MyAccountView.qml";
        loader.item.uploads.connect(loadVideos);
        loader.item.favourites.connect(loadVideos);
        loader.item.playlists.connect(loadPlaylists);
        loader.item.subscriptions.connect(loadSubscriptions);
        loader.item.goToVideo.connect(loadVideoInfo);
        loader.item.goToUserVideos.connect(loadUserVideos);
        notificationArea.addTitle(qsTr("My Channel"));
        windowView.incrementCurrentIndex();
    }
    else {
        messages.displayMessage(messages._NO_ACCOUNT_FOUND);
    }
}

function loadArchiveView() {
    /* Loads the view of previously downloaded videos */

    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "ArchiveListView.qml";
    loader.item.playVideos.connect(loadPlaybackView);
    notificationArea.addTitle(qsTr("Archive"));
    windowView.incrementCurrentIndex();
}

function loadVideos(feed, title) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "VideoListView.qml";
    loader.item.goToVideo.connect(loadVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    loader.item.setVideoFeed(feed);
    notificationArea.addTitle(title);
    windowView.incrementCurrentIndex();
}

function loadUserVideos(username) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "UserVideosView.qml";
    loader.item.goToVideo.connect(loadVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    loader.item.getUserProfile(username);
    notificationArea.addTitle(username);
    windowView.incrementCurrentIndex();
}

function loadPlaylistVideos(playlist) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "PlaylistVideosView.qml";
    loader.item.goToVideo.connect(loadVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    if (playlist.xml) {
        loader.item.setPlaylistXml(playlist);
        notificationArea.addTitle(playlist.info.title);
    }
    else {
        loader.item.setPlaylist(playlist);
        notificationArea.addTitle(playlist.title);
    }
    windowView.incrementCurrentIndex();
}

function loadPlaylists() {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "PlaylistsView.qml";
    loader.item.goToPlaylist.connect(loadPlaylistVideos);
    loader.item.playVideos.connect(loadPlaybackView);
    notificationArea.addTitle(qsTr("My Playlists"));
    windowView.incrementCurrentIndex();
}

function loadSubscriptions() {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "SubscriptionsView.qml";
    loader.item.goToUserVideos.connect(loadUserVideos);
    loader.item.goToNewSubVideos.connect(loadVideos);
    notificationArea.addTitle(qsTr("My Subscriptions"));
    windowView.incrementCurrentIndex();
}

function loadVideoInfo(video) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "VideoInfoView.qml";
    loader.item.playVideo.connect(loadPlaybackView);
    loader.item.goToVideo.connect(loadVideoInfo);
    loader.item.authorClicked.connect(loadUserVideos);
    loader.item.search.connect(search);
    loader.item.setVideo(video);
    notificationArea.addTitle(qsTr("Video Info"));
    windowView.incrementCurrentIndex();
}

function loadPlaybackView(videoList) {
    if (Controller.getMediaPlayer() == "cutetubeplayer") {
        Controller.setOrientation("landscape");
        var loader = viewsModel.children[windowView.currentIndex + 1];
        windowView.currentItem.opacity = 0;
        loader.source = "VideoPlaybackView.qml";
        notificationArea.addTitle(qsTr("Playback View"));
        toggleControls(false);
        _VIDEO_PLAYING = true;
        loader.item.setPlaylist(videoList);
        windowView.incrementCurrentIndex();
        loader.item.playbackStopped.connect(stopPlaying);
    }
    else {
        var video = videoList[0];
        if (video.archive) {
            Controller.playVideo(video.filePath);
        }
        else if (video.xtube) {
            Controller.playVideo(video.url);
        }
        else {
            YouTube.getVideoUrl(video.videoId);
        }
    }
}

function youtubeSearch(query, order) {
    /* Perform a YouTube search and open video list window */

    var encodedQuery = encodeURIComponent(query.replace(/\s.\s/gi, " "));
    var safe = Settings.getSetting("safeSearch");
    var videoFeed = ("http://gdata.youtube.com/feeds/api/videos?v=2&max-results=50&safeSearch=" + safe + "&q=%22"
                     + encodedQuery + "%22%7C" + encodedQuery.replace(/\s/g, "+") + "&orderby=" + order);
    loadVideos(videoFeed, qsTr("Search ") + "('" + query + "')");
}

function search(query, order) {
    /* Check if xTube is installed and parse the search query */

    if (xTubeInstalled) {
        var youporn = /^yp:/i;
        var tubeeight = /^t8:/i;
        var pornhub = /^ph:/i;
        if (youporn.test(query)) {
            loadXtubeVideos("youporn", query.slice(3), order);
        }
        else if (tubeeight.test(query)) {
            loadXtubeVideos("tube8", query.slice(3), order);
        }
        else if (pornhub.test(query)) {
            loadXtubeVideos("pornhub", query.slice(3), order);
        }
        else {
            youtubeSearch(query, order);
        }
    }
    else {
        youtubeSearch(query, order);
    }
}

function stopPlaying() {
    toggleControls(true);
    _VIDEO_PLAYING = false;
    Controller.setOrientation(Settings.getSetting("screenOrientation"));
    Controller.doNotDisturb(false);
    goToPreviousView();
}
