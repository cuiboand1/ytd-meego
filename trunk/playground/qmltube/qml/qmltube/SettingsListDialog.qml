import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property string titleText

    signal settingChosen(string setting)
    signal close

    function setSettingsList(title, list, currentSetting) {
        /* Set the title and populate the settings model */
        titleText = title;
        settingsModel.clear();
        for (var i = 0; i < list.length; i++) {
            settingsModel.append({ "setting": list[i] });
            if (list[i] == currentSetting) {
                settingsList.currentIndex = i;
            }
        }
    }

    anchors.fill: parent

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: title

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: titleText
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    ListView {
        id: settingsList

        anchors { fill: dialog; leftMargin: 10; rightMargin: 10; topMargin: 55; bottomMargin: 10 }
        clip: true
        interactive: settingsList.count > 3

        model: ListModel {
            id: settingsModel
        }

        delegate: SettingsDelegate {
            id: delegate

            Connections {
                onDelegateClicked: {
                    settingsList.currentIndex = index;
                    settingChosen(setting);
                    close();
                }
            }
        }

        ScrollBar {}
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
