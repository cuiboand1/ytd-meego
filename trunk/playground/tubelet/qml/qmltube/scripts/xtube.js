/* Functions for access to adult content */

function loadXtubeVideos(site, query, order) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "XtubeListView.qml";
    loader.item.loadVideoInfo.connect(loadXtubeVideoInfo);
    loader.item.playXtubeVideo.connect(loadPlaybackView);
    loader.item.setSearchQuery(site, query, order);
    notificationArea.addTitle(qsTr("Search ") + "('" + query + "')");
    windowView.incrementCurrentIndex();
}

function loadXtubeVideoInfo(site, video) {
    var loader = viewsModel.children[windowView.currentIndex + 1];
    windowView.currentItem.opacity = 0;
    loader.source = "XtubeInfoView.qml";
    loader.item.goToVideo.connect(loadXtubeVideoInfo);
    loader.item.playVideo.connect(loadPlaybackView);
    loader.item.search.connect(loadXtubeVideos);
    loader.item.setVideo(site, video);
    notificationArea.addTitle(qsTr("Video Info"));
    windowView.incrementCurrentIndex();
}

function getYouPornVideos(feed) {
    videoFeed = feed;
    var link = "";
    var title = "";
    var thumbnail = "";
    var duration = "";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.replace(/\n\s{2,}/g, "").split('class="clearfix"><li>');
            var results = page.slice(3).join().split('<div id="related-searches"')[0].split('<img id=').slice(1);
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                link = "http://youporn.com" + r.slice(r.indexOf('href="') + 6, r.indexOf('/?from='));
                title = r.slice(r.indexOf('alt="') + 5, r.indexOf('" />')).replace("&amp;", "&");
                thumbnail = r.slice(r.indexOf('src=') + 5, r.indexOf('" num'));
                duration = r.split('<div class="duration_views"><h2>')[1].split('</h2>')[0].replace(/[<>/\\\\span]/g, "");
                videoListModel.append({ "link": link,
                                      "title": title,
                                      "thumbnail": thumbnail,
                                      "duration": duration
            });
            }
            videoList.loading = false;
            videoList.loaded = true;
        }
    }
    doc.open("GET", feed);
    doc.send();
}

function getYouPornRelatedVideos(feed) {
    videoFeed = feed;
    var link = "";
    var title = "";
    var thumbnail = "";
    var duration = "";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.replace(/\n\s{2,}/g, "").split('<img id="related1" src="')[1].split('<a href="#featured">')[0];
            var results = page.split('src="');
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                link = "http://youporn.com" + r.split('href="')[1].split('"')[0];
                title = r.split('pos=' + (i + 1).toString() + '">')[1].split('<')[0].replace("&amp;", "&");
                thumbnail = r.slice(0, r.indexOf('"'));
                duration = r.split('class="duration">')[1].split('<')[0].replace(/[A-z]/g, "").replace(" ", ":");
                videoListModel.append({ "link": link,
                                      "title": title,
                                      "thumbnail": thumbnail,
                                      "duration": duration
            });
            }
            videoList.loading = false;
            videoList.loaded = true;
        }
    }
    doc.open("GET", feed);
    doc.send();
}

function getYouPornUrl(index) {
    toggleBusy(true);

    var video = videoListModel.get(index);
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (request.readyState == XMLHttpRequest.DONE) {
            var page = request.responseText;
            if (/MP4 - For iPhone\/iPod/.test(page)) {
                var s = page.split('">MP4 - For iPhone/iPod')[0];
                var url = s.slice(s.lastIndexOf('http'));
                request = new XMLHttpRequest();
                request.onreadystatechange = function() {
                    if (request.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                        var videoUrl = decodeURIComponent(request.getResponseHeader('location'));
                        toggleBusy(false);
                        playVideo([{ "title": video.title,
                                   "thumbnail": video.thumbnail,
                                   "url": videoUrl,
                                   "xtube": true
                    }]);
                    }
                }
                request.open("HEAD", url);
                request.send();
            }
            else {
                messages.displayMessage(qsTr("No suitable video url"));
            }
        }
    }
    request.open("GET", video.link);
    request.send();
}

