import QtQuick 1.0
import "scripts/videolistscripts.js" as Scripts

Item {
    id: window

    property string searchQuery
    property string searchOrder
    property bool canLoadYouPorn : false

    signal loadVideoInfo(string site, variant video)
    signal playXtubeVideo(variant video)

    function setSearchQuery(site, query, order) {
        searchQuery = query
        searchOrder = order;
        if (site == "youporn") {
            youpornSearch();
        }
        else if (site == "pornhub") {
            tabView.currentIndex = 1;
        }
        else if (site == "tube8") {
            tabView.currentIndex = 2;
        }
    }

    function youpornSearch() {
        /* Perform a search of YouPorn */

        var order = "";
        if (searchOrder = "date") {
            order = "time";
        }

        var query = searchQuery.replace(/\s/g, "+");
        var videoFeed = ("http://youporn.com/search/" + order + "?query=" + query + "&page=1");
        youpornList.setVideoFeed(videoFeed);
    }

    function pornhubSearch() {
        /* Perform a search of PornHub */

        var order = "mr";
        if (searchOrder = "views") {
            order = "mv";
        }
        else if (searchOrder = "rating") {
            order = "tr";
        }

        var query = searchQuery.replace(/\s/g, "+");
        var videoFeed = ("http://pornhub.com/video/search?search=" + query + "&o=" + order + "&page=1");
        pornhubList.setVideoFeed(videoFeed);
    }

    function tubeEightSearch() {
        /* Perform a search of tube8 */

        var order = "";
        if (searchOrder = "date") {
            order = "nt";
        }
        else if (searchOrder = "views") {
            order = "mv";
        }
        else if (searchOrder = "rating") {
            order = "tr";
        }

        var query = searchQuery.replace(/\s/g, "+");
        var videoFeed = ("http://tube8.com/search.html?q=" + query + "&orderby=" + order + "&page=1");
        tubeEightList.setVideoFeed(videoFeed);
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Item {
            id: tabItem

            property variant sites : [ qsTr("YouPorn"), qsTr("PornHub"), qsTr("tube8") ]
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

                onCurrentIndexChanged: {
                    if ((tabView.currentIndex == 0) && (canLoadYouPorn) && (!youpornList.loaded)) {
                        youpornSearch();
                    }
                    else if ((tabView.currentIndex == 1) && (!pornhubList.loaded)) {
                        canLoadYouPorn = true;
                        pornhubSearch();
                    }
                    else if ((tabView.currentIndex == 2) && (!tubeEightList.loaded)) {
                        canLoadYouPorn = true;
                        tubeEightSearch();
                    }
                }
            }

            Item {
                width: tabView.width
                height: 100
                anchors { top: tabView.top; topMargin: (tabView.currentItem.count == 0) ? 0 : 100 }
                visible: tabView.currentItem.loading

                BusyDialog {
                    anchors.centerIn: parent
                }
            }
        }

        VisualItemModel {
            id: tabModel

            XtubeVideoList {
                id: youpornList

                site: "youporn"
                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 0) ? 1 : 0
                onGoToVideo: loadVideoInfo("youporn", video)
                onPlayVideo: playXtubeVideo(video)
            }

            XtubeVideoList {
                id: pornhubList

                site: "pornhub"
                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                onGoToVideo: loadVideoInfo("pornhub", video)
                onPlayVideo: playXtubeVideo(video)
            }

            XtubeVideoList {
                id: tubeEightList

                site: "tube8"
                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 2) ? 1 : 0
                onGoToVideo: loadVideoInfo("tube8", video)
                onPlayVideo: playXtubeVideo(video)
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
