import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property string playbackQuality
    property string downloadQuality
    property string downloadStatus
    property string downloadPath
    property string safeSearch
    property string categoryFeedOne //NPM: changed to hold the untranslated, non-display name of the feed, Default is "MostRecent"
    property string categoryFeedTwo //NPM: changed to hold the untranslated, non-display name of the feed. Default is "MostViewed"
    property string categoryOrder
    property string screenOrientation
    property string mediaPlayer
    property string theme
    property string language
    property string proxy
    property string widgetFeedOne
    property string widgetFeedTwo
    property string widgetFeedThree
    property string widgetFeedFour

    property variant playbackSettings
    property variant downloadSettings
    property variant downloadStatusSettings
    property variant safeSearchSettings
    property variant orientationSettings
    property variant mediaPlayerSettings
    property variant themeSettings
    property variant languageSettings
    property variant widgetFeeds

    property string settingToBeChanged

    signal close

    Component.onCompleted: {
        playbackSettings =          { "hq":   qsTr("High quality"),
                                      "360p": qsTr("360p") };
        //Don't allow playback resolutions that are known to not be handled by given platform...
        //NPM: TODO: allow "480p" playback of streaming videos on Harmattan when bug that displays blank screen resolved.
        if (!(Controller.isHarmattan || Controller.isMaemo || Controller.isSymbian)) { //NPM: for non-handhelds, such as MeeGo Netbook or Tablet, let user choose, as some hardware capable of 720p ...
            playbackSettings["480p"]        = qsTr("480p");
            playbackSettings["720p"]        = qsTr("720p");
        }
        downloadSettings =          { "hq":   qsTr("High quality"),
                                      "360p": qsTr("360p"),
                                      "480p": qsTr("480p"),
                                      "720p": qsTr("720p") };
/* NPM: commentout: 'mobile' doesn't exist anymore..., now the lowest-quality setting is "High Quality" :-)
        if (!Controller.isSymbian) {
            var ds = downloadSettings;
            ds["mobile"] = qsTr("Mobile");
            downloadSettings = ds;
        }
end-NPM: commentout */
        downloadStatusSettings = { "queued": qsTr("Automatically"), "paused": qsTr("Manually") };
        safeSearchSettings = { "strict": qsTr("On"), "none": qsTr("Off") };
        orientationSettings = { "automatic": qsTr("Automatic"), "landscape": qsTr("Landscape"), "portrait": qsTr("Portrait") };
        themeSettings = { "light": qsTr("Light"), "dark": qsTr("Dark"), "night": qsTr("Midnight Blue"), "nightred": qsTr("Midnight Red") };
        languageSettings = { "nl": qsTr("Dutch"), "en": qsTr("English"), "fi": qsTr("Finnish"), "de": qsTr("German"), "it": qsTr("Italian"),
                "pl": qsTr("Polish"), "pt": qsTr("Portuguese"), "ru": qsTr("Russian") };
        widgetFeeds = { "_MOST_RECENT_FEED": qsTr("Most recent"), "_MOST_VIEWED_FEED": qsTr("Most viewed"),
                "archive": qsTr("Archive"), "_NEW_SUB_VIDEOS_FEED": qsTr("Latest subscription videos"),
                "_UPLOADS_FEED": qsTr("My uploads"), "_FAVOURITES_FEED": qsTr("My favourites") };

        getSettings();
    }

    function getSettings() {
        /* Retrieve relevent settings from the database
          and populate the dialog */

        widgetColumn.visible = Controller.widgetInstalled();
        mediaPlayerSettings = Controller.getInstalledMediaPlayers();
        playbackQuality = playbackSettings[Settings.getSetting("playbackQuality")];
        downloadQuality = downloadSettings[Settings.getSetting("downloadQuality")];
        downloadStatus = downloadStatusSettings[Settings.getSetting("downloadStatus")];
        var cf1, cf2;
	if (typeof (cf1 = Settings.getSetting("categoryFeedOne")) === 'string')
	    categoryFeedOne = cf1; //was: _CATEGORY_DICT[cf1].name;
	else {
	    categoryFeedOne = "MostRecent"; // NPM: set same default as for scripts/settings.js:setDefaultSettings(): "_MOST_RECENT_FEED"
	    console.log('Error: in getSettings(), bad value from Settings.getSetting("categoryFeedOne") == "' + cf1 + '" defaulting to "MostRecent"...');
	}
	if (typeof (cf2 = Settings.getSetting("categoryFeedTwo")) === 'string')
	    categoryFeedTwo = cf2; //was: _CATEGORY_DICT[cf2].name;
	else {
	    categoryFeedTwo = "MostViewed";  // NPM: set same default as for scripts/settings.js:setDefaultSettings():"_MOST_VIEWED_FEED"
	    console.log('Error: in getSettings(), bad value from Settings.getSetting("categoryFeedTwo") == "' + cf2 + '" defaulting to "MostViewed"...');
	}
        categoryOrder = _ORDER_BY_DICT[Settings.getSetting("categoryOrder")];
        safeSearch = safeSearchSettings[Settings.getSetting("safeSearch")];
        downloadPath = Settings.getSetting("downloadPath");
        screenOrientation = orientationSettings[Settings.getSetting("screenOrientation")];
        mediaPlayer = Settings.getSetting("mediaPlayer");
        theme = themeSettings[Settings.getSetting("theme")];
        language = languageSettings[Settings.getSetting("language")];
        proxy = Settings.getSetting("proxy");
        widgetFeedOne = widgetFeeds[Settings.getSetting("widgetFeedOne")];
        widgetFeedTwo = widgetFeeds[Settings.getSetting("widgetFeedTwo")];
        widgetFeedThree = widgetFeeds[Settings.getSetting("widgetFeedThree")];
        widgetFeedFour = widgetFeeds[Settings.getSetting("widgetFeedFour")];
    }

    function saveSettings() {
        /* Save all settings to the database */

        var settings = [ ["playbackSettings", "playbackQuality"],
                        ["downloadSettings", "downloadQuality"],
                        ["downloadStatusSettings", "downloadStatus"],
                        ["_ORDER_BY_DICT", "categoryOrder"],
                        ["safeSearchSettings", "safeSearch"],
                        ["orientationSettings", "screenOrientation"],
                        ["themeSettings", "theme"],
                        ["languageSettings", "language"],
                        ["widgetFeeds", "widgetFeedOne"],
                        ["widgetFeeds", "widgetFeedTwo"],
                        ["widgetFeeds", "widgetFeedThree"],
                        ["widgetFeeds", "widgetFeedFour"] ];

        var settingDict;
        var value;
        for (var i = 0; i < settings.length; i++) {
            settingDict = eval(settings[i][0]);
            value = eval(settings[i][1]);
            for (var attribute in settingDict) {
                if (settingDict[attribute] == value) {
                    Settings.setSetting(settings[i][1], attribute);
                }
            }
        }
        Settings.setSetting("categoryFeedOne", categoryFeedOne);
        Settings.setSetting("categoryFeedTwo", categoryFeedTwo);
        setCategoryFeeds(categoryFeedOne, categoryFeedTwo,
			 Settings.getSetting("categoryOrder"));
        Settings.setSetting("proxy", proxy);
        Settings.setSetting("mediaPlayer", mediaPlayer);
        Settings.setSetting("downloadPath", downloadPath);
        cuteTubeTheme = Settings.getSetting("theme");
        Controller.setOrientation(Settings.getSetting("screenOrientation"));
        Controller.setMediaPlayer(mediaPlayer)
        YouTube.setPlaybackQuality(Settings.getSetting("playbackQuality"));
        DownloadManager.setDownloadQuality(Settings.getSetting("downloadQuality"));
        messages.displayMessage(qsTr("Your settings have been saved"));
        close();
    }

    function showDownloadPathDialog() {
        settingToBeChanged = qsTr("Download Path");
        settingsLoader.source = "FileChooserDialog.qml";
        settingsLoader.item.title = qsTr("Download Location");
        settingsLoader.item.showButton = true;
        settingsLoader.item.showFiles = false;
        settingsLoader.item.folder = downloadPath;
        dialog.state = "showChild";
    }

    function showProxyDialog() {
        settingToBeChanged = qsTr("Network Proxy");
        settingsLoader.source = "ProxyDialog.qml";
        settingsLoader.item.setProxy(proxy);
        dialog.state = "showChild";
    }

    function showCategoryList(categoryToChange, currentSetting) {
        var currentDisplay, list = [];
        for (var category in _CATEGORY_DICT) {
	    var name = _CATEGORY_DICT[category].name;
            list.push(name);
	    if (category == currentSetting) {
		currentDisplay = name; // NPM: for setSettingsList() to be set to correct item, must pass display value not id like 'MostViewed'.
	    }
        }
        list.sort();
        settingToBeChanged = categoryToChange;
        settingsLoader.source = "SettingsListDialog.qml";
        settingsLoader.item.setSettingsList(categoryToChange, list, currentDisplay);
        dialog.state = "showChild";
    }

    function showSettingsList(title, settingsList, currentSetting) {
        /* Show the settings list dialog */

        var list = [];
        var settings = eval(settingsList);
        for (var value in settings) {
            list.push(settings[value]);
        }
        list.sort();
        settingToBeChanged = title;
        settingsLoader.source = "SettingsListDialog.qml";
        settingsLoader.item.setSettingsList(title, list, currentSetting);
        dialog.state = "showChild";
    }

    function changeSetting(setting) {
        /* Change the appropriate setting in the dialog */

        if (settingToBeChanged == qsTr("YouTube Playback Quality")) {
            playbackQuality = setting;
        }
        else if (settingToBeChanged == qsTr("YouTube Download Quality")) {
            downloadQuality = setting;
        }
        else if (settingToBeChanged == qsTr("Start Downloads")) {
            downloadStatus = setting;
        }
        else if (settingToBeChanged == qsTr("Download Path")) {
            downloadPath = setting;
        }
        else if (settingToBeChanged == qsTr("Category Feed One")) {
	    for (var category in _CATEGORY_DICT) {
		if ((_CATEGORY_DICT[category].name) == setting) {
		    categoryFeedOne = category;
//		    console.log('Debug:  changeSettings() categoryFeedTwo == "' + categoryFeedOne + '"');
		}
	    }
        }
        else if (settingToBeChanged == qsTr("Category Feed Two")) {
	    for (var category in _CATEGORY_DICT) {
		if ((_CATEGORY_DICT[category].name) == setting) {
		    categoryFeedTwo = category;
//		    console.log('Debug:  changeSettings() categoryFeedTwo == "' + categoryFeedTwo + '"');
		}
	    }
        }
        else if (settingToBeChanged == qsTr("Order Category Videos By")) {
            categoryOrder = setting;
        }
        else if (settingToBeChanged == qsTr("Safe Search")) {
            safeSearch = setting;
        }
        else if (settingToBeChanged == qsTr("Screen Orientation")) {
            screenOrientation = setting;
        }
        else if (settingToBeChanged == qsTr("Media Player")) {
            mediaPlayer = setting;
        }
        else if (settingToBeChanged == qsTr("Theme")) {
            theme = setting;
        }
        else if (settingToBeChanged == qsTr("Language")) {
            language = setting;
        }
        else if (settingToBeChanged == qsTr("Network Proxy")) {
            proxy = setting;
        }
        else if (settingToBeChanged == qsTr("Widget Feed One")) {
            widgetFeedOne = setting;
        }
        else if (settingToBeChanged == qsTr("Widget Feed Two")) {
            widgetFeedTwo = setting;
        }
        else if (settingToBeChanged == qsTr("Widget Feed Three")) {
            widgetFeedThree = setting;
        }
        else if (settingToBeChanged == qsTr("Widget Feed Four")) {
            widgetFeedFour = setting;
        }
    }

    function clearSearches() {
        /* Delete all saved searches from the database */

        if (Settings.clearSearches()) {
            messages.displayMessage(qsTr("Your saved searches have been cleared"));
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to clear searches"));
        }
    }

    function deleteFacebookToken() {
        if (Settings.deleteAccessToken("Facebook")) {
            Sharing.setFacebookToken("");
            messages.displayMessage(qsTr("Your facebook access token has been deleted"));
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to delete facebook access token"));
        }
    }

    function deleteTwitterToken() {
        if (Settings.deleteAccessToken("Twitter")) {
            Sharing.setTwitterToken("", "");
            messages.displayMessage(qsTr("Your twitter access token has been deleted"));
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to delete twitter access token"));
        }
    }

    // NPM -- prevent multiline labels that I added from overflowing the expected
    // dimensions of ValueButton
    function trimMultiLineDisplayCategory(category) {
	var i, elt = _CATEGORY_DICT[category].name;
	if ((i = elt.indexOf("\n")) >= 0)
	    return (elt.substring(0, i) + "...");
	else
	    return (elt);
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Loader {
        id: settingsLoader

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

        Connections {
            target: settingsLoader.item
            onClose: dialog.state = "show"
            onSettingChosen: changeSetting(setting)
        }
    }

    Item {
        id: background

        anchors.fill: dialog

        Rectangle {
            anchors.fill: background
            color: _BACKGROUND_COLOR
            opacity: 0.5
            smooth: true
        }

        Text {
            id: title

            anchors { horizontalCenter: background.horizontalCenter; top: background.top; topMargin: 10 }
            font.pixelSize: _SMALL_FONT_SIZE
            color: _TEXT_COLOR
            text: qsTr("Settings")
            smooth: true
        }

        Flickable {
            id: flicker

            anchors { fill: background; topMargin: 50; leftMargin: 6; rightMargin: (dialog.width > dialog.height) ? 176 : 6; bottomMargin: (dialog.width > dialog.height) ? 8 : 100 }
            contentWidth: dialog.width
            contentHeight: widgetColumn.visible ? settingsColumn.height + widgetColumn.height + 12 : settingsColumn.height + 2
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragOverBounds

            Column {
                id: settingsColumn

                width: flicker.width - 4
                anchors { top: parent.top; left: parent.left; leftMargin: 2 }
                spacing: 10

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Network")
                    smooth: true
                }

                ValueButton {
                    id: proxyButton

                    width: parent.width
                    name: qsTr("Network proxy")
                    value: (proxy == ":") ? qsTr("None") : proxy
                    onButtonClicked: showProxyDialog()
                }

                ValueButton {
                    id: downloadStatusButton

                    width: parent.width
                    name: qsTr("Start downloads")
                    value: downloadStatus
                    onButtonClicked: showSettingsList(qsTr("Start Downloads"), "downloadStatusSettings", downloadStatus)
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Media")
                    smooth: true
                }

                ValueButton {
                    id: mediaPlayerButton

                    width: parent.width
                    name: qsTr("Media player")
                    value: mediaPlayer
                    visible: !Controller.isSymbian
                    onButtonClicked: showSettingsList(qsTr("Media Player"), "mediaPlayerSettings", mediaPlayer)
                }

                ValueButton {
                    id: playbackQualityButton

                    width: parent.width
                    name: qsTr("YouTube playback quality")
                    value: playbackQuality
                    visible: !Controller.isSymbian
                    onButtonClicked: showSettingsList(qsTr("YouTube Playback Quality"), "playbackSettings", playbackQuality)
                }

                ValueButton {
                    id: downloadQualityButton

                    width: parent.width
                    name: qsTr("YouTube download quality")
                    value: downloadQuality
                    onButtonClicked: showSettingsList(qsTr("YouTube Download Quality"), "downloadSettings", downloadQuality)
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Homescreen categories")
                    smooth: true
                }

                ValueButton {
                    id: categoryFeedOneButton

                    width: parent.width
                    name: qsTr("Category feed one")
		    value:	     trimMultiLineDisplayCategory(categoryFeedOne) // NPM -- don't let multiline names I added overflow expected area for display
                    onButtonClicked: showCategoryList(qsTr("Category Feed One"), categoryFeedOne)
                }

                ValueButton {
                    id: categoryFeedTwoButton

                    width: parent.width
                    name: qsTr("Category feed two")
                    value:	     trimMultiLineDisplayCategory(categoryFeedTwo) // NPM -- don't let multiline names I added overflow expected area for display
                    onButtonClicked: showCategoryList(qsTr("Category Feed Two"), categoryFeedTwo)
                }

                ValueButton {
                    id: categoryOrderButton

                    width: parent.width
                    name: qsTr("Order category videos by")
                    value: categoryOrder
                    onButtonClicked: showSettingsList(qsTr("Order Category Videos By"), "_ORDER_BY_DICT", categoryOrder)
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Searches")
                    smooth: true
                }

                ValueButton {
                    id: safeSearchButton

                    width: parent.width
                    name: qsTr("Safe search")
                    value: safeSearch
                    onButtonClicked: showSettingsList(qsTr("Safe Search"), "safeSearchSettings", safeSearch)
                }

                PushButton {
                    id: clearSearchesButton

                    width: parent.width
                    showIcon: false
                    showText: true
                    name: qsTr("Clear saved searches")
                    onButtonClicked: clearSearches()
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Social networks")
                    smooth: true
                    visible: clearFacebookButton.visible
                }

                PushButton {
                    id: clearFacebookButton

                    width: parent.width
                    showIcon: false
                    showText: true
                    name: qsTr("Delete facebook access token")
                    visible: !(Sharing.facebookToken == "")
                    onButtonClicked: deleteFacebookToken()
                }

                PushButton {
                    id: clearTwitterButton

                    width: parent.width
                    showIcon: false
                    showText: true
                    name: qsTr("Delete twitter access token")
                    visible: !(Sharing.twitterToken == "")
                    onButtonClicked: deleteTwitterToken()
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Appearance")
                    smooth: true
                }

                ValueButton {
                    id: themeButton

                    width: parent.width
                    name: qsTr("Theme")
                    value: theme
                    onButtonClicked: showSettingsList(qsTr("Theme"), "themeSettings", theme)
                }

                ValueButton {
                    id: languageButton

                    width: parent.width
                    name: qsTr("Language")
                    value: language
                    visible: !Controller.isSymbian
                    onButtonClicked: showSettingsList(qsTr("Language"), "languageSettings", language)
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("System")
                    smooth: true
                }

                ValueButton {
                    id: downloadPathButton

                    width: parent.width
                    name: qsTr("Download location")
                    value: downloadPath
                    onButtonClicked: showDownloadPathDialog()
                }

                ValueButton {
                    id: orientationButton

                    width: parent.width
                    name: qsTr("Screen orientation")
                    value: screenOrientation
                    onButtonClicked: showSettingsList(qsTr("Screen Orientation"), "orientationSettings", screenOrientation)
                }
            }

            Column {
                id: widgetColumn

                width: flicker.width - 4
                anchors { top: parent.top; topMargin: settingsColumn.height + 10; left: parent.left; leftMargin: 2 }
                spacing: 10

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Widget")
                    smooth: true
                }

                ValueButton {
                    id: feedOneButton

                    width: parent.width
                    name: qsTr("Feed one")
                    value: widgetFeedOne
                    onButtonClicked: showSettingsList(qsTr("Widget Feed One"), "widgetFeeds", widgetFeedOne)
                }

                ValueButton {
                    id: feedTwoButton

                    width: parent.width
                    name: qsTr("Feed two")
                    value: widgetFeedTwo
                    onButtonClicked: showSettingsList(qsTr("Widget Feed Two"), "widgetFeeds", widgetFeedTwo)
                }

                ValueButton {
                    id: feedThreeButton

                    width: parent.width
                    name: qsTr("Feed three")
                    value: widgetFeedThree
                    onButtonClicked: showSettingsList(qsTr("Widget Feed Three"), "widgetFeeds", widgetFeedThree)
                }

                ValueButton {
                    id: feedFourButton

                    width: parent.width
                    name: qsTr("Feed four")
                    value: widgetFeedFour
                    onButtonClicked: showSettingsList(qsTr("Widget Feed Four"), "widgetFeeds", widgetFeedFour)
                }
            }
        }

        PushButton {
            id: saveButton

            width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
            anchors { right: background.right; bottom: background.bottom; margins: 10 }
            icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"

            Connections {
                onButtonClicked: saveSettings()
            }
        }
    }

    CloseButton {
        onButtonClicked: close()
    }

    MouseArea {

        property real xPos

        z: -1
        anchors.fill: dialog
        onPressed: xPos = mouseX
        onReleased: {
            if (xPos - mouseX > 100) {
                close();
            }
        }
    }

    states: [
        State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        },

        State {
            name: "showChild"
            AnchorChanges { target: dialog; anchors { left: parent.right; right: undefined } }
        }
    ]

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
