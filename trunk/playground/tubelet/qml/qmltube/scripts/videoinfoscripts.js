/* Video info functions */

function getDuration(secs) {
    /* Convert seconds to HH:MM:SS format. */

    var hours = Math.floor(secs / 3600);
    var minutes = Math.floor(secs / 60) - (hours * 60);
    var seconds = secs - (hours * 3600) - ( minutes * 60);
    if (seconds < 10) {
        seconds = "0" + seconds;
    }
    var duration = minutes + ":" + seconds;
    if (hours > 0) {
        duration = hours + ":" + duration;
    }
    return duration;
}

function showPlaylistDialog() {
    if (dimmer.state == "") {
        toggleControls(false);
        var playlistDialog = ObjectCreator.createObject("AddToPlaylistDialog.qml", window);
        playlistDialog.playlistClicked.connect(addVideoToPlaylist);
        playlistDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        playlistDialog.state = "show";
    }
}

function addVideoToPlaylist(playlistId) {
    toggleBusy(true);
    YouTube.addToPlaylist(videoId, playlistId);
    closeDialogs();
}

function shareVideo(service) {
    if (dimmer.state == "") {
        toggleControls(false);
        if (service == "Twitter") {
            checkTwitterAccess();
        }
        else if (service == "Facebook") {
            checkFacebookAccess();
        }
    }
}

function rateVideo(rating) {
    if (userIsSignedIn()) {
        if (!video.rating) {
            toggleBusy(true);
            likeOrDislike = rating;
            YouTube.rateVideo(videoId, rating);
        }
    }
    else {
        messages.displayMessage(messages._NOT_SIGNED_IN);
    }
}

function showAddCommentDialog() {
    /* Add a new comment */

    if (dimmer.state == "") {
        toggleControls(false);
        var commentDialog = ObjectCreator.createObject("AddCommentDialog.qml", window);
        commentDialog.setService("YouTube", video);
        commentDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        commentDialog.state = "show";
    }
}

function closeDialogs() {
    /* Close any open dialogs and return the window to its default state */

    dialogClose();
    dimmer.state = "";
    toggleControls(true);
}

function checkFacebookAccess() {
    toggleControls(false);
    if (Sharing.facebookToken != "unknown") {
        var shareDialog = ObjectCreator.createObject("AddCommentDialog.qml", window);
        shareDialog.setService("Facebook", video);
        shareDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        shareDialog.state = "show";
    }
    else {
        getFacebookAccessToken();
    }
}

function getFacebookAccessToken() {
    var oauthDialog = ObjectCreator.createObject("OAuthDialog.qml", window);
    oauthDialog.setService("Facebook");
    oauthDialog.authorised.connect(checkFacebookAccess);
    oauthDialog.close.connect(closeDialogs);
    dimmer.state = "dim";
    oauthDialog.state = "show";
}

function loadComments() {
    commentsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            commentsModel.setXml(xml);

            commentsModel.loading = false;
            commentsList.loaded = true;
            commentsList.positionViewAtIndex(0, ListView.Beginning);
        }
    }
    doc.open("GET", commentsList.commentsFeed);
    doc.send();
}

function appendComments() {
    commentsModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            commentsModel.appendXml(xml);

            commentsModel.loading = false;
        }
    }
    doc.open("GET", commentsList.commentsFeed + "&start-index=" + (commentsModel.count + 1).toString());
    doc.send();
}

function loadRelatedVideos() {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            relatedModel.setXml(xml);

            relatedModel.loading = false;
            relatedView.loaded = true;
        }
    }
    doc.open("GET", relatedView.videoFeed);
    doc.send();
}

function appendRelatedVideos() {
    relatedModel.loading = true;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var xml = doc.responseText;
            relatedModel.appendXml(xml);

            relatedModel.loading = false;
        }
    }
    doc.open("GET", relatedView.videoFeed + "&start-index=" + (relatedModel.count + 1).toString());
    doc.send();
}
