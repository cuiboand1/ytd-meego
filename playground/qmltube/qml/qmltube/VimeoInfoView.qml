import QtQuick 1.0
import "scripts/videoinfoscripts.js" as Scripts
import "scripts/settings.js" as Settings
import "scripts/createobject.js" as ObjectCreator
import "scripts/dateandtime.js" as DT
import "scripts/vimeo.js" as VM

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

    signal authorClicked(variant author)
    signal playVideo(variant video)
    signal goToVideo(variant video)
    signal searchVimeo(string query, string order, string site)
    signal dialogClose

    function setVideo(videoObject) {

        video = videoObject;
        videoId = video.id;
        playerUrl = video.playerUrl;
        title = video.title;
        author = video.author;
        date = video.uploadDate.split(" ")[0];
        thumbnail = video.largeThumbnail;
        duration = DT.getYTDuration(video.duration);
        if (video.description != "") {
            description = video.description;
        }
        if (video.views) {
            views = video.views;
        }
        if (video.likes) {
            likes = video.likes;
        }
        if (video.comments) {
            comments = video.comments;
        }
        if (video.tags) {
            tags = video.tags.split(", ");
        }
    }

    function onMenuButtonOneClicked() {
        VM.setLike(true, videoId);
    }

    function onMenuButtonTwoClicked() {
        showPlaylistDialog();
    }

    function onMenuButtonThreeClicked() {
        Scripts.checkFacebookAccess();
    }

    function onMenuButtonFourClicked() {
        Controller.copyToClipboard(playerUrl);
    }

    function showPlaylistDialog() {
        if (!(Vimeo.currentUser == "")) {
            if (dimmer.state == "") {
                toggleControls(false);
                var playlistDialog = ObjectCreator.createObject("AddToPlaylistDialog.qml", window);
                playlistDialog.site = "vimeo";
                playlistDialog.playlistClicked.connect(addVideoToPlaylist);
                playlistDialog.close.connect(Scripts.closeDialogs);
                dimmer.state = "dim";
                playlistDialog.state = "show";
            }
        }
        else {
            messages.displayMessage(messages._NOT_SIGNED_IN);
        }
    }

    function addVideoToPlaylist(playlistId) {
        Scripts.closeDialogs();
        VM.addToPlaylist(videoId, playlistId);
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

    Connections {
        target: Vimeo

        onCommentAdded: {
            messages.displayMessage(messages._COMMENT_ADDED);
            var v = video;
            v["commentAdded"] = true;
            video = v;
            VM.getComments();
            comments = parseInt(comments + 1).toString()
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
                onClicked: playVideo([VM.createVideoObject(video)])
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

            property variant tabs : [ qsTr("Info"), qsTr("Comments") ]

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
                    if ((tabView.currentIndex == 1) && (comments != "0") && (!commentsList.loaded)) {
                        VM.getComments();
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
                            onClicked: authorClicked({ "title": author, "id": video.authorId })
                        }
                    }

                    Row {
                        x: 2
                        spacing: 10

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: _TEXT_COLOR
                            text: qsTr("Likes")
                        }

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: likes
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
                                    onClicked: searchVimeo(parent.text, Settings.getSetting("searchOrder").toLowerCase(), "vimeo")
                                }

                                Text {
                                    anchors.left: parent.right
                                    font.pixelSize: _SMALL_FONT_SIZE
                                    color: "grey"
                                    text: ","
                                    visible: index < (tags.length - 2)
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
                                if (!(Vimeo.currentUser == "")) {
                                    toggleBusy(true);
                                    VM.addComment(text, videoId);
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

                        width: commentsItem.width
                        height: commentsItem.height - 60
                        clip: true
                        interactive: visibleArea.heightRatio < 1
                        highlightRangeMode: ListView.StrictlyEnforceRange

                        footer: Item {
                            id: footer

                            width: commentsList.width
                            height: 100
                            visible: vimeoCommentsModel.loading
                            opacity: footer.visible ? 1 : 0

                            BusyDialog {
                                anchors.centerIn: footer
                                opacity: footer.opacity
                            }
                        }

                        model: ListModel {
                            id: vimeoCommentsModel

                            property bool loading : false
                            property bool moreResults : false
                            property int page : 1
                        }

                        onCurrentIndexChanged: {
                            if ((commentsList.count - commentsList.currentIndex == 1)
                                    && (vimeoCommentsModel.moreResults)
                                    && (!vimeoCommentsModel.loading)) {
                                VM.getComments();
                            }
                        }

                        delegate: CommentsDelegate {
                            id: commentDelegate

                            onCommentClicked: authorClicked({ "title": author, "id": vimeoCommentsModel.get(index).authorId });
                        }
                    }
                }
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

