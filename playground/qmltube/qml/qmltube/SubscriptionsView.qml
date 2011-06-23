import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    signal goToUserVideos(string username)
    signal goToNewSubVideos(string feed, string title)
    signal dialogClose

    function showUserInfoDialog(index) {
        /* Show the user profile dialog */

        if (subscriptionsList.state == "") {
            toggleControls(false);
            var userDialog = ObjectCreator.createObject("UserInfoDialog.qml", window);
            userDialog.getUserProfile(subscriptionsModel.get(index).title);
            userDialog.userVideosClicked.connect(goToUserVideos);
            userDialog.close.connect(closeDialogs);
            subscriptionsList.state = "dim";
            userDialog.state = "show";
        }
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        subscriptionsList.state = "";
        toggleControls(true);
    }

    function onMenuButtonOneClicked() {
        goToNewSubVideos(_NEW_SUB_VIDEOS_FEED, qsTr("Latest Subscriptions Videos"));
    }

    Connections {
        target: YouTube

        onUnsubscribed: {
            messages.displayMessage(qsTr("You have unsubscribed to this channel"));
        }
    }

    ListView {
        id: subscriptionsList

        anchors { fill: window; topMargin: 50 }
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: visibleArea.heightRatio < 1
        model: subscriptionsModel

        ScrollBar {}

        MouseArea {
            id: mouseArea
            anchors.fill: subscriptionsList
            enabled: false
            onClicked: closeDialogs()
        }

        delegate: SubscriptionDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    var username = subscriptionsModel.get(index).title;
                    goToUserVideos(username);
                }
                onDelegatePressed: showUserInfoDialog(index);
            }
        }

        Text {
            anchors.centerIn: subscriptionsList
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No subscriptions found")
            visible: (subscriptionsModel.status == XmlListModel.Ready) && (subscriptionsList.count == 0)
        }

        states: [
            State {
                name: "dim"
                PropertyChanges { target: subscriptionsList; opacity: 0.1 }
            }
        ]
        transitions: [
            Transition {
                PropertyAnimation { properties: "opacity"; duration: 500 }
            }
        ]
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
    }
}
