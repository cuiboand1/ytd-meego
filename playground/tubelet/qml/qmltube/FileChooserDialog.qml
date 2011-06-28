import QtQuick 1.0
import Models 1.0

Item {
    id: dialog

    property alias title : titleText.title
    property alias showFiles : folderModel.showFiles
    property alias folder : folderModel.folder
    property alias showButton : saveButton.visible

    signal fileChosen(string filepath)
    signal settingChosen(string setting)
    signal close

    anchors.fill: parent

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        property string title : qsTr("Choose Video File")

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: titleText.title
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Text {
        id: folderText

        property string folderName : folderModel.folder

        anchors { left: dialog.left; leftMargin: 10; right: dialog.right; rightMargin: 10; top: dialog.top; topMargin: 50 }
        elide: Text.ElideRight
        text: Controller.isSymbian ? folderName.substr(8) : folderName.substr(7)
        font.pixelSize: _SMALL_FONT_SIZE
        color: _ACTIVE_COLOR_LOW
    }

    ListView {
        id: fileList

        property alias fmodel : folderModel

        anchors { fill: dialog; leftMargin: 10; rightMargin: ((saveButton.visible) && (dialog.width > dialog.height)) ? 170 : 10; topMargin: 80; bottomMargin: ((!saveButton.visible) || (dialog.width > dialog.height)) ? 10 : 90 }
        clip: true
        interactive: visibleArea.heightRatio < 1

        model: FolderListModel {
            id: folderModel

            nameFilters: [ "*.ogv", "*.avi", "*.divx", "*.flv", "*.mp4", "*.mkv", "*.mpg", "*.wmv" ]
            showDotAndDotDot: !Controller.isSymbian
            showFiles: true
            folder: Controller.homePath //NPM: was 'folder: Controller.isSymbian ? "E:/" : "/home/meego/"'
        }

        header: Item {
            width: fileList.width
            height: 100
            visible: Controller.isSymbian

            ListHighlight {
                visible: headerMouseArea.pressed
            }

            Image {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                width: 50
                height: 50
                sourceSize.width: 50
                sourceSize.height: 50
                source: (cuteTubeTheme == "light") ? "ui-images/backiconlight.png" : "ui-images/backicon.png"
            }

            Rectangle {
                height: 1
                anchors { bottom: parent.bottom; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                color: _ACTIVE_COLOR_HIGH
                opacity: 0.5
            }

            MouseArea {
                id: headerMouseArea

                anchors.fill: parent
                onClicked: folderModel.folder = folderModel.parentFolder
            }
        }

        delegate: FileChooserDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    fileList.currentIndex = index;
                    if (!folderModel.isFolder(index)) {
                        fileChosen(filepath);
                        close();
                    }
                    else {
                        folderModel.folder = filepath;
                    }
                }
            }
        }

        ScrollBar {}        
    }

    PushButton {
        id: saveButton

        width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
        anchors { right: dialog.right; bottom: dialog.bottom; margins: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
        visible: false

        Connections {
            onButtonClicked: {
                var downloadPath = "";
                if (Controller.isSymbian) {
                    downloadPath = folderText.folderName.substr(8);
                }
                else {
                    downloadPath = folderText.folderName.substr(7);
                }
                if (downloadPath.slice(-1) != "/") {
                    downloadPath = downloadPath + "/";
                }
                settingChosen(downloadPath);
                close();
            }
        }
    }

    CloseButton {
        onButtonClicked: close()
    }

    MouseArea {

        property real xPos

        z: -1
        anchors.fill: dialog
        onPressed: xPos = mouseX
        onReleased: {
            if (xPos - mouseX > 100) {
                close();
            }
        }
    }
}
