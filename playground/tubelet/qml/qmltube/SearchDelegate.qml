import QtQuick 1.0

Rectangle {
    id: delegate

    signal delegateClicked(string searchterm)

    width: delegate.ListView.view.width
    height: 40
    color: "white"

    ListHighlight {
        visible: mouseArea.pressed
    }

    Rectangle {
        height: 1
        anchors { top: delegate.top; left: delegate.left; leftMargin: 10; right: delegate.right; rightMargin: 10 }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
    }

    Text {
        id: titleText
        elide: Text.ElideRight
        text: searchterm
        color: "black"
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: delegateClicked(titleText.text)
    }
}
