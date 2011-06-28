import QtQuick 1.0

Item {

    id: button

    width: Controller.isSymbian ? Math.floor(parent.width / 5) : Math.floor(parent.width / 6)
    height: parent.height

    property alias icon : icon.source

    signal buttonClicked
    signal buttonPressed

    Image {
        id: background

        width: button.height - 10
        height: background.width
        anchors.centerIn: button
        source: (cuteTubeTheme == "nightred") ? "ui-images/menubuttonbackgroundred.png" : "ui-images/menubuttonbackground.png"
        sourceSize.width: background.width
        sourceSize.height: background.height
        smooth: true
        visible: mouseArea.pressed
    }

    Image {
        id: icon

        anchors.fill: background
        sourceSize.width: icon.width
        sourceSize.height: icon.height
        smooth: true
        opacity: 0.5
    }

    MouseArea {
        id: mouseArea

        anchors.fill: button
        onClicked: buttonClicked()
        onPressAndHold: buttonPressed()
    }
}




