import QtQuick 1.0

Item {
    id: delegate

    signal delegateClicked
    signal delegatePressed

    width: parent.width
    height: 100

    ListHighlight {
        visible: mouseArea.pressed
    }

    Text {
        id: titleText

        elide: Text.ElideRight
        text: title
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        elide: Text.ElideRight
        text: videoCount + qsTr(" videos")
        color: "grey"
        font.pixelSize: _SMALL_FONT_SIZE
        anchors.rightMargin: 5
        anchors.fill: parent
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        height: 1
        anchors { bottom: delegate.bottom; left: delegate.left; leftMargin: 10; right: delegate.right; rightMargin: 10 }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
        visible: !(index == delegate.ListView.view.count - 1)
    }

    MouseArea {
        id: mouseArea

        anchors.fill: delegate
        onClicked: delegateClicked()
        onPressAndHold: delegatePressed()
    }
}
