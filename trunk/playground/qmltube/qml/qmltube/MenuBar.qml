import QtQuick 1.0

Item {
    id: menu

    property string currentSource : (menu.parent.currentIndex == 0) ? "HomeView" : menu.parent.currentItem.source

    property variant buttonOneIcons
    property variant buttonTwoIcons
    property variant buttonThreeIcons
    property variant buttonFourIcons
    property variant buttonFiveIcons

    signal backClicked
    signal homeClicked
    signal quitClicked

    width: parent.width
    height: Controller.isSymbian ? 50 : 60
    anchors.bottom: parent.bottom
    z: 3

    Component.onCompleted: {
        buttonOneIcons = {
                "HomeView": "settingsicon", "MyAccountView": "uploadsicon", "VideoListView": "tick",
                "VimeoUserVideosView": "tick", "UserVideosView": "tick", "PlaylistVideosView": "tick", "DMPlaylistVideosView": "tick",
                "VimeoPlaylistVideosView": "tick", "PlaylistsView": "playlistsicon", "SubscriptionsView": "subscriptionsicon",
                "ArchiveListView": "tick", "VideoInfoView": "favouritesicon", "DMListView": "tick",
                "DMInfoView": "favouritesicon", "DMUserVideosView": "tick", "VimeoInfoView": "favouritesicon"
    };

        buttonTwoIcons = {
                "HomeView": "accountsicon", "MyAccountView": "inboxicon", "VideoListView": "favouritesicon",
                "VimeoUserVideosView": "favouritesicon", "UserVideosView": "favouritesicon", "PlaylistVideosView": "favouritesicon", "DMPlaylistVideosView": "favouritesicon",
                "VimeoPlaylistVideosView": "favouritesicon", "ArchiveListView": "playicon", "VideoInfoView": "playlistsicon", "VimeoInfoView": "playlistsicon",
                "DMListView": "playicon", "DMInfoView": "facebookicon", "DMUserVideosView": "favouritesicon"
    };

        buttonThreeIcons = {
                "HomeView": "abouticon", "VideoListView": "playlistsicon",
                "VimeoUserVideosView": "playlistsicon", "UserVideosView": "playlistsicon", "PlaylistVideosView": "deleteplaylistsicon", "DMPlaylistVideosView": "playicon",
                "VimeoPlaylistVideosView": "deleteplaylistsicon", "ArchiveListView": "deletearchiveicon", "VideoInfoView": "facebookicon", "VimeoInfoView": "facebookicon",
                "DMInfoView": "twittericon", "DMUserVideosView": "playicon"
    };

        buttonFourIcons = {
                "HomeView": "ytliveicon", "VideoListView": "playicon", "VimeoUserVideosView": "playicon", "UserVideosView": "playicon", "VimeoPlaylistVideosView": "playicon",
                "PlaylistVideosView": "playicon", "DMPlaylistVideosView": "videodownloadicon", "ArchiveListView": "mostrecenticon",
                "VideoInfoView": "twittericon", "VimeoInfoView": "twittericon", "DMUserVideosView": "videodownloadicon", "DMInfoView": "clipboardicon"
    };

        buttonFiveIcons = {
                "VideoListView": "videodownloadicon",
                "UserVideosView": "videodownloadicon",
                "VimeoUserVideosView": "videodownloadicon",
                "PlaylistVideosView": "videodownloadicon",
                "VimeoPlaylistVideosView": "videodownloadicon",
                "VimeoInfoView": "clipboardicon",
                "VideoInfoView": "clipboardicon",
                "ArchiveListView": "sorttitleicon"
    };

    }

    Image {
        id: menuImage

        anchors.fill: menu
        source: "ui-images/menu2.png"
        sourceSize.width: menuImage.width
        sourceSize.height: menuImage.height
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: !((cuteTubeTheme == "night") || (cuteTubeTheme == "nightred"))
    }

    Rectangle {
        id: background

        width: menu.width + 8
        height: menu.height + 8
        anchors.centerIn: menu
        radius: 10
        gradient: Gradient {
            GradientStop { id: gradient1; position: 0.0; color: _GRADIENT_COLOR_HIGH }
            GradientStop { id: gradient2; position: 0.7; color: _GRADIENT_COLOR_LOW }
        }
        border.width: 2
        border.color: _ACTIVE_COLOR_LOW
        opacity: 0.8
        smooth: true
        visible: ((cuteTubeTheme == "night") || (cuteTubeTheme == "nightred"))
    }

    Row {
        anchors.fill: menu

        MenuButton {
            id: buttonOne

            visible: (menu.parent.currentIndex == 0) || (menu.parent.currentItem.item.showMenuButtonOne)
            icon: {
                if (buttonOne.visible) {
                    if ((menu.parent.currentIndex > 0) && (menu.parent.currentItem.item.itemsSelected)) {
                        "ui-images/ticknone.png";
                    }
                    else {
                        "ui-images/" + menu.buttonOneIcons[menu.currentSource.split("/").pop().split(".")[0]] + ".png";
                    }
                }
                else {
                    "";
                }
            }
            onButtonClicked: (menu.parent.currentIndex == 0) ? menu.parent.currentItem.onMenuButtonOneClicked() : menu.parent.currentItem.item.onMenuButtonOneClicked()
        }

        MenuButton {
            id: buttonTwo

            visible: (menu.parent.currentIndex == 0) || (menu.parent.currentItem.item.showMenuButtonTwo)
            icon: {
                if (buttonTwo.visible) {
                    if ((menu.parent.currentIndex > 0) && (menu.parent.currentItem.item.showingFavourites)) {
                        "ui-images/deletefavouritesicon.png";
                    }
                    else {
                        "ui-images/" + menu.buttonTwoIcons[menu.currentSource.split("/").pop().split(".")[0]] + ".png";
                    }
                }
                else {
                    "";
                }
            }
            onButtonClicked: (menu.parent.currentIndex == 0) ? menu.parent.currentItem.onMenuButtonTwoClicked() : menu.parent.currentItem.item.onMenuButtonTwoClicked()
        }

        MenuButton {
            id: buttonThree

            visible: (menu.parent.currentIndex == 0) || (menu.parent.currentItem.item.showMenuButtonThree)
            icon: buttonThree.visible ? "ui-images/" + menu.buttonThreeIcons[menu.currentSource.split("/").pop().split(".")[0]] + ".png" : ""
            onButtonClicked: (menu.parent.currentIndex == 0) ? menu.parent.currentItem.onMenuButtonThreeClicked() : menu.parent.currentItem.item.onMenuButtonThreeClicked()
        }

        MenuButton {
            id: buttonFour

            visible: !(menu.parent.currentIndex == 0) && (menu.parent.currentItem.item.showMenuButtonFour)
            icon: buttonFour.visible ? "ui-images/" + menu.buttonFourIcons[menu.currentSource.split("/").pop().split(".")[0]] + ".png" : ""
            onButtonClicked: (menu.parent.currentIndex == 0) ? menu.parent.currentItem.onMenuButtonFourClicked() : menu.parent.currentItem.item.onMenuButtonFourClicked()

            Text {
                anchors { top: buttonFour.top; horizontalCenter: Controller.isSymbian ? buttonFour.left : buttonFour.right }
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                text: qsTr("Sort")
                smooth: true
                opacity: (menu.currentSource.split("/").pop().split(".")[0] == "ArchiveListView") ? 0.5 : 0
            }
        }

        MenuButton {
            id: buttonFive

            visible: !(menu.parent.currentIndex == 0) && (menu.parent.currentItem.item.showMenuButtonFive)
            icon: buttonFive.visible ? "ui-images/" + menu.buttonFiveIcons[menu.currentSource.split("/").pop().split(".")[0]] + ".png" : ""
            onButtonClicked: menu.parent.currentItem.item.onMenuButtonFiveClicked()
        }
    }

    MenuButton {
        id: backButton

        anchors.right: menu.right
        icon: "ui-images/backicon.png"
        onButtonClicked: backClicked()
        onButtonPressed: homeClicked()
        visible: !quitButton.visible
    }

    MenuButton {
        id: quitButton

        anchors.right: menu.right
        icon: "ui-images/quiticon.png"
        visible: menu.parent.currentIndex == 0
        onButtonClicked: quitClicked()
    }

    MouseArea {
        z: -1
        anchors.fill: menu
    }
}


