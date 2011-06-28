import QtQuick 1.0

Rectangle {
    id: scrollbar

    anchors.right: parent.right
    y: parent.visibleArea.yPosition * parent.height
    width: 10
    height: parent.visibleArea.heightRatio * (parent.height * 3)
    color: _ACTIVE_COLOR_HIGH
    opacity: parent.movingVertically ? 0.5 : 0

    Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
}
