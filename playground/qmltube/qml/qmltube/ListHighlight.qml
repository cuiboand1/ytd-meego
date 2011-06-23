import QtQuick 1.0

Rectangle {
    id: highlight

    anchors.fill: parent
    gradient: Gradient {
        GradientStop { position: 0.0; color: _ACTIVE_COLOR_HIGH }
        GradientStop { position: 0.7; color: _ACTIVE_COLOR_LOW }
    }
    opacity: 0.7
    smooth: true
}
