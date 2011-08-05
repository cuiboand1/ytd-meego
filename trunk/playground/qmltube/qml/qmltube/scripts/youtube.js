Qt.include("createobject.js")
Qt.include("videolistscripts.js")

function getYouTubeSearch(query, order) {

    var encodedQuery = encodeURIComponent(query.replace(/\s.\s/gi, " "));
    var safe = Settings.getSetting("safeSearch");
    var videoFeed = "http://gdata.youtube.com/feeds/api/videos?v=2&max-results=50&safeSearch=" + safe + "&q=%22"
        + encodedQuery + "%22%7C" + encodedQuery.replace(/\s/g, "+") + "&orderby=" + order + "&alt=json";
    return videoFeed;
}

function getYouTubeVideos() {
    videoListModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            //            console.log(doc.responseText)
            var results = eval("(" + doc.responseText + ")");
            if (videoListModel.page == 0) {
                videoListModel.totalResults = parseInt(results.feed.openSearch$totalResults.$t);
            }
            if (results.feed.entry) {
                var res;
                for (var i = 0; i < results.feed.entry.length; i++) {
                    res = results.feed.entry[i];
                    if ((res.app$control) && (res.app$control.yt$state) && (res.app$control.yt$state.reasonCode != "limitedSyndication")) {
                        videoListModel.totalResults--;
                    }
                    else {
                        videoListModel.append({ "playerUrl": "http://youtube.com/watch?v=" + res.media$group.yt$videoid.$t, "id": res.id.$t,
                                              "videoId": res.media$group.yt$videoid.$t, "title": res.title.$t,
                                              "description": res.media$group.media$description.$t, "author": res.media$group.media$credit[0].$t,
                                              "likes": res.yt$rating ? res.yt$rating.numLikes : "0", "dislikes": res.yt$rating ? res.yt$rating.numDislikes : "0",
                                              "views": res.yt$statistics ? res.yt$statistics.viewCount : "0", "duration": res.media$group.yt$duration.seconds,
                                              "tags": res.media$group.media$keywords.$t, "uploadDate": res.media$group.yt$uploaded.$t,
                                              "thumbnail": res.media$group.media$thumbnail[0].url, "comments": res.gd$comments ? res.gd$comments.gd$feedLink.countHint : "0",
                                              "largeThumbnail": res.media$group.media$thumbnail[1].url, "youtube": true });
                    }
                }
            }
            videoListModel.loading = false;
            videoListModel.page++
        }
    }
    doc.open("GET", videoFeed + "&start-index=" + (videoListModel.page * 50 + 1).toString());
    if ((videoFeed == _FAVOURITES_FEED) || (videoFeed == _UPLOADS_FEED) || (videoFeed == _NEW_SUB_VIDEOS_FEED)) {
        doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken); // Set 'Authorization' header if viewing the favourites/uploads feed
    }
    doc.send();
}

function getInbox() {
    /* Retrieve the user's message inbox */

    inboxModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            //            console.log(doc.responseText)
            var results = eval("(" + doc.responseText + ")");
            if (results.feed.entry) {
                var res;
                for (var i = 0; i < results.feed.entry.length; i++) {
                    res = results.feed.entry[i];
                    inboxModel.append({ "playerUrl": "http://youtube.com/watch?v=" + res.media$group.yt$videoid.$t, "id": res.id.$t,
                                          "videoId": res.media$group.yt$videoid.$t, "title": res.title.$t,
                                          "description": res.media$group.media$description.$t, "author": res.author[0].name.$t,
                                          "subject": res.title.$t, "uploader": res.media$group.media$credit[0].$t,
                                          "message": res.summary ? res.summary.$t : "", "messageDate": res.published.$t,
                                          "likes": res.yt$rating ? res.yt$rating.numLikes : "0", "dislikes": res.yt$rating ? res.yt$rating.numDislikes : "0",
                                          "views": res.yt$statistics ? res.yt$statistics.viewCount : "0", "duration": res.media$group.yt$duration.seconds,
                                          "tags": res.media$group.media$keywords.$t, "uploadDate": res.media$group.yt$uploaded.$t,
                                          "thumbnail": res.media$group.media$thumbnail[0].url, "comments": res.gd$comments ? res.gd$comments.gd$feedLink.countHint : "0",
                                          "largeThumbnail": res.media$group.media$thumbnail[1].url, "youtube": true });
                }
            }
            inboxModel.loading = false;
        }
    }
    doc.open("GET", "http://gdata.youtube.com/feeds/api/users/default/inbox?v=2&max-results=50&alt=json");
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function getComments(videoId) {
    commentsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            //            console.log(doc.responseText)
            var results = eval("(" + doc.responseText + ")");
            if (commentsModel.page == 0) {
                commentsModel.totalResults = parseInt(results.feed.openSearch$totalResults.$t);
            }
            if (results.feed.entry) {
                var res;
                for (var i = 0; i < results.feed.entry.length; i++) {
                    res = results.feed.entry[i];
                    commentsModel.append({ "author": res.author[0].name.$t,
                                            "date": res.published.$t,
                                            "comment": res.content.$t,
                                            "commentId": res.id.$t });
                }
            }
            commentsModel.loading = false;
            commentsModel.page++
        }        
    }
    doc.open("GET", "http://gdata.youtube.com/feeds/api/videos/" + videoId + "/comments?v=2&max-results=50&alt=json&start-index=" + (commentsModel.page * 50 + 1).toString());
    doc.send();
}

