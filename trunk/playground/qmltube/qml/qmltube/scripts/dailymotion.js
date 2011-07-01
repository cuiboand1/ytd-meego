function getDailymotionSearch(query, order) {
    var searchOrders = { "rating": "rated", "published": "recent", "viewCount": "visited-today", "relevance": "relevance" };
    order = searchOrders[order];
    var encodedQuery = encodeURIComponent(query.replace(/\s.\s/gi, " "));
    var safe = (Settings.getSetting("safeSearch") == "none") ? "false" : "true";
    var videoFeed = "https://api.dailymotion.com/videos?limit=50&family_filter=" + safe + "&fields="
                     + _DM_FIELDS + "&sort=" + order + "&search=" + encodedQuery.replace(/\s/g, "+");
    return videoFeed;
}

function getDailymotionVideos() {
    videoListModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
//        console.log(doc.responseText)
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            videoListModel.moreResults = results.has_more;
            var res;
            for (var i = 0; i < results.list.length; i++) {
                res = results.list[i];
                videoListModel.append({ "playerUrl": "http://iphone.dailymotion.com/video/" + res.id, "id": res.id, "title": res.title,
                                      "description": res.description, "author": res.owner, "rating": res.rating,
                                      "views": res.views_total, "duration": res.duration, "tags": res.tags.toString(),
                                      "thumbnail": res.thumbnail_medium_url,
                                      "largeThumbnail": res.thumbnail_large_url, "dailymotion": true });
            }

            videoListModel.loading = false;
            videoListModel.page++;
        }
    }
    doc.open("GET", videoFeed + "&page=" + videoListModel.page.toString());
    if ((videoFeed == _DM_UPLOADS_FEED) || (videoFeed == _DM_FAVOURITES_FEED) || (videoFeed == _DM_NEW_SUB_VIDEOS_FEED)) {
        doc.setRequestHeader("Authorization", "OAuth " + DailyMotion.accessToken);
    }
    doc.send();
}

function getRelatedVideos() {
    relatedModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            relatedModel.moreResults = results.has_more;
            var res;
            for (var i = 0; i < results.list.length; i++) {
                res = results.list[i];
                relatedModel.append({ "playerUrl": "http://iphone.dailymotion.com/video/" + res.id, "id": res.id, "title": res.title,
                                      "description": res.description, "author": res.owner, "rating": res.rating,
                                      "views": res.views_total, "duration": res.duration, "tags": res.tags.toString(),
                                      "thumbnail": res.thumbnail_medium_url,
                                      "largeThumbnail": res.thumbnail_large_url, "dailymotion": true });
            }

            relatedModel.loading = false;
            relatedModel.page++;
        }
    }
    doc.open("GET", relatedView.videoFeed + "&page=" + relatedModel.page.toString());
    doc.send();
}

function getDailymotionPlaylistVideos() {
    videoListModel.loading = true;

    var title;
    var id;
    var description;
    var thumbnail;
    var largeThumbnail;
    var duration;
    var views;
    var author;
    var res;
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.split('our staff picks')[0];
            var results = page.split('with_context not_ajax" id="');
            videoListModel.moreResults = /Next Page/.test(page);
            for (var i = 1; i < results.length; i++) {
                res = results[i];
                thumbnail = res.split('data-src="')[1].split('"')[0];
                largeThumbnail = thumbnail.replace("medium", "large");
                title = res.split('dmco_link with_context not_ajax">')[1].split('<')[0];
                description = res.split('dmpi_video_description foreground"><div>')[1].split('<')[0];
                id = res.slice(0, res.indexOf('"'));
                duration = res.split('"duration">')[1].split('<')[0];
                views = res.split('"video_views_value">')[1].split('<')[0].replace(",", "");
                author = res.split('"login name"href="/')[1].split('"')[0];
                videoListModel.append({ "title": title, "id": id, "thumbnail": thumbnail,
                                                "largeThumbnail": largeThumbnail,
                                                "description": description, "views": views, "rating": "3",
                                                "duration": duration, "author": author, "tags": "", "dailymotion": true,
                                                "playerUrl": "http://iphone.dailymotion.com/video/" + id });
            }

            videoListModel.page++;
            videoListModel.loading = false;
        }
    }
    doc.open("GET", videoFeed + "/" + videoListModel.page.toString());
    doc.send();
}

