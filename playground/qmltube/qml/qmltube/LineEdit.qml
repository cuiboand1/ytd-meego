import QtQuick 1.0

Rectangle {
    id: lineEdit

    property alias text : input.text
    property alias echoMode : input.echoMode

    height: 50
    color:  "white"
    border.width: 2
    border.color: input.activeFocus ? _ACTIVE_COLOR_LOW : "grey"
    radius: 5

    TextInput {
        id: input

        anchors { fill: parent; margins: 2 }
        //focus: true
        font.pixelSize: _STANDARD_FONT_SIZE
        selectByMouse: true
        selectionColor: _ACTIVE_COLOR_LOW
    }
}
