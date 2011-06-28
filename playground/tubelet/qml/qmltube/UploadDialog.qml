import QtQuick 1.0

Item {
    id: dialog

    property string fileToUpload

    property variant categoryDict

    signal close

    function getCategory() {
        var category = qsTr("Entertainment");
        for (var cat in categoryDict) {
            if (categoryDict[cat] == categoryText.text) {
                category = cat;
            }
        }
        return category;
    }

    function showCategoryList() {
        var list = [];
        for (var category in categoryDict) {
            list.push(categoryDict[category]);
        }
        list.sort();
        dialogLoader.source = "SettingsListDialog.qml";
        dialogLoader.item.setSettingsList(qsTr("Category"), list, categoryText.text);
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
        YouTube.uploadVideo(fileToUpload, title, description, tags, category, isPrivate);
        showUploadProgress(fileToUpload.split("/").pop(), title);
    }

    function showUploadProgress(filename, title) {
        dialogLoader.source = "UploadProgressDialog.qml";
        dialogLoader.item.setDetails(filename, title);
        dialogLoader.item.close.connect(close);
        dialog.state = "showChild";
    }

    function setCategory(category) {
        categoryText.text = category;
    }

    width: parent.width
    anchors { right: parent.left; top: parent.top; bottom: parent.bottom }

    Component.onCompleted: {
        categoryDict = { "Autos": qsTr("Cars & Vehicles"), "Comedy": qsTr("Comedy"),
                "Education": qsTr("Education"), "Entertainment": qsTr("Entertainment"),
                "Film": qsTr("Film & Animation"), "Games": qsTr("Gaming"),
                "Howto": qsTr("Howto & Style"), "Music": qsTr("Music"), "News": qsTr("News & Politics"),
                "Nonprofit": qsTr("Non-profits & Activism"), "People": qsTr("People & Blogs"),
                "Animals": qsTr("Pets & Animals"), "Tech": qsTr("Science & Technology"),
                "Sports": qsTr("Sport"), "Travel": qsTr("Travel & Events") };
    }

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
            interactive: (dialog.width > dialog.height) && (Controller.isSymbian)

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
