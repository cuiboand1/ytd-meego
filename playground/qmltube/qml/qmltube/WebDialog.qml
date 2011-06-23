import QtQuick 1.0
import QtWebKit 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal close

    function setWebPage(title, url) {
        titleText.text = title;
        webView.url = url;
    }

    anchors.fill: parent

    Rectangle {
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Flickable {
        id: webFlicker

        anchors { fill: dialog; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
        contentWidth: webView.width
        contentHeight: webView.height
        boundsBehavior: Flickable.DragOverBounds
        clip: true

        WebView {
            id: webView

            width: 1000
            height: 1000
            preferredWidth: parent.width - 20
            preferredHeight: parent.height - 60
            opacity:(webView.progress == 1) ? 1 : 0

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
    }

    BusyDialog {
        id: busyDialog

        anchors.centerIn: dialog
        opacity: (webView.progress < 1) ? 1 : 0
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
