import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {

    signal userVideos(string username)
    signal dialogClose

    ListView {
        id: subscriptionsList

        anchors.fill: parent
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: visibleArea.heightRatio < 1
        model: dailymotionSubscriptionsModel

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
                var username = dailymotionSubscriptionsModel.get(index).title;
                userVideos(username);
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
            visible: (!dailymotionSubscriptionsModel.loading) && (dailymotionSubscriptionsModel.count === 0)
        }
    }
}
