import QtQuick 1.0

Item {
    id: delegate

    property alias checked : checkbox.visible

    signal delegateClicked
    signal delegatePressed
    signal playClicked

    width: delegate.parent.width
    height: 100
    smooth: true

    ListHighlight {
        visible: mouseArea.pressed
    }

    Text {
        id: titleText

        wrapMode: Text.WordWrap
        text: title
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors { left: frame.right; leftMargin: 5; right: delegate.right; rightMargin: 5; top: frame.top; bottom: frame.bottom }
        verticalAlignment: Text.AlignTop
        smooth: true
        clip: true
    }

    Rectangle {
        id: frame

        z: 1
        width: 122
        height: 92
        anchors { left: delegate.left; leftMargin: 3; verticalCenter: delegate.verticalCenter }
        color: _BACKGROUND_COLOR
        border.width: 1
        border.color: (cuteTubeTheme == "light") ? "grey" : "white"
        smooth: true

        Image {
            id: thumb

            anchors { fill: frame; margins: 1 }
            source: thumb.status == Image.Error ? "ui-images/error.jpg" : thumbnail
            sourceSize.width: thumb.width
            sourceSize.height: thumb.height
            smooth: true
        }

        Rectangle {
            id: durationLabel

            width: 50
            height: 22
            anchors { bottom: thumb.bottom; right: thumb.right }
            color: "black"
            opacity: 0.5
            smooth: true
        }

        Text {
            anchors.fill: durationLabel
            text: duration
            color: "white"
            font.pixelSize: _SMALL_FONT_SIZE
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            smooth: true
        }

        Rectangle {
            width: 30
            height: width
            anchors.centerIn: thumb
            color: playMouseArea.pressed ? _ACTIVE_COLOR_LOW : "black"
            opacity: 0.5
            radius: 2
            smooth: true

            Image {
                id: playIcon

                anchors { fill: parent; margins: 5 }
                smooth: true
                source: "ui-images/playicon.png"
                sourceSize.width: playIcon.width
                sourceSize.height: playIcon.height
            }
        }

        MouseArea {
            id: playMouseArea

            z: 1
            anchors.fill: frame
            onClicked: playClicked()
        }
    }

    Image {
        id: checkbox

        width: 70
        height: 70
        source: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
        visible: false
        smooth: true
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }
    }

    Rectangle {
        height: 1
        anchors { bottom: delegate.bottom; left: delegate.left; leftMargin: 10; right: delegate.right; rightMargin: 10 }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
        visible: !(index == delegate.parent.count - 1)
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: delegateClicked()
        //onPressAndHold: delegatePressed()
    }
}
