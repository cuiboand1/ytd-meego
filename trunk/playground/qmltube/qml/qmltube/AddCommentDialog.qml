import QtQuick 1.0
import "scripts/OAuth.js" as OAuth

Item {
    id: dialog

    property string title
    property variant video
    property string service

    signal close

    function setService(name, videoObject) {
        service = name;
        video = videoObject;
        title = qsTr("Share Via ") + name;
        if (name == "Facebook") {
            titleInput.text = video.title;
            descriptionEdit.text = video.description;
        }
        else if (name == "Twitter") {
            if (video.youtube) {
                commentEdit.text = "http://youtu.be/" + video.videoId;
            }
            else {
                commentEdit.text = video.playerUrl.replace("iphone.", "");
            }
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

    Rectangle {
        id: background

        color: _BACKGROUND_COLOR
        opacity: 0.5
        anchors.fill: dialog
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: title
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Column {
        id: column

        anchors { fill: dialog; leftMargin: 10; rightMargin: (dialog.width > dialog.height) ? 180 : 10; topMargin: 50; bottomMargin: (dialog.width > dialog.height) ? 10 : 90 }
        spacing: 10

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Title")
            visible: dialog.service == "Facebook"
        }

        LineEdit {
            id: titleInput

            width: column.width
            visible: dialog.service == "Facebook"
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Description")
            visible: dialog.service == "Facebook"
        }

        Rectangle {
            height: Controller.isSymbian ? Math.floor(dialog.height / 5 - 3) : Math.floor(dialog.height / 4)
            width: column.width
            color:  "white"
            border.width: 2
            border.color: descriptionEdit.activeFocus ? _ACTIVE_COLOR_LOW : "grey"
            radius: 5
            visible: dialog.service == "Facebook"

            Flickable {
                anchors { fill: parent; margins: 2 }
                contentWidth: childrenRect.width
                contentHeight: childrenRect.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.DragOverBounds
                clip: true

                TextEdit {
                    id: descriptionEdit

                    width: column.width - 4
                    height: Math.floor(dialog.height / 4)
                    font.pixelSize: _STANDARD_FONT_SIZE
                    selectByMouse: true
                    wrapMode: Text.WordWrap
                    selectionColor: _ACTIVE_COLOR_LOW
                }
            }
        }

        Text {
            id: charText

            property int charsRemaining : 140 - commentEdit.text.length

            font.pixelSize: _SMALL_FONT_SIZE
            color: (dialog.service == "Facebook") || (charsRemaining > 10) ? "grey" : (charsRemaining >= 0) ? "yellow" : "red"
            text: (dialog.service == "Facebook") ? qsTr("Message") : charsRemaining.toString()
        }

        Rectangle {
            width: column.width
            height: (dialog.service == "Facebook") ? Controller.isSymbian ? Math.floor(dialog.height / 5 - 3) : Math.floor(dialog.height / 4 + 12) : column.height - (charText.height + 10)
            color:  "white"
            border.width: 2
            border.color: commentEdit.activeFocus ? _ACTIVE_COLOR_LOW : "grey"
            radius: 5

            Flickable {
                anchors { fill: parent; margins: 2 }
                contentWidth: childrenRect.width
                contentHeight: childrenRect.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.DragOverBounds
                interactive: (dialog.service == "Facebook")
                clip: true

                TextEdit {
                    id: commentEdit

                    width: column.width - 4
                    height: parent.parent.height - 4
                    //focus: true
                    font.pixelSize: _STANDARD_FONT_SIZE
                    selectByMouse: true
                    wrapMode: Text.WordWrap
                    selectionColor: _ACTIVE_COLOR_LOW
                }
            }
        }
    }

    PushButton {
        id: confirmButton

        width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"

        onButtonClicked: {
            toggleBusy(true);
            var site;
            var thumbUrl;
            var id;
            if (service == "Facebook") {
                if (video.dailymotion) {
                    site = "Dailymotion";
                    thumbUrl = video.largeThumbnail;
                    id = video.id;
                }
                else if (video.vimeo) {
                    site = "vimeo";
                    thumbUrl = video.largeThumbnail;
                    id = video.id;
                }
                else {
                    site = "YouTube";
                    thumbUrl = video.largeThumbnail;
                    id = video.videoId;
                }
                Sharing.postToFacebook(site, id, titleInput.text, descriptionEdit.text, commentEdit.text, thumbUrl);
            }
            else if (service == "Twitter") {
                var credentials = { "token": Sharing.twitterToken, "secret": Sharing.twitterTokenSecret };
                var body = "status=" + OAuth.url_encode(commentEdit.text);
                var oauthData = OAuth.createOAuthHeader("twitter", "POST", "http://api.twitter.com/1/statuses/update.json", credentials, undefined, undefined, body);
                Sharing.postToTwitter(oauthData.url, oauthData.header, body);
            }
            commentEdit.focus = false;
            close();
        }
    }

    CloseButton {
        onButtonClicked: {
            commentEdit.focus = false;
            close();
        }
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
