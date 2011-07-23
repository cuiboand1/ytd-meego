import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {

    signal userVideos(variant user)
    signal showUserInfo(int index)
    signal dialogClose

    Connections {
        target: Vimeo
        onUnsubscribed: {
            messages.displayMessage(qsTr("You have unsubscribed to this channel"));
        }
    }

    ListView {
        id: subscriptionsList

        anchors.fill: parent
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: visibleArea.heightRatio < 1
        model: vimeoSubscriptionsModel

        ScrollBar {}

        MouseArea {
            id: mouseArea
            anchors.fill: subscriptionsList
            enabled: false
            onClicked: closeDialogs()
        }

        delegate: SubscriptionDelegate {
            id: delegate

            onDelegateClicked: {
                var user = vimeoSubscriptionsModel.get(index);
                userVideos(user);
            }
            onDelegatePressed: showUserInfo(index)
        }

        Text {
            anchors.centerIn: subscriptionsList
            font.pixelSize: _LARGE_FONT_SIZE
            font.bold: true
            color: "grey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("No subscriptions found")
            visible: (!vimeoSubscriptionsModel.loading) && (vimeoSubscriptionsModel.count === 0)
        }
    }
}
