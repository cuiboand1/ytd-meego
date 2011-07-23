import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator
import "scripts/vimeo.js" as VM

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : true
    property bool showMenuButtonFour : !Controller.isSymbian
    property bool showMenuButtonFive : true

    property variant videoFeed
    property variant user
    property string username
    property bool isSubscribed
    property string videoCount
    property string userThumbnail
    property alias checkList: videoList.checkList
    property bool itemsSelected : videoList.checkList.length > 0

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setUserProfile(userObject) {
        if (userObject.videoCount) {
            user = userObject;
            username = user.title;
            videoCount = user.videoCount;
            userThumbnail = user.thumbnail;
        }
        else {
            username = userObject.title;
            VM.getUserInfo(userObject.id);
        }

        videoFeed = [["method", "vimeo.videos.getUploaded"], ["sort", "newest"], ["user_id", userObject.id]]
        VM.getVimeoVideos();

        var i = 0;
        while ((!isSubscribed) && (i < vimeoSubscriptionsModel.count)) {
            if (vimeoSubscriptionsModel.get(i).title == username) {
                isSubscribed = true;
            }
            i++;
        }
    }

    function showUserInfoDialog() {
        /* Show the user profile dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var userDialog = ObjectCreator.createObject("VimeoUserInfoDialog.qml", window);
            userDialog.setUserProfile(user);
            userDialog.close.connect(Scripts.closeDialogs);
            dimmer.state = "dim";
            userDialog.state = "show";
        }
    }

    function onMenuButtonOneClicked() {
        /* Toggle select all/none */

        var cl = videoList.checkList;
        if (cl.length == 0) {
            for (var i = 0; i < videoList.count; i++) {
                cl.push(i);
            }
            videoList.checkList = cl;
        }
        else {
            videoList.checkList = [];
        }
    }

    function onMenuButtonTwoClicked() {
        /* Add videos to favourites */

        VM.setLikes(true);
    }

    function onMenuButtonThreeClicked() {
        if (videoList.checkList.length > 0) {
            Scripts.showPlaylistDialog();
        }
    }

    function onMenuButtonFourClicked() {
        VM.addVideosToPlaybackQueue();
    }

    function onMenuButtonFiveClicked() {
        Scripts.addVideosToDownloads(false);
    }

    Connections {
        target: Vimeo
        onSubscribed: {
            isSubscribed = true;
            messages.displayMessage(qsTr("You have subscribed to '") + username + "'");
        }
        onUnsubscribed: {
            isSubscribed = false;
            messages.displayMessage(qsTr("You have unsubscribed to '") + username + "'");
        }
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Text {
            id: noResultsText

            anchors.centerIn: dimmer
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No videos found")
            visible: false

            Timer {
                interval: 5000
                running: (!videoListModel.loading) && (videoListModel.count == 0)
                onTriggered: {
                    if (videoListModel.count == 0) {
                        noResultsText.visible = true;
                    }
                }
            }
        }

        Item {
            id: profileBox

            z: 10
            width: dimmer.width
            height: 60
            anchors { top: dimmer.top; topMargin: 50 }

            Rectangle {
                id: frame

                width: 72
                height: 54
                anchors { left: profileBox.left; leftMargin: 3; verticalCenter: profileBox.verticalCenter }
                color: _BACKGROUND_COLOR
                border.width: 1
                border.color: userInfoMouseArea.pressed ? _ACTIVE_COLOR_LOW : (cuteTubeTheme == "light") ? "grey" : "white"

                Image {
                    id: thumb

                    anchors { fill: frame; margins: 1 }
                    source: userThumbnail
                    sourceSize.width: thumb.width
                    sourceSize.height: thumb.height
                    smooth: true
                }

                MouseArea {
                    id: userInfoMouseArea

                    anchors.fill: frame
                    onClicked: showUserInfoDialog()
                }

                Row {
                    id: textColumn

                    anchors { left: frame.right; leftMargin: 8; top: frame.top }
                    width: 200
                    spacing: 5

                    Text {
                        text: qsTr("Videos")
                        color: _TEXT_COLOR
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: videoListModel.totalResults
                        color: "grey"
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }
                }
            }

            PushButton {
                id: subscribeButton

                width: (subscribeButton.textWidth > 120) ? subscribeButton.textWidth + 12 : 120
                height: 54
                anchors { right: profileBox.right; rightMargin: 3; verticalCenter: profileBox.verticalCenter }
                showText: true
                showIcon: false
                name: isSubscribed ? qsTr("Unsubscribe") : qsTr("Subscribe")
                nameSize: 18
                visible: username != Vimeo.currentUser
                onButtonClicked: VM.setSubscription(user.id)
            }

            Rectangle {
                height: 1
                anchors { bottom: profileBox.bottom; left: profileBox.left; leftMargin: 10; right: profileBox.right; rightMargin: 10 }
                color: _ACTIVE_COLOR_HIGH
                opacity: 0.5
            }
        }

        ListView {
            id: videoList

            property variant checkList : []

            anchors { fill: dimmer; topMargin: 110 }
            boundsBehavior: Flickable.DragOverBounds
            highlightMoveDuration: 500
            preferredHighlightBegin: 0
            preferredHighlightEnd: 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            cacheBuffer: 2500
            interactive: visibleArea.heightRatio < 1
            clip: true
            onCurrentIndexChanged: {
                if ((videoList.count - videoList.currentIndex == 1)
                        && (videoListModel.count < videoListModel.totalResults)
                        && (!videoListModel.loading)) {
                    VM.getVimeoVideos();
                }
            }

            footer: Item {
                id: footer

                width: videoList.width
                height: 100
                visible: videoListModel.loading
                opacity: footer.visible ? 1 : 0

                BusyDialog {
                    anchors.centerIn: footer
                    opacity: footer.opacity
                }
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

            model: ListModel {
                id: videoListModel

                property bool loading : true
                property int totalResults
                property int page : 1
            }

            delegate: VimeoListDelegate {
                id: delegate

                function addOrRemoveFromCheckList() {
                    var cl = videoList.checkList;
                    if (!delegate.checked) {
                        cl.push(index);
                    }
                    else {
                        for (var i = 0; i < cl.length; i++) {
                            if (cl[i] == index) {
                                cl.splice(i, 1);
                            }
                        }
                    }
                    videoList.checkList = cl;
                }

                checked: Scripts.indexInCheckList(index)
                onDelegateClicked: {
                    videoList.checkList = [];
                    goToVideo(videoListModel.get(index));
                }
                onDelegatePressed: addOrRemoveFromCheckList()
                onPlayClicked: {
                    var video = VM.createVideoObject(videoListModel.get(index));
                    playVideos([video]);
                }
            }

            ScrollBar {}
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1}
        }

    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
