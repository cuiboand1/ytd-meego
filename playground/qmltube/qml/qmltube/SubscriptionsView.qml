import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property bool showMenuButtonOne : true
    property bool showMenuButtonTwo : false
    property bool showMenuButtonThree : false
    property bool showMenuButtonFour : false
    property bool showMenuButtonFive : false

    signal goToUserVideos(string username)
    signal goToDMUserVideos(string username)
    signal goToVimeoUserVideos(variant user)
    signal goToNewSubVideos(variant feeds, string title, string site)
    signal dialogClose

    function showUserInfoDialog(index) {
        /* Show the user profile dialog */

        toggleControls(false);
        var userDialog = ObjectCreator.createObject("UserInfoDialog.qml", window);
        userDialog.getUserProfile(subscriptionsModel.get(index).title);
        userDialog.userVideosClicked.connect(goToUserVideos);
        userDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        userDialog.state = "show";
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        dimmer.state = "";
        toggleControls(true);
    }

    function onMenuButtonOneClicked() {
        var feeds = { "youtube": YouTube.currentUser == "" ? "none" : _NEW_SUB_VIDEOS_FEED,
                      "dailymotion": DailyMotion.currentUser == "" ? "none" : _DM_NEW_SUB_VIDEOS_FEED,
                      "vimeo": Vimeo.currentUser == "" ? "none" : _VM_NEW_SUB_VIDEOS_FEED };
        var title = qsTr("Latest Subscriptions Videos");
        var site;
        if (tabView.currentIndex == 0) {
            site = "YouTube";
        }
        else if (tabView.currentIndex == 1) {
            site = "Dailymotion";
        }
        else if (tabView.currentIndex == 2) {
            site = "vimeo";
        }
        goToNewSubVideos(feeds, title, site);
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Item {
            id: tabItem

            property variant sites : ["YouTube", "Dailymotion", "vimeo" ]

            anchors { fill: dimmer; topMargin: 60 }

            Row {
                id: tabRow

                Repeater {
                    model: tabItem.sites

                    Item {
                        width: tabItem.width / tabItem.sites.length
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
            }
        }

        VisualItemModel {
            id: tabModel

            YTSubscriptionsList {
                id: youtubeList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 0) ? 1 : 0
                onUserVideos: goToUserVideos(username)
                onShowUserInfo: showUserInfoDialog(index)
            }

            DMSubscriptionsList {
                id: dailymotionList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                onUserVideos: goToDMUserVideos(username)
            }

            VimeoSubscriptionsList {
                id: vimeoList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 2) ? 1 : 0
                onUserVideos: goToVimeoUserVideos(user)
            }
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1 }
        }

    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
