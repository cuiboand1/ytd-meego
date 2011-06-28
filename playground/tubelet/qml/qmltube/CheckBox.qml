import QtQuick 1.0

Item {
    id: checkbox

    property bool checked : true

    width: 50
    height: 50

    Rectangle {
        id: border

        anchors.fill: checkbox
        color: _BACKGROUND_COLOR
        border.width: 2
        border.color: _ACTIVE_COLOR_LOW
        radius: 5
        opacity: 0.5
    }

    Image {
        id: tick

        width: 35
        height: 35
        anchors.centerIn: checkbox
        source: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
        sourceSize.width: 35
        sourceSize.height: 35
        smooth: true
        visible: checkbox.checked
    }

    MouseArea {
        id: mouseArea

        anchors.fill: checkbox
        onClicked: checkbox.checked = !checkbox.checked
    }
}
