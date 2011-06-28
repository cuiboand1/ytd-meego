import QtQuick 1.0

Rectangle {
    id: frame

    property alias image : image.source

    width: 202
    height: Math.floor(frame.width * 0.5625)
    color: _BACKGROUND_COLOR
    border.width: 1
    border.color: mouseArea.pressed ? _ACTIVE_COLOR_LOW : (cuteTubeTheme == "light") ? "grey" : "white"
    smooth: true

    Image {
        id: image

        anchors { fill: frame; margins: 1 }
        smooth: true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: frame
        onClicked: {
            if (frame.state == "") {
                frame.state = "expand";
            }
            else {
                frame.state = "";
            }
        }
    }

    states: State {
        name: "expand"
        PropertyChanges { target: frame; width: (window.width > window.height) ? window.width - 160 : window.width - 30 }
    }

    transitions: Transition {
        PropertyAnimation { target: frame; property: "width"; easing.type: Easing.OutQuart; duration: 500 }
        PropertyAnimation { target: frame; property: "height"; easing.type: Easing.OutQuart; duration: 500 }
    }
}
