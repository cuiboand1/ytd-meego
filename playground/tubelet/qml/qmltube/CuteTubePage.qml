import QtQuick 1.0
import MeeGo.Components 0.1 as MeeGo
import "scripts/mainscripts.js" as Scripts
import "scripts/settings.js" as Settings

MeeGo.AppPage { // see: ~/qtquick/ux/meego-ux-components/src/components/ux/AppPage.qml
    id: mainWindow;
    pageTitle:			"CuteTube Tablet Edition";
    anchors.fill:		parent;

    property string _UPLOADS_FEED : "http://gdata.youtube.com/feeds/api/users/default/uploads?v=2&max-results=50"
    property string _FAVOURITES_FEED : "http://gdata.youtube.com/feeds/api/users/default/favorites?v=2&max-results=50"
    property string _PLAYLISTS_FEED : "http://gdata.youtube.com/feeds/api/users/default/playlists?v=2&max-results=50"
    property string _SUBSCRIPTIONS_FEED : "http://gdata.youtube.com/feeds/api/users/default/subscriptions?v=2&max-results=50"
    property string _NEW_SUB_VIDEOS_FEED : "http://gdata.youtube.com/feeds/api/users/default/newsubscriptionvideos?v=2&max-results=50"
    property string _MOST_RECENT_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_recent?v=2&max-results=50"
    property string _MOST_VIEWED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_viewed?v=2&max-results=50&time=today"
    property string _ON_THE_WEB_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/on_the_web?v=2&max-results=50"
    property string _MOST_SHARED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_shared?v=2&max-results=50"
    property string _TOP_RATED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?v=2&max-results=50"
    property string _TOP_FAVORITES_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?v=2&max-results=50"
    property string _MOST_POPULAR_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2&max-results=50"
    property string _MOST_DISCUSSED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_discussed?v=2&max-results=50"
    property string _MOST_RESPONDED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/most_responded?v=2&max-results=50"
    property string _RECENTLY_FEATURED_FEED : "http://gdata.youtube.com/feeds/api/standardfeeds/recently_featured?v=2&max-results=50"
    property string _CATEGORY_FEED : "http://gdata.youtube.com/feeds/api/videos?v=2&max-results=50&category="
    property variant _CATEGORY_DICT
    property variant _ORDER_BY_DICT
    property bool _VIDEO_PLAYING : false

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
        _CATEGORY_DICT = {
		"Comedy": qsTr("Comedy"),
		"Education": qsTr("Education"),
		"Entertainment": qsTr("Entertainment"),
		"Film": qsTr("Film & Animation"),
		"Games": qsTr("Gaming"),
	    "Animals": qsTr("Pets & Animals"),
	    "Autos": qsTr("Cars & Vehicles"),
	    "Howto": qsTr("Howto & Style"),
	    "MostDiscussed": qsTr("Most Discussed"),
	    "MostPopular": qsTr("Most Popular"),
	    "MostRecent": qsTr("Most Recent"),
	    "MostResponded": qsTr("Most Responded"),
	    "MostShared": qsTr("Most Shared"),
	    "MostViewed": qsTr("Most Viewed"),
	    "Music": qsTr("Music"),
	    "News": qsTr("News & Politics"),
	    "Nonprofit": qsTr("Non-profits & Activism"),
	    "OnTheWeb": qsTr("On The Web"),
	    "People": qsTr("People & Blogs"),
	    "Sports": qsTr("Sport"),
	    "Tech": qsTr("Science & Technology"),
	    "TopFavorites": qsTr("Top Favorites"),
	    "TopRated": qsTr("Top Rated"),
	    "Travel": qsTr("Travel & Events"),
     };
        _ORDER_BY_DICT = { "relevance": qsTr("Relevance"), "published": qsTr("Date"), "viewCount": qsTr("Views"), "rating": qsTr("Rating") };
        Scripts.restoreSettings();
    }

    function userIsSignedIn() {
        /* Check if the user is signed in */

        var signedIn = false;
        if (YouTube.currentUser != "") {
            signedIn = true;
        }
        else if (Settings.getDefaultAccount() != "unknown") {
            Scripts.signInToDefaultAccount();
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

        if (feedOne == "MostRecent") {
            homeView.categoryFeedOne = _MOST_RECENT_FEED;
        }
        else if (feedOne == "MostViewed") {
            homeView.categoryFeedOne = _MOST_VIEWED_FEED;
        }
        else if (feedOne == "OnTheWeb") { // NPM
            homeView.categoryFeedOne = _ON_THE_WEB_FEED;
    	}
        else if (feedOne == "MostShared") { // NPM
            homeView.categoryFeedOne = _MOST_SHARED_FEED;
    	}
        else if (feedOne == "TopRated") { // NPM
            homeView.categoryFeedOne = _TOP_RATED_FEED;
    	}
        else if (feedOne == "TopFavorites") { // NPM
            homeView.categoryFeedOne = _TOP_FAVORITES_FEED;
    	}
        else if (feedOne == "MostPopular") { // NPM
            homeView.categoryFeedOne = _MOST_POPULAR_FEED;
    	}
        else if (feedOne == "MostDiscussed") { // NPM
            homeView.categoryFeedOne = _MOST_DISCUSSED_FEED;
    	}
        else if (feedOne == "MostResponded") { // NPM
            homeView.categoryFeedOne = _MOST_RESPONDED_FEED;
    	}
        else if (feedOne == "RecentlyFeatured") { // NPM
            homeView.categoryFeedOne = _RECENTLY_FEATURED_FEED;
    	}
        else {
            homeView.categoryFeedOne = _CATEGORY_FEED + feedOne + "&orderby=" + order;
        }

        if (feedTwo == "MostRecent") {
            homeView.categoryFeedTwo = _MOST_RECENT_FEED;
        }
        else if (feedTwo == "MostViewed") {
            homeView.categoryFeedTwo = _MOST_VIEWED_FEED;
        }
        else if (feedOne == "OnTheWeb") { // NPM
            homeView.categoryFeedTwo = _ON_THE_WEB_FEED;
    	}
        else if (feedOne == "MostShared") { // NPM
            homeView.categoryFeedTwo = _MOST_SHARED_FEED;
    	}
        else if (feedOne == "TopRated") { // NPM
            homeView.categoryFeedTwo = _TOP_RATED_FEED;
    	}
        else if (feedOne == "TopFavorites") { // NPM
            homeView.categoryFeedTwo = _TOP_FAVORITES_FEED;
    	}
        else if (feedOne == "MostPopular") { // NPM
            homeView.categoryFeedTwo = _MOST_POPULAR_FEED;
    	}
        else if (feedOne == "MostDiscussed") { // NPM
            homeView.categoryFeedTwo = _MOST_DISCUSSED_FEED;
    	}
        else if (feedOne == "MostResponded") { // NPM
            homeView.categoryFeedTwo = _MOST_RESPONDED_FEED;
    	}
        else if (feedOne == "RecentlyFeatured") { // NPM
            homeView.categoryFeedTwo = _RECENTLY_FEATURED_FEED;
    	}
        else {
            homeView.categoryFeedTwo = _CATEGORY_FEED + feedTwo + "&orderby=" + order;
        }

        homeView.categoryFeedOneName = _CATEGORY_DICT[feedOne];
        homeView.categoryFeedTwoName = _CATEGORY_DICT[feedTwo];

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
                                    messages.item.state = mainWindow.state;
                                }
                            }

