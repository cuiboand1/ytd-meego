import QtQuick 1.0

Item {
    id: dialog

    property variant uploadStatusDict
    property variant statusColorDict
    property string uploadStatus : "preparing"

    signal close

    function setDetails(filename, title) {
        filenameText.text = filename;
        titleText.text = title;
    }

    anchors.fill: parent

    Component.onCompleted: {
        uploadStatusDict = {
                "preparing": qsTr("Starting upload"), "started": qsTr("Upload is in progress"),
                "interrupted": qsTr("Upload interrupted - attempting to resume"), "aborted": qsTr("Upload aborted"),
                "completed": qsTr("Upload completed"), "failed": qsTr("Upload failed")
    }
        statusColorDict = {
                "preparing": _TEXT_COLOR, "started": "#3d6be0",
                "interrupted": "yellow", "aborted": "yellow",
                "completed": "green", "failed": "red"
    }
    }

    Rectangle {
        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
        smooth: true
    }

    Text {
        id: title

        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: qsTr("Upload Progress")
    }

    Column {
        id: column

        anchors { left: dialog.left; leftMargin: 10; right: dialog.right; rightMargin: 180; top: dialog.top; topMargin: 50 }
        spacing: 10

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Filename")
        }

        Text {
            id: filenameText

            anchors { left: column.left; right: column.right; rightMargin: 10 }
            font.pixelSize: _STANDARD_FONT_SIZE
            elide: Text.ElideRight
            color: _TEXT_COLOR
        }

        Text {
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Title")
        }

        Text {
            id: titleText

            anchors { left: column.left; right: column.right; rightMargin: 10 }
            font.pixelSize: _STANDARD_FONT_SIZE
            elide: Text.ElideRight
            color: _TEXT_COLOR
        }

        Text {
            id: resultText

            anchors.left: parent.left
            font.pixelSize: _SMALL_FONT_SIZE
            color: statusColorDict[uploadStatus]
            text:  uploadStatusDict[uploadStatus]
        }
    }

    ProgressBar {
        id: progressBar

        height: 70
        width: 420
        anchors { left: dialog.left; bottom: dialog.bottom; margins: 10 }
    }

    PushButton {
        id: cancelButton

        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        name: uploadStatus == "started" ? qsTr("Abort") : qsTr("Close")
        showText: true
        showIcon: false

        Connections {
            onButtonClicked: {
                if (uploadStatus == "started") {
                    YouTube.abortVideoUpload();
                }
                else {
                    close();
                }
            }
        }
    }

    MouseArea {
        z: -1
        anchors.fill: dialog
    }

    Connections {
        target: YouTube
        onUpdateUploadProgress: {
            progressBar.received = bytesSent;
            progressBar.total = bytesTotal;
        }
        onUploadStatusChanged: {
            uploadStatus = status;
        }
    }

    states: State {
        name: "portrait"
        when: dialog.height > dialog.width
        PropertyChanges { target: column; anchors.rightMargin: 10 }
        AnchorChanges { target: progressBar; anchors.bottom: cancelButton.top }
        PropertyChanges { target: progressBar; width: dialog.width - 20 }
        PropertyChanges { target: cancelButton; width: dialog.width - 20 }
    }
}