function getPornHubVideos(feed) {
    videoFeed = feed;
    var link = "";
    var title = "";
    var thumbnail = "";
    var duration = "";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.replace(/\n\s{2,}/g, "").split('"videoblock relative videos_1"><div class="wrap"><a href="')[1].split('style="display:none">')[0];
            var results = page.split('class="wrap"><a href="');
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                link = r.split('"')[0];
                title = r.split('title="')[1].split('"')[0];
                thumbnail = r.split('<img src="')[1].split('"')[0];
                duration = r.split('class="duration">')[1].split('<')[0];
                videoListModel.append({ "link": link,
                                      "title": title,
                                      "thumbnail": thumbnail,
                                      "duration": duration
            });
            }
            videoList.loading = false;
            videoList.loaded = true;
        }
    }
    doc.open("GET", feed);
    doc.send();
}

function getPornHubRelatedVideos(feed) {
    videoFeed = feed;
    var link = "";
    var title = "";
    var thumbnail = "";
    var duration = "";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var page = doc.responseText.replace(/\n\s{2,}/g, "").split('"videoblock relative videos_1"><div class="wrap"><a href=')[1].split('<a class="nav-related"')[0];
            var results = page.split('class="wrap"><a href="');
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                link = r.slice(0, r.indexOf('"'));
                title = r.split('title="')[1].split('"')[0];
                thumbnail = r.split('<img src="')[1].split('"')[0];
                duration = r.split('class="duration">')[1].split('<')[0];
                videoListModel.append({ "link": link,
                                      "title": title,
                                      "thumbnail": thumbnail,
                                      "duration": duration
            });
            }
            videoList.loading = false;
            videoList.loaded = true;
        }
    }
    doc.open("GET", feed);
    doc.send();
}

function getPornHubUrl(index) {
    toggleBusy(true);

    var video = videoListModel.get(index);
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (request.readyState == XMLHttpRequest.DONE) {
            var page = request.responseText;
            var videoUrl = decodeURIComponent(page.split('"video_url","')[1].split('"')[0]);
            toggleBusy(false);
            playVideo([{ "title": video.title,
                       "thumbnail": video.thumbnail,
                       "url": videoUrl,
                       "xtube": true
        }]);
        }
    }
    request.open("GET", video.link);
    request.send();
}

function getTubeEightVideos(feed) {
    videoFeed = feed;

    var thumbnail = "";
    var title = "";
    var duration = "";
    var link = "";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var results = doc.responseText.split('class="box-thumbnail-friends">')[0].split('class="videoThumbs"');
            for (var i = 1; i < results.length; i++) {
                var r = results[i];
                thumbnail = r.split('src="')[2].split('"')[0];
                title = r.split('title="')[1].split('"')[0];
                duration = r.split('<strong>')[1].split('<')[0];
                link = r.split('<a href="')[1].split('"')[0];
                videoListModel.append({ "link": link,
                                      "title": title,
                                      "thumbnail": thumbnail,
                                      "duration": duration
            });
            }
            videoList.loading = false;
            videoList.loaded = true;
        }
    }
    doc.open("GET", feed);
    doc.send();
}

function getTubeEightUrl(index) {
    toggleBusy(true);

    var video = videoListModel.get(index);
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (request.readyState == XMLHttpRequest.DONE) {
            var page = request.responseText;
            var url = page.split('var videourl="')[1].split('"')[0];
            toggleBusy(false);
            playVideo([{ "title": video.title,
                       "thumbnail": video.thumbnail,
                       "url": videoUrl,
                       "xtube": true
        }]);
        }
    }
    request.open("GET", video.link);
    request.send();
}

