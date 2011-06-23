import QtQuick 1.0

Item {
    id: button

    property bool useTheme : true
    property alias icon: icon.source
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height
    property alias buttonState: background.state

    signal buttonClicked
    signal buttonHeld

    width: 40
    height: 40

    Rectangle {
        id: background

        anchors.fill: button
        radius: 5
        gradient: Gradient {
            GradientStop { id: gradient1; position: 0.0; color: button.useTheme ? _GRADIENT_COLOR_HIGH : "#524e4e" }
            GradientStop { id: gradient2; position: 0.7; color: button.useTheme ? _GRADIENT_COLOR_LOW : "black"}
        }
        border.width: 2
        border.color: _ACTIVE_COLOR_LOW
        opacity: 0.7
        smooth: true
        state: mouseArea.pressed ? "highlight" : ""

        states: State {
            name: "highlight"
            PropertyChanges { target: gradient1; color: _ACTIVE_COLOR_HIGH }
            PropertyChanges { target: gradient2; color: _ACTIVE_COLOR_LOW }
        }
    }

    Image {
        id: icon

        anchors.centerIn: button
        width: 35
        height: 35
        sourceSize.width: icon.width
        sourceSize.height: icon.height
        smooth: true
    }

    MouseArea {
        id: mouseArea

        width: 60
        height: 60
        anchors.centerIn: button
        onClicked: buttonClicked()
        onPressAndHold: buttonHeld()
    }

    states: State {
        name: "disabled"
        PropertyChanges { target: button; opacity: 0.3 }
    }
}



