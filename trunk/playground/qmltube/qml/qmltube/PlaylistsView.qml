import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property bool showMenuButtonOne : tabView.currentIndex == 0
    property bool showMenuButtonTwo : false
    property bool showMenuButtonThree : false
    property bool showMenuButtonFour : false
    property bool showMenuButtonFive : false

    signal goToYTPlaylist(variant playlistData)
    signal goToDMPlaylist(variant playlistData)
    signal goToVimeoPlaylist(variant playlistData)
    signal playVideos(variant videos)
    signal dialogClose

    function showPlaylistDialog(playlist) {
        toggleControls(false);
        if (tabView.currentIndex == 0) {
            var playlistDialog = ObjectCreator.createObject("PlaylistDialog.qml", window);
            playlistDialog.playlistVideosClicked.connect(goToYTPlaylist);
        }
        else if (tabView.currentIndex == 1) {
            var playlistDialog = ObjectCreator.createObject("DMPlaylistDialog.qml", window);
            playlistDialog.playlistVideosClicked.connect(goToDMPlaylist);
        }
        else if (tabView.currentIndex == 2) {
            var playlistDialog = ObjectCreator.createObject("VimeoPlaylistDialog.qml", window);
            playlistDialog.playlistVideosClicked.connect(goToVimeoPlaylist);
        }
        playlistDialog.playClicked.connect(playPlaylist);
        playlistDialog.close.connect(closeDialogs);
        playlistDialog.setPlaylist(playlist);
        dimmer.state = "dim";
        playlistDialog.state = "show";
    }

    function playPlaylist(videos) {
        dialogClose();
        dimmer.state = "";
        playVideos(videos);
    }

    function onMenuButtonOneClicked() {
        /* Show the new playlist dialog */

        toggleControls(false);
        var playlistDialog = ObjectCreator.createObject("NewPlaylistDialog.qml", window);
        if (tabView.currentIndex == 2) {
            playlistDialog.site = "vimeo";
        }
        playlistDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        playlistDialog.state = "show";
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        dimmer.state = "";
        toggleControls(true);
    }

    Item {
        id: dimmer

        anchors.fill: window

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        Item {
            id: tabItem

            property variant sites : [ "YouTube", "Dailymotion", "vimeo" ]

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

            YTPlaylists {
                id: youtubeList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 0) ? 1 : 0
                onShowPlaylistInfo: showPlaylistDialog(playlist)
                onGoToPlaylist: goToYTPlaylist(playlistData)
            }

            DMPlaylists {
                id: dailymotionList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                onShowPlaylistInfo: showPlaylistDialog(playlist)
                onGoToPlaylist: goToDMPlaylist(playlistData)
            }

            VimeoPlaylists {
                id: vimeoList

                width: tabView.width
                height: tabView.height
                opacity: (tabView.currentIndex == 2) ? 2 : 0
                onShowPlaylistInfo: showPlaylistDialog(playlist)
                onGoToPlaylist: goToVimeoPlaylist(playlistData)
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
