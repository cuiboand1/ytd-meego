import QtQuick 1.0

Item {
    id: delegate

    property alias checked : checkbox.visible

    signal delegateClicked
    signal delegatePressed

    width: delegate.ListView.view.width; height: 100
    smooth: true

    ListHighlight {
        visible: mouseArea.pressed
    }

    Rectangle {
        width: Math.floor(bytesReceived / totalBytes * delegate.width)
        anchors { left: delegate.left; top: delegate.top; bottom: delegate.bottom }
        color: _ACTIVE_COLOR_LOW
        opacity: 0.5
        smooth: true
        visible: Controller.isSymbian

        Behavior on width { SmoothedAnimation { velocity: 1200 } }
    }

    Text {
        id: titleText

        elide: Text.ElideRight
        text: title
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors { left: frame.right; leftMargin: 5; right: Controller.isSymbian ? delegate.right : progressBar.left; rightMargin: 5; top: frame.top }
        verticalAlignment: Text.AlignTop
        smooth: true
    }

    Image {
        id: convertIcon

        width: 40
        height: 40
        anchors { left: titleText.left; top: titleText.bottom }
        source: (cuteTubeTheme == "light") ? "ui-images/musiciconlight.png" : "ui-images/musicicon.png"
        sourceSize.width: convertIcon.width
        sourceSize.height: convertIcon.height
        smooth: true
        visible: convert
    }

    Text {
        id: statusText

        elide: Text.ElideRight
        text: downloadModel.statusDict[status]
        color: ((status == "paused") || (status == "queued")) ? "grey" : (status == "failed") ? "red" : _ACTIVE_COLOR_LOW
        font.pixelSize: _SMALL_FONT_SIZE
        anchors { left: frame.right; leftMargin: 5; bottom: frame.bottom }
        verticalAlignment: Text.AlignBottom
        smooth: true
    }

    Text {
        id: speedText

        anchors { left: statusText.right; leftMargin: 5; right: Controller.isSymbian ? delegate.right : progressBar.left; rightMargin: 5; bottom: frame.bottom }
        font.pixelSize: _SMALL_FONT_SIZE
        verticalAlignment: Text.AlignBottom
        elide: Text.ElideRight
        color: _ACTIVE_COLOR_LOW
        smooth: true
        text: Controller.isSymbian ? "(" + speed + ") - " + Math.floor(bytesReceived / totalBytes * 100) + '%' : "(" + speed + ")"
        visible: status == "downloading"
    }

    Rectangle {
        id: frame

        width: 122
        height: 92
        anchors { left: delegate.left; leftMargin: 3; verticalCenter: delegate.verticalCenter }
        color: _BACKGROUND_COLOR
        border.width: 1
        border.color: (cuteTubeTheme == "light") ? "grey" : "white"
        smooth: true
    }

    Image {
        id: thumb

        anchors { fill: frame; margins: 1 }
        source: thumb.status == Image.Error ? "ui-images/error.jpg" : thumbnail
        smooth: true
    }

    ProgressBar {
        id: progressBar

        anchors { verticalCenter: delegate.verticalCenter; right: delegate.right; rightMargin: 3 }
        received: bytesReceived
        total: totalBytes
        visible: !Controller.isSymbian
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
        visible: !(index == delegate.ListView.view.count - 1)
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: delegateClicked()
        onPressAndHold: delegatePressed()
    }
}

