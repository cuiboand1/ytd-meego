import Qt 4.7
import "scripts/settings.js" as Settings

Item {
    id: dialog

    signal settingChosen(string setting)
    signal close

    function setProxy(proxy) {
        var p = proxy.split(":");
        proxyEdit.text = p[0];
        hostEdit.text = p[1];
    }

    anchors.fill: parent

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: title

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Network Proxy")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Grid {
        anchors { left: dialog.left; leftMargin: 10; right: dialog.right; rightMargin: 10; top: dialog.top; topMargin: 50 }
        columns: (dialog.width > dialog.height) ? 2 : 1
        spacing: 10

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            width: proxyEdit.width
            text: qsTr("Host (e.g. 192.168.100.1)")
        }

        LineEdit {
            id: proxyEdit

            width: 300
            focus: true
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            width: hostEdit.width
            text: qsTr("Port (e.g. 8080)")
        }

        LineEdit {
            id: hostEdit

            width: 100
        }
    }

    PushButton {
        id: saveButton

        width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
        onButtonClicked: {
            var proxy = proxyEdit.text;
            var host = hostEdit.text;
            settingChosen(proxy + ":" + host);
            close();
        }
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
}
