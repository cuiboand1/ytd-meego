import QtQuick 1.0

Item {
    id: banner

    property alias message : messageText.text

    height: 70

    Rectangle {
        id: background

        anchors.fill: banner
        color: _ACTIVE_COLOR_LOW
        smooth: true
        opacity: 0.7
    }

    Text {
        id: messageText


        anchors.fill: banner
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font.pixelSize: _STANDARD_FONT_SIZE
        color: _TEXT_COLOR
    }

    states: State {
        name: "portrait"
        PropertyChanges { target: banner; height: 105 }
    }
}
