import QtQuick 1.0

Item {
    id: dialog

    property variant uploadStatusDict
    property variant statusColorDict
    property string uploadStatus : "preparing"
    property variant video

    signal close

    function setDetails(videoObject, site) {
        video = videoObject;
        siteText.text = site;
        filenameText.text = video.filename;
        titleText.text = video.title;
    }

    anchors.fill: parent

    Component.onCompleted: {
        uploadStatusDict = {
                "preparing": qsTr("Starting upload"), "started": qsTr("Upload is in progress"),
                "interrupted": qsTr("Upload interrupted - attempting to resume"), "aborted": qsTr("Upload aborted"),
                "completed": qsTr("Upload completed"), "failed": qsTr("Upload failed")
    }
        statusColorDict = {
                "preparing": _TEXT_COLOR, "started": _ACTIVE_COLOR_LOW,
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
            text: qsTr("Site")
        }

        Text {
            id: siteText

            anchors { left: column.left; right: column.right; rightMargin: 10 }
            font.pixelSize: _STANDARD_FONT_SIZE
            elide: Text.ElideRight
            color: _TEXT_COLOR
        }

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
            font.pixelSize: _SMALL_FONT_SIZE
            color: "grey"
            text: qsTr("Status")
        }

        Text {
            id: resultText

            anchors.left: parent.left
            font.pixelSize: _SMALL_FONT_SIZE
            color: statusColorDict[uploadStatus]
            text:  uploadStatusDict[uploadStatus]

            Text {
                id: speedText

                property string speed

                anchors { left: resultText.right; leftMargin: 5 }
                font.pixelSize: _SMALL_FONT_SIZE
                color: resultText.color
                text: "(" + speedText.speed + ")"
                visible: uploadStatus == "started"
            }
        }

        ProgressBar {
            id: progressBar

            height: 70
            width: 420
        }
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
        onUploadProgressChanged: {
            progressBar.sent = bytesSent;
            progressBar.total = bytesTotal;
            speedText.speed = speed;
        }
        onUploadStatusChanged: {
            uploadStatus = status;
        }
    }

    Connections {
        target: DailyMotion
        onUploadProgressChanged: {
            progressBar.received = bytesSent;
            progressBar.total = bytesTotal;
            speedText.speed = speed;
        }
        onUploadStatusChanged: uploadStatus = status
        onWaitingForMetadata: DailyMotion.setUploadMetadata(id, video.title, video.description, video.tags, video.category, video.isPrivate)
        onUploadCompleted: uploadStatus = "completed"
        onUploadFailed: uploadStatus = "failed"
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
