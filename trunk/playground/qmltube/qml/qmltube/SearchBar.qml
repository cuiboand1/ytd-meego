import QtQuick 1.0
import "scripts/settings.js" as Settings
import "scripts/OAuth.js" as OAuth

Item {
    id: searchItem

    property alias searchText : searchInput.text
    property string searchOrder
    property string site : "YouTube"

    signal search(string query, string order, string site)
    signal video(variant video)
    signal dmVideo(variant video)
    signal vimeoVideo(variant video)

    Component.onCompleted: getSearches()

    function getYouTubeVideo(id) {
        /* Get video data */

        var videoObject = {};
        videoObject["videoId"] = id;
        videoObject["description"] = "";
        videoObject["likes"] = "";
        videoObject["dislikes"] = "";
        var node;
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                var doc = request.responseXML.documentElement;
                for (var i = 0; i < doc.childNodes.length; i++) {
                    if (doc.childNodes[i].nodeName == "comments") {
                        videoObject["comments"] = doc.childNodes[i].childNodes[0].attributes[1].value;
                    }
                    else if (doc.childNodes[i].nodeName == "group") {
                        for (var ii = 0; ii < doc.childNodes[i].childNodes.length; ii++) {
                            node = doc.childNodes[i].childNodes[ii];
                            if (node.nodeName == "credit") {
                                videoObject["author"] = node.firstChild.nodeValue;
                            }
                            else if (node.nodeName == "description") {
                                if (node.firstChild != undefined) {
                                    videoObject["description"] = node.firstChild.nodeValue;
                                }
                            }
                            else if (node.nodeName == "keywords") {
                                if (node.firstChild != undefined) {
                                    videoObject["tags"] = node.firstChild.nodeValue;
                                }
                            }
                            else if (node.nodeName == "player") {
                                videoObject["playerUrl"] = node.attributes[0].value;
                            }
                            else if (node.nodeName == "thumbnail") {
                                var value = node.attributes[0].value;
                                var patt = value.split("/")[5];
                                if (patt == "default.jpg") {
                                    videoObject["thumbnail"] = value;
                                }
                                else if (patt == "hqdefault.jpg") {
                                    videoObject["largeThumbnail"] = value;
                                }
                            }
                            else if (node.nodeName == "title") {
                                videoObject["title"] = node.firstChild.nodeValue;
                            }
                            else if (node.nodeName == "duration") {
                                videoObject["duration"] = node.attributes[0].value;
                            }
                            else if (node.nodeName == "uploaded") {
                                videoObject["uploadDate"] = node.firstChild.nodeValue.split("T")[0];
                            }
                        }
                    }
                    else if (doc.childNodes[i].nodeName == "statistics") {
                        videoObject["views"] = doc.childNodes[i].attributes[1].value;
                    }
                    else if (doc.childNodes[i].nodeName == "rating") {
                        if (doc.childNodes[i].attributes[0].name == "numDislikes") {
                            if (doc.childNodes[i].attributes[1].value != undefined) {
                                videoObject["likes"] = doc.childNodes[i].attributes[1].value;
                            }
                            if (doc.childNodes[i].attributes[1].value != undefined) {
                                videoObject["dislikes"] = doc.childNodes[i].attributes[0].value;
                            }
                        }
                    }
                }
                video(videoObject);
            }
        }
        request.open("GET", "http://gdata.youtube.com/feeds/api/videos/" + id + "?v=2");
        request.send();
    }

    function getDailymotionVideo(id) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var res = eval("(" + doc.responseText + ")");

                dmVideo({ "playerUrl": "http://iphone.dailymotion.com/video/" + res.id, "id": res.id, "title": res.title,
                        "description": res.description, "author": res.owner, "rating": res.rating,
                        "views": res.views_total, "duration": res.duration, "tags": res.tags.toString(),
                        "thumbnail": res.thumbnail_medium_url,
                        "largeThumbnail": res.thumbnail_large_url, "dailymotion": true });
            }
        }
        doc.open("GET", "https://api.dailymotion.com/video/" + id + "&fields=" + _DM_FIELDS);
        doc.send();
    }

    function getVimeoVideo(id) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var res = eval("(" + doc.responseText + ")").video[0];
