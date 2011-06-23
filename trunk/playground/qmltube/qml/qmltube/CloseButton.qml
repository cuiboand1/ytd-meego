import QtQuick 1.0

Image {
    id: closeButton

    property bool useTheme : true
    signal buttonClicked

    height: 50
    width:  50
    source: closeMouseArea.pressed ? (cuteTubeTheme == "nightred")
                                     ? "ui-images/backiconred.png" : "ui-images/backicon2.png" : ((closeButton.useTheme) && (cuteTubeTheme == "light"))
                                                                   ? "ui-images/backiconlight.png" : "ui-images/backicon.png"
    sourceSize.width: closeButton.width
    sourceSize.height: closeButton.height
    smooth: true
    anchors { top: parent.top; right: parent.right; margins: 5 }

    MouseArea {
        id: closeMouseArea

        anchors.fill: closeButton
        onClicked: buttonClicked()
    }
}
