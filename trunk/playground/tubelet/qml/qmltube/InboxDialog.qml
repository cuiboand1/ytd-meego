import QtQuick 1.0

Item {
    id: dialog

    signal close
    signal videoClicked(variant video)
    signal userClicked(string username)

    function getInbox() {
        /* Retrieve the user's message inbox */

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var xml = doc.responseText;
                inboxModel.setXml(xml);

                inboxModel.loading = false;
                messageList.positionViewAtIndex(0, ListView.Beginning);
            }
        }

        doc.open("GET", "http://gdata.youtube.com/feeds/api/users/default/inbox?v=2&max-results=50");
        doc.setRequestHeader("Authorization", "GoogleLogin auth=" + YouTube.accessToken);
        doc.send();
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Component.onCompleted: getInbox()

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: title

        anchors { top: dialog.top; topMargin: 10; horizontalCenter: dialog.horizontalCenter }
        color: _TEXT_COLOR
        font.pixelSize: _SMALL_FONT_SIZE
        text: qsTr("Inbox")
    }

    Text {
        id: noResultsText

        anchors.centerIn: dialog
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No messages found")
        visible: false

        Timer {
            interval: 5000
            running: (!inboxModel.loading) && (inboxModel.count == 0)
            onTriggered: {
                if (inboxModel.count == 0) {
                    noResultsText.visible = true;
                }
            }
        }
    }

    ListView {
        id: messageList

        anchors { fill: dialog; topMargin: 50 }
        boundsBehavior: Flickable.DragOverBounds
        highlightMoveDuration: 500
        preferredHighlightBegin: 0
        preferredHighlightEnd: 100
        highlightRangeMode: ListView.StrictlyEnforceRange
        cacheBuffer: 2500
        interactive: visibleArea.heightRatio < 1
        clip: true

        footer: Item {
            id: footer

            width: messageList.width
            height: 100
            visible: ((inboxModel.loading) || (inboxModel.status == XmlListModel.Loading))
            opacity: footer.visible ? 1 : 0

            BusyDialog {
                anchors.centerIn: footer
                opacity: footer.opacity
            }
        }

        Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

        model: InboxModel {
            id: inboxModel

            property bool loading : true
        }

        delegate: InboxDelegate {
            id: delegate

            onDelegateClicked: {
                videoClicked(inboxModel.get(index));
                close();
            }
            onPlayClicked: YouTube.getVideoUrl(videoId)
            onAuthorClicked: {
                userClicked(author);
                close();
            }
        }

        ScrollBar {}
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
