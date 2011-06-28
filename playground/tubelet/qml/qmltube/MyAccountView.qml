import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    signal uploads(string feed, string title)
    signal favourites(string feed, string title)
    signal playlists
    signal subscriptions
    signal dialogClose
    signal goToVideo(variant video)
    signal goToUserVideos(string username)

    function changeCurrentUser() {
        /* Raise a dialog enabling the user to choose from available users */

        if (dimmer.state == "") {
            toggleControls(false);
            var userDialog = ObjectCreator.createObject("ChangeUserDialog.qml", window);
            userDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            userDialog.state = "show";
        }
    }

    function onMenuButtonOneClicked() {
        /* Show the video upload dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var uploadDialog = ObjectCreator.createObject("UploadDialog.qml", window);
            uploadDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            uploadDialog.state = "show";
        }
    }

    function onMenuButtonTwoClicked() {
        /* Show the message inbox dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var inboxDialog = ObjectCreator.createObject("InboxDialog.qml", window);
            inboxDialog.close.connect(closeDialogs);
            inboxDialog.videoClicked.connect(goToVideo)
            inboxDialog.userClicked.connect(goToUserVideos)
            dimmer.state = "dim";
            inboxDialog.state = "show";
        }
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        dimmer.state = "";
        toggleControls(true);
    }

    Connections {
        target: YouTube

        onUploadStarted: mouseArea.enabled = false;
    }

    Item {
        id: dimmer

        anchors.fill: window

        Grid {
            id: buttonGrid

            anchors.centerIn: dimmer
            rows: 2
            columns: 4
            spacing: (window.state == "") ? Math.floor(window.width / 12) : Math.floor(window.height / 12)

            Column {

                PushButton {
                    id: uploadsButton

                    width: (window.state == "") ? (window.width / 6) : (window.height / 6)
                    height: uploadsButton.width
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/uploadsiconlight.png" : "ui-images/uploadsicon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: uploads(_UPLOADS_FEED, qsTr("My Uploads"))
                }

                Text {
                    y: 10
                    width: uploadsButton.width
                    text: qsTr("Uploads")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: favouritesButton

                    width: uploadsButton.width
                    height: uploadsButton.height
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/favouritesiconlight.png" : "ui-images/favouritesicon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: favourites(_FAVOURITES_FEED, qsTr("My Favourites"))
                }

                Text {
                    y: 10
                    width: favouritesButton.width
                    text: qsTr("Favourites")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: playlistsButton

                    width: uploadsButton.width
                    height: uploadsButton.height
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/playlistsiconlight.png" : "ui-images/playlistsicon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: playlists()
                }

                Text {
                    y: 10
                    width: playlistsButton.width
                    text: qsTr("Playlists")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: subscriptionsButton

                    width: uploadsButton.width
                    height: uploadsButton.height
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/subscriptionsiconlight.png" : "ui-images/subscriptionsicon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: subscriptions()
                }

                Text {
                    y: 10
                    width: subscriptionsButton.width
                    text: qsTr("Subscriptions")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Row {
            anchors { bottom: dimmer.bottom; bottomMargin: 80; right: dimmer.right; rightMargin: 64 }
            spacing: 5

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                color: _TEXT_COLOR
                text: qsTr("Signed in as:")
                visible: currentUserText.visible
            }

            Text {
                id: currentUserText

                font.pixelSize: _SMALL_FONT_SIZE
                color: userMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                text: YouTube.currentUser
                visible: !(YouTube.currentUser == "")

                MouseArea {
                    id: userMouseArea

                    width: 200
                    height: 70
                    anchors.centerIn: currentUserText
                    onClicked: changeCurrentUser()
                }
            }

        }

        MouseArea {
            id: mouseArea

            anchors.fill: dimmer
            enabled: false
            onClicked: closeDialogs()
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1}
        }

        transitions: Transition {
            PropertyAnimation { target: dimmer; properties: "opacity"; duration: 500 }
        }
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
        PropertyChanges { target: buttonGrid; columns: 2 }
    }
}
