import QtQuick 1.0

Item {
    id: notificationArea

    property variant titleList : ["tubelet"]
    property alias viewTitle: title.titleText
    property alias isBusy: busyIndicator.isBusy
    property bool searchBarOpen : (searchBar.source != "")

    signal startSearch(string query, string order)
    signal goToVideo(variant video)
    signal goToDownloads

    function addTitle(title) {
        var titles = titleList;
        titles.push(title);
        titleList = titles;
    }

    function removeTitle() {
        var titles = titleList;
        titles.pop();
        titleList = titles;
    }

    function showSearchBar(text) {
        if (searchBar.source == "") {
            searchBar.source = "SearchBar.qml";
            if (text) {
                searchBar.item.searchText = text;
            }
        }
    }

    function closeSearchBar() {
        searchBar.state = "";
        timer.running = true;
    }

    function sortNumber(a, b) {
        /* Sort function for the checkList */

        return b - a;
    }

    height: parent.height
    width: parent.width
    focus: true
    anchors { bottom: parent.top; bottomMargin: -50 }
    z: 100 // Ensures that the notification area is always on top

    Rectangle {
        id: background

        anchors { fill: notificationArea; bottomMargin: 50 }
        color: _BACKGROUND_COLOR
        opacity: 0.8
    }

    Text {
        anchors.centerIn: notificationArea
        font.pixelSize: _LARGE_FONT_SIZE
        font.bold: true
        color: "grey"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No active downloads")
        visible: (downloadsLoader.source != "") && (downloadsLoader.item.count == 0)
    }

    Loader {
        id: downloadsLoader

        anchors { left: notificationArea.left; right: notificationArea.right; bottom: notificationArea.bottom; bottomMargin: 50 }
        onLoaded: notificationArea.state = "show"

        Timer {
            id: downloadsTimer

            interval: 600
            onTriggered: downloadsLoader.source = ""
        }
    }

    Rectangle {
        id: bar

        height: 50
        anchors { left: notificationArea.left; right: notificationArea.right; bottom: notificationArea.bottom }
        color: _BACKGROUND_COLOR
        opacity: notificationArea.state == "show" ? 1 : 0.5
        smooth: true
    }

    ToolButton {
        id: minimizeButton

        anchors { verticalCenter: bar.verticalCenter; left: bar.left; leftMargin: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/minimizeiconlight.png" : "ui-images/minimizeicon.png"
        visible: !Controller.isSymbian

        Connections {
            onButtonClicked: Controller.minimize()
            onButtonHeld: Controller.toggleState()
        }

    }

    Loader {
        id: searchBar

        anchors { left: bar.left; right: searchButton.left; bottom: bar.top; margins: 10 }
        z: 11
        focus: true
        visible: notificationArea.state == ""

        onLoaded: {
            searchBar.item.state = searchBar.state;
            searchBar.state = "show";
            searchBar.focus = true;
        }

        Timer {
            id: timer

            interval: 600
            onTriggered: searchBar.source = ""
        }

        Connections {
            target: searchBar.item

            onSearch: {
                startSearch(query, order);
                closeSearchBar();
            }
            onVideo: {
                goToVideo(video);
                closeSearchBar();
            }
        }

        states: State {
            name: "show"
            AnchorChanges { target: searchBar; anchors { bottom: undefined; top: bar.top } }
            PropertyChanges { target: searchBar; anchors.topMargin: 5 }
        }

        transitions: Transition {
            AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
        }
    }

    Text {
        id: title

        property string titleText

        anchors { fill: bar; leftMargin: Controller.isSymbian ? 10 : 60; rightMargin: 110 }
        font.pixelSize: _STANDARD_FONT_SIZE
        color: _TEXT_COLOR
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        smooth: true
        text: notificationArea.state == "show" ? qsTr("Downloads") : qsTr(titleText)
        visible: !buttonRow.visible
    }

    Row {
        id: buttonRow

        anchors.centerIn: bar
        spacing: 10
        visible: (notificationArea.state == "show") && (downloadModel.count > 0)

        ToolButton {
            id: toggleSelectButton

            icon: {
                if (downloadsLoader.source != "") {
                    if (cuteTubeTheme == "light") {
                        if (downloadsLoader.item.checkList.length > 0) {
                            "ui-images/ticknonelight.png";
                        }
                        else {
                            "ui-images/ticklight.png";
                        }
                    }
                    else if (downloadsLoader.item.checkList.length > 0) {
                        "ui-images/ticknone.png";
                    }
                    else {
                        "ui-images/tick.png";
                    }
                }
                else {
                    "";
                }
            }

            onButtonClicked: {
                var cl = downloadsLoader.item.checkList;
                if (cl.length == 0) {
                    for (var i = 0; i < downloadModel.count; i++) {
                        cl.push(i);
                    }
                    downloadsLoader.item.checkList = cl;
                }
                else {
                    downloadsLoader.item.checkList = [];
                }
            }
        }

        ToolButton {
            id: resumeButton

            icon: (cuteTubeTheme == "light") ? "ui-images/downloadiconlight.png" : "ui-images/downloadicon.png"

            onButtonClicked: {
                for (var i = 0; i < downloadsLoader.item.checkList.length; i++) {
                    downloadModel.resumeDownload(downloadsLoader.item.checkList[i]);
                }
                downloadsLoader.item.checkList = [];
                downloadModel.getNextDownload();
            }
        }

        ToolButton {
            id: pauseButton

            icon: (cuteTubeTheme == "light") ? "ui-images/pauseiconlight.png" : "ui-images/pauseicon.png"

            onButtonClicked: {
                for (var i = 0; i < downloadsLoader.item.checkList.length; i++) {
                    downloadModel.pauseDownload(downloadsLoader.item.checkList[i]);
                }
                downloadsLoader.item.checkList = [];
                downloadModel.getNextDownload();
            }
        }

        ToolButton {
            id: cancelButton

            icon: (cuteTubeTheme == "light") ? "ui-images/deleteiconlight.png" : "ui-images/deleteicon.png"

            onButtonClicked: {
                var list = downloadsLoader.item.checkList;
                list.sort(sortNumber);
                for (var i = 0; i < list.length; i++) {
                    downloadModel.cancelDownload(list[i]);
                }
                downloadsLoader.item.checkList = [];
                downloadModel.getNextDownload();
            }
        }
    }

    Image {
        id: busyIndicator

        property bool isBusy : false

        width: 40
        height: 40
        anchors { right: bar.right; rightMargin: 60; verticalCenter: bar.verticalCenter }
        source: "ui-images/busy.png"
        sourceSize.width: busyIndicator.width
        sourceSize.height: busyIndicator.height
        smooth: true
        opacity: 0

        NumberAnimation on rotation {
            running: busyIndicator.opacity > 0; from: 0; to: 360; loops: Animation.Infinite; duration: 1500
        }

        states: State {
            name: "busy"
            when: busyIndicator.isBusy
            PropertyChanges { target: busyIndicator; opacity: 1 }
        }

        transitions: Transition {
            PropertyAnimation { properties: "opacity"; duration: 500 }
        }
    }

    ToolButton {
        id: searchButton

        anchors { verticalCenter: bar.verticalCenter; right: bar.right; rightMargin: 10 }
        icon: (cuteTubeTheme == "light") ? "ui-images/searchiconlight.png" : "ui-images/searchicon.png"
        visible: notificationArea.state == ""

        Connections {
            onButtonClicked: {
                if (searchBar.source == "") {
                    showSearchBar();
                }
                else if (searchBar.item.searchText == "") {
                    closeSearchBar();
                }
                else {
                    searchBar.item.parseSearchQuery();
                }
            }
        }

    }

    Image {
        id: dragIcon

        anchors { bottom: bar.bottom; bottomMargin: 2; horizontalCenter: bar.horizontalCenter }
        width: 10
        height: 10
        source: {
            if (cuteTubeTheme == "light") {
                if (notificationArea.state == "show") {
                    "ui-images/dragiconlight2.png";
                }
                else {
                    "ui-images/dragiconlight.png";
                }
            }
            else if (notificationArea.state == "show") {
                "ui-images/dragicon2.png";
            }
            else {
                "ui-images/dragicon.png";
            }
        }
        sourceSize.width: dragIcon.width
        sourceSize.height: dragIcon.height
        smooth: true
        visible: (searchBar.source == "") && (notificationArea.state == "")
    }

    Rectangle {
        height: 1
        anchors { left: bar.left; leftMargin: 10; right: bar.right; rightMargin: 10; bottom: bar.top }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
    }

    Rectangle {
        height: 1
        anchors { left: bar.left; leftMargin: 10; right: bar.right; rightMargin: 10; bottom: bar.bottom }
        color: _ACTIVE_COLOR_HIGH
        opacity: 0.5
    }

    MouseArea {
        anchors { fill: notificationArea; bottomMargin: bar.height }
        z: -1
    }

    MouseArea {
        id: dragMouseArea

        property real yPos
        anchors.fill: bar
        z: -1
        onClicked: {
            if (notificationArea.state == "") {
                downloadsLoader.source = "DownloadList.qml";
            }
            else {
                notificationArea.state = "";
                downloadsTimer.running = true;
            }
        }
    }

    states: State {
        name: "show"
        AnchorChanges { target: notificationArea; anchors.bottom: parent.bottom }
        PropertyChanges { target: notificationArea; anchors.bottomMargin: 0 }
    }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}




