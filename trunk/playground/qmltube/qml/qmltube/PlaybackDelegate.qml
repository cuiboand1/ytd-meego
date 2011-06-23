import QtQuick 1.0

Item {
    id: delegate

    property alias videoTitle: titleText.text
    property alias checked : checkbox.visible

    signal delegateClicked
    signal delegatePressed

    function getDuration(secs) {
        /* Converts seconds to HH:MM:SS format. */
        var hours = Math.floor(secs / 3600);
        var minutes = Math.floor(secs / 60) - (hours * 60);
        var seconds = secs - (hours * 3600) - ( minutes * 60);
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        var duration = minutes + ":" + seconds;
        if (hours > 0) {
            duration = hours + ":" + duration;
        }
        return duration;
    }

    width: delegate.ListView.view.width; height: 100
    smooth: true

    ListHighlight {
        visible: (mouseArea.pressed) || (delegate.ListView.view.parent.playlistPosition == index)
    }

    Text {
        id: titleText

        elide: Text.ElideRight
        text: title
        color: "white"
        font.pixelSize: _STANDARD_FONT_SIZE
        anchors { left: frame.right; leftMargin: 5; right: delegate.right; rightMargin: 5; top: frame.top }
        verticalAlignment: Text.AlignTop
        smooth: true
    }

//    Text {
//        id: authorText

//        elide: Text.ElideRight
//        text: "By " + author + " on " + uploadDate.split("T")[0]
//        color: "grey"
//        font.pixelSize: _SMALL_FONT_SIZE
//        anchors { left: frame.right; leftMargin: 8; bottom: frame.bottom }
//        verticalAlignment: Text.AlignBottom
//        smooth: true
//    }

    Rectangle {
        id: frame

        width: 124
        height: 94
        anchors { left: delegate.left; leftMargin: 3; verticalCenter: delegate.verticalCenter }
        color: "black"
        border.width: 2
        border.color: "white"
        smooth: true
    }

    Image {
        id: thumb

        width: 120
        height: 90
        anchors.centerIn: frame
        source: thumb.status == Image.Error ? "ui-images/error.jpg" : thumbnail
        smooth: true
    }

//    Rectangle {
//        id: durationLabel

//        width: 50
//        height: 22
//        anchors { bottom: thumb.bottom; right: thumb.right }
//        color: "black"
//        opacity: 0.5
//        smooth: true
//    }

//    Text {
//        anchors.fill: durationLabel
//        text: getDuration(duration)
//        color: "white"
//        font.pixelSize: _SMALL_FONT_SIZE
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        smooth: true
//    }

    Image {
        id: checkbox

        width: 70
        height: 70
        source: "ui-images/tick.png"
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
