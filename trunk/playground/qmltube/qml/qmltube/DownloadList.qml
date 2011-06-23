import QtQuick 1.0

ListView {
    id: downloadList

    property variant checkList : []

    function indexInCheckList(index) {
        var result = false;
        for (var i = 0; i < downloadList.checkList.length; i ++) {
            if (downloadList.checkList[i] == index) {
                result = true;
            }
        }
        return result;
    }

    Component.onCompleted: positionViewAtIndex(downloadList.count - 1, ListView.End)


    height: downloadList.count * 100
    boundsBehavior: Flickable.DragOverBounds
    highlightMoveDuration: 500
    preferredHighlightBegin: downloadList.height - 100
    preferredHighlightEnd: downloadList.height
    highlightRangeMode: ListView.StrictlyEnforceRange
    cacheBuffer: 2500
    interactive: (downloadList.height) > (downloadList.parent.height - 10)

    model: downloadModel

    delegate: DownloadListDelegate {
        id: delegate

        function addToOrRemoveFromCheckList() {
            var cl = downloadList.checkList;
            if (!delegate.checked) {
                cl.push(index);
            }
            else {
                for (var i = 0; i < cl.length; i++) {
                    if (cl[i] == index) {
                        cl.splice(i, 1);
                    }
                }
            }
            downloadList.checkList = cl;
        }

        onDelegateClicked: addToOrRemoveFromCheckList()

        checked: downloadList.indexInCheckList(index)
    }

    ScrollBar {}
}

