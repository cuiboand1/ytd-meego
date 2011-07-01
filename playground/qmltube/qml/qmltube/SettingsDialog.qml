import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property string playbackQuality
    property string downloadQuality
    property string downloadStatus
    property string downloadPath
    property string safeSearch
    property string categoryFeedOne
    property string categoryFeedTwo
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
        playbackSettings = { "mobile": qsTr("Mobile"), "hq": qsTr("High quality") };
        downloadSettings = { "hq": qsTr("High quality"), "360p": qsTr("360p"), "480p": qsTr("480p"), "720p": qsTr("720p") };
        if (!Controller.isSymbian) {
            var ds = downloadSettings;
            ds["mobile"] = qsTr("Mobile");
            downloadSettings = ds;
        }
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
        var catOne = Settings.getSetting("categoryFeedOne");
        var catTwo = Settings.getSetting("categoryFeedTwo");
        var catOneFound = false;
        var catTwoFound = false;
        var i = 0;
        var category;
        while (!((catOneFound) && (catTwoFound)) && (i < _CATEGORY_DICT.length)) {
            category = _CATEGORY_DICT[i];
            if (category.youtube == catOne) {
                categoryFeedOne = category.name;
                catOneFound = true;
            }
            else if (category.youtube == catTwo) {
                categoryFeedTwo = category.name;
                catTwoFound = true;
            }
            i++;
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
        var catOneFound = false;
        var catTwoFound = false;
        var i = 0;
        var category;
        while (!((catOneFound) && (catTwoFound)) && (i < _CATEGORY_DICT.length)) {
            category = _CATEGORY_DICT[i];
            if (category.name == categoryFeedOne) {
                Settings.setSetting("categoryFeedOne", category.youtube);
                catOneFound = true;
            }
            else if (category.name == categoryFeedTwo) {
                Settings.setSetting("categoryFeedTwo", category.youtube);
                catTwoFound = true;
            }
            i++;
        }
        Settings.setSetting("proxy", proxy);
        Settings.setSetting("mediaPlayer", mediaPlayer);
        Settings.setSetting("downloadPath", downloadPath);
        cuteTubeTheme = Settings.getSetting("theme");
        var catOne = Settings.getSetting("categoryFeedOne");
        var catTwo = Settings.getSetting("categoryFeedTwo");
        var catOrder = Settings.getSetting("categoryOrder");
        setCategoryFeeds(catOne, catTwo, catOrder);
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
        var list = [];
        var category;
        for (var i = 0; i < _CATEGORY_DICT.length; i++) {
            category = _CATEGORY_DICT[i];
            list.push(category.name);
        }
        list.sort();
        settingToBeChanged = categoryToChange;
        settingsLoader.source = "SettingsListDialog.qml";
        settingsLoader.item.setSettingsList(categoryToChange, list, currentSetting);
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
            categoryFeedOne = setting;
        }
        else if (settingToBeChanged == qsTr("Category Feed Two")) {
            categoryFeedTwo = setting;
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
        /* Delete all saved searches from the database */

        if (Settings.deleteAccessToken("Facebook")) {
            Sharing.setFacebookToken("");
            messages.displayMessage(qsTr("Your facebook token has been deleted"));
        }
        else {
            messages.displayMessage(qsTr("Database error. Unable to delete facebook token"));
        }
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
                    value: categoryFeedOne
                    onButtonClicked: showCategoryList(qsTr("Category Feed One"), categoryFeedOne)
                }

                ValueButton {
                    id: categoryFeedTwoButton

                    width: parent.width
                    name: qsTr("Category feed two")
                    value: categoryFeedTwo
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
                    name: qsTr("Delete facebook token")
                    visible: !(Sharing.facebookToken == "")
                    onButtonClicked: deleteFacebookToken()
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
