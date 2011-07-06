/* Video list functions */

function addVideosToDownloads(convertToAudio) {
    var video;
    for (var i = 0; i < videoList.checkList.length; i++) {
        video = videoListModel.get(videoList.checkList[i]);
        if (convertToAudio) {
            addAudioDownload(video);
        }
        else {
            addDownload(video);
        }
    }
    videoList.checkList = [];
}

function copyVideosToClipboard() {
    var urls = "";
    var url;
    for (var i = 0; i < videoList.checkList.length; i++) {
        url = videoListModel.get(videoList.checkList[i]).playerUrl.split("&")[0];
        urls = urls + url + "\n";
    }
    Controller.copyToClipboard(urls);
    videoList.checkList = [];
}

function closeDialogs() {
    /* Close any open dialogs and return the window to its default state */

    dialogClose();
    dimmer.state = "";
    toggleControls(true);
}

function indexInCheckList(index) {
    var result = false;
    for (var i = 0; i < videoList.checkList.length; i ++) {
        if (videoList.checkList[i] == index) {
            result = true;
        }
    }
    return result;
}

function showOrHideFilter() {
    if (listFilter.source == "") {
        if ((event.key != Qt.Key_Left)
                && (event.key != Qt.Key_Right)
                && (event.key != Qt.Key_Up)
                && (event.key != Qt.Key_Down)
                && (event.key != Qt.Key_Control)
                && (event.key != Qt.Key_Shift)
                && (event.key != Qt.Key_Enter)
                && (event.key != Qt.Key_Return)
                && (event.key != Qt.Key_Backspace)) {
            listFilter.source = "ListFilter.qml";
            listFilter.item.filterString = event.text;
        }
    }
}
