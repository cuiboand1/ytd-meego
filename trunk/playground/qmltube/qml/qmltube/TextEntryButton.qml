import QtQuick 1.0

Item {
    id: button

    property bool useTheme : true
    property int textEntryWidth
    property int textEntryHeight
    property alias icon: icon.source
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height

    signal submitText(string text)

    width: 40
    height: 40
    onStateChanged: {
        textEdit.text = "";
        background.state = "";
    }
    focus: button.state == "show"

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

    TextEdit {
        id: textEdit

        anchors { fill: button; leftMargin: 10; rightMargin: 10; topMargin: 50; bottomMargin: 50 }
        font.pixelSize: _STANDARD_FONT_SIZE
        selectByMouse: true
        wrapMode: Text.WordWrap
        selectionColor: _ACTIVE_COLOR_LOW
        focus: true
        clip: true
        visible: false

    }

    Image {
        id: closeButton

        anchors { bottom: textEdit.top; bottomMargin: 10; left: textEdit.left; leftMargin: -5 }
        width: 35
        height: 35
        source:closeMouseArea.pressed ? (cuteTubeTheme == "nightred") ? "ui-images/closeiconred.png" : "ui-images/closeiconblue.png" : "ui-images/closeicon.png"
        sourceSize.width: icon.width
        sourceSize.height: icon.height
        smooth: true
        visible: (textEdit.visible) && (button.width == button.textEntryWidth)

        MouseArea {
            id: closeMouseArea

            width: 50
            height: 50
            anchors.centerIn: closeButton
            onClicked: button.state = "";
        }
    }

    Image {
        id: submitButton

        anchors { top: textEdit.bottom; topMargin: 10; right: textEdit.right }
        width: 35
        height: 35
        source: submitMouseArea.pressed ? (cuteTubeTheme == "nightred") ? "ui-images/tickred.png" : "ui-images/tickblue.png" : "ui-images/ticklight.png"
        sourceSize.width: icon.width
        sourceSize.height: icon.height
        smooth: true
        visible: (textEdit.visible) && (button.width == button.textEntryWidth)

        MouseArea {
            id: submitMouseArea

            width: 50
            height: 50
            anchors.centerIn: submitButton
            onClicked: {
                if (!(textEdit.text == "")) {
                    submitText(textEdit.text);
                    button.state = "";
                }
            }
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
        onClicked: button.state = "show"
    }

    states: State {
        name: "show"
        PropertyChanges { target: button; width: textEntryWidth; height: textEntryHeight }
        PropertyChanges { target: background; border.color: textEdit.activeFocus ? _ACTIVE_COLOR_LOW : "grey"; opacity: 1 }
        PropertyChanges { target: gradient1; color: "white" }
        PropertyChanges { target: gradient2; color: "white" }
        PropertyChanges { target: mouseArea; enabled: false }
        PropertyChanges { target: icon; visible: false }
        PropertyChanges { target: notificationArea; focus: false }
        PropertyChanges { target: textEdit; visible: true; focus: true }
    }

    transitions: Transition {
        PropertyAnimation { target: button; property: "width"; easing.type: Easing.OutQuart; duration: 500 }
        PropertyAnimation { target: button; property: "height"; easing.type: Easing.OutQuart; duration: 500 }
    }
}