function getSubscriptions() {
    /* Retrieve the user's subscriptions and
      populate the model */

    subscriptionsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
//                        console.log(doc.responseText)
            var results = eval("(" + doc.responseText + ")");
            if (subscriptionsModel.page === 0) {
                subscriptionsModel.totalResults = parseInt(results.feed.openSearch$totalResults.$t);
            }
            if (results.feed.entry) {
                var res;
                for (var i = 0; i < results.feed.entry.length; i++) {
                    res = results.feed.entry[i];
                    subscriptionsModel.append({ "title": res.yt$username.$t,
                                            "subscriptionId": res.id.$t });
                }
            }
            subscriptionsModel.loading = false;
            subscriptionsModel.page++
        }
    }
    doc.open("GET", _SUBSCRIPTIONS_FEED + "&start-index=" + (subscriptionsModel.page * 50 + 1).toString());
    doc.setRequestHeader("Authorization", "AuthSub token=" + YouTube.accessToken);
    doc.send();
}

function getPlaylists() {
    /* Retrieve the user's playlists and
      populate the model */

    playlistModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
//                        console.log(doc.responseText)
            var results = eval("(" + doc.responseText + ")");
            if (playlistModel.page === 0) {
                playlistModel.totalResults = parseInt(results.feed.openSearch$totalResults.$t);
            }
            if (results.feed.entry) {
                var res;
                for (var i = 0; i < results.feed.entry.length; i++) {
                    res = results.feed.entry[i];
                    playlistModel.append({ "playlistId": res.yt$playlistId.$t,
                                            "title": res.title.$t,
                                            "videoCount": res.yt$countHint.$t,
                                            "createdDate": res.published.$t,
                                            "updatedDate": res.updated.$t,
                                            "description": res.summary.$t });
                }
            }
            playlistModel.loading = false;
            playlistModel.page++
        }        
    }
    doc.open("GET", _PLAYLISTS_FEED + "&start-index=" + (playlistModel.page * 50 + 1).toString());
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
    if (!(YouTube.currentUser === "")) {
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
    if (!(YouTube.currentUser === "")) {
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

function getUserProfile(user) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
//            console.log(doc.responseText)
            var res = eval("(" + doc.responseText + ")").entry;
            userThumbnail = res.media$thumbnail.url;
            for (var i = 0; i < res.gd$feedLink.length; i++) {
                if (res.gd$feedLink[i].rel == "http://gdata.youtube.com/schemas/2007#user.uploads") {
                    videoCount = res.gd$feedLink[i].countHint;
                }
            }
            subscriberCount = res.yt$statistics.subscriberCount;
            subscriberCount = res.yt$statistics.subscriberCount;
            about = res.yt$aboutMe ? res.yt$aboutMe.$t : "";
            age = res.yt$age ? res.yt$age.$t : "";
            firstName = res.yt$firstName ? res.yt$firstName.$t : "";
            lastName = res.yt$lastName ? res.yt$lastName.$t : "";
            gender = res.yt$gender ? res.yt$gender.$t : "";
        }
    }
    doc.open("GET", "http://gdata.youtube.com/feeds/api/users/" + user + "?v=2&alt=json");
    doc.send();
}

function setSubscription() {
    if (!(YouTube.currentUser === "")) {
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

function createVideoObject(video) {
    var videoObject = {};
    videoObject["id"] = video.id;
    videoObject["videoId"] = video.videoId;
    videoObject["playerUrl"] = video.playerUrl;
    videoObject["title"] = video.title;
    videoObject["duration"] = video.duration;
    videoObject["description"] = video.description;
    videoObject["author"] = video.author;
    videoObject["uploadDate"] = video.uploadDate;
    videoObject["views"] = video.views;
    videoObject["likes"] = video.likes;
    videoObject["dislikes"] = video.dislikes;
    videoObject["thumbnail"] = video.thumbnail;
    videoObject["largeThumbnail"] = video.largeThumbnail;
    videoObject["comments"] = video.comments;
    videoObject["youtube"] = true;
    return videoObject;
}

function createPlaylistObject(playlist) {
    var playlistObject = {};
    playlistObject["title"] = playlist.title;
    playlistObject["playlistId"] = playlist.playlistId;
    playlistObject["videoCount"] = playlist.videoCount;
    playlistObject["createdDate"] = playlist.createdDate;
    playlistObject["updatedDate"] = playlist.updatedDate;
    playlistObject["description"] = playlist.description;
    return playlistObject;
}

function addVideosToPlaybackQueue() {
    if (videoList.checkList.length > 0) {
        if (Controller.getMediaPlayer() == "cutetubeplayer") {
            var list = [];
            var video;
            for (var i = 0; i < videoList.checkList.length; i++) {
                video = createVideoObject(videoListModel.get(videoList.checkList[i]));
                list.push(video);
            }
            playVideos(list);
        }
        else {
            messages.displayMessage(messages._USE_CUTETUBE_PLAYER);
        }
        videoList.checkList = [];
    }
}
