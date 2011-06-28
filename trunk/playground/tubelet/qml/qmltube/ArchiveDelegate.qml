import QtQuick 1.0
import "scripts/dateandtime.js" as GetDate


Item {
    id: delegate

    property alias checked : checkbox.visible

    signal delegateClicked
    signal delegatePressed

    width: delegate.ListView.view.width
    height: 100
    smooth: true

    ListHighlight {
        visible: mouseArea.pressed
    }

    Text {
        id: titleText

        elide: Text.ElideRight
        text: title
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors { left: frame.right; leftMargin: 5; right: delegate.right; rightMargin: 5; top: frame.top }
        verticalAlignment: Text.AlignTop
        smooth: true

        Text {
            id: dateLabel

            anchors { left: titleText.left; top: titleText.bottom; topMargin: 5 }
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: "Added on " + GetDate.getDate(date)
            visible: date > 0
        }
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

    Row {
        id: labelRow

        anchors { left: frame.right; leftMargin: 5; bottom: frame.bottom }
        spacing: 5

        Image {
            id: qualityIcon

            width: 50
            height: 30
            source: !(/[amh347]/.test(quality.charAt(0))) ? "" : (cuteTubeTheme == "light") ? "ui-images/" + quality + "iconlight.png" : "ui-images/" + quality + "icon.png";
            sourceSize.width: qualityIcon.width
            sourceSize.height: qualityIcon.height
            smooth: true
            visible: qualityIcon.source != ""
        }

        Image {
            id: newIcon

            width: 50
            height: 30
            source: (cuteTubeTheme == "light") ? "ui-images/newiconlight.png" : "ui-images/newicon.png";
            sourceSize.width: newIcon.width
            sourceSize.height: newIcon.height
            smooth: true
            opacity: (isNew == 1) ? 1 : 0.3
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
        visible: !(index == delegate.ListView.view.count - 1)
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: delegateClicked()
        onPressAndHold: delegatePressed()
    }
}

