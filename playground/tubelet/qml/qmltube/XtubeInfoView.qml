import QtQuick 1.0
import "scripts/videoinfoscripts.js" as Scripts
import "scripts/settings.js" as Settings
import "scripts/xtube.js" as Xtube

Item {
    id: window

    property string site
    property variant video
    property string playerUrl
    property string title
    property string date : qsTr("N/A")
    property string thumbnail
    property string duration
    property string views : qsTr("N/A")
    property variant tags : []
    property string videoFeed

    signal playVideo(variant video)
    signal goToVideo(string site, variant video)
    signal search(string site, string query, string order)

    function setVideo(videoSite, videoObject) {

        site = videoSite;
        video = videoObject;
        title = video.title;
        duration = video.duration;

        if (site == "youporn") {
            setYouPornVideo();
        }
        else if (site == "pornhub") {
            setPornHubVideo();
        }
        else if (site == "tube8") {
            setTubeEightVideo();
        }
    }

    function setYouPornVideo() {

        toggleBusy(true);
        thumbnail = video.thumbnail;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                var page = request.responseText;
                var s = page.split('">MP4 - For iPhone/iPod')[0];
                var url = s.slice(s.lastIndexOf('http'));
                date = page.split('Date:</span> ')[1].split('<')[0];
                views = page.split('Views:</span> ')[1].split(/\n|\s|\t/)[0];
                request = new XMLHttpRequest();
                request.onreadystatechange = function() {
                    if (request.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                        playerUrl = decodeURIComponent(request.getResponseHeader('location'));

                        toggleBusy(false);
                    }
                }
                request.open("HEAD", url);
                request.send();
            }
        }
        request.open("GET", video.link);
        request.send();
    }

    function setPornHubVideo() {

        toggleBusy(true);
        thumbnail = video.thumbnail;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                var page = request.responseText.replace(/\n|\s{2,}/g, '');
                playerUrl = decodeURIComponent(page.split('"video_url","')[1].split('"')[0]);
                var info = page.split('<div class="video-info">')[1].split('" name="TJVideo1A"')[0];
                views = info.slice(0, info.indexOf(' '))
                date = info.split('>Added: ')[1].split('<')[0];
                tags = info.split('&amp;c=')[1].split('+');

                toggleBusy(false);

            }
        }
        request.open("GET", video.link);
        request.send();
    }

    function setTubeEightVideo() {

        toggleBusy(true);
        thumbnail = video.thumbnail;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                var page = request.responseText;
                playerUrl = page.split('var videourl="')[1].split('"')[0];
                views = page.split('Views: </strong>')[1].split('<')[0];
                date = page.split('Added: </strong>')[1].split('<')[0];
                tags = page.split('&amp;c=')[1].split('"')[0].split('+');

                toggleBusy(false);
            };
        }
        request.open("GET", video.link);
        request.send();
    }

    function setRedTubeVideo() {

        toggleBusy(true);
        thumbnail = video.thumbnail;

        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                var page = request.responseText.replace(/\n\s{2,}/g, "");
                playerUrl = page.split('<source src="')[1].split('"')[0];
                var tagsParts = page.split('<ul class="tags">')[1].split('</ul>')[0].split('</a>');
                var t = [];
                for (var i = 0; i < tagsParts.length; i++) {
                    t.push(tagsParts[i].slice(tagsParts[i].lastIndexOf('>') + 1));
                }
                tags = t;

                toggleBusy(false);
            };
        }
        request.open("GET", video.link);
        request.send();
    }

    Item {
        id: dimmer

        anchors.fill: window

        Rectangle {
            id: frame

            width: Math.floor(window.width / 3.2)
            height: Math.floor(frame.width / (4 / 3))
            anchors { left: dimmer.left; leftMargin: 10; top: dimmer.top; topMargin: 60 }
            color: _BACKGROUND_COLOR
            border.width: 2
            border.color: (cuteTubeTheme == "light") ? "grey" : "white"

            Image {
                id: thumb

                anchors { fill: frame; margins: 2 }
                source: thumbnail
                smooth: true

                Rectangle {
                    id: durationLabel

                    width: Math.floor(thumb.width / 2.5)
                    height: Math.floor(durationLabel.width / 2.5)
                    anchors { bottom: thumb.bottom; right: thumb.right }
                    color: "black"
                    opacity: 0.5

                }

                Text {
                    id: durationText

                    anchors.fill: durationLabel
                    text: duration
                    color: "white"
                    font.pixelSize: _STANDARD_FONT_SIZE
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: Math.floor(thumb.width / 3.5)
                    height: width
                    anchors.centerIn: thumb
                    color: frameMouseArea.pressed ? _ACTIVE_COLOR_LOW : "black"
                    opacity: 0.5
                    radius: 5
                    smooth: true

                    Image {
                        id: playIcon

                        anchors { fill: parent; margins: 5 }
                        smooth: true
                        source: "ui-images/playicon.png"
                        sourceSize.width: playIcon.width
                        sourceSize.height: playIcon.height
                    }
                }
            }

            MouseArea {
                id: frameMouseArea

                anchors.fill: frame
                onClicked: playVideo([{ "title": title,
                                      "thumbnail": video.thumbnail,
                                      "url": playerUrl,
                                      "xtube": true
                                      }])
            }

            PushButton {
                id: videoButton

                width: frame.width
                anchors { left: frame.left; top: frame.bottom; topMargin: 10 }
                icon: (cuteTubeTheme == "light") ? "ui-images/videodownloadiconlight.png" : "ui-images/videodownloadicon.png"
                iconWidth: 65
                iconHeight: 65
                onButtonClicked: addDownload({ "title": title,
                                             "thumbnail": video.thumbnail,
                                             "playerUrl": playerUrl })
            }
        }

        Item {
            id: tabItem

            anchors { fill: dimmer; leftMargin: frame.width + 20; rightMargin: 10; topMargin: 60; bottomMargin: 65 }

            Row {
                id: tabRow

                Item {
                    id: infoTab

                    width: tabItem.width / 2
                    height: 40

                    BorderImage {
                        anchors.fill: infoTab
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 0
                    }

                    Text {
                        anchors.fill: infoTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 0 ? _TEXT_COLOR : "grey"
                        text: qsTr("Info")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: infoTab.bottom; left: infoTab.left; right: infoTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 0)
                    }

                    MouseArea {
                        id: infoMouseArea

                        anchors.fill: infoTab
                        onClicked: tabView.currentIndex = 0
                    }
                }

                Item {
                    id: relatedTab

                    width: tabItem.width / 2
                    height: 40

                    BorderImage {
                        anchors.fill: parent
                        source: (cuteTubeTheme == "nightred") ? "ui-images/tabred.png" : "ui-images/tab.png"
                        smooth: true
                        visible: tabView.currentIndex == 1
                    }

                    Text {
                        anchors.fill: relatedTab
                        font.pixelSize: _STANDARD_FONT_SIZE
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: tabView.currentIndex == 1 ? _TEXT_COLOR : "grey"
                        text: qsTr("Related")
                    }

                    Rectangle {
                        height: 1
                        anchors { bottom: relatedTab.bottom; left: relatedTab.left; right: relatedTab.right }
                        color: _ACTIVE_COLOR_HIGH
                        opacity: 0.5
                        visible: !(tabView.currentIndex == 1)
                    }

                    MouseArea {
                        id: relatedMouseArea

                        anchors.fill: relatedTab
                        onClicked: tabView.currentIndex = 1
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

                onCurrentIndexChanged: {
                    if ((tabView.currentIndex == 1) && (!videoList.loaded) && (videoList.count == 0)) {
                        videoList.loadVideos();
                    }
                }
            }
        }

        VisualItemModel {
            id: tabModel

            Flickable {
                id: scrollArea

                width: tabView.width
                height: tabView.height
                clip: true
                contentWidth: textColumn.width
                contentHeight: textColumn.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.DragOverBounds
                interactive: visibleArea.heightRatio < 1
                opacity: (tabView.currentIndex == 0) ? 1 : 0

                Column {
                    id: textColumn

                    spacing: 10
                    width: tabView.width
                    height: childrenRect.height

                    Text {
                        id: titleText

                        width: textColumn.width
                        text: title
                        color: _TEXT_COLOR
                        font.pixelSize: _STANDARD_FONT_SIZE
                        wrapMode: TextEdit.WordWrap
                    }

                    Text {
                        width: textColumn.width
                        color: _TEXT_COLOR
                        font.pixelSize: _SMALL_FONT_SIZE
                        textFormat: Text.StyledText
                        wrapMode: TextEdit.WordWrap
                        text: qsTr("Uploaded")
                    }

                    Text {
                        width: textColumn.width
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        textFormat: Text.StyledText
                        wrapMode: TextEdit.WordWrap
                        text: date
                    }

                    Text {
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: _TEXT_COLOR
                        text: qsTr("Views")
                    }

                    Text {
                        width: textColumn.width
                        color: "grey"
                        font.pixelSize: _SMALL_FONT_SIZE
                        textFormat: Text.StyledText
                        wrapMode: TextEdit.WordWrap
                        text: views
                    }

                    Text {
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: _TEXT_COLOR
                        text: qsTr("Tags")
                    }

                    Flow {
                        spacing: 10
                        width: parent.width

                        Text {
                            font.pixelSize: _SMALL_FONT_SIZE
                            color: "grey"
                            text: qsTr("No tags")
                            visible: tags.length == 0
                        }

                        Repeater {
                            model: tags

                            Text {
                                font.pixelSize: _SMALL_FONT_SIZE
                                color: children[0].pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                                text: modelData

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: search(site, parent.text, Settings.getSetting("searchOrder").toLowerCase())
                                }

                                Text {
                                    anchors.left: parent.right
                                    font.pixelSize: _SMALL_FONT_SIZE
                                    color: "grey"
                                    text: ","
                                    visible: index < (tags.length - 1)
                                }
                            }
                        }
                    }

                }
            }

            ListView {
                id: videoList

                property bool loaded : false // True if related videos have been loaded
                property bool loading : false // True if related videos are loading.

                function loadVideos() {
                    videoList.loading = true;
                    if (site == "youporn") {
                        Xtube.getYouPornRelatedVideos(video.link);
                    }
                    else if (site == "pornhub") {
                        Xtube.getPornHubRelatedVideos(video.link);
                    }
                    else if (site == "tube8") {
                        Xtube.getTubeEightVideos(video.link);
                    }
                }

                width: tabView.width
                height: tabView.height
                boundsBehavior: Flickable.DragOverBounds
                highlightMoveDuration: 500
                preferredHighlightBegin: 0
                preferredHighlightEnd: 100
                highlightRangeMode: ListView.StrictlyEnforceRange
                cacheBuffer: 2500
                interactive: visibleArea.heightRatio < 1
                clip: true
                opacity: (tabView.currentIndex == 1) ? 1 : 0
                Item {
                    id: footer

                    width: videoList.width
                    height: 100
                    visible: (tabView.currentIndex == 1 && videoList.loading)
                    opacity: footer.visible ? 1 : 0

                    BusyDialog {
                        anchors.centerIn: footer
                        opacity: footer.opacity
                    }
                }

                model: ListModel {
                    id: videoListModel
                }

                delegate: XListDelegate {
                    id: delegate

                    onDelegateClicked: goToVideo(site, videoListModel.get(index))
                    onPlayClicked: {
                        if (site == "youporn") {
                            Xtube.getYouPornUrl(index);
                        }
                        else if (site == "pornhub") {
                            Xtube.getPornHubUrl(index);
                        }
                        else if (site == "tube8") {
                            Xtube.getTubeEightUrl(index);
                        }
                    }
                }

                ScrollBar {}
            }
        }

        states: State {
            name: "dim"
            PropertyChanges { target: dimmer; opacity: 0.3 }
        }

        transitions: Transition {
            PropertyAnimation { properties: "opacity"; duration: 500 }
        }
    }

    states: State {
        name: "portrait"
        when: window.height > window.width
        PropertyChanges { target: frame; width: Math.floor(window.width / 1.9) }
        PropertyChanges { target: tabItem; anchors { leftMargin: 10; rightMargin: 10; topMargin: frame.height + 70 } }
        AnchorChanges { target: videoButton; anchors { left: frame.right; top: frame.top } }
        PropertyChanges { target: videoButton; anchors.leftMargin: 10; anchors.topMargin: 0; width: window.width - (frame.width + 30); }
    }
}

