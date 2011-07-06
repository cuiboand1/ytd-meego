Qt.include("OAuth.js");
Qt.include("createobject.js")
Qt.include("videolistscripts.js")

function getVimeoSearch(query, order) {
    var searchOrders = { "rating": "most_liked", "published": "newest", "viewCount": "most_played", "relevance": "relevant" };
    order = searchOrders[order];
    var encodedQuery = encodeURIComponent(query.replace(/\s.\s/gi, " "));
    var videoFeed = [["method", "vimeo.videos.search"], ["sort", order], ["query", query]]
    return videoFeed;
}

function getVimeoVideos() {
    videoListModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            if (videoListModel.page == 1) {
                videoListModel.totalResults = parseInt(results.videos.total);
            }
            if (results.videos.video) {
                var tags = "";
                var res;
                for (var i = 0; i < results.videos.video.length; i++) {
                    res = results.videos.video[i];
                    if (res.urls.url.length < 2) {
                        videoListModel.totalResults--;
                    }
                    else {
                        if (res.tags) {
                            for (var ii = 0; ii < res.tags.tag.length; ii++) {
                                tags += res.tags.tag[ii]._content + ", ";
                            }
                        }
                        videoListModel.append({ "playerUrl": res.urls.url[0]._content,
                                              "id": res.id, "title": res.title,
                                              "description": res.description, "author": res.owner.display_name,
                                              "authorId": res.owner.id, "uploadDate": res.upload_date, "likes": res.number_of_likes,
                                              "views": res.number_of_plays, "comments": res.number_of_comments,
                                              "duration": res.duration, "tags": tags, "thumbnail": res.thumbnails.thumbnail[1]._content,
                                              "largeThumbnail": res.thumbnails.thumbnail[2]._content, "vimeo": true });
                        tags = "";
                    }
                }
            }

            videoListModel.page++;
            videoListModel.loading = false;
        }
    }
    var credentials = undefined;
    if (!(Vimeo.currentUser == "")) {
        credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    }
    var params = videoFeed;
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", credentials, undefined, params.concat([["format", "json"], ["full_response", "true"],
                                                                                                                              ["per_page", "50"], ["page", videoListModel.page.toString()]]));
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function getComments() {
    commentsList.loaded = true;
    vimeoCommentsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            var total = parseInt(results.comments.total);
            if (total > 0) {
                var res;
                for (var i = 0; i < results.comments.comment.length; i++) {
                    res = results.comments.comment[i];
                    vimeoCommentsModel.append({ "author": res.author.display_name, "authorId": res.author.id, "comment": res.text, "date": res.datecreate });
                }
            }

            vimeoCommentsModel.moreResults = (commentsModel.count < total);
            vimeoCommentsModel.loading = false;
            vimeoCommentsModel.page++;
        }
    }
    var params = [["method", "vimeo.videos.comments.getList"], ["format", "json"], ["video_id", videoId],
                  ["per_page", "50"], ["page", vimeoCommentsModel.page.toString()]];
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", undefined, undefined, params);
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function setSubscription(userId) {
    if (!(Vimeo.currentUser== "")) {
        toggleBusy(true);
        var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
        var params = [["method", isSubscribed ? "vimeo.people.removeSubscription" : "vimeo.people.addSubsciption"],
                      ["format", "json"], ["user_id", userId], ["types", "uploads"]];
        var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
        if (isSubscribed) {
            Vimeo.unsubscribeToChannel(oauthData.url, oauthData.header);
        }
        else {
            Vimeo.subscribeToChannel(oauthData.url, oauthData.header);
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    closeDialogs();
}

function setLike(like, id) {
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["method", "vimeo.videos.setLike"],
                  ["format", "json"], ["video_id", id], ["like", like]];
    var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    if (like) {
        Vimeo.addToFavourites(oauthData.url, oauthData.header);
    }
    else {
        Vimeo.deleteFromFavourites(oauthData.url, oauthData.header);
    }
}

function setLikes(like) {
    if (!(Vimeo.currentUser== "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var id;
            for (var i = 0; i < videoList.checkList.length; i++) {
                id = videoListModel.get(videoList.checkList[i]).id;
                setLike(like, id);
            }
            videoList.checkList = [];
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
}

function showPlaylistDialog() {
    if (!(Vimeo.currentUser == "")) {
        if (dimmer.state == "") {
            toggleControls(false);
            var playlistDialog = createObject("AddToPlaylistDialog.qml", window);
            playlistDialog.site = "vimeo";
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

function addToPlaylist(videoId, playlistId) {
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["method", "vimeo.albums.addVideo"],
                  ["format", "json"], ["video_id", videoId], ["album_id", playlistId]];
    var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    Vimeo.addToPlaylist(oauthData.url, oauthData.header);
}

function deleteFromPlaylist(videoId, playlistId) {
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["method", "vimeo.albums.removeVideo"],
                  ["format", "json"], ["video_id", videoId], ["album_id", playlistId]];
    var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    Vimeo.deleteFromPlaylist(oauthData.url, oauthData.header);
}

function deleteVideosFromPlaylist(playlistId) {
    if (!(Vimeo.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var videoId;
            for (var i = 0; i < videoList.checkList.length; i++) {
                videoId = videoListModel.get(videoList.checkList[i]).id;
                deleteFromPlaylist(videoId, playlistId);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function addVideosToPlaylist(playlistId) {
    closeDialogs();
    toggleBusy(true);
    var videoId;
    for (var i = 0; i < videoList.checkList.length; i++) {
        videoId = videoListModel.get(videoList.checkList[i]).id;
        addToPlaylist(videoId, playlistId);
    }
    videoList.checkList = [];
}

function createNewPlaylist(title, description, videoId) {
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["method", "vimeo.albums.create"],
                  ["format", "json"], ["title", title], ["description", description], ["video_id", videoId]];
    var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    Vimeo.createNewPlaylist(oauthData.url, oauthData.header);
}

function addComment(comment, id) {
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["method", "vimeo.videos.comments.addComment"],
                  ["format", "json"], ["video_id", id], ["comment_text", comment]];
    var oauthData = createOAuthHeader("vimeo", "POST", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    Vimeo.addComment(oauthData.url, oauthData.header);
}

function getVimeoPlaylists() {
    vimeoPlaylistModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            var total = parseInt(results.albums.total);
            if (total > 0) {
                var res;
                for (var i = 0; i < results.albums.album.length; i++) {
                    res = results.albums.album[i];
                    vimeoPlaylistModel.append({ "title": res.title, "id": res.id, "videoCount": res.total_videos,
                                              "createdDate": res.created_on, "description": res.description,
                                              "thumbnail": res.thumbnail_video.thumbnails.thumbnail[0]._content,
                                              "largeThumbnail": res.thumbnail_video.thumbnails.thumbnail[2]._content });
                }
            }

            vimeoPlaylistModel.moreResults = (vimeoPlaylistModel.count < total);
            vimeoPlaylistModel.loading = false;
            vimeoPlaylistModel.page++;
        }
    }
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["format", "json"], ["method", "vimeo.albums.getAll"],
                  ["per_page", "50"], ["sort", "alphabetical"], ["page", vimeoPlaylistModel.page.toString()]];
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function getVimeoSubscriptions() {
    vimeoSubscriptionsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            var total = parseInt(results.subscriptions.total);
            if (total > 0) {
                if (total == 1) {
                    getSubscriptionInfo(results.subscriptions.subscription.subject_id);
                }
                else {
                    var res;
                    for (var i = 0; i < results.subscriptions.subscription.length; i++) {
                        res = results.subscriptions.subscription[i];
                        getSubscriptionInfo(res.subject_id);
                    }
                }
            }

            //            vimeoSubscriptionsModel.moreResults = (vimeoSubscriptionsModel.count < total);
            vimeoSubscriptionsModel.loading = false;
            vimeoSubscriptionsModel.page++;
        }
    }
    var credentials = { "token": Vimeo.accessToken, "secret": Vimeo.tokenSecret };
    var params = [["format", "json"], ["method", "vimeo.people.getSubscriptions"], ["types", "uploads"],
                  ["per_page", "50"], ["sort", "alphabetical"], ["page", vimeoPlaylistModel.page.toString()]];
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", credentials, undefined, params);
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function getSubscriptionInfo(userId) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            vimeoSubscriptionsModel.append({ "title": results.person.display_name, "id": results.person.id, "location": results.person.location,
                                           "bio": results.person.bio, "videoCount": results.person.number_of_uploads,
                                           "thumbnail": results.person.portraits.portrait[2]._content,
                                           "largeThumbnail": results.person.portraits.portrait[3]._content });
        }
    }
    var params = [["format", "json"], ["method", "vimeo.people.getInfo"], ["user_id", userId]];
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", undefined, undefined, params);
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function getUserInfo(userId) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            //            console.log(doc.responseText)
            user = { "location": results.person.location,
                    "bio": results.person.bio, "videoCount": results.person.number_of_uploads,
                    "thumbnail": results.person.portraits.portrait[2]._content,
                    "largeThumbnail": results.person.portraits.portrait[3]._content };

            videoCount = user.videoCount;
            userThumbnail = user.thumbnail;
        }
    }
    var params = [["format", "json"], ["method", "vimeo.people.getInfo"], ["user_id", userId]];
    var oauthData = createOAuthHeader("vimeo", "GET", "http://vimeo.com/api/rest/v2/", undefined, undefined, params);
    doc.open("GET", oauthData.url);
    doc.setRequestHeader("Authorization", oauthData.header);
    doc.send();
}

function createVideoObject(video) {
    var videoObject = {};
    videoObject["id"] = video.id;
    videoObject["playerUrl"] = video.playerUrl;
    videoObject["title"] = video.title;
    videoObject["description"] = video.description;
    videoObject["duration"] = video.duration;
    videoObject["author"] = video.author;
    videoObject["views"] = video.views;
    videoObject["likes"] = video.likes;
    videoObject["comments"] = video.comments;
    videoObject["thumbnail"] = video.thumbnail;
    videoObject["vimeo"] = true;
    return videoObject;
}

function createPlaylistObject(playlist) {
    var playlistObject = {};
    playlistObject["title"] = playlist.title;
    playlistObject["id"] = playlist.id;
    playlistObject["videoCount"] = playlist.videoCount;
    playlistObject["createdDate"] = playlist.updatedDate;
    playlistObject["description"] = playlist.description;
    playlistObject["thumbnail"] = playlist.thumbnail;
    playlistObject["largeThumbnail"] = playlist.largeThumbnail;
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
