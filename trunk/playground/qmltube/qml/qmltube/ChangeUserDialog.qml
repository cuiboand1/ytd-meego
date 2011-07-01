import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: dialog

    property variant accounts : []

    signal close()

    function getAccounts() {
        /* Retrieve the user's accounts and populate the model */

        var sites = ["YouTube", "Dailymotion", "vimeo"];
        var accounts = [];
        var acc = [];
        for (var i = 0; i < sites.length; i++) {
            acc = Settings.getAllAccounts(sites[i]);
            if (acc.length > 0) {
                for (var ii = 0; ii < acc.length; ii++) {
                    accounts.push(acc[ii]);
                }
            }
        }
        for (var i = 0; i < accounts.length; i++) {
            var username = accounts[i].username;
            var site = accounts[i].site;
            var accessToken = accounts[i].accessToken
            if (site == "YouTube") {
                youtubeAccounts.append({ "site": "", "username": username, "accessToken": accessToken });
            }
            else if (site == "Dailymotion") {
                var refreshToken = accounts[i].refreshToken;
                var tokenExpiry = accounts[i].tokenExpiry;
                dailymotionAccounts.append({ "site": "", "username": username, "accessToken": accessToken, "refreshToken": refreshToken, "tokenExpiry": tokenExpiry });
            }
            else if (site == "vimeo") {
                vimeoAccounts.append({ "site": "", "username": username, "accessToken": accessToken });
            }
        }
    }

    function changeDailymotionUser(index) {
        var account = dailymotionAccounts.get(index);
        var username = account.username;
        var accessToken = account.accessToken;
        var refreshToken = account.refreshToken;
        var tokenExpiry = account.tokenExpiry;
        DailyMotion.setUserCredentials(username, accessToken, refreshToken, tokenExpiry);
        close();
    }

    function changeYouTubeUser(index) {
        var account = youtubeAccounts.get(index);
        var username = account.username;
        var accessToken = account.accessToken;
        YouTube.setUserCredentials(username, accessToken);
        close();
    }

    function changeVimeoUser(index) {

    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Component.onCompleted: getAccounts()

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: qsTr("Change Current User")
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
    }

    Item {
        id: tabItem

        property variant sites : [ "YouTube", "Dailymotion", "vimeo" ]

        anchors { fill: dialog; topMargin: 60 }

        Row {
            id: tabRow

            Repeater {
                model: tabItem.sites

                Item {
                    width: tabItem.width / tabItem.sites.length
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == index
                    }

                    Text {
                        anchors.fill: parent
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == index ? _TEXT_COLOR : "grey"
                        text: modelData
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == index)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabView.currentIndex = index
                    }
                }
            }
        }

        ListView {
            id: tabView

            anchors { left: tabItem.left; right: tabItem.right; top: tabRow.bottom; bottom: tabItem.bottom }
            orientation: ListView.Horizontal
            highlightMoveDuration: 200
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapOneItem
            flickDeceleration: 500
            boundsBehavior: Flickable.StopAtBounds
            model: tabModel
            clip: true
        }
    }

    VisualItemModel {
        id: tabModel

        ListView {
            id: youtubeList

            width: tabView.width
            height: tabView.height
            interactive: visibleArea.heightRatio < 1
            opacity: (tabView.currentIndex == 0) ? 1 : 0
            model: ListModel {
                id: youtubeAccounts
            }
            delegate: AccountDelegate {
                id: youtubeDelegate

                onDelegateClicked: {
                    if (!(youtubeList.currentIndex == index)) {
                        youtubeList.currentIndex = index;
                        changeYouTubeUser(index);
                    }
                }
            }
        }

        ListView {
            id: dailymotionList

            width: tabView.width
            height: tabView.height
            interactive: visibleArea.heightRatio < 1
            opacity: (tabView.currentIndex == 1) ? 1 : 0
            model: ListModel {
                id: dailymotionAccounts
            }
            delegate: AccountDelegate {
                id: dailymotionDelegate

                onDelegateClicked: {
                    if (!(dailymotionList.currentIndex == index)) {
                        dailymotionList.currentIndex = index;
                        changeDailymotionUser(index);
                    }
                }
            }
        }

        ListView {
            id: vimeoList

            width: tabView.width
            height: tabView.height
            interactive: visibleArea.heightRatio < 1
            opacity: (tabView.currentIndex == 2) ? 1 : 0
            model: ListModel {
                id: vimeoAccounts
            }
            delegate: AccountDelegate {
                id: vimeoDelegate

                onDelegateClicked: {
                    if (!(vimeoList.currentIndex == index)) {
                        vimeoList.currentIndex = index;
                        changeVimeoUser(index);
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: dialog
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No accounts found")
        visible: ((tabView.currentIndex == 0) && (youtubeList.count == 0))
                 || ((tabView.currentIndex == 1) && (dailymotionList.count == 0))
                 || ((tabView.currentIndex == 2) && (vimeoList.count == 0))
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

    states: State {
        name: "show"
        AnchorChanges { target: dialog; anchors.right: parent.right }
    }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
