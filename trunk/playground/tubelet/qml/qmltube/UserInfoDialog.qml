import QtQuick 1.0

Item {
    id: dialog

    property string username
    property string id
    property string thumbnail
    property string subscriberCount
    property string videoCount
    property string firstName
    property string lastName
    property string age
    property string gender
    property string location
    property string about
    property bool isSubscribed

    signal userVideosClicked(string username)
    signal close

    function getUserProfile(user) {
        username = user;

        var i = 0;
        while ((!isSubscribed) && (i < subscriptionsModel.count)) {
            if (subscriptionsModel.get(i).title == username) {
                id = subscriptionsModel.get(i).subscriptionId.split(":")[5];
                isSubscribed = true;
            }
            i++;
        }

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var xml = doc.responseXML.documentElement;
                for (var i = 0; i < xml.childNodes.length; i++) {
                    if (xml.childNodes[i].nodeName == "thumbnail") {
                        thumbnail = xml.childNodes[i].attributes[0].value;
                    }
                    else if (xml.childNodes[i].nodeName == "aboutMe") {
                        about = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "age") {
                        age = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "firstName") {
                        firstName = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "lastName") {
                        lastName = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "gender") {
                        gender = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "location") {
                        location = xml.childNodes[i].childNodes[0].nodeValue;
                    }
                    else if (xml.childNodes[i].nodeName == "statistics") {
                        subscriberCount = xml.childNodes[i].attributes[1].value;
                    }
                    else if (xml.childNodes[i].nodeName == "feedLink") {
                        if (xml.childNodes[i].attributes[0].value == "http://gdata.youtube.com/schemas/2007#user.uploads") {
                            videoCount = xml.childNodes[i].attributes[2].value;
                        }
                    }
                }
            }
        }
        doc.open("GET", "http://gdata.youtube.com/feeds/api/users/" + username + "?v=2");
        doc.send();
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
            text: qsTr("Uploads")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Subscribers")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: videoCount
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: subscriberCount
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Name")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Age")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: (firstName == "") ? username : firstName + " " + lastName
            color: "grey"
            elide: Text.ElideRight
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: (age == "") ? qsTr("None") : age
            color: "grey"
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Gender")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: qsTr("Location")
            color: _TEXT_COLOR
            font.pixelSize: _SMALL_FONT_SIZE
        }

        Text {
            text: (gender == "") ? qsTr("None") : (gender == "m") ? qsTr("Male") : qsTr("Female")
            color: "grey"
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
            if (isSubscribed) {
                YouTube.unsubscribeToChannel(id);
            }
            else {
                YouTube.subscribeToChannel(username);
            }
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
