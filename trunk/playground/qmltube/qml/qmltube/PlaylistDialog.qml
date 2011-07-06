import QtQuick 1.0
import "scripts/youtube.js" as YT

Item {
    id: dialog

    property string videoFeed
    property variant playlist
    property string playlistId
    property string title
    property string videoCount
    property string description
    property string createdDate
    property string updatedDate

    signal playClicked(variant videos)
    signal playlistVideosClicked(variant playlist)
    signal close

    function setPlaylist(playlistItem) {
        playlist = playlistItem;
        playlistId = playlist.playlistId;
        title = playlist.title;
        videoCount = playlist.videoCount;
        description = playlist.description;
        createdDate = playlist.createdDate.split("T")[0];
        updatedDate = playlist.updatedDate.split("T")[0];
        videoFeed = "https://gdata.youtube.com/feeds/api/playlists/" + playlistId + "?v=2&max-results=50&alt=json";

        YT.getYouTubeVideos();
    }

    function setPlaylistVideos(playlistItem) {
        /* This function is used to pass the videos of
          a fully loaded ListModel */

        playlist = playlistItem.info;
        playlistId = playlist.playlistId;
        title = playlist.title;
        videoCount = playlist.videoCount;
        description = playlist.description;
        createdDate = playlist.createdDate.split("T")[0];
        updatedDate = playlist.updatedDate.split("T")[0];
        for (var i = 0; i < playlistItem.videos.length; i++) {
            videoListModel.append(playlistItem.videos[i]);
        }
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    ListModel {
        id: videoListModel

        property bool loading : true
        property int totalResults
        property int page : 0
    }
    Connections {
        target: videoListModel
        onLoadingChanged: {
            if ((!videoListModel.loading) &&
                    (videoListModel.totalResults > 50) &&
                    (videoListModel.totalResults > videoListModel.count)) {
                YT.getYouTubeVideos();
            }
        }
    }

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Playlist Info")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Rectangle {
        id: frame

        width: (dialog.width > dialog.height) ? Math.floor(dialog.width / 3.2) : Math.floor(window.width / 1.9)
        height: Math.floor(frame.width / (4 / 3))
        anchors { left: dialog.left; leftMargin: 10; top: dialog.top; topMargin: 50 }
        color: _BACKGROUND_COLOR
        border.width: 2
        border.color: mouseArea.pressed ? _ACTIVE_COLOR_LOW : (cuteTubeTheme == "light") ? "grey" : "white"

        Image {
            id: thumb

            anchors { fill: frame; margins: 2 }
            source: (videoListModel.count > 0) ? videoListModel.get(0).largeThumbnail : ""
            smooth: true
        }

        MouseArea {
            id: mouseArea

            anchors.fill: frame
            enabled: !busyDialog.visible
            onClicked: {
                var list = [];
                for (var i = 0; i < videoListModel.count; i++) {
                    list.push(YT.createVideoObject(videoListModel.get(i)));
                }
                playlistVideosClicked({ "info": playlist, "videos": list });
                close();
            }
        }
    }

    Grid {
        id: infoGrid

        visible: !(videoCount == "")
        columns: 2
        spacing: 10
        anchors { left: (dialog.width > dialog.height) ? frame.right : dialog.left; leftMargin: 10;
            right: (dialog.width > dialog.height) ? buttonColumn.left : dialog.right; rightMargin: 10;
            top: dialog.top; topMargin: (dialog.width > dialog.height) ? 50 : frame.height + 70 }

        Text {
            text: qsTr("Title")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Videos")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: title
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: videoCount
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Created")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Updated")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: createdDate
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: updatedDate
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }
    }

    Column {
        spacing: 10

        visible: !busyDialog.visible
        anchors { left: infoGrid.left; right: dialog.right; rightMargin: 10; top: infoGrid.bottom; topMargin: 10;
            bottom: dialog.bottom; bottomMargin: (dialog.width > dialog.height) ? 4 : 170 }

        Text {
            text: qsTr("Description")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Flickable {
            height: parent.height - 40
            width: parent.width
            contentHeight: descriptionText.height
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragOverBounds
            interactive: !(description == "")

            Text {
                id: descriptionText

                width: parent.width
                text: (description == "") ? qsTr("No description") : description
                color: "grey"
                wrapMode: Text.WordWrap
                font.pixelSize: _SMALL_FONT_SIZE
            }
        }
    }

    Column {
        id: buttonColumn
        anchors { bottom: dialog.bottom; left: dialog.left; margins: 10 }
        spacing: 10

        PushButton {
            id: playButton

            width: downloadButton.width
            showIcon: false
            showText: true
            name: qsTr("Play")
            disabled: busyDialog.visible
            visible: !Controller.isSymbian
            onButtonClicked: {
                if (Controller.getMediaPlayer() == "cutetubeplayer") {
                    var list = [];
                    var video;
                    for (var i = 0; i < videoListModel.count; i++) {
                        list.push(YT.createVideoObject(videoListModel.get(i)));
                    }
                    playClicked(list);
                }
                else {
                    messages.displayMessage(messages._USE_CUTETUBE_PLAYER);
                }
            }
        }

        PushButton {
            id: downloadButton

            width: (dialog.width > dialog.height) ? frame.width : dialog.width - 20
            showIcon: false
            showText: true
            name: qsTr("Download")
            disabled: busyDialog.visible
            onButtonClicked: {
                for (var i = 0; i < videoListModel.count; i++) {
                    addDownload(videoListModel.get(i));
                }
                close();
            }
        }
    }

    BusyDialog {
        id: busyDialog

        anchors { centerIn: dialog; verticalCenterOffset: 20 }
        visible: ((videoListModel.count == 0) || (videoListModel.count < videoListModel.totalResults))
    }

    CloseButton {
        onButtonClicked: close()
    }

    MouseArea {

        property real xPos

        z: -1
        anchors.fill: dialog
        onPressed: xPos = mouseX
        onReleased: {
            if (xPos - mouseX > 100) {
                close();
            }
        }
    }

    states: State {
        name: "show"
        AnchorChanges { target: dialog; anchors.right: parent.right }
    }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
