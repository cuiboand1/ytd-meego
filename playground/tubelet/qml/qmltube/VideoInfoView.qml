import QtQuick 1.0
import "scripts/videoinfoscripts.js" as Scripts
import "scripts/settings.js" as Settings
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property variant video
    property string videoId
    property string playerUrl
    property string title
    property string author
    property string date
    property string description : qsTr("No description")
    property string thumbnail
    property string duration
    property string views : "0"
    property string comments : "0"
    property string likes : "0"
    property string dislikes : "0"
    property variant tags : []
    property string likeOrDislike

    signal authorClicked(string username)
    signal playVideo(variant video)
    signal goToVideo(variant video)
    signal search(string query, string order)
    signal dialogClose

    function setVideo(videoObject) {

        video = videoObject;
        videoId = video.videoId;
        playerUrl = video.playerUrl;
        title = video.title;
        author = video.author;
        date = video.uploadDate.split("T")[0];
        thumbnail = video.largeThumbnail;
        duration = Scripts.getDuration(video.duration);
        if (video.description != "") {
            description = video.description;
        }
        if (video.views) {
            views = video.views;
        }
        if (video.likes) {
            likes = video.likes;
        }
        if (video.dislikes) {
            dislikes = video.dislikes;
        }
        if (video.comments) {
            comments = video.comments;
        }
        if (video.tags) {
            tags = video.tags.split(", ");
        }
    }

    function onMenuButtonOneClicked() {
        if (userIsSignedIn()) {
            toggleBusy(true);
            YouTube.addToFavourites(videoId);
        }
        else {
            messages.displayMessage(messages._NOT_SIGNED_IN);
        }
    }

    function onMenuButtonTwoClicked() {
        if (userIsSignedIn()) {
            Scripts.showPlaylistDialog();
        }
        else {
            messages.displayMessage(messages._NOT_SIGNED_IN);
        }
    }

    function onMenuButtonThreeClicked() {
        Scripts.checkFacebookAccess();
    }

    function onMenuButtonFourClicked() {
        Controller.copyToClipboard(playerUrl);
    }

    Connections {
        target: YouTube

        onCommentAdded: {
            messages.displayMessage(messages._COMMENT_ADDED);
            var v = video;
            v["commentAdded"] = true;
            video = v;
            Scripts.loadComments();
            comments = parseInt(comments + 1).toString()
        }
        onVideoRated: {
            var v = video;
            v["rating"] = likeOrDislike;
            video = v;
            messages.displayMessage(messages._VIDEO_RATED);
        }
        onCannotRate: messages.displayMessage(messages._CANNOT_RATE)
    }

    Connections {
        target: Sharing

        onAlert: messages.displayMessage(message)
        onPostedToFacebook: messages.displayMessage(messages._SHARED_VIA_FACEBOOK)
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

                Rectangle {
                    id: durationLabel

                    width: Math.floor(thumb.width / 2.5)
                    height: Math.floor(durationLabel.width / 2.5)
                    anchors { bottom: thumb.bottom; right: thumb.right }
                    color: "black"
                    opacity: 0.5
                    smooth: true
                }

                Text {
                    id: durationText

                    anchors.fill: durationLabel
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
                onClicked: playVideo([video])
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

            anchors { fill: dimmer; leftMargin: frame.width + 20; rightMargin: 10; topMargin: 60; bottomMargin: 65 }

            Row {
                id: tabRow

                Item {
                    id: infoTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: infoTab
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 0
                    }

                    Text {
                        anchors.fill: infoTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 0 ? _TEXT_COLOR : "grey"
                        text: qsTr("Info")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: infoTab.bottom; left: infoTab.left; right: infoTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 0)
                    }

                    MouseArea {
                        id: infoMouseArea

                        anchors.fill: infoTab
                        onClicked: tabView.currentIndex = 0
                    }
                }

                Item {
                    id: commentsTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 1
                    }

                    Text {
                        anchors.fill: commentsTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 1 ? _TEXT_COLOR : "grey"
                        text: qsTr("Comments")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: commentsTab.bottom; left: commentsTab.left; right: commentsTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 1)
                    }

                    MouseArea {
                        id: commentsMouseArea

                        anchors.fill: commentsTab
                        onClicked: tabView.currentIndex = 1
                    }
                }

                Item {
                    id: relatedTab

                    width: tabItem.width / 3
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 2
                    }

                    Text {
                        anchors.fill: relatedTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 2 ? _TEXT_COLOR : "grey"
                        text: qsTr("Related")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: relatedTab.bottom; left: relatedTab.left; right: relatedTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 2)
                    }

                    MouseArea {
                        id: relatedMouseArea

                        anchors.fill: relatedTab
                        onClicked: tabView.currentIndex = 2
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
                    if ((tabView.currentIndex == 1) && (comments != "0") && (!commentsList.loaded)) {
                        Scripts.loadComments();
                    }
                    else if ((tabView.currentIndex == 2) && (!relatedView.loaded) && (relatedView.count == 0)) {
                        Scripts.loadRelatedVideos();
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
                                                        + "</font>" + qsTr(" on ") + date
                                                      : qsTr("By ") + "<font color='"
                                                        + _ACTIVE_COLOR_LOW + "'>" + author
                                                        + "</font>" + qsTr(" on ") + date

                        MouseArea {
                            id: authorMouseArea

                            anchors.fill: authorText
                            onClicked: authorClicked(author)
                        }
                    }

                    Row {
                        x: 2
                        spacing: 10

                        ToolButton {
                            id: likeButton

                            icon: (video) && (video.rating == "like") ? (cuteTubeTheme == "nightred") ? "ui-images/likeiconred.png" : "ui-images/likeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/likeiconlight.png" : "ui-images/likeicon.png"
                            onButtonClicked: Scripts.rateVideo("like")
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: likes
                        }

                        ToolButton {
                            id: dislikeButton

                            icon: (video) && (video.rating == "dislike") ? (cuteTubeTheme == "nightred") ? "ui-images/dislikeiconred.png" : "ui-images/dislikeiconblue.png" : (cuteTubeTheme == "light") ? "ui-images/dislikeiconlight.png" : "ui-images/dislikeicon.png"
                            onButtonClicked: Scripts.rateVideo("dislike")
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: dislikes
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Views")
                        }

                        Text {
                            y: 20
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
                                    onClicked: search(parent.text, Settings.getSetting("searchOrder").toLowerCase())
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

            Item {
                id: commentsItem

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0

                Column {
                    y: 10
                    spacing: 10

                    Row {
                        x: 2
                        spacing: 10

                        TextEntryButton {
                            id: commentButton

                            focus: commentButton.state == "show"
                            textEntryWidth: commentsList.width - 5
                            textEntryHeight: commentsList.height
                            icon: (video) && (video.commentAdded) ? (cuteTubeTheme == "nightred")
                                                                    ? "ui-images/commenticonred.png" : "ui-images/commenticonblue.png" : (cuteTubeTheme == "light")
                                                                                                     ? "ui-images/commenticonlight.png" : "ui-images/commenticon.png"
                            onSubmitText: {
                                if (userIsSignedIn()) {
                                    toggleBusy(true);
                                    YouTube.addComment(videoId, text);
                                }
                                else {
                                    messages.displayMessage(messages._NOT_SIGNED_IN);
                                }
                            }
                        }

                        Text {
                            y: 20
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: comments == "0" ? qsTr("No comments") : comments + qsTr(" comments")
                            visible: commentButton.state == ""
                        }
                    }

                    ListView {
                        id: commentsList

                        property bool loaded : false // True if comments have been loaded
                        property string commentsFeed : "http://gdata.youtube.com/feeds/api/videos/" + videoId + "/comments?v=2&max-results=50"

                        width: commentsItem.width
                        height: commentsItem.height - 60
                        clip: true
                        interactive: visibleArea.heightRatio < 1
                        highlightRangeMode: ListView.StrictlyEnforceRange

                        footer: Item {
                            id: footer

                            width: commentsList.width
                            height: 100
                            visible: ((commentsModel.loading) || (commentsModel.status == XmlListModel.Loading))
                            opacity: footer.visible ? 1 : 0

                            BusyDialog {
                                anchors.centerIn: footer
                                opacity: footer.opacity
                            }
                        }

                        model: CommentsModel {
                            id: commentsModel

                            property bool loading : false
                        }

                        onCurrentIndexChanged: {
                            if ((commentsList.count - commentsList.currentIndex == 1)
                                    && (commentsModel.count < commentsModel.totalResults)
                                    && (commentsModel.status == XmlListModel.Ready)) {
                                Scripts.appendComments();
                            }
                        }

                        delegate: CommentsDelegate {
                            id: commentDelegate

                            onCommentClicked: authorClicked(author);
                        }
                    }
                }
            }

            ListView {
                id: relatedView

                property bool loaded : false // True if related videos have been loaded
                property string videoFeed : "http://gdata.youtube.com/feeds/api/videos/" + videoId + "/related?v=2&max-results=50"

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
                opacity: (tabView.currentIndex == 2) ? 1 : 0
                onCurrentIndexChanged: {
                    if ((relatedView.count - relatedView.currentIndex == 1)
                            && (relatedModel.count < relatedModel.totalResults)
                            && (relatedModel.status == XmlListModel.Ready)) {
                        Scripts.appendRelatedVideos();
                    }
                }

                footer: Item {
                    id: footer

                    width: relatedView.width
                    height: 100
                    visible: ((relatedModel.loading) || (relatedModel.status == XmlListModel.Loading))
                    opacity: footer.visible ? 1 : 0

                    BusyDialog {
                        anchors.centerIn: footer
                        opacity: footer.opacity
                    }
                }

                model: VideoListModel {
                    id: relatedModel

                    property bool loading : true
                }

                delegate: VideoListDelegate {
                    id: delegate

                    onDelegateClicked: goToVideo(relatedModel.get(index))
                    onPlayClicked: playVideo([relatedModel.get(index)])
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

