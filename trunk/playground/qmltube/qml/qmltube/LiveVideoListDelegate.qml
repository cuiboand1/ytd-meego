import QtQuick 1.0

Item {
    id: delegate

    signal playClicked

    width: 204
    height: 230

    Rectangle {
        id: frame

        z: 1
        width: 204
        height: 154
        color: _BACKGROUND_COLOR
        border.width: 2
        border.color: (cuteTubeTheme == "light") ? "grey" : "white"
        smooth: true

        Image {
            id: thumb

            anchors { fill: frame; margins: 2 }
            source: thumbnail
            sourceSize.width: thumb.width
            sourceSize.height: thumb.height
            smooth: true
            onStatusChanged: {
                if (thumb.status == Image.Error) {
                    thumb.source = "ui-images/error.jpg";
                }
            }

            Rectangle {
                id: durationLabel

                width: durationText.width + 20
                height: 30
                anchors { bottom: thumb.bottom; right: thumb.right }
                color: "black"
                opacity: 0.5
                smooth: true
            }

            Text {
                id: durationText

                anchors.centerIn: durationLabel
                text: qsTr("Live")
                color: "white"
                font.pixelSize: _SMALL_FONT_SIZE
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                smooth: true
            }

            Rectangle {
                width: 50
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
        }

        MouseArea {
            id: playMouseArea

            z: 1
            anchors.fill: frame
            onClicked: playClicked()
        }
    }

    Text {
        id: titleText

        anchors { left: frame.left; right: frame.right; top: frame.bottom; topMargin: 5; bottom: delegate.bottom; bottomMargin: 5 }
        wrapMode: Text.WordWrap
        font.pixelSize: _STANDARD_FONT_SIZE
        color: _TEXT_COLOR
        horizontalAlignment: Text.AlignHCenter
        text: title
        clip: true
    }
}
