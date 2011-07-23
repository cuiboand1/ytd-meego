import QtQuick 1.0

Item {
    id: dialog

    property string fileToUpload
    property string site : "YouTube"
    property variant sites : ["YouTube", "Dailymotion"]

    signal close

    function getCategory() {
        if (site == "YouTube") {
	    for (var c in _CATEGORY_DICT) {
		var category = _CATEGORY_DICT[c];
		if ((!isSpecialCategory(category)) && (category.name == categoryText.text)) {
		    console.log("Debug: getCategory() category.youtube == " + category.youtube);
		    return (category.youtube);
		}
	    }
	}
	else if (site == "Dailymotion") {
	    for (var c in _CATEGORY_DICT) {
		var category = _CATEGORY_DICT[c];
		if ((!isSpecialCategory(category)) && (category.name == categoryText.text)) {
		    console.log("Debug: getCategory() category.dailymotion == " + category.dailymotion);
		    return (category.dailymotion);
		}
	    }
	}
    }

    function showCategoryList() {
        var list = [];
        for (var c in _CATEGORY_DICT) {
            var category = _CATEGORY_DICT[c];
            if (!isSpecialCategory(category)) { //NPM: was "(!(((category.youtube == "MostRecent") || (category.youtube == "MostViewed")) || ((site == "YouTube") && (category.youtube == "none")) || ((site == "Dailymotion") && (category.dailymotion == "none"))))"
                list.push(category.name);
            }
        }
        list.sort();
        dialogLoader.source = "SettingsListDialog.qml";
        dialogLoader.item.setSettingsList(qsTr("Category"), list, categoryText.text);
        dialogLoader.item.settingChosen.disconnect();
        dialogLoader.item.settingChosen.connect(setCategory);
        dialog.state = "showChild";
    }

    function showFileChooser() {
        dialogLoader.source = "FileChooserDialog.qml";
        dialogLoader.item.fileChosen.connect(setFilename);
        dialog.state = "showChild";
    }

    function setFilename(filepath) {
        if (Controller.isSymbian) {
            fileToUpload = filepath.substr(8);
        }
        else {
            fileToUpload = filepath.substr(7);
        }
        filenameText.text = filepath.split("/").pop();
    }

    function startUpload() {
        var title = titleInput.text;
        var description = descriptionInput.text;
        var tags = tagInput.text;
        var category = getCategory();
        var isPrivate = checkbox.checked;
	// NPM: note qmltube 1.06 disabled visibility of checkbox, instead of fixing
	// YouTube.uploadVideo() existing private uploading code that doesn't result in
	// a private upload. Therefore, 'isPrivate' is always false.
        // console.log("Debug: in startUpload() checkbox.checked == " + checkbox.checked);
        var video = { "filename": fileToUpload.split("/").pop(), "title": title, "description": description, "tags": tags, "category": category, "isPrivate": isPrivate };
        if (site == "YouTube") {
            YouTube.uploadVideo(fileToUpload, title, description, tags, category, isPrivate);
        }
        else if (site == "Dailymotion") {
            DailyMotion.uploadVideo(fileToUpload);
        }
        showUploadProgress(video, site);
    }

    function showUploadProgress(video, site) {
        dialogLoader.source = "UploadProgressDialog.qml";
        dialogLoader.item.setDetails(video, site);
        dialogLoader.item.close.connect(close);
        dialog.state = "showChild";
    }

    function setCategory(category) {
        categoryText.text = category;
    }

    function showSiteList() {
        dialogLoader.source = "SettingsListDialog.qml";
        dialogLoader.item.setSettingsList(qsTr("Choose Site"), sites, site);
        dialogLoader.item.settingChosen.disconnect();
        dialogLoader.item.settingChosen.connect(setSite);
        dialog.state = "showChild";
    }

    function setSite(siteName) {
        site = siteName;
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Connections {
        target: dialog.parent

        onDialogClose: {
            dialog.state = "";
            dialog.destroy(600);
        }
    }

    Loader {
        id: dialogLoader

        width: parent.width
        anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

        Connections {
            target: dialogLoader.item
            onClose: dialog.state = "show"
        }
    }

    Item {
        id: background

        anchors.fill: dialog

        Rectangle {
            anchors.fill: background
            color: _BACKGROUND_COLOR
            opacity: 0.5
            smooth: true
        }

        Text {
            id: title

            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10 }
            font.pixelSize: _SMALL_FONT_SIZE
            color: _TEXT_COLOR
            text: qsTr("Upload Video")
        }

        Flickable {
            id: flicker

            anchors { fill: background; topMargin: 50; leftMargin: 6; rightMargin: (dialog.width > dialog.height) ? 176 : 6; bottomMargin: (dialog.width > dialog.height) ? 8 : 100 }
            contentWidth: flicker.width
            contentHeight: column.height + 35
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragOverBounds
            interactive: (dialog.width > dialog.height)

            Column {
                id: column

                width: flicker.width - 4
                anchors { top: parent.top; left: parent.left; leftMargin: 2 }
                spacing: 10

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("File")
                }

                Text {
                    id: filenameText

                    width: column.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: _STANDARD_FONT_SIZE
                    color: fileMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                    text: qsTr("None chosen")
                    smooth: true
                    onTextChanged: {
                        if (!(filenameText.text == qsTr("None chosen"))) {
                            titleInput.text = filenameText.text.slice(0, filenameText.text.lastIndexOf('.'));
                        }
                    }

                    MouseArea {
                        id: fileMouseArea

                        anchors.fill: parent
                        onClicked: showFileChooser()
                    }
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Site")
                }

                Text {
                    id: siteText

                    width: column.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: _STANDARD_FONT_SIZE
                    color: siteMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                    text: site
                    smooth: true

                    MouseArea {
                        id: siteMouseArea

                        anchors.fill: parent
                        onClicked: showSiteList()
                    }
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Title")
                }

                LineEdit {
                    id: titleInput

                    width: column.width
                    focus: true
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Description (optional)")
                }

                LineEdit {
                    id: descriptionInput

                    width: column.width
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Tags (seperated by commas)")
                }

                LineEdit {
                    id: tagInput

                    width: column.width

                    Text {

                        anchors { top: parent.bottom; topMargin: 10; right: parent.right; rightMargin: 60 }
                        font.pixelSize: _SMALL_FONT_SIZE
                        color: "grey"
                        text: qsTr("Private?")
                        visible: false

                        CheckBox {
                            id: checkbox
                            checked: false

                            anchors { left: parent.right; leftMargin: 10 }
                        }
                    }
                }

                Text {
                    font.pixelSize: _SMALL_FONT_SIZE
                    color: "grey"
                    text: qsTr("Category")

                    Text {
                        id: categoryText

                        anchors { top: parent.bottom; topMargin: 5 }
                        font.pixelSize: _STANDARD_FONT_SIZE
                        color: categoryMouseArea.pressed ? _ACTIVE_COLOR_HIGH : _ACTIVE_COLOR_LOW
                        text: qsTr("None chosen")
                        smooth: true

                        MouseArea {
                            id: categoryMouseArea

                            width: categoryText.width
                            height: 40
                            anchors.centerIn: parent
                            onClicked: showCategoryList()
                        }
                    }
                }
            }
        }

        PushButton {
            id: saveButton

            width: (dialog.width > dialog.height) ? 150 : dialog.width - 20
            anchors { right: background.right; bottom: background.bottom; margins: 10 }
            icon: (cuteTubeTheme == "light") ? "ui-images/ticklight.png" : "ui-images/tick.png"
            onButtonClicked: {
                if ((fileToUpload != "") && (titleInput.text != "")) {
                    startUpload();
                }
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

    states: [
        State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        },

        State {
            name: "showChild"
            AnchorChanges { target: dialog; anchors { left: parent.right; right: undefined } }
        }
    ]

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
