import QtQuick 1.0

Item {
    id: dialog

    property string title : qsTr("Add Comment")
    property variant video
    property string service

    signal close

    function setService(name, videoObject) {
        service = name;
        video = videoObject;
        if (name != "YouTube") {
            title = qsTr("Share Via ") + name;
            titleInput.text = video.title;
            descriptionEdit.text = video.description;
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
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Message")
            visible: dialog.service == "Facebook"
        }

        Rectangle {
            width: column.width
            height: (dialog.service == "Facebook") ? Controller.isSymbian ? Math.floor(dialog.height / 5 - 3) : Math.floor(dialog.height / 4 + 12) : column.height
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
            var site;
            var thumbUrl;
            var id;
            if (dialog.service == "Facebook") {
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
            else if (dialog.service == "Twitter") {
            }
            else {
                YouTube.addComment(dialog.videoId, commentEdit.text);
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
