/* Main view functions */

var xTubeInstalled = false;
Qt.include("youtube.js");
Qt.include("dailymotion.js");
Qt.include("vimeo.js");

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
    var twitterToken = Settings.getAccessToken("Twitter");
    if (!(twitterToken == "unknown")) {
        Sharing.setTwitterToken(twitterToken.token, twitterToken.secret);
    }
    getDefaultAccounts();
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

function getDefaultAccounts() {
    var ytAcc = Settings.getDefaultAccount("YouTube");
    var dmAcc = Settings.getDefaultAccount("Dailymotion");
    var vAcc = Settings.getDefaultAccount("vimeo");
    if (!(ytAcc == "unknown")) {
        YouTube.setUserCredentials(ytAcc.username, ytAcc.accessToken);
    }
    if (!(dmAcc == "unknown")) {
        refreshDailymotionAccessToken(dmAcc);
    }
    if (!(vAcc == "unknown")) {
        Vimeo.setUserCredentials(vAcc.username, vAcc.accessToken, vAcc.tokenSecret);
    }
    if (!((userIsSignedIn()) || (Settings.getSetting("noAccountDialog") == "raised"))) {
        homeView.showNoAccountDialog();
    }
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
        loader.item.playVideo.connect(loadPlaybackView);
        loader.item.goToUserVideos.connect(loadUserVideos);
        notificationArea.addTitle(qsTr("My Channel"));
        windowView.incrementCurrentIndex();
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
}

function loadVideos(feeds, title, site) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "VideoListView.qml";
    loader.item.goToYTVideo.connect(loadVideoInfo);
    loader.item.goToDMVideo.connect(loadDMVideoInfo);
    loader.item.goToVimeoVideo.connect(loadVimeoVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    if (!site) {
        site = _DEFAULT_SITE;
    }
    loader.item.setVideoFeeds(feeds, site);

    var i;
    if ((i = title.indexOf("\n")) >= 0)	//NPM:if multiline category name
	notificationArea.addTitle(title.substring(0, i)); //trim second line and only display first.
    else
	notificationArea.addTitle(title); //display the non-multiline title
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
    if (playlist.videos) {
        loader.item.setPlaylistVideos(playlist);
        notificationArea.addTitle(playlist.info.title);
    }
    else {
        loader.item.setPlaylist(playlist);
        notificationArea.addTitle(playlist.title);
    }
    windowView.incrementCurrentIndex();
}

function loadDMPlaylistVideos(playlist) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "DMPlaylistVideosView.qml";
    loader.item.goToVideo.connect(loadDMVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    if (playlist.videos) {
        loader.item.setPlaylistVideos(playlist);
        notificationArea.addTitle(playlist.info.title);
    }
    else {
        loader.item.setPlaylist(playlist);
        notificationArea.addTitle(playlist.title);
    }
    windowView.incrementCurrentIndex();
}

function loadVimeoPlaylistVideos(playlist) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "VimeoPlaylistVideosView.qml";
    loader.item.goToVideo.connect(loadVimeoVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    if (playlist.videos) {
        loader.item.setPlaylistVideos(playlist);
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
    loader.item.goToYTPlaylist.connect(loadPlaylistVideos);
    loader.item.goToDMPlaylist.connect(loadDMPlaylistVideos);
    loader.item.goToVimeoPlaylist.connect(loadVimeoPlaylistVideos);
    loader.item.playVideos.connect(loadPlaybackView);
    notificationArea.addTitle(qsTr("My Playlists"));
    windowView.incrementCurrentIndex();
}

function loadSubscriptions() {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "SubscriptionsView.qml";
    loader.item.goToUserVideos.connect(loadUserVideos);
    loader.item.goToDMUserVideos.connect(loadDMUserVideos);
    loader.item.goToVimeoUserVideos.connect(loadVimeoUserVideos);
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
    loader.item.searchYouTube.connect(search);
    loader.item.setVideo(video);
    notificationArea.addTitle(qsTr("Video Info"));
    windowView.incrementCurrentIndex();
}

function loadDMVideoInfo(video) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "DMInfoView.qml";
    loader.item.playVideo.connect(loadPlaybackView);
    loader.item.goToVideo.connect(loadDMVideoInfo);
    loader.item.authorClicked.connect(loadDMUserVideos);
    loader.item.searchDailymotion.connect(search);
    loader.item.setVideo(video);
    notificationArea.addTitle(qsTr("Video Info"));
    windowView.incrementCurrentIndex();
}

function loadVimeoVideoInfo(video) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "VimeoInfoView.qml";
    loader.item.playVideo.connect(loadPlaybackView);
    loader.item.goToVideo.connect(loadVideoInfo);
    loader.item.authorClicked.connect(loadVimeoUserVideos);
    loader.item.searchVimeo.connect(search);
    loader.item.setVideo(video);
    notificationArea.addTitle(qsTr("Video Info"));
    windowView.incrementCurrentIndex();
}

function loadDMUserVideos(username) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "DMUserVideosView.qml";
    loader.item.goToVideo.connect(loadDMVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    loader.item.setVideoFeed(username);
    notificationArea.addTitle(username);
    windowView.incrementCurrentIndex();
}

function loadVimeoUserVideos(user) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    windowView.currentItem.visible = false;
    loader.source = "VimeoUserVideosView.qml";
    loader.item.goToVideo.connect(loadVimeoVideoInfo);
    loader.item.playVideos.connect(loadPlaybackView);
    loader.item.setUserProfile(user);
    notificationArea.addTitle(user.title);
    windowView.incrementCurrentIndex();
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

function loadLiveVideos() {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "LiveVideoListView.qml";
    loader.item.playVideos.connect(loadPlaybackView);
    notificationArea.addTitle(qsTr("YouTube Live"));
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
        else if (video.dailymotion) {
            DailyMotion.getVideoUrl(video.id);
        }
        else if (video.vimeo) {
            Vimeo.getVideoUrl(video.id);
        }
        else if (video.live) {
            YouTube.getLiveVideoUrl(video.videoId);
        }
        else {
            YouTube.getVideoUrl(video.videoId);
        }
    }
}

function stopPlaying() {
    toggleControls(true);
    _VIDEO_PLAYING = false;
    Controller.setOrientation(Settings.getSetting("screenOrientation"));
    Controller.doNotDisturb(false);
    goToPreviousView();
}

function search(query, order, site) {
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
            var feeds = getSearches(query, order);
            var title = qsTr("Search ") + "('" + query + "')"
            loadVideos(feeds, title, site);
        }
    }
    else {
        var feeds = getSearches(query, order);
        var title = qsTr("Search ") + "('" + query + "')"
        loadVideos(feeds, title, site);
    }
}

function getSearches(query, order) {
    var ytFeed = getYouTubeSearch(query, order);
    var dmFeed = getDailymotionSearch(query, order);
    var vimeoFeed = getVimeoSearch(query, order);
    var feeds = { "youtube": ytFeed, "dailymotion": dmFeed, "vimeo": vimeoFeed };
    return feeds;
}
