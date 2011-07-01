import QtQuick 1.0
import "scripts/mainscripts.js" as Scripts
import "scripts/settings.js" as Settings

Rectangle {
    id: window

    property bool _VIDEO_PLAYING : false
    property string _DEFAULT_SITE : "YouTube"
    property variant _CATEGORY_DICT
    property variant _ORDER_BY_DICT

    /* YouTube feeds */

    property string _UPLOADS_FEED : "http://gdata.youtube.com/feeds/api/users/default/uploads?v=2&max-results=50"
    property string _FAVOURITES_FEED : "http://gdata.youtube.com/feeds/api/users/default/favorites?v=2&max-results=50"
    property string _PLAYLISTS_FEED : "http://gdata.youtube.com/feeds/api/users/default/playlists?v=2&max-results=50"
    property string _SUBSCRIPTIONS_FEED : "http://gdata.youtube.com/feeds/api/users/default/subscriptions?v=2&max-results=50"
    property string _NEW_SUB_VIDEOS_FEED : "http://gdata.youtube.com/feeds/api/users/default/newsubscriptionvideos?v=2&max-results=50"
    property string _MOST_RECENT_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_recent?v=2&max-results=50"
    property string _MOST_VIEWED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_viewed?v=2&max-results=50&time=today"
    property string _ON_THE_WEB_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/on_the_web?v=2&max-results=50" //NPM
    property string _MOST_SHARED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_shared?v=2&max-results=50" //NPM
    property string _TOP_RATED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?v=2&max-results=50" //NPM
    property string _TOP_FAVORITES_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?v=2&max-results=50" //NPM
    property string _MOST_POPULAR_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2&max-results=50" //NPM
    property string _MOST_DISCUSSED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_discussed?v=2&max-results=50" //NPM
    property string _MOST_RESPONDED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_responded?v=2&max-results=50" //NPM
    property string _RECENTLY_FEATURED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/recently_featured?v=2&max-results=50" //NPM
    property string _CATEGORY_FEED : "http://gdata.youtube.com/feeds/api/videos?v=2&max-results=50&category="

    /* Dailymotion feeds */

    property string _DM_UPLOADS_FEED : "https://api.dailymotion.com/videos/uploaded?limit=50&fields=" + _DM_FIELDS
    property string _DM_FAVOURITES_FEED : "https://api.dailymotion.com/videos/favorites?limit=50&fields=" + _DM_FIELDS
    property string _DM_PLAYLISTS_FEED : "http://www.dailymotion.com/playlists/user/" + DailyMotion.currentUser
    property string _DM_NEW_SUB_VIDEOS_FEED : "https://api.dailymotion.com/videos/subscriptions?limit=50&fields=" + _DM_FIELDS
    property string _DM_MOST_RECENT_FEED : "https://api.dailymotion.com/videos?sort=recent&limit=50&fields=" + _DM_FIELDS
    property string _DM_MOST_VIEWED_FEED : "https://api.dailymotion.com/videos?sort=visited-today&limit=50&fields=" + _DM_FIELDS
// NPM http://www.dailymotion.com/doc/api/rest-api-reference.html lists
// recent, visited, visited-hour, visited-today, visited-week, visited-month, commented, commented-hour, commented-today, commented-week, commented-month, rated, rated-hour, rated-today, rated-week, rated-month, discussed, discussed-hour, discussed-today, discussed-week, discussed-month, relevance, random
// attempt to find correlation between YT names and DM names...
//  property string _DM_ON_THE_WEB_FEED     : "https://api.dailymotion.com/videos?sort=???&limit=50&fields=" + _DM_FIELDS //NPM
//  property string _DM_MOST_SHARED_FEED    : "https://api.dailymotion.com/videos?sort=???&limit=50&fields=" + _DM_FIELDS //NPM
    property string _DM_TOP_RATED_FEED      : "https://api.dailymotion.com/videos?sort=rated-today&limit=50&fields=" + _DM_FIELDS  //NPM
//  property string _DM_TOP_FAVORITES_FEED  : "https://api.dailymotion.com/videos?sort=???&limit=50&fields=" + _DM_FIELDS  //NPM
//  property string _DM_MOST_POPULAR_FEED   : "https://api.dailymotion.com/videos?sort=???&limit=50&fields=" + _DM_FIELDS  //NPM
    property string _DM_MOST_DISCUSSED_FEED : "https://api.dailymotion.com/videos?sort=discussed-today&limit=50&fields=" + _DM_FIELDS  //NPM
    property string _DM_MOST_RESPONDED_FEED : "https://api.dailymotion.com/videos?sort=commented-today&limit=50&fields=" + _DM_FIELDS  //NPM
//  property string _DM_RECENTLY_FEATURED_FEED : "https://api.dailymotion.com/videos?sort=???&limit=50&fields=" + _DM_FIELDS  //NPM
    property string _DM_CATEGORY_FEED : "https://api.dailymotion.com/videos?limit=50&fields=" + _DM_FIELDS + "&channel="
    property string _DM_FIELDS : "id,title,description,duration,owner,thumbnail_medium_url,thumbnail_large_url,rating,views_total,tags"


    /* Vimeo feeds */

    property variant _VM_UPLOADS_FEED : [["method", "vimeo.videos.getUploaded"], ["sort", "newest"]]
    property variant _VM_FAVOURITES_FEED : [["method", "vimeo.videos.getLikes"], ["sort", "newest"]]
    property variant _VM_NEW_SUB_VIDEOS_FEED : [["method", "vimeo.videos.getSubscriptions"], ["sort", "newest"]]

    /* Theme variables */

    property string cuteTubeTheme : "nightred"
    property string _ACTIVE_COLOR_HIGH : (cuteTubeTheme == "nightred") ? "#d93333" : "#6382c6"
    property string _ACTIVE_COLOR_LOW : (cuteTubeTheme == "nightred") ? "#932424" : "#3d6be0"
    property string _BACKGROUND_COLOR : (cuteTubeTheme == "light") ? "white" : "black"
    property string _GRADIENT_COLOR_HIGH : (cuteTubeTheme == "light") ? "white" : "#524e4e"
    property string _GRADIENT_COLOR_LOW : (cuteTubeTheme == "light") ? "#edece8" : "black"
    property string _TEXT_COLOR : (cuteTubeTheme == "light") ? "black" : "white"
    property int _SMALL_FONT_SIZE : Controller.isSymbian ? 16 : 18
    property int _STANDARD_FONT_SIZE : Controller.isSymbian ? 20 : 24
    property int _LARGE_FONT_SIZE : Controller.isSymbian ? 32 : 36

    Component.onCompleted: {
        _CATEGORY_DICT = [
                    { "youtube": "Autos", "dailymotion": "auto", "vimeo": "cars", "name": qsTr("Cars & Vehicles") },
                    { "youtube": "Comedy", "dailymotion": "fun", "vimeo": "comedy", "name": qsTr("Comedy") },
                    { "youtube": "Education", "dailymotion": "school", "vimeo": "education", "name": qsTr("Education") },
                    { "youtube": "Entertainment", "dailymotion": "none", "vimeo": "entertainment", "name": qsTr("Entertainment") },
                    { "youtube": "Film", "dailymotion": "shortfilms", "vimeo": "films", "name": qsTr("Film") },
                    { "youtube": "Games", "dailymotion": "videogames", "vimeo": "videogames", "name": qsTr("Gaming") },
                    { "youtube": "Howto", "dailymotion": "lifestyle", "vimeo": "lifestyle", "name": qsTr("Style") },
                    { "youtube": "Music", "dailymotion": "music", "vimeo": "music", "name": qsTr("Music") },
                    { "youtube": "News", "dailymotion": "news", "vimeo": "news", "name": qsTr("News & Politics") },
                    { "youtube": "Nonprofit", "dailymotion": "none", "vimeo": "nonprofit", "name": qsTr("Non-profits & Activism") },
                    { "youtube": "People", "dailymotion": "people", "vimeo": "people", "name": qsTr("People") },
                    { "youtube": "Animals", "dailymotion": "animals", "vimeo": "animals", "name": qsTr("Pets & Animals") },
                    { "youtube": "Tech", "dailymotion": "tech", "vimeo": "technology", "name": qsTr("Science & Technology") },
                    { "youtube": "Sports", "dailymotion": "sport", "vimeo": "sport", "name": qsTr("Sport") },
                    { "youtube": "Travel", "dailymotion": "travel", "vimeo": "travel", "name": qsTr("Travel & Events") },
                    { "youtube": "MostRecent", "dailymotion": "feed", "name": qsTr("Most Recent") },
                    { "youtube": "MostViewed", "dailymotion": "feed", "name": qsTr("Most Viewed") },
                    { "youtube": "MostDiscussed", "dailymotion": "feed", "name": qsTr("Most Discussed") }, //NPM
                    { "youtube": "MostPopular", "dailymotion": "feed", "name": qsTr("Most Popular") }, //NPM
                    { "youtube": "MostResponded", "dailymotion": "feed", "name": qsTr("Most Responded") }, //NPM
                    { "youtube": "MostShared", "dailymotion": "feed", "name": qsTr("Most Shared") }, //NPM
                    { "youtube": "OnTheWeb", "dailymotion": "feed", "name": qsTr("On The Web") }, //NPM
                    { "youtube": "TopFavorites", "dailymotion": "feed", "name": qsTr("Top Favorites") }, //NPM
                    { "youtube": "TopRated", "dailymotion": "feed", "name": qsTr("Top Rated") }, //NPM
                ];

        _ORDER_BY_DICT = { "relevance": qsTr("Relevance"), "published": qsTr("Date"), "viewCount": qsTr("Views"), "rating": qsTr("Rating") };
        Scripts.restoreSettings();
    }

    function userIsSignedIn() {
        /* Check if the user is signed in */

        var signedIn = false;
        if (!((YouTube.currentUser == "") && (DailyMotion.currentUser == "") && (Vimeo.currentUser == ""))) {
            signedIn = true;
        }
        return signedIn;
    }

    function toggleBusy(isBusy) {
        notificationArea.isBusy = isBusy;
    }

    function toggleControls(showControls) {
        /* Show/hide the notification area and menu bar */

        if (showControls) {
            controlsTimer.running = true;
        }
        else {
            notificationArea.visible = false;
            menu.visible = false
        }
    }

    function setCategoryFeeds(feedOne, feedTwo, order) {
        /* Set the category feeds of Home View */

        var category;
        var categoryFound = false;
        var i = 0;
        if (feedOne == "MostRecent") {
            homeView.categoryFeedOne = { "youtube": _MOST_RECENT_FEED, "dailymotion": _DM_MOST_RECENT_FEED, "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Recent"); //TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
        }
        else if (feedOne == "MostViewed") {
            homeView.categoryFeedOne = { "youtube": _MOST_VIEWED_FEED, "dailymotion": _DM_MOST_VIEWED_FEED, "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Viewed");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
        }
        else if (feedOne == "OnTheWeb") { // NPM
            homeView.categoryFeedOne = { "youtube": _ON_THE_WEB_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("On The Web");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "MostShared") { // NPM
            homeView.categoryFeedOne = { "youtube": _MOST_SHARED_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Shared");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "TopRated") { // NPM
            homeView.categoryFeedOne = { "youtube": _TOP_RATED_FEED, "dailymotion": _DM_TOP_RATED_FEED, "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Top Rated");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "TopFavorites") { // NPM
            homeView.categoryFeedOne = { "youtube": _TOP_FAVORITES_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Top Favorites");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "MostPopular") { // NPM
            homeView.categoryFeedOne = { "youtube": _MOST_POPULAR_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Popular");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "MostDiscussed") { // NPM
            homeView.categoryFeedOne = { "youtube": _MOST_DISCUSSED_FEED, "dailymotion":_DM_MOST_DISCUSSED_FEED, "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Discussed");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "MostResponded") { // NPM
            homeView.categoryFeedOne = { "youtube": _MOST_RESPONDED_FEED, "dailymotion": _DM_MOST_RESPONDED_FEED, "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Most Responded");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else if (feedOne == "RecentlyFeatured") { // NPM
            homeView.categoryFeedOne = { "youtube": _RECENTLY_FEATURED_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedOneName = qsTr("Recently Featured");//TODO: lookup, out of _CATEGORY_DICT[feedOne].name ?
    	}
        else {
            while ((!categoryFound) && (i < _CATEGORY_DICT.length)) {
                category = _CATEGORY_DICT[i];
                if (category.youtube == feedOne) {
                    homeView.categoryFeedOne = { "youtube": _CATEGORY_FEED + feedOne + "&orderby=" + order,
                            "dailymotion": _DM_CATEGORY_FEED + category.dailymotion,
                            "vimeo": [["method", "vimeo.videos.getByTag"], ["sort", "newest"], ["tag", category.vimeo]] };
                    homeView.categoryFeedOneName = category.name;
                    categoryFound = true;
                }
                i++;
            }
            categoryFound = false;
            i = 0;
        }
        if (feedTwo == "MostRecent") {
            homeView.categoryFeedTwo = { "youtube": _MOST_RECENT_FEED, "dailymotion": _DM_MOST_RECENT_FEED, "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Recent");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
        }
        else if (feedTwo == "MostViewed") {
            homeView.categoryFeedTwo = { "youtube": _MOST_VIEWED_FEED, "dailymotion": _DM_MOST_VIEWED_FEED, "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Viewed");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
        }
        else if (feedTwo == "OnTheWeb") { // NPM
            homeView.categoryFeedTwo = { "youtube": _ON_THE_WEB_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("On The Web");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else if (feedTwo == "MostShared") { // NPM
            homeView.categoryFeedTwo = { "youtube": _MOST_SHARED_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Shared");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else if (feedTwo == "TopRated") { // NPM
            homeView.categoryFeedTwo = { "youtube": _TOP_RATED_FEED, "dailymotion": _DM_TOP_RATED_FEED, "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Top Rated");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else if (feedTwo == "TopFavorites") { // NPM
            homeView.categoryFeedTwo = { "youtube": _TOP_FAVORITES_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Top Favorites");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else if (feedTwo == "MostPopular") { // NPM
            homeView.categoryFeedTwo = { "youtube": _MOST_POPULAR_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Popular");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else if (feedTwo == "MostDiscussed") { // NPM
            homeView.categoryFeedTwo = { "youtube": _MOST_DISCUSSED_FEED, "dailymotion": _DM_MOST_DISCUSSED_FEED, "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Discussed");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?

    	}
        else if (feedTwo == "MostResponded") { // NPM
            homeView.categoryFeedTwo = { "youtube": _MOST_RESPONDED_FEED, "dailymotion": _DM_MOST_RESPONDED_FEED, "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Most Responded");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?

    	}
        else if (feedTwo == "RecentlyFeatured") { // NPM
            homeView.categoryFeedTwo = { "youtube": _RECENTLY_FEATURED_FEED, "dailymotion": "none", "vimeo": "none" };
            homeView.categoryFeedTwoName = qsTr("Recently Featured");//TODO: lookup, out of _CATEGORY_DICT[feedTwo].name ?
    	}
        else {
            while ((!categoryFound) && (i < _CATEGORY_DICT.length)) {
                category = _CATEGORY_DICT[i];
                if (category.youtube == feedTwo) {
                    homeView.categoryFeedTwo = { "youtube": _CATEGORY_FEED + feedTwo + "&orderby=" + order,
                            "dailymotion": _DM_CATEGORY_FEED + category.dailymotion,
                            "vimeo": [["method", "vimeo.videos.getByTag"], ["sort", "newest"], ["tag", category.vimeo]] };
                    homeView.categoryFeedTwoName = category.name
                    categoryFound = true;
                }
                i++;
            }
        }
        if (cuteTubeTheme == "light") {
            homeView.categoryFeedOneIcon = "ui-images/" + feedOne.toLowerCase() + "iconlight.png";
            homeView.categoryFeedTwoIcon = "ui-images/" + feedTwo.toLowerCase() + "iconlight.png";
        }
        else {
            homeView.categoryFeedOneIcon = "ui-images/" + feedOne.toLowerCase() + "icon.png";
            homeView.categoryFeedTwoIcon = "ui-images/" + feedTwo.toLowerCase() + "icon.png";
        }
    }

    function createDownloadItem(video, convertToAudio) {
        /* Check for duplicate filepaths and create a new download item */

        var downloadItem = null;
        var path = Settings.getSetting("downloadPath") + video.title.replace(/[\"@&~=\/:?#!|<>*^]/g, "_") + ".mp4";
        if (convertToAudio) {
            path = path.slice(0, -4) + " (Audio).mp4";
        }

        var duplicate = false;
        var i = 0;
        while ((i < downloadModel.count) && (!duplicate)) {
            duplicate = (downloadModel.get(i).filePath == path);
            i++;
        }
        if (!duplicate) {
            var downloadItem = {
                filePath: path,
                title: video.title,
                thumbnail: video.thumbnail,
                playerUrl: video.playerUrl,
                status: video.status ? video.status : Settings.getSetting("downloadStatus"),
                                                    quality: "",
                                                    isNew: 1,
                                                    convert: convertToAudio,
                                                    bytesReceived: 0,
                                                    totalBytes: 100,
                                                    speed: ""
        }
    }
    return downloadItem;
}

    function addDownload(video) {
        /* Add a video to the download list model */

        var downloadItem = createDownloadItem(video, false);
        if (downloadItem) {
            Settings.storeDownload(downloadItem);
            downloadModel.appendDownload(downloadItem);
            messages.displayMessage(messages._VIDEO_DOWNLOAD_ADDED);
        }
            else {
                messages.displayMessage(messages._VIDEO_IN_DOWNLOAD_QUEUE);
            }
            }

                function addAudioDownload(video) {
                    /* Add a video to the download list model and set 'convert' to true */

                    var downloadItem = createDownloadItem(video, true);
                    if (downloadItem) {
                        Settings.storeDownload(downloadItem);
                        downloadModel.appendDownload(downloadItem);
                        messages.displayMessage(messages._AUDIO_DOWNLOAD_ADDED);
                    }
                        else {
                            messages.displayMessage(messages._AUDIO_IN_DOWNLOAD_QUEUE);
                        }
                        }

                            onStateChanged: {
                                if (messages.source != "") {
                                    messages.item.state = window.state;
                                }
                            }

                            width: 800
                            height: 480
                            anchors.fill: parent
                            color: _VIDEO_PLAYING ? "black" : _BACKGROUND_COLOR

                            Image {
                                id: background

                                anchors.fill: window
                                source: (window.state == "portrait") ? "ui-images/background2.png" : "ui-images/background.png"
                                sourceSize.width: background.width
                                sourceSize.height: background.height
                                smooth: true
                                visible: !_VIDEO_PLAYING && ((cuteTubeTheme == "night") || (cuteTubeTheme == "nightred"))

                            }

                            Timer {
                                id: controlsTimer

                                interval: 500
                                onTriggered: {
                                    notificationArea.visible = true;
                                    menu.visible = true;
                                }
                            }

                            Connections {
                                /* Connect to signals from C++ object YouTube */

                                target: YouTube

                                onAlert: messages.displayMessage(message)
                                onAddedToFavourites: messages.displayMessage(messages._ADDED_TO_FAVOURITES)
                                onVideoInFavourites: messages.displayMessage(messages._VIDEO_IN_FAVOURITES)
                                onAddedToPlaylist: {
                                    messages.displayMessage(messages._ADDED_TO_PLAYLIST);
                                    playlistTimer.restart();
                                }
                                onDeletedFromPlaylist: playlistTimer.restart()
                                onGotVideoUrl: {
                                    if (!_VIDEO_PLAYING) {
                                        Controller.playVideo(videoUrl);
                                    }
                                }
                                onAccessTokenChanged: {
                                    Scripts.getYouTubeSubscriptions();
                                    Scripts.getYouTubePlaylists();
                                }
                                onPlaylistCreated: {
                                    messages.displayMessage(messages._PLAYLIST_CREATED);
                                    Scripts.getYouTubePlaylists();
                                }
                                onPlaylistDeleted: {
                                    messages.displayMessage(messages._PLAYLIST_DELETED);
                                    Scripts.getYouTubePlaylists();
                                }
                                onSubscribed: Scripts.getYouTubeSubscriptions()
                                onUnsubscribed: Scripts.getYouTubeSubscriptions()
                            }

                            Connections {
                                /* Connect to signals from C++ object DailyMotion */

                                target: DailyMotion
                                onAlert: messages.displayMessage(message)
                                onAddedToFavourites: messages.displayMessage(messages._ADDED_TO_FAVOURITES)
                                onGotVideoUrl: {
                                    if (!_VIDEO_PLAYING) {
                                        Controller.playVideo(videoUrl);
                                    }
                                }
                                onAccessTokenChanged: {
                                    dailymotionPlaylistModel.page = 1;
                                    dailymotionSubscriptionsModel.page = 1;
                                    Scripts.getDailymotionSubscriptions();
                                    Scripts.getDailymotionPlaylists();
                                }
                            }

                            Connections {
                                /* Connect to signals from C++ object DailyMotion */

                                target: Vimeo
                                onAlert: messages.displayMessage(message)
                                onAddedToFavourites: messages.displayMessage(messages._ADDED_TO_FAVOURITES)
                                onAddedToPlaylist: {
                                    messages.displayMessage(messages._ADDED_TO_PLAYLIST);
                                    vimeoPlaylistTimer.restart();
                                }
                                onDeletedFromPlaylist: vimeoPlaylistTimer.restart()
                                onGotVideoUrl: {
                                    if (!_VIDEO_PLAYING) {
                                        Controller.playVideo(videoUrl);
                                    }
                                }
                                onAccessTokenChanged: {
                                    vimeoPlaylistModel.page = 1;
                                    vimeoSubscriptionsModel.page = 1;
                                    vimeoPlaylistModel.clear();
                                    vimeoSubscriptionsModel.clear();
                                    vimeoTimer.restart();
                                }
                                onPlaylistCreated: {
                                    messages.displayMessage(messages._PLAYLIST_CREATED);
                                    vimeoPlaylistModel.page = 1;
                                    vimeoPlaylistModel.clear();
                                    Scripts.getVimeoPlaylists();
                                }
                                onPlaylistDeleted: {
                                    messages.displayMessage(messages._PLAYLIST_DELETED);
                                    vimeoPlaylistModel.page = 1;
                                    vimeoPlaylistModel.clear();
                                    Scripts.getVimeoPlaylists();
                                }
                                onSubscribed: {
                                    vimeoSubscriptionsModel.clear();
                                    Scripts.getVimeoSubscriptions();
                                }
                                onUnsubscribed: {
                                    vimeoSubscriptionsModel.clear();
                                    Scripts.getVimeoSubscriptions();
                                }
                            }

                            Timer {
                                id: vimeoTimer

                                interval: 1000
                                onTriggered: {
                                    Scripts.getVimeoPlaylists();
                                    Scripts.getVimeoSubscriptions();
                                }
                            }

                            Connections {
                                /* Connect to signals from C++ object DownloadManager */

                                target: DownloadManager
                                onAlert: messages.displayMessage(message)
                                onDownloadCompleted: {
                                    var downloadItem = downloadModel.get(downloadModel.currentDownload);
                                    messages.displayMessage(qsTr("Download of") + " '" + downloadItem.title + "' " + qsTr("completed"));
                                    Settings.removeStoredDownload(downloadItem.filePath);
                                    downloadModel.setProperty(downloadModel.currentDownload, "filePath", filename);
                                    if (downloadItem.convert) {
                                        Controller.convertToAudio(filename);
                                    }
                                    else {
                                        Scripts.moveToArchive(downloadItem);
                                    }
                                }
                                onDownloadCancelled: {
                                    downloadModel.deleteDownload(downloadModel.currentDownload);
                                    downloadModel.getNextDownload();
                                }
                                onQualityChanged: downloadModel.setProperty(downloadModel.currentDownload, "quality", quality)
                                onStatusChanged: downloadModel.setProperty(downloadModel.currentDownload, "status", status)
                                onProgressChanged: {
                                    downloadModel.setProperty(downloadModel.currentDownload, "bytesReceived", bytesReceived);
                                    downloadModel.setProperty(downloadModel.currentDownload, "totalBytes", bytesTotal);
                                    downloadModel.setProperty(downloadModel.currentDownload, "speed", speed);
                                }
                            }

                            Connections {
                                /* Connect to signals from C++ object Controller */

                                target: Controller
                                onAlert: messages.displayMessage(message)
                                onConversionStarted: downloadModel.setProperty(downloadModel.currentDownload, "status", "converting");
                                onConversionCompleted: {
                                    Settings.removeStoredDownload(downloadModel.get(downloadModel.currentDownload).filePath);
                                    downloadModel.setProperty(downloadModel.currentDownload, "filePath", downloadModel.get(downloadModel.currentDownload).filePath.replace(".mp4", ".m4a"));
                                    downloadModel.setProperty(downloadModel.currentDownload, "quality", "audio");
                                    Scripts.moveToArchive(downloadModel.get(downloadModel.currentDownload));
                                }
                                onConversionFailed: {
                                    var downloadItem = downloadModel.get(downloadModel.currentDownload);
                                    messages.displayMessage(qsTr("Conversion of '") + downloadItem.title + qsTr("' failed"));
                                    Settings.removeStoredDownload(downloadItem.filePath);
                                    Scripts.moveToArchive(downloadItem);
                                }
                            }

                            ListModel {
                                /* Download list model */

                                id: downloadModel

                                property int currentDownload
                                property variant statusDict

                                Component.onCompleted: {
                                    downloadModel.statusDict = { "paused": qsTr("Paused"), "queued": qsTr("Queued"), "downloading": qsTr("Downloading"), "converting": qsTr("Converting"), "failed": qsTr("Failed") }
                                }

                                function appendDownload(downloadItem) {
                                    downloadModel.insert(0, downloadItem);
                                    if ((downloadItem.status == "queued") && (!DownloadManager.isDownloading)) {
                                        DownloadManager.startDownload(downloadItem.filePath, downloadItem.playerUrl);
                                        downloadModel.currentDownload = 0;
                                    }
                                    else {
                                        downloadModel.currentDownload++;
                                    }
                                }

                                function resumeDownload(index) {
                                    downloadModel.setProperty(index, "status", "queued");
                                }

                                function pauseDownload(index) {
                                    if ((index == downloadModel.currentDownload) && (DownloadManager.isDownloading)) {
                                        DownloadManager.pauseDownload();
                                    }
                                    else {
                                        downloadModel.setProperty(index, "status", "paused");
                                    }
                                }

                                function cancelDownload(index) {
                                    if ((index == downloadModel.currentDownload) && (DownloadManager.isDownloading)) {
                                        DownloadManager.cancelDownload();
                                    }
                                    else {
                                        deleteDownload(index);
                                    }
                                }

                                function deleteDownload(index) {
                                    var itemToDelete = downloadModel.get(index);
                                    var downloadItem;
                                    var deleted = false;
                                    var i = 0;
                                    while ((i < downloadModel.count) && (!deleted)) {
                                        downloadItem = downloadModel.get(i);
                                        if (downloadItem == itemToDelete) {
                                            Settings.removeStoredDownload(downloadItem.filePath);
                                            if (i < downloadModel.currentDownload) {
                                                downloadModel.currentDownload--;
                                            }
                                            downloadModel.remove(i);
                                        }
                                        i++;
                                    }
                                }

                                function getNextDownload() {
                                    var i = downloadModel.count - 1;
                                    while ((i >= 0) && (!DownloadManager.isDownloading)) {
                                        var downloadItem = downloadModel.get(i);
                                        if (downloadItem.status == "queued") {
                                            downloadModel.currentDownload = i;
                                            DownloadManager.startDownload(downloadItem.filePath, downloadItem.playerUrl);
                                        }
                                        i--;
                                    }
                                }
                            }

                            ListModel {
                                /* Archive list model */

                                id: archiveModel

                                function markItemAsOld(filePath) {
                                    /* Mark the item with matching filePath as old */

                                    var i = 0;
                                    var marked = false
                                    while ((!marked) && (i < archiveModel.count)) {
                                        if (archiveModel.get(i).filePath == filePath) {
                                            archiveModel.setProperty(i, "isNew", 0);
                                            Settings.editArchiveVideo(filePath, "isNew", 0);
                                            marked = true;
                                        }
                                        i++;
                                    }
                                }
                            }

                            PlaylistModel {
                                /* Holds the users YouTube playlists */

                                id: playlistModel

                                onStatusChanged: {
                                    if ((playlistModel.status == XmlListModel.Ready) &&
                                            (playlistModel.totalResults > 50) &&
                                            (playlistModel.totalResults > playlistModel.count)) {
                                        Scripts.appendYouTubePlaylists();
                                    }
                                }
                            }

                            Timer {
                                id: playlistTimer

                                interval: 3000
                                onTriggered: Scripts.getYouTubePlaylists()
                            }

                            SubscriptionsModel {
                                /* Holds the users YouTube subscriptions */

                                id: subscriptionsModel

                                onStatusChanged: {
                                    if ((subscriptionsModel.status == XmlListModel.Ready) &&
                                            (subscriptionsModel.totalResults > 50) &&
                                            (subscriptionsModel.totalResults > subscriptionsModel.count)) {
                                        Scripts.appendYouTubeSubscriptions();
                                    }
                                }
                            }

                            ListModel {
                                /* Holds the users Dailymotion playlists */

                                id: dailymotionPlaylistModel

                                property bool loading : false
                                property bool moreResults : false
                                property int page : 1
                            }

                            Connections {
                                target: dailymotionPlaylistModel
                                onLoadingChanged: {
                                    if ((!dailymotionPlaylistModel.loading) && (dailymotionPlaylistModel.moreResults)) {
                                        Scripts.getDailymotionPlaylists();
                                    }
                                }
                            }

                            ListModel {
                                /* Holds the users Dailymotion subscriptions */

                                id: dailymotionSubscriptionsModel

                                property bool loading : false
                                property bool moreResults : false
                                property int page : 1
                            }

                            Connections {
                                target: dailymotionSubscriptionsModel
                                onLoadingChanged: {
                                    if ((!dailymotionSubscriptionsModel.loading) && (dailymotionSubscriptionsModel.moreResults)) {
                                        Scripts.getDailymotionSubscriptions();
                                    }
                                }
                            }

                            ListModel {
                                /* Holds the users vimeo playlists */

                                id: vimeoPlaylistModel

                                property bool loading : false
                                property bool moreResults : false
                                property int page : 1
                            }

                            Timer {
                                id: vimeoPlaylistTimer

                                interval: 3000
                                onTriggered: {
                                    vimeoPlaylistModel.page = 1;
                                    vimeoPlaylistModel.clear();
                                    Scripts.getVimeoPlaylists();
                                }
                            }

                            Connections {
                                target: vimeoPlaylistModel
                                onLoadingChanged: {
                                    if ((!vimeoPlaylistModel.loading) && (vimeoPlaylistModel.moreResults)) {
                                        Scripts.getVimeoPlaylists();
                                    }
                                }
                            }

                            ListModel {
                                /* Holds the users vimeo subscriptions */

                                id: vimeoSubscriptionsModel

                                property bool loading : false
                                property bool moreResults : false
                                property int page : 1
                            }

                            Connections {
                                target: vimeoSubscriptionsModel
                                onLoadingChanged: {
                                    if ((!vimeoSubscriptionsModel.loading) && (vimeoSubscriptionsModel.moreResults)) {
                                        Scripts.getVimeoSubscriptions();
                                    }
                                }
                            }

                            NotificationArea {
                                id: notificationArea

                                z: 100
                                focus: true
                                viewTitle: titleList[windowView.currentIndex]

                                Connections {
                                    onStartSearch: Scripts.search(query, order, site)
                                    onGoToVideo: Scripts.loadVideoInfo(video)
                                    onGoToDMVideo: Scripts.loadDMVideoInfo(video)
                                    onGoToVimeoVideo: Scripts.loadVimeoVideoInfo(video)
                                    onGoToDownloads: {
                                        if (windowView.currentIndex != viewsModel.count - 1) {
                                            Scripts.loadDownloads()
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: dismissSearchBar

                                z: 99
                                anchors.fill: window
                                enabled: notificationArea.searchBarOpen
                                onClicked: notificationArea.closeSearchBar()
                            }

                            Keys.onPressed: {
                                if (!(notificationArea.searchBarOpen) && (event.key > 47) && (event.key < 91)) {
                                    notificationArea.showSearchBar(event.text);
                                }
                            }

                            Loader {
                                id: messages

                                /* Message strings */

                                property string _VIDEO_RATED : qsTr("Your rating has been added")
                                property string _CANNOT_RATE : qsTr("You cannot rate your own videos")
                                property string _COMMENT_ADDED  : qsTr("Your comment has been added")
                                property string _ADDED_TO_FAVOURITES : qsTr("Video(s) added to favourites")
                                property string _VIDEO_IN_FAVOURITES : qsTr("Video already in favourites")
                                property string _ADDED_TO_PLAYLIST : qsTr("Video(s) added to playlist")
                                property string _PLAYLIST_CREATED : qsTr("New playlist created")
                                property string _PLAYLIST_DELETED : qsTr("Playlist deleted")
                                property string _SHARED_VIA_FACEBOOK : qsTr("Video shared on facebook")
                                property string _VIDEO_DOWNLOAD_ADDED : qsTr("Videos(s) added to download queue")
                                property string _VIDEO_IN_DOWNLOAD_QUEUE : qsTr("Video(s) already in download queue")
                                property string _AUDIO_DOWNLOAD_ADDED : qsTr("Audio track(s) added to download queue")
                                property string _AUDIO_IN_DOWNLOAD_QUEUE : qsTr("Audio track(s) already in download queue")
                                property string _NOT_SIGNED_IN : qsTr("You are not signed in to an account")
                                property string _USE_CUTETUBE_PLAYER : qsTr("Use the cuteTube Player to access this feature")
                                property string _UNABLE_TO_PLAY : qsTr("Unable to play videos at 360p quality or higher")

                                function displayMessage(message) {
                                    /* Display a notification using the message banner */

                                    if (!_VIDEO_PLAYING) {
                                        messages.source = "";
                                        messages.source = "MessageBanner.qml";
                                        messages.item.message = message;
                                    }
                                    toggleBusy(false);
                                }

                                width: window.width
                                anchors.bottom: window.top
                                z: 1
                                onLoaded: {
                                    messages.item.state = window.state;
                                    timer.running = true;
                                    messages.state = "show"
                                }

                                Timer {
                                    id: timer

                                    interval: 2500
                                    onTriggered: messages.state = ""
                                }

                                states: State {
                                    name: "show"
                                    AnchorChanges { target: messages; anchors { bottom: undefined; top: window.top } }
                                    PropertyChanges { target: messages; anchors.topMargin: 50 }
                                }

                                transitions: Transition {
                                    AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
                                }

                            }

                            VisualItemModel {
                                id: viewsModel

                                HomeView {
                                    id: homeView

                                    width: window.width
                                    height: window.height
                                    onMyChannel: Scripts.loadAccountView()
                                    onLiveVideos: Scripts.loadLiveVideos()
                                    onLoadCategory: Scripts.loadVideos(categoryFeed, title)
                                    onArchive: Scripts.loadArchiveView()
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }

                                Loader {
                                    width: window.width
                                    height: window.height
                                }
                            }

                            ListView {
                                id: windowView

                                anchors.fill: window
                                model: viewsModel
                                orientation: ListView.Horizontal
                                interactive: false
                                highlightMoveDuration: 300
                                onCurrentIndexChanged: {
                                    windowView.currentItem.visible = true;
                                    windowView.currentItem.opacity = 1;
                                }

                                MenuBar {
                                    id: menu

                                    z: 1
                                    onBackClicked: Scripts.goToPreviousView()
                                    onHomeClicked: Scripts.goHome()
                                    onQuitClicked: DownloadManager.isDownloading ? homeView.showConfirmExitDialog() : Qt.quit()
                                }
                            }

                            states: State {
                                name: "portrait"
                                when: window.height > window.width
                            }
                        }
