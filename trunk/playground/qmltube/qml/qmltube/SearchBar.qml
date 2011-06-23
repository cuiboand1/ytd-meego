import QtQuick 1.0
import "scripts/settings.js" as Settings

Item {
    id: searchItem

    property alias searchText : searchInput.text
    property string searchOrder

    signal search(string query, string order)
    signal video(variant video)

    Component.onCompleted: getSearches()

    function getVideo(id) {
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

    function parseSearchQuery() {

        var query = searchInput.text;
        var pattern = /youtu.be|watch\?v=/; // Check if user entered a direct link to a video
        if (pattern.test(query)) {
            var videoId = query.split("&")[0].slice(-11); // Extract videoId from link
            getVideo(videoId);
        }
        else {
            search(query, searchItem.searchOrder);
            Settings.setSetting("searchOrder", searchItem.searchOrder);
            Settings.addSearchTerm(query);

        }
    }

    function getSearches() {
        /* Retreive the searches from the database and
          populate the model */

        searchItem.searchOrder = Settings.getSetting("searchOrder");
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
            anchors { top: searchBar.top; topMargin: 55; right: searchBar.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: _STANDARD_FONT_SIZE
            smooth: true
            text: qsTr("Order by:")

            Text {
                anchors { left: parent.right; leftMargin: 10 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: _STANDARD_FONT_SIZE
                color: orderMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                smooth: true
                text: _ORDER_BY_DICT[searchItem.searchOrder]
            }
        }

        MouseArea {
            id: orderMouseArea

            width: searchBar.width
            height: 45
            anchors { top: searchBar.top; topMargin: 55; horizontalCenter: searchBar.horizontalCenter }
            onClicked: changeSearchOrder()
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
                        search(searchterm, searchItem.searchOrder);
                        Settings.setSetting("searchOrder", searchItem.searchOrder);
                        Settings.addSearchTerm(searchterm);
                    }
                }
            }

            ScrollBar {}
        }
    }
}
