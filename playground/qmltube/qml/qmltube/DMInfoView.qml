import QtQuick 1.0
import "scripts/videoinfoscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator
import "scripts/settings.js" as Settings
import "scripts/dateandtime.js" as DT
import "scripts/dailymotion.js" as DM

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : true
    property bool showMenuButtonFour : true
    property bool showMenuButtonFive : false

    property variant video
    property string videoId
    property string playerUrl
    property string title
    property string author
    property string description : qsTr("No description")
    property string thumbnail
    property string duration
    property string views : "0"
    property int rating : 0
    property variant tags : []

    signal authorClicked(string username)
    signal playVideo(variant video)
    signal goToVideo(variant video)
    signal searchDailymotion(string query, string order, string site)
    signal dialogClose

    function setVideo(videoObject) {
        video = videoObject;
        videoId = video.id;
        playerUrl = video.playerUrl;
        title = video.title;
        author = video.author;
        thumbnail = video.largeThumbnail;
        duration = /:/.test(video.duration) ? video.duration : DT.getYTDuration(video.duration);
        if (video.description != "") {
            description = video.description;
        }
        if (video.views) {
            views = video.views;
        }
        if (video.rating) {
            rating = parseInt(video.rating);
        }
        if (video.tags) {
            tags = video.tags.split(",");
        }
    }

    function onMenuButtonOneClicked() {
        DailyMotion.addToFavourites(videoId);
    }

    function onMenuButtonTwoClicked() {
        Scripts.checkFacebookAccess();
    }

    function onMenuButtonThreeClicked() {
        Scripts.checkTwitterAccess();
    }

    function onMenuButtonFourClicked() {
        Controller.copyToClipboard("http://dailymotion/video/" + videoId);
    }

    Connections {
        target: Sharing
        onAlert: messages.displayMessage(message)
        onPostedToFacebook: messages.displayMessage(messages._SHARED_VIA_FACEBOOK)
        onPostedToTwitter: messages.displayMessage(messages._SHARED_VIA_TWITTER)
        onRenewFacebookToken: {
            Scripts.closeDialogs();
            Settings.deleteAccessToken("Facebook");
            Scripts.checkFacebookAccess();
        }
    }

    Item {
        id: dimmer

        anchors.fill: window

        Rectangle {
            id: frame

            width: Math.floor(window.width / 3.2)
            height: Math.floor(frame.width / (4 / 3))
            anchors { left: dimmer.left; leftMargin: 10; top: dimmer.top; topMargin: 60 }
            color: _BACKGROUND_COLOR
            border.width: 2
            border.color: (cuteTubeTheme == "light") ? "grey" : "white"

            Image {
                id: thumb

                anchors { fill: frame; margins: 2 }
                source: thumbnail
                smooth: true
                onStatusChanged: {
                    if (thumb.status == Image.Error) {
                        thumb.source = "ui-images/error.jpg";
                    }
                }

                Rectangle {
                    id: durationLabel

                    width: durationText.width + 30
                    height: durationText.height + 10
                    anchors { bottom: thumb.bottom; right: thumb.right }
                    color: "black"
                    opacity: 0.5
                    smooth: true
                }

                Text {
                    id: durationText

                    anchors.centerIn: durationLabel
                    text: duration
                    color: "white"
                    font.pixelSize: _STANDARD_FONT_SIZE
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: Math.floor(thumb.width / 3.5)
                    height: width
                    anchors.centerIn: thumb
                    color: frameMouseArea.pressed ? _ACTIVE_COLOR_LOW : "black"
                    opacity: 0.5
                    radius: 5
                    smooth: true

                    Image {
                        id: playIcon

                        anchors { fill: parent; margins: 5 }
                        smooth: true
                        source: "ui-images/playicon.png"
                        sourceSize.width: playIcon.width
                        sourceSize.height: playIcon.height
                    }
                }
            }

            MouseArea {
                id: frameMouseArea

                anchors.fill: frame
                onClicked: playVideo([DM.createVideoObject(video)])
            }

            Grid {
                id: buttonGrid

                anchors { left: frame.left; top: frame.bottom; topMargin: 10 }
                columns: 2
                spacing: 10

                PushButton {
                    id: videoButton

                    width: Controller.isSymbian ? frame.width : Math.floor(frame.width / 2) - 5
                    icon: (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                    iconWidth: 65
                    iconHeight: 65
                    onButtonClicked: addDownload(video)
                }

                PushButton {
                    id: audioButton

                    width: videoButton.width
                    height: videoButton.height
                    icon: (cuteTubeTheme == "light") ? "ui-images/audiodownloadiconlight.png" : "ui-images/audiodownloadicon.png"
                    iconWidth: 65
                    iconHeight: 65
                    onButtonClicked: addAudioDownload(video)
                    visible: !Controller.isSymbian
                }
            }
        }

        Item {
            id: tabItem

            property variant tabs : [ qsTr("Info"), qsTr("Related") ]

            anchors { fill: dimmer; leftMargin: frame.width + 20; rightMargin: 10; topMargin: 60; bottomMargin: 65 }

            Row {
                id: tabRow

                Repeater {
                    model: tabItem.tabs

                    Item {
                        width: tabItem.width / tabItem.tabs.length
                        height: 40

                        BorderImage {
                            anchors.fill: parent
                            source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                            smooth: true
                            visible: tabView.currentIndex == index
                        }

                        Text {
                            anchors.fill: parent
                            font.pixelSize: _STANDARD_FONT_SIZE
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: tabView.currentIndex == index ? _TEXT_COLOR : "grey"
                            text: modelData
                        }

                        Rectangle {
                            height: 1
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            color: _ACTIVE_COLOR_HIGH
                            opacity: 0.5
                            visible: !(tabView.currentIndex == index)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: tabView.currentIndex = index
                        }
                    }
                }
            }

            ListView {
                id: tabView

                anchors { left: tabItem.left; right: tabItem.right; top: tabRow.bottom; bottom: tabItem.bottom }
                orientation: ListView.Horizontal
                highlightMoveDuration: 200
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapOneItem
                flickDeceleration: 500
                boundsBehavior: Flickable.StopAtBounds
                model: tabModel
                clip: true

                onCurrentIndexChanged: {
                    if ((tabView.currentIndex == 1) && (!relatedView.loaded) && (relatedView.count == 0)) {
                        DM.getRelatedVideos();
                    }
                }
            }
        }

        VisualItemModel {
            id: tabModel

            Flickable {
                id: scrollArea

                width: tabView.width
                height: tabView.height
                clip: true
                contentWidth: textColumn.width
                contentHeight: textColumn.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.DragOverBounds
                interactive: visibleArea.heightRatio < 1
                opacity: (tabView.currentIndex == 0) ? 1 : 0

                Column {
                    id: textColumn

                    spacing: 10
                    width: tabView.width
                    height: childrenRect.height

                    Text {
                        id: titleText

                        width: textColumn.width
                        text: title
                        color: _TEXT_COLOR
                        font.pixelSize: _STANDARD_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                    }

                    Text {
                        id: authorText

                        width: textColumn.width
                        color: _TEXT_COLOR
                        font.pixelSize: _SMALL_FONT_SIZE
                        textFormat: Text.StyledText
                        wrapMode: TextEdit.WordWrap
                        text: authorMouseArea.pressed ? qsTr("By ") + "<font color='"
                                                        + _ACTIVE_COLOR_HIGH + "'>" + author
                                                      : qsTr("By ") + "<font color='"
                                                        + _ACTIVE_COLOR_LOW + "'>" + author

                        MouseArea {
                            id: authorMouseArea

                            anchors.fill: authorText
                            onClicked: authorClicked(author)
                        }
                    }

                    Row {
                        x: 2
                        spacing: 10

                        Repeater {
                            model: rating

                            Image {
                                width: 20
                                height: 20
                                source: (cuteTubeTheme == "nightred") ? "ui-images/favouritesiconred.png" : "ui-images/favouritesiconblue.png"
                                sourceSize.width: width
                                sourceSize.height: height
                                smooth: true
                            }

                        }

                        Repeater {
                            model: 5 - rating

                            Image {
                                width: 20
                                height: 20
                                source: "ui-images/emptyrating.png"
                                sourceSize.width: width
                                sourceSize.height: height
                                smooth: true
                            }

                        }

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Views")
                        }

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: views
                        }
                    }

                    Text {
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: _TEXT_COLOR
                        text: qsTr("Description")
                    }

                    Text {
                        id: descriptionText

                        width: textColumn.width
                        text: description
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                    }

                    Text {
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: _TEXT_COLOR
                        text: qsTr("Tags")
                    }

                    Flow {
                        spacing: 10
                        width: parent.width

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: qsTr("No tags")
                            visible: tags.length == 0
                        }

                        Repeater {
                            model: tags

                            Text {
                                font.pixelSize: _SMALL_FONT_SIZE
                                color: children[0].pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                                text: modelData

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: searchDailymotion(parent.text, Settings.getSetting("searchOrder").toLowerCase(), "Dailymotion")
                                }

                                Text {
                                    anchors.left: parent.right
                                    font.pixelSize: _SMALL_FONT_SIZE
                                    color: "grey"
                                    text: ","
                                    visible: index < (tags.length - 1)
                                }
                            }
                        }
                    }

                }
            }

            ListView {
                id: relatedView

                property bool loaded : false // True if related videos have been loaded
                property string videoFeed : "https://api.dailymotion.com/video/" + videoId
                                            + "/related?limit=50&fields="
                                            + _DM_FIELDS

                width: tabView.width
                height: tabView.height
                boundsBehavior: Flickable.DragOverBounds
                highlightMoveDuration: 500
                preferredHighlightBegin: 0
                preferredHighlightEnd: 100
                highlightRangeMode: ListView.StrictlyEnforceRange
                cacheBuffer: 2500
                interactive: visibleArea.heightRatio < 1
                clip: true
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                onCurrentIndexChanged: {
                    if ((relatedView.count - relatedView.currentIndex == 1)
                            && (!relatedModel.loading) && (relatedModel.moreResults)) {
                        DM.getRelatedVideos();
                    }
                }

                footer: Item {
                    id: footer

                    width: relatedView.width
                    height: 100
                    visible: (relatedModel.loading)
                    opacity: footer.visible ? 1 : 0

                    BusyDialog {
                        anchors.centerIn: footer
                        opacity: footer.opacity
                    }
                }

                model: ListModel {
                    id: relatedModel

                    property bool loading : true
                    property bool moreResults : true
                    property int page : 1
                }

                delegate: DMListDelegate {
                    id: delegate

                    onDelegateClicked: goToVideo(relatedModel.get(index))
                    onPlayClicked: {
                        var relatedVideo = DM.createVideoObject(relatedModel.get(index));
                        playVideo([relatedVideo])
                    }
                }

                Text {
                    id: noResultsText

                    anchors { top: relatedView.top; topMargin: 60; horizontalCenter: relatedView.horizontalCenter }
                    font.pixelSize: _STANDARD_FONT_SIZE
                    font.bold: true
                    color: "grey"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("No related videos")
                    visible: false

                    Timer {
                        interval: 5000
                        running: (!relatedModel.loading) && (relatedModel.count == 0)
                        onTriggered: {
                            if (relatedModel.count == 0) {
                                noResultsText.visible = true;
                            }
                        }
                    }
                }

                ScrollBar {}
            }
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1}
        }

        transitions: Transition {
            PropertyAnimation { properties: "opacity"; duration: 500 }
        }
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
        PropertyChanges { target: frame; width: Math.floor(window.width / 1.9) }
        PropertyChanges { target: tabItem; anchors { leftMargin: 10; rightMargin: 10; topMargin: frame.height + 70 } }
        PropertyChanges { target: videoButton; width: window.width - (frame.width + 30); height: Math.floor(frame.height / 2) - 5 }
        AnchorChanges { target: buttonGrid; anchors { left: frame.right; top: frame.top } }
        PropertyChanges { target: buttonGrid; anchors.leftMargin: 10; anchors.topMargin: 0; columns: 1 }
    }
}

