import QtQuick 1.0
import "scripts/dailymotion.js" as DM

Item {
    id: dialog

    property string videoFeed
    property variant playlist
    property string playlistId
    property string title
    property string videoCount
    property string updatedDate

    signal playClicked(variant videos)
    signal playlistVideosClicked(variant playlist)
    signal close

    function setPlaylist(playlistItem) {
        playlist = playlistItem;
        playlistId = playlist.id;
        title = playlist.title;
        videoCount = playlist.videoCount;
        updatedDate = playlist.updatedDate;
        videoFeed = "http://www.dailymotion.com/playlist/" + playlistId;

        DM.getDailymotionPlaylistVideos();
    }

    function setPlaylistVideos(playlistItem) {
        /* This function is used to pass the videos of
          a fully loaded ListModel */

        playlist = playlistItem.info;
        playlistId = playlist.id;
        title = playlist.title;
        videoCount = playlist.videoCount;
        updatedDate = playlist.updatedDate;
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
        property bool moreResults : false
        property int page : 1
    }

    Connections {
        target: videoListModel
        onLoadingChanged: {
            if((!videoListModel.loading) && (videoListModel.moreResults)) {
                DM.getDailymotionPlaylistVideos();
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
                    list.push(DM.createVideoObject(videoListModel.get(i)));
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
            text: qsTr("Updated")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: "        "
            color: _TEXT_COLOR
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
                    for (var i = 0; i < videoListModel.count; i++) {
                        list.push(DM.createVideoObject(videoListModel.get(i)));
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
        visible: videoListModel.count < parseInt(videoCount)
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
