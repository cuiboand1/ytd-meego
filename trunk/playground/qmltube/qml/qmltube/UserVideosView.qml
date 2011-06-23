import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property string videoFeed
    property string username
    property bool isSubscribed
    property string subscriptionId
    property string subscriberCount
    property string videoCount
    property string userThumbnail
    property alias checkList: videoList.checkList

    signal goToVideo(variant video)
    signal playVideos(variant videos)
    signal dialogClose

    function setVideoFeed() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var xml = doc.responseText;
                videoListModel.setXml(xml);

                videoListModel.loading = false;
            }
        }
        doc.open("GET", videoFeed);
        doc.send();
    }

    function getUserProfile(user) {
        username = user;
        videoFeed = "http://gdata.YouTube.com/feeds/api/users/" + username  + "/uploads?v=2&max-results=50";

        setVideoFeed();

        var i = 0;
        while ((!isSubscribed) && (i < subscriptionsModel.count)) {
            if (subscriptionsModel.get(i).title == username) {
                subscriptionId = subscriptionsModel.get(i).subscriptionId.split(":")[5];
                isSubscribed = true;
            }
            i++;
        }

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var xml = doc.responseXML.documentElement;
                for (i = 0; i < xml.childNodes.length; i++) {
                    if (xml.childNodes[i].nodeName == "thumbnail") {
                        userThumbnail = xml.childNodes[i].attributes[0].value;
                    }
                    else if (xml.childNodes[i].nodeName == "statistics") {
                        subscriberCount = xml.childNodes[i].attributes[1].value;
                    }
                    else if (xml.childNodes[i].nodeName == "feedLink") {
                        if (xml.childNodes[i].attributes[0].value == "http://gdata.youtube.com/schemas/2007#user.uploads") {
                            videoCount = xml.childNodes[i].attributes[2].value;
                        }
                    }
                }
            }
        }
        doc.open("GET", "http://gdata.youtube.com/feeds/api/users/" + username + "?v=2");
        doc.send();
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
            mouseArea.enabled = true;
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

        Scripts.addVideosToFavourites();
    }

    function onMenuButtonThreeClicked() {
        if (videoList.checkList.length > 0) {
            Scripts.showPlaylistDialog();
        }
    }

    function onMenuButtonFourClicked() {
        if (Controller.isSymbian) {
            Scripts.addVideosToDownloads(false);
        }
        else {
            Scripts.addVideosToPlaybackQueue();
        }
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
                onButtonClicked: Scripts.setSubscription()
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
                        && (videoList.count < videoListModel.totalResults)
                        && (videoListModel.status == XmlListModel.Ready)) {
                    Scripts.appendVideoFeed();
                }
            }

            footer: Item {
                id: footer

                width: videoList.width
                height: 100
                visible: ((videoListModel.loading) || (videoListModel.status == XmlListModel.Loading))
                opacity: footer.visible ? 1 : 0

                BusyDialog {
                    anchors.centerIn: footer
                    opacity: footer.opacity
                }
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

            model: VideoListModel {
                id: videoListModel

                property bool loading : true
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
                    videoList.checkList = [];
                    goToVideo(videoListModel.get(index));
                }
                onDelegatePressed: addOrRemoveFromCheckList()
                onPlayClicked: playVideos([videoListModel.get(index)])
            }

            ScrollBar {}
        }

        MouseArea {
            id: mouseArea

            anchors { fill: dimmer; topMargin: 50 }
            enabled: false
            onClicked: Scripts.closeDialogs()
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
