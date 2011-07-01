import QtQuick 1.0

Item {
    id: delegate

    signal commentClicked(string author)

    width: delegate.ListView.view.width;
    height: authorText.height + commentText.height + 20

    Text {
        id: authorText

        width: delegate.width
        height: 30
        anchors { top: delegate.top; left: delegate.left; margins: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: mouseArea.pressed ? qsTr("By ") + "<font color='" + _ACTIVE_COLOR_HIGH + "'>"
                                  + author + "</font>" + qsTr(" on ") + date.split(/\s|T/)[0]
                                : qsTr("By ") + "<font color='" + _ACTIVE_COLOR_LOW + "'>"
                                  + author + "</font>" + qsTr(" on ") + date.split(/\s|T/)[0]

        MouseArea {
            id: mouseArea

            anchors.fill: authorText
            onClicked: commentClicked(author);
        }
    }

    Text {
        id: commentText

        width: delegate.width - 20
        anchors {top: authorText.bottom; left: authorText.left }
        wrapMode: TextEdit.WordWrap
        font.pixelSize: _SMALL_FONT_SIZE
        color: "grey"
        text: comment
    }

    Rectangle {
        height: 1
        anchors { bottom: delegate.bottom; left: delegate.left; leftMargin: 10; right: delegate.right; rightMargin: 10 }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
        visible: !(index == delegate.ListView.view.count - 1)
    }
}
