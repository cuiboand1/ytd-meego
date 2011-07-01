import QtQuick 1.0
import "scripts/vimeo.js" as VM

Item {
    id: dialog

    property string username
    property string id
    property string thumbnail
    property string videoCount
    property string name
    property string location
    property string about
    property bool isSubscribed

    signal userVideosClicked(string username)
    signal close

    function setUserProfile(user) {
        username = user.title;
        id = user.id;
        thumbnail = user.largeThumbnail;
        videoCount = user.videoCount;
        name = user.title;
        location = user.location;
        about = user.bio;

        var i = 0;
        while ((!isSubscribed) && (i < vimeoSubscriptionsModel.count)) {
            if (vimeoSubscriptionsModel.get(i).title == username) {
                isSubscribed = true;
            }
            i++;
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


    Connections {
        target: YouTube

        onSubscribed: isSubscribed = true
        onUnsubscribed: isSubscribed = false
    }

    Rectangle {
        id: background

        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: username + "'s " + qsTr("Profile")
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
            source: thumbnail
            smooth: true

        }

        MouseArea {
            id: mouseArea

            anchors.fill: frame
            onClicked: {
                userVideosClicked(username);
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
            right: (dialog.width > dialog.height) ? subscribeButton.left : dialog.right; rightMargin: 10;
            top: dialog.top; topMargin: (dialog.width > dialog.height) ? 50 : frame.height + 70 }

        Text {
            text: qsTr("Name")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Uploads")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: name
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
            text: qsTr("Location")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: "           "
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: (location == "") ? qsTr("None") : location
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }
    }

    Column {
        spacing: 10

        visible: infoGrid.visible
        anchors { left: infoGrid.left; right: dialog.right; rightMargin: 10; top: infoGrid.bottom; topMargin: 10;
            bottom: dialog.bottom; bottomMargin: (dialog.width > dialog.height) ? 4 : 90 }

        Text {
            text: qsTr("About")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Flickable {
            height: parent.height - 40
            width: parent.width
            contentHeight: aboutText.height
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragOverBounds
            interactive: !(about == "")

            Text {
                id: aboutText

                width: parent.width
                text: (about == "") ? qsTr("No info") : about
                color: "grey"
                wrapMode: Text.WordWrap
                font.pixelSize: _SMALL_FONT_SIZE
            }
        }
    }

    PushButton {
        id: subscribeButton

        width: (dialog.width > dialog.height) ? frame.width : dialog.width - 20
        anchors { bottom: dialog.bottom; left: dialog.left; margins: 10 }
        showIcon: false
        showText: true
        name: isSubscribed ? qsTr("Unsubscribe") : qsTr("Subscribe")
        onButtonClicked: {
            VM.setSubscription(id);
            close();
        }
    }

    BusyDialog {
        anchors.centerIn: dialog
        visible: !(infoGrid.visible)
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
