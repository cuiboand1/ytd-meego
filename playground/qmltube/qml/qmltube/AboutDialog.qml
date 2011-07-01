import QtQuick 1.0

Item {
    id: dialog

    signal close

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

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Loader {
        id: childLoader

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

        Connections {
            target: childLoader.item
            onClose: dialog.state = "show"
        }
    }

    Image {
        id: icon

        width: 100
        height: 100
        anchors { top: dialog.top; topMargin: 10; horizontalCenter: dialog.horizontalCenter }
        smooth: true
        source: (cuteTubeTheme == "nightred") ? "ui-images/cutetubered.png" : "ui-images/cutetubehires.png"
    }

    Text {
        id: title

        anchors { top: icon.bottom; topMargin: 10; horizontalCenter: dialog.horizontalCenter }
        color: _TEXT_COLOR
        font { pixelSize: _LARGE_FONT_SIZE; bold: true }
        text: qsTr("cuteTube - 1.0.0")
    }

    Text {
        id: description

        anchors { top: title.bottom; left: dialog.left; right: dialog.right; margins: 10 }
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        wrapMode: TextEdit.WordWrap
        horizontalAlignment: TextEdit.AlignHCenter
        textFormat: Text.RichText
        text: qsTr("A feature-rich client for YouTube, vimeo and Dailymotion providing playback, uploading and downloading of videos, plus access to your accounts. <br><br> &copy; Stuart Howarth 2011")
    }

    CloseButton {
        onButtonClicked: close()
    }

    Column {
        id: buttonColumn

        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        spacing: 10
        visible: !Controller.isSymbian

        PushButton {
            id: helpButton

            width: (dialog.width > dialog.height) ? helpButton.textWidth + 20 : dialog.width - 20
            showIcon: false
            showText: true
            name: qsTr("Hints and tips")
            onButtonClicked: {
                childLoader.source = "HelpDialog.qml";
                dialog.state = "showChild";
            }
        }

        PushButton {
            id: donateButton

            width: helpButton.width
            showIcon: false
            showText: true
            name: qsTr("Donate")
            onButtonClicked: {
                childLoader.source = "WebDialog.qml";
                childLoader.item.setWebPage(donateButton.name, decodeURIComponent("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=stuhowarth77%40gmail%2ecom&lc=GB&item_name=cuteTube&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"));
                dialog.state = "showChild";
            }
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

    states: [
        State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        },

        State {
            name: "showChild"
            AnchorChanges { target: dialog; anchors { left: parent.right; right: undefined } }
        }
    ]

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
