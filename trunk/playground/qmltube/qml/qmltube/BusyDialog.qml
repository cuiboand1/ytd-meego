import QtQuick 1.0

Item {
    id: dialog

    property alias message : message.text

    width: message.width + 70
    height: 60
    opacity: dialog.visible ? 1 : 0

    Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }

    Image {
        id: border

        anchors.fill: dialog
        source: (cuteTubeTheme == "nightred") ? "ui-images/busydialogred.png" : "ui-images/busydialog.png"
        fillMode: Image.Stretch
        smooth: true
    }

    Image {
        id: busyIndicator

        width: 40
        height: 40
        anchors { left: dialog.left; leftMargin: 10; verticalCenter: dialog.verticalCenter }
        source: "ui-images/busy.png"
        sourceSize.width: 40
        sourceSize.height: 40
        smooth: true

        NumberAnimation on rotation {
            running: dialog.opacity > 0; from: 0; to: 360; loops: Animation.Infinite; duration: 1500
        }
    }

    Text {
        id: message

        anchors { left: busyIndicator.right; leftMargin: 10; verticalCenter: dialog.verticalCenter }
        font.pixelSize: _STANDARD_FONT_SIZE
        color: _TEXT_COLOR
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        smooth: true
        text: qsTr("Loading...")
    }
}