//                          width: 800
//                          height: 480
//                          anchors.fill: parent
//                          color: _VIDEO_PLAYING ? "black" : _BACKGROUND_COLOR

                            Image {
                                id: background

                                anchors.fill: mainWindow
                                source: (mainWindow.state == "portrait") ? "ui-images/background2.png" : "ui-images/background.png"
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
                                    Scripts.getSubscriptions();
                                    Scripts.getPlaylists();
                                    Settings.setSetting("ytAccessToken", token);
                                }
                                onPlaylistCreated: {
                                    messages.displayMessage(messages._PLAYLIST_CREATED);
                                    Scripts.getPlaylists();
                                }
                                onPlaylistDeleted: {
                                    messages.displayMessage(messages._PLAYLIST_DELETED);
                                    Scripts.getPlaylists();
                                }
                                onSubscribed: Scripts.getSubscriptions()
                                onUnsubscribed: Scripts.getSubscriptions()
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
                                        Scripts.appendPlaylists();
                                    }
                                }
                            }

                            Timer {
                                id: playlistTimer

                                interval: 3000
                                onTriggered: Scripts.getPlaylists()
                            }

                            SubscriptionsModel {
                                /* Holds the users YouTube subscriptions */

                                id: subscriptionsModel

                                onStatusChanged: {
                                    if ((subscriptionsModel.status == XmlListModel.Ready) &&
                                            (subscriptionsModel.totalResults > 50) &&
                                            (subscriptionsModel.totalResults > subscriptionsModel.count)) {
                                        Scripts.appendSubscriptions();
                                    }
                                }
                            }

                            NotificationArea {
                                id: notificationArea

                                z: 100
                                focus: true
                                viewTitle: titleList[windowView.currentIndex]

                                Connections {
                                    onStartSearch: Scripts.search(query, order)
                                    onGoToVideo: Scripts.loadVideoInfo(video)
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
                                anchors.fill: mainWindow
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
                                property string _NOT_SIGNED_IN : qsTr("You are not signed in to a YouTube account")
                                property string _NO_ACCOUNT_FOUND : qsTr("No YouTube account found")
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

                                width: mainWindow.width
                                anchors.bottom: mainWindow.top
                                z: 1
                                onLoaded: {
                                    messages.item.state = mainWindow.state;
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
                                    AnchorChanges { target: messages; anchors { bottom: undefined; top: mainWindow.top } }
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

                                    width: mainWindow.width
                                    height: mainWindow.height

                                    Connections {
                                        onMyChannel: Scripts.loadAccountView()
                                        onLoadCategory: Scripts.loadVideos(categoryFeed, title)
                                        onArchive: Scripts.loadArchiveView()
                                    }
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }

                                Loader {
                                    width: mainWindow.width
                                    height: mainWindow.height
                                }
                            }

                            ListView {
                                id: windowView

                                anchors.fill: mainWindow
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
                                when: mainWindow.height > mainWindow.width
                            }
                        }
