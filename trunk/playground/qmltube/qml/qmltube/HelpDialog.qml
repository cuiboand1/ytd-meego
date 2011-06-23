import QtQuick 1.0

Item {
    id: dialog

    signal close

    anchors.fill: parent

    Rectangle {
        id: background

        anchors.fill: dialog
        color: _BACKGROUND_COLOR
        opacity: 0.5
    }

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        font.pixelSize: _SMALL_FONT_SIZE
        color: _TEXT_COLOR
        text: qsTr("Hint And Tips")
    }

    Flickable {
        id: flicker

        anchors { fill: dialog; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 8 }
        contentWidth: helpColumn.width
        contentHeight: helpColumn.height + 2
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.DragOverBounds

        Column {
            id: helpColumn

            width: flicker.width
            anchors { top: parent.top; left: parent.left; leftMargin: 2 }
            spacing: 10

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                color: _TEXT_COLOR
                text: qsTr("Playback")
                smooth: true
            }

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                wrapMode: Text.WordWrap
                width: helpColumn.width
                clip: true
                color: "grey"
                textFormat: Text.RichText
                text: qsTr(
                          "Playback is possible via any one of four the available media players, Media Player, cuteTube Player, KMPlayer and MPlayer (KMPlayer and MPlayer require seperate installation). " +
                          "Playback with cuteTube Player provides these additional features:<br><ul>" +
                          "<li>Playback of entire YouTube playlists (Tap the 'Play All' button in a playlist or show the playlist dialog via a long-press on a playlist).</li><br>" +
                          "<li>Playback of multiple videos selected from any video list. (Select videos via a long-press, then tap the 'play' menu icon).</li><br>" +
                          "<li>Rate and favourite videos, and add them to your download queue during playback.</li><br>" +
                          "<li>View videos in 'info' mode, where you can view/add comments.</li></ul><br>" +
                          "When using cuteTubePlayer, 'info' mode is chosen automatically for playback of audio downloads, otherwise you can choose it via tapping the video screen then tapping the 'i' button."
                          )
            }

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                color: _TEXT_COLOR
                text: qsTr("Downloads")
                smooth: true
            }

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                wrapMode: Text.WordWrap
                width: helpColumn.width
                clip: true
                color: "grey"
                textFormat: Text.RichText
                text: qsTr(
                          "You can add a video to your download queue by either:<br><ul>" +
                          "<li>Clicking one of the download buttons in the Video Info view.</li><br>" +
                          "<li>Selecting multiple videos (via a long-press) from a list and tapping the 'download'' menu icon.</li><br>" +
                          "<li>Choosing to download an entire playlist.</li></ul><br>" +
                          "By default, downloads will be added to the queue in 'paused' status, but you can choose to have them begin automatically. " +
                          "Once a download is added to the queue, you can check on its progress by tapping the top bar, and you will be notified once a download is completed. " +
                          "Completed downloads are automatically removed from the download queue and added to your archive, which can be viewed by clicking the 'Archive' button in the main screen."
                          )
                smooth: true
            }            

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                color: _TEXT_COLOR
                text: qsTr("Settings")
                smooth: true
            }

            Text {
                font.pixelSize: _SMALL_FONT_SIZE
                wrapMode: Text.WordWrap
                width: helpColumn.width
                clip: true
                color: "grey"
                textFormat: Text.RichText
                text: qsTr(
                          "Most of the settings in cuteTube are self-explanatory, but here are some tips:<br><ul>" +
                          "<li><font color='white'>Network proxy:</font> Adding a proxy enables all requests to be sent via a proxy server. To add a proxy server, enter the host address and port, in the text boxes. " +
                          "After saving the new settings, you must restart cuteTube to allow the proxy settings to take effect.</li><br>" +
                          "<li><font color='white'>Start downloads:</font> Choose whether downloads are started automatically or manually (default). See the 'downloads' section above for more information on downloads.<br>" +
                          "<li><font color='white'>Media player:</font> Choose which media player you would like to use for playback. The default is to use the stock media player.</li><br>" +
                          "<li><font color='white'>Playback quality:</font> Choose between 'mobile' and 'high quality' (current maximum resolution of 640 x 360) YouTube streams.</li><br>" +
                          "<li><font color='white'>Download quality:</font> Choose between 'mobile', 'high quality', 360p, 480p and 720p YouTube streams." +
                          "<font color='red'> Only videos saved as audio, 'mobile' or 'high quality' can be played on the device</font>.</li><br>" +
                          "<li><font color='white'>YouTube categories:</font> Choose any two of the available categories to appear on the main screen (defaults are 'Most Recent' and 'Most Viewed'). You can also choose how to order the results.</li><br>" +
                          "<li><font color='white'>Safe search:</font> If enabled, YouTube results will be filtered to remove potentially unsuitable content (default is 'off').</li><br>" +
                          "<li><font color='white'>Clear saved searches:</font> Clears the searches that appear when displaying the search bar.</li><br>" +
                          "<li><font color='white'>Delete facebook token:</font> Deletes your facebook access token. To revoke access to your facebook account, you must change the settings in your facebook account via the website.</li><br>" +
                          "<li><font color='white'>Theme:</font> Choose from the four available themes.</li><br>" +
                          "<li><font color='white'>Language:</font> Choose from the available languages. After saving the new settings, cuteTube must be restarted to enable your choice of language.</li><br>" +
                          "<li><font color='white'>Download location:</font> Choose where you would like your downloaded videos to be saved (default is /home/user/MyDocs/.cutetube).</li><br>" +
                          "<li><font color='white'>Screen orientation:</font> Choose between automatic rotation (default), or forced landscape/portrait orientation.</li><br>" +
                          "<li><font color='white'>Widget:</font> Choose which video feeds you would like to be able to access via the widget." +
                          "The widget can be installed seperately (package name is qmltube-widget), and is displayed by selecting it from the list in the same way as any other homescreen widget.</li></ul>"
                          )
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

    states: State {
            name: "show"
            AnchorChanges { target: dialog; anchors.right: parent.right }
        }

    transitions: Transition {
        AnchorAnimation { easing.type: Easing.OutQuart; duration: 500 }
    }
}
