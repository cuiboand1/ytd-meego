import QtQuick 1.0

Item {
    id: button

    property bool disabled : false
    property alias icon: icon.source
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height
    property alias showIcon: icon.visible
    property alias name : label.text
    property alias nameSize : label.textSize
    property alias textWidth : label.width
    property alias showText: label.visible
    property alias value : valueLabel.text

    signal buttonClicked

    width: 150
    height: 70

    Rectangle {
        id: background

        anchors.fill: button
        radius: 10
        gradient: Gradient {
            GradientStop { id: gradient1; position: 0.0; color: _GRADIENT_COLOR_HIGH }
            GradientStop { id: gradient2; position: 0.7; color: _GRADIENT_COLOR_LOW }
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
        width: 50
        height: 50
        smooth: true
        sourceSize.width: icon.width
        sourceSize.height: icon.height
        visible: false
    }

    Text {
        id: label

        property int textSize : _STANDARD_FONT_SIZE

        anchors { top: button.top; topMargin: 5; horizontalCenter: button.horizontalCenter }
        font.pixelSize: textSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: _TEXT_COLOR
        smooth: true
    }

    Text {
        id: valueLabel

        property int textSize : _SMALL_FONT_SIZE

        anchors { bottom: button.bottom; bottomMargin: 5; horizontalCenter: button.horizontalCenter }
        font.pixelSize: textSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: _ACTIVE_COLOR_LOW
        smooth: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: buttonClicked()
    }

    states: State {
        name: "disabled"
        when: button.disabled
        PropertyChanges { target: button; opacity: 0.4 }
        PropertyChanges { target: mouseArea; enabled: false }
    }
}



