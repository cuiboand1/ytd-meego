import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator
import "scripts/youtube.js" as YT

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : true
    property bool showMenuButtonThree : true
    property bool showMenuButtonFour : !Controller.isSymbian
    property bool showMenuButtonFive : true

    property string videoFeed
    property string username
    property bool isSubscribed
    property string subscriptionId
    property string subscriberCount
    property string videoCount
    property string userThumbnail
    property string about
    property string age
    property string firstName
    property string lastName
    property string gender
    property alias checkList: videoList.checkList
    property bool itemsSelected : videoList.checkList.length > 0

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function getUserProfile(user) {
        username = user;
        videoFeed = "http://gdata.youtube.com/feeds/api/users/" + username  + "/uploads?v=2&max-results=50&alt=json";

        YT.getYouTubeVideos();

        var i = 0;
        while ((!isSubscribed) && (i < subscriptionsModel.count)) {
            if (subscriptionsModel.get(i).title == username) {
                subscriptionId = subscriptionsModel.get(i).subscriptionId.split(":")[5];
                isSubscribed = true;
            }
            i++;
        }
        YT.getUserProfile(user);
    }

    function showUserInfoDialog() {
        /* Show the user profile dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var userDialog = ObjectCreator.createObject("UserInfoDialog.qml", window);
            userDialog.getUserProfile(username);
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

        YT.addVideosToFavourites();
    }

    function onMenuButtonThreeClicked() {
        if (videoList.checkList.length > 0) {
            YT.showPlaylistDialog();
        }
    }

    function onMenuButtonFourClicked() {
        YT.addVideosToPlaybackQueue();
    }

    function onMenuButtonFiveClicked() {
        Scripts.addVideosToDownloads(false);
    }

    Connections {
        target: YouTube

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
            visible: (!videoListModel.loading) && (videoListModel.count == 0)
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

                Grid {
                    id: textColumn

                    anchors { left: frame.right; leftMargin: 8; top: frame.top }
                    width: 200
                    columns: 2
                    spacing: 5

                    Text {
                        text: qsTr("Subscribers")
                        color: _TEXT_COLOR
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: subscriberCount
                        color: "grey"
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: qsTr("Videos")
                        color: _TEXT_COLOR
                        elide: Text.ElideRight
                        font.pixelSize: _SMALL_FONT_SIZE
                    }

                    Text {
                        text: videoCount
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
                visible: username != YouTube.currentUser
                onButtonClicked: YT.setSubscription()
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
                    YT.getYouTubeVideos();
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

                property bool loading : false
                property int totalResults
                property int page : 0
            }

            delegate: VideoListDelegate {
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
                    if (videoList.checkList.length == 0) {
                        goToVideo(videoListModel.get(index));
                    }
                }
                onDelegatePressed: addOrRemoveFromCheckList()
                onPlayClicked: {
                    if (videoList.checkList.length == 0) {
                        var video = YT.createVideoObject(videoListModel.get(index));
                        playVideos([video]);
                    }
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
