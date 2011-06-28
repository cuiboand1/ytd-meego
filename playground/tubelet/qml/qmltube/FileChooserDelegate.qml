import QtQuick 1.0

Item {
    id: delegate

    signal delegateClicked(string filepath)

    width: delegate.ListView.view.width
    height: 100

    ListHighlight {
        visible: mouseArea.pressed
    }

    Image {
        anchors { left: delegate.left; leftMargin: 10; verticalCenter: delegate.verticalCenter }
        width: 50
        height: 50
        sourceSize.width: 50
        sourceSize.height: 50
        source: {
            if (delegate.ListView.view.fmodel.isFolder(index)) {
                if (cuteTubeTheme == "light") {
                 "ui-images/foldericonlight.png";
                }
                else {
                    "ui-images/foldericon.png";
                }
            }
            else {
                if (cuteTubeTheme == "light") {
                     "ui-images/videosiconlight.png";
                }
                else {
                    "ui-images/videosicon.png";
                }
            }
        }
    }

    Text {
        id: titleText

        anchors { fill: delegate; leftMargin: 70; rightMargin: 10 }
        elide: Text.ElideRight
        text: fileName
        color: _TEXT_COLOR
        font.pixelSize: _STANDARD_FONT_SIZE
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

        anchors.fill: parent
        onClicked: delegateClicked(filePath)
    }
}
