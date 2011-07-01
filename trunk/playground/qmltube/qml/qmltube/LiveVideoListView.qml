import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts
import "scripts/youtube.js" as YT

Item {
    id: window

    property bool showMenuButtonOne : false
    property bool showMenuButtonTwo : false
    property bool showMenuButtonThree : false
    property bool showMenuButtonFour : false
    property bool showMenuButtonFive : false

    signal playVideos(variant videos)

    Component.onCompleted: YT.getCurrentLiveStreams()

    GridView {
        id: videoList

        property variant checkList : []

        anchors { fill: window; topMargin: 60; leftMargin: (window.height > window.width) ? 25 : 48; bottomMargin: 70 }
        boundsBehavior: Flickable.DragOverBounds
        cacheBuffer: 2500
        cellWidth: (window.height > window.width) ? Math.floor(videoList.width / 2) : Math.floor(videoList.width / 3)
        cellHeight: videoList.cellWidth
        interactive: visibleArea.heightRatio < 1

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        model: ListModel {
            id: videoListModel

            property bool loading : false
        }

        delegate: LiveVideoListDelegate {
            id: delegate

            onPlayClicked: playVideos([videoListModel.get(index)])

        }

        ScrollBar {}
    }

    BusyDialog {
        anchors.centerIn: window
        visible: videoListModel.loading
    }

    Text {
        id: noResultsText

        anchors.centerIn: window
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No live streams found")
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
}