function getDailymotionPlaylists() {
    dailymotionPlaylistModel.loading = true;

    var title;
    var id;
    var videoCount;
    var updatedDate;
    var res;
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.split('class="bottom hide"')[0];
            var results = page.split('"listplaylist" title="');
            dailymotionPlaylistModel.moreResults = /Next Page/.test(page);
            for (var i = 1; i < results.length; i++) {
                res = results[i];
                title = res.slice(0, res.indexOf('"'));
                id = res.split('href="/playlist/')[1].split('_')[0];
                videoCount = res.split('</a> | ')[1].split(' ')[0];
                updatedDate = res.split(' | updated ')[1].split('<')[0];
                dailymotionPlaylistModel.append({ "title": title, "id": id, "videoCount": videoCount, "updatedDate": updatedDate });
            }

            dailymotionPlaylistModel.page++;
            dailymotionPlaylistModel.loading = false;
        }
    }
    doc.open("GET", _DM_PLAYLISTS_FEED + "/" + dailymotionPlaylistModel.page.toString());
    doc.send();
}

function getDailymotionSubscriptions() {
    dailymotionSubscriptionsModel.loading = true;

    var userFound = false;
    var ii = 0;
    var res;
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = eval("(" + doc.responseText + ")");
            dailymotionSubscriptionsModel.moreResults = results.has_more;
            for (var i = 0; i < results.list.length; i++) {
                res = results.list[i];
                while (!(userFound) && (ii < dailymotionSubscriptionsModel.count)) {
                    userFound = dailymotionSubscriptionsModel.get(ii).title == res.owner;
                    ii++;
                }
                ii = 0;
                if (!userFound) {
                    dailymotionSubscriptionsModel.append({ "title": res.owner });
                }
            }

            dailymotionSubscriptionsModel.page++;
            dailymotionSubscriptionsModel.loading = false;
        }
    }
    doc.open("GET", "https://api.dailymotion.com/videos/subscriptions?limit=100&fields=owner&page=" + dailymotionSubscriptionsModel.page.toString());
    doc.setRequestHeader("Authorization", "OAuth " + DailyMotion.accessToken);
    doc.send();
}

function refreshDailymotionAccessToken(account) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var response = eval("(" + doc.responseText + ")");
            if (response.access_token) {
                var accessToken = response.access_token;
                var refreshToken = response.refresh_token;
                var date = new Date();
                var tokenExpiry = date.valueOf() + parseInt(response.expires_in);
                Settings.addDailymotionAccount(account.username, accessToken, refreshToken, tokenExpiry);
                DailyMotion.setUserCredentials(account.username, accessToken, refreshToken, tokenExpiry);
            }
        }
    }
    var data = "grant_type=refresh_token" +
        "&client_id=5dae8d881f02f2b4f641" +
        "&client_secret=d08c9c72ed843cd4be501145cfa22bd0b2ff2775" +
        "&refresh_token=" + account.refreshToken;
    doc.open("POST", "https://api.dailymotion.com/oauth/token");
    doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    doc.send(data);
}

function addVideosToFavourites() {
    if (!(DailyMotion.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var id;
            for (var i = 0; i < videoList.checkList.length; i++) {
                id = videoListModel.get(videoList.checkList[i]).id;
                DailyMotion.addToFavourites(id);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function deleteVideosFromFavourites() {
    if (!(DailyMotion.currentUser == "")) {
        if (videoList.checkList.length > 0) {
            toggleBusy(true);
            var id;
            for (var i = 0; i < videoList.checkList.length; i++) {
                id = videoListModel.get(videoList.checkList[i]).id;
                DailyMotion.deleteFromFavourites(id);
            }
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
    videoList.checkList = [];
}

function createVideoObject(video) {
    var videoObject = {};
    videoObject["id"] = video.id;
    videoObject["playerUrl"] = video.playerUrl;
    videoObject["title"] = video.title;
    videoObject["description"] = video.description;
    videoObject["author"] = video.author;
    videoObject["views"] = video.views;
    videoObject["rating"] = video.rating;
    videoObject["thumbnail"] = video.thumbnail;
    videoObject["dailymotion"] = true;
    return videoObject;
}

function createPlaylistObject(playlist) {
    var playlistObject = {};
    playlistObject["title"] = playlist.title;
    playlistObject["id"] = playlist.id;
    playlistObject["videoCount"] = playlist.videoCount;
    playlistObject["updatedDate"] = playlist.updatedDate;
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