//                            console.log(doc.responseText)

                var tags = "";
                for (var i = 0; i < res.tags.tag.length; i++) {
                    tags += res.tags.tag[i]._content + ", ";
                }
                vimeoVideo({ "playerUrl": res.urls.url[0]._content,
                           "id": res.id, "title": res.title,
                           "description": res.description, "author": res.owner.display_name,
                           "authorId": res.owner.id, "uploadDate": res.upload_date, "likes": res.number_of_likes,
                           "views": res.number_of_plays, "comments": res.number_of_comments,
                           "duration": res.duration, "tags": tags, "thumbnail": res.thumbnails.thumbnail[1]._content,
                           "largeThumbnail": res.thumbnails.thumbnail[2]._content, "vimeo": true });

                if (res.urls.url.length < 2) {
                    messages.displayMessage(qsTr("This video cannot be played or downloaded"));
                }
            }
        }
        var params = [["format", "json"], ["method", "vimeo.videos.getInfo"], ["video_id", id]];
        var oauthData = OAuth.createOAuthHeader("GET", "http://vimeo.com/api/rest/v2/", undefined, undefined, params);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    function parseSearchQuery() {

        var query = searchInput.text;
        var youtube = /youtu.be|watch\?v=/; // Check if user entered a direct link to a video
        var dailymotion = /dailymotion.com\/video/;
        var vimeo = /vimeo.com/;
        if (youtube.test(query)) {
            var videoId = query.split("&")[0].slice(-11); // Extract videoId from link
            getYouTubeVideo(videoId);
        }
        else if (dailymotion.test(query)) {
            var videoId = query.split("/").pop().split("_")[0];
            getDailymotionVideo(videoId);
        }
        else if (vimeo.test(query)) {
            var videoId = query.split("/").pop().split("_")[0];
            getVimeoVideo(videoId);
        }
        else {
            search(query, searchItem.searchOrder, searchItem.site);
            Settings.setSetting("searchOrder", searchItem.searchOrder);
            Settings.setSetting("searchSite", searchItem.site);
            Settings.addSearchTerm(query);

        }
    }

    function getSearches() {
        /* Retreive the searches from the database and
          populate the model */

        searchItem.searchOrder = Settings.getSetting("searchOrder");
        searchItem.site = Settings.getSetting("searchSite");
        var searches = Settings.getSearches();
        for (var i = 0; i < searches.length; i++) {
            searchModel.insert(0, { "searchterm": searches[i] });
        }
    }

    function changeSearchOrder() {
        if (searchItem.searchOrder == "published") {
            searchItem.searchOrder = "relevance";
        }
        else if (searchItem.searchOrder == "relevance") {
            searchItem.searchOrder = "viewCount";
        }
        else if (searchItem.searchOrder == "viewCount") {
            searchItem.searchOrder = "rating";
        }
        else if (searchItem.searchOrder == "rating") {
            searchItem.searchOrder = "published";
        }
    }

    height: searchList.count == 0 ? 95 : ((Controller.isSymbian) && (searchList.count > 4)) ? 255 : searchList.count > 6 ? 320 : 95 + searchList.count * 40
    focus: true

    Behavior on height { PropertyAnimation { properties: "height"; easing.type: Easing.OutQuart; duration: 500 } }

    Rectangle {
        id: searchBar

        anchors.fill: searchItem
        color:  "white"
        border.width: 2
        border.color: _ACTIVE_COLOR_LOW
        radius: 5
        smooth: true

        TextInput {
            id: searchInput

            height: 43
            anchors { top: searchBar.top; left: searchBar.left; right: searchBar.right; margins: 2 }
            font.pixelSize: _STANDARD_FONT_SIZE
            selectByMouse: true
            selectionColor: _ACTIVE_COLOR_LOW
            smooth: true
            focus: true
            Keys.onEnterPressed: {
                if (searchInput.text != "") {
                    parseSearchQuery();
                }
            }
            Keys.onReturnPressed: {
                if (searchInput.text != "") {
                    parseSearchQuery();
                }
            }

            Rectangle {
                height: 1
                anchors { top: searchInput.bottom; left: searchInput.left; leftMargin: 12; right: searchInput.right; rightMargin: 12 }
                color: _ACTIVE_COLOR_HIGH
                opacity: 0.5
            }
        }

        Text {
            anchors { top: searchBar.top; topMargin: 55; left: searchBar.left; leftMargin: 10 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: _STANDARD_FONT_SIZE
            smooth: true
            text: qsTr("Site:")

            Text {
                anchors { left: parent.right; leftMargin: 10 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: _STANDARD_FONT_SIZE
                color: siteMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                smooth: true
                text: searchItem.site

                MouseArea {
                    id: siteMouseArea

                    anchors.fill: parent
                    onClicked: {
                        if (searchItem.site == "YouTube") {
                            searchItem.site = "Dailymotion";
                        }
                        else if (searchItem.site == "Dailymotion") {
                            searchItem.site = "vimeo";
                        }
                        else {
                            searchItem.site = "YouTube";
                        }
                    }
                }
            }
        }

        Text {
            anchors { top: searchBar.top; topMargin: 55; right: searchBar.right; rightMargin: 10 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: _STANDARD_FONT_SIZE
            color: orderMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
            smooth: true
            text: _ORDER_BY_DICT[searchItem.searchOrder]

            Text {
                anchors { right: parent.left; rightMargin: 10 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: _STANDARD_FONT_SIZE
                smooth: true
                text: qsTr("Order:")
            }

            MouseArea {
                id: orderMouseArea

                width: Math.floor(searchBar.width / 2)
                height: 45
                anchors.fill: parent
                onClicked: changeSearchOrder()
            }
        }

        ListView {
            id: searchList

            anchors { fill: searchBar; topMargin: 90; leftMargin: 4; rightMargin: 4; bottomMargin: 10 }
            clip: true
            snapMode: ListView.SnapToItem
            visible: !(searchList.count == 0)

            model: ListModel {
                id: searchModel
            }

            delegate: SearchDelegate {
                id: delegate

                Connections {
                    onDelegateClicked: {
                        search(searchterm, searchItem.searchOrder, searchItem.site);
                        Settings.setSetting("searchOrder", searchItem.searchOrder);
                        Settings.setSetting("searchSite", searchItem.site)
                        Settings.addSearchTerm(searchterm);
                    }
                }
            }

            ScrollBar {}
        }
    }
}
