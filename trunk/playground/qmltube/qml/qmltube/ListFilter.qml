import QtQuick 1.0

Rectangle {
    id: filter

    property alias filterString : filterInput.text

    signal filterChanged(string text)

    height: 0
    color:  "white"
    border.width: 2
    border.color: _ACTIVE_COLOR_LOW
    radius: 5
    smooth: true
    visible: height > 0
    //focus: true

    Component.onCompleted: filter.state = "show"

    Behavior on height { PropertyAnimation { properties: "height"; easing.type: Easing.OutQuart; duration: 500 } }

    TextInput {
        id: filterInput

        anchors { fill: filter; margins: 2 }
        font.pixelSize: _STANDARD_FONT_SIZE
        selectByMouse: true
        selectionColor: _ACTIVE_COLOR_LOW
        smooth: true
        //focus: true
        onTextChanged: filterChanged(filterInput.text)
    }

    states: State {
        name: "show"
        PropertyChanges { target: filter; height: 50 }
    }
}
