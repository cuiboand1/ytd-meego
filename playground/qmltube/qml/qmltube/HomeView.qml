import QtQuick 1.0
import "scripts/createobject.js" as ObjectCreator

Item {
    id: window

    property alias dimmerState : dimmer.state
    property string categoryFeedOne
    property string categoryFeedOneName
    property alias categoryFeedOneIcon : categoryFeedOneButton.icon
    property string categoryFeedTwo
    property string categoryFeedTwoName
    property alias categoryFeedTwoIcon : categoryFeedTwoButton.icon

    signal myChannel
    signal loadCategory(string categoryFeed, string title)
    signal archive
    signal dialogClose

    function showNoAccountDialog() {
        if (dimmer.state == "") {
            toggleControls(false);
            var noAccDialog = ObjectCreator.createObject("NoAccountDialog.qml", window);
            noAccDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            noAccDialog.state = "show";
        }
    }

    function onMenuButtonOneClicked() {
        /* Show the settings dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var settingsDialog = ObjectCreator.createObject("SettingsDialog.qml", window);
            settingsDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            settingsDialog.state = "show";
        }
    }

    function onMenuButtonTwoClicked() {
        /* Show the accounts dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var accDialog = ObjectCreator.createObject("AccountsDialog.qml", window);
            accDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            accDialog.state = "show";
        }
    }

    function onMenuButtonThreeClicked() {
        /* Show the 'about' dialog */

        if (dimmer.state == "") {
            toggleControls(false);
            var aboutDialog = ObjectCreator.createObject("AboutDialog.qml", window);
            aboutDialog.close.connect(closeDialogs);
            dimmer.state = "dim";
            aboutDialog.state = "show";
        }
    }

    function showConfirmExitDialog() {
        /* If a download is taking place, show
          a confirmation dialog */

        toggleControls(false);
        var confirmDialog = ObjectCreator.createObject("ConfirmExitDialog.qml", window);
        confirmDialog.close.connect(closeDialogs);
        dimmer.state = "dim";
        confirmDialog.state = "show";
    }

    function closeDialogs() {
        /* Close any open dialogs and return the window to its default state */

        dialogClose();
        dimmer.state = "";
        toggleControls(true);
    }

    Item {
        id: dimmer

        anchors.fill: window

        Grid {
            id: buttonGrid

            anchors.centerIn: dimmer
            rows: 2
            columns: 4
            spacing: (window.state == "") ? Math.floor(window.width / 12) : Math.floor(window.height / 12)

            Column {

                PushButton {
                    id: myAccountButton

                    width: (window.state == "") ? (window.width / 6) : (window.height / 6)
                    height: myAccountButton.width
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/myaccounticonlight.png" : "ui-images/myaccounticon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: myChannel()
                }

                Text {
                    y: 10
                    width: myAccountButton.width
                    text: qsTr("My Channel")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: categoryFeedOneButton

                    width: myAccountButton.width
                    height: myAccountButton.height
                    smooth: true
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: loadCategory(categoryFeedOne, categoryFeedOneName)
                }

                Text {
                    y: 10
                    width: categoryFeedOneButton.width
                    text: categoryFeedOneName
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: categoryFeedTwoButton

                    width: myAccountButton.width
                    height: myAccountButton.height
                    smooth: true
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: loadCategory(categoryFeedTwo, categoryFeedTwoName)
                }

                Text {
                    y: 10
                    width: categoryFeedTwoButton.width
                    text: categoryFeedTwoName
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Column {

                PushButton {
                    id: archiveButton

                    width: myAccountButton.width
                    height: myAccountButton.height
                    smooth: true
                    icon: (cuteTubeTheme == "light") ? "ui-images/downloadiconlight.png" : "ui-images/downloadicon.png"
                    iconWidth: 100
                    iconHeight: 100
                    onButtonClicked: archive()
                }

                Text {
                    y: 10
                    width: archiveButton.width
                    text: qsTr("Archive")
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: _TEXT_COLOR
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: dimmer
            enabled: false
            onClicked: closeDialogs()
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.1}
        }

        transitions: Transition {
            PropertyAnimation { target: dimmer; properties: "opacity"; duration: 500 }
        }
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
        PropertyChanges { target: buttonGrid; columns: 2 }
    }
}
