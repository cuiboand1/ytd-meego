import QtQuick 1.0

Item {
    id: box

    property alias icon: icon.source
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height
    property alias showIcon: icon.visible
    property alias name : label.text
    property alias showText: label.visible

    width: 50
    height: 25

    Rectangle {
        id: background

        anchors.fill: box
        radius: 5
        color: _BACKGROUND_COLOR
        border.width: 2
        border.color: _ACTIVE_COLOR_LOW
        opacity: 0.5
        smooth: true
    }

    Image {
        id: icon

        anchors.centerIn: box
        width: 40
        height: 40
        smooth: true
        visible: false
    }

    Text {
        id: label

        anchors.fill: box
        font.pixelSize: _SMALL_FONT_SIZE
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: _TEXT_COLOR
        smooth: true
    }
}



