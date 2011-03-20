/****************************************************************************
** Copyright (C) 2011 Niels Mayer (nielsmayer.com)
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
****************************************************************************/
//import Qt 4.7    //"old form" ??
import QtQuick 1.0 //"new form" for Qt 4.7.1 per http://doc.qt.nokia.com/latest/qtquick-whatsnew.html

/*QtMobility's MultimediaKit is needed only for "Video" element below,
which requires a hack like 'youtube-dl' to extract and download... not 
clear how to stream from youtube directly, punting, and using flash in
webkit */
//import QtMultimediaKit 1.2 

import QtWebKit 1.0 //'video'==instance of WebView below for display of youtube video

import "jsoncontent"
import "ytjson.js" as YTJSON
import "jsoncontent/script.js" as Script

Rectangle { id: window; width: 1440; height: 480;
    
    // window.currentFeed: set to selected Feed category by MouseArea in
    // CategoryDelegate of "categories" ListView.
    property string	currentFeed:	"top_rated";
    // window.loading: Used by YTJSON.showFeed() to turn on/off
    // BusyIndicator, in CategoryDelegate of "categories" ListView.
    property bool	loading:	true; 

    JsonFeeds { id: jsonFeeds }

    // JSON Model should be built-in but following hack is required,
    // see http://bugreports.qt.nokia.com/browse/QTBUG-1211
    // http://mobilephonedevelopment.com/qt-qml-tips/#Consuming%20JSON%20Data
    ListModel {			// http://doc.qt.nokia.com/4.7-snapshot/qml-listmodel.html
	id: jsonModel;
	signal loadCompleted();

	Component.onCompleted: { // http://doc.qt.nokia.com/latest/qml-component.html
	    YTJSON.showFeed(window.currentFeed);
	    jsonModel.loadCompleted();
	}
    }

    Row {
        Rectangle {
            width: 180; height: window.height
            color: "#efefef"

            ListView {
                focus: true;
                id: categories;
                anchors.fill: parent;
                model: jsonFeeds;
                footer: quitButtonDelegate;
                delegate: CategoryDelegate {}
                highlight: Rectangle { color: "steelblue" }
                highlightMoveSpeed: 9999999;
            }
            ScrollBar {
                scrollArea: categories;
		height: categories.height;
		width: 8
                anchors.right:
		categories.right
            }
        }
//	Video {
//	    id: video
//		width : 640
//		height : 480
//		source: "/home/npm/Download/CaptainBeefheartDocumentary-2of4.flv"
//
//		MouseArea {
//		anchors.fill: parent
//		    onClicked: {
//		    video.play()
//			}
//	    }
//
//	    focus: true
//		Keys.onSpacePressed: video.paused = !video.paused
//		Keys.onLeftPressed: video.position -= 5000
//		Keys.onRightPressed: video.position += 5000
//		}
	WebView {
	    id: video;
	    url: "";
	    width: 640;
	    height: 480;
        scale: 1.0;
	    settings.privateBrowsingEnabled: true;
	    settings.autoLoadImages: true;
	    settings.javascriptEnabled: true;
	    settings.javaEnabled: false;
	    settings.pluginsEnabled: true;
	    settings.javascriptCanOpenWindows: false;
	    settings.javascriptCanAccessClipboard: false;
	    onLoadFinished: Script.webPageLoaded();
	    onAlert: function (msg) { console.log("WebView alert() signal: " + msg); }
	}
        ListView {
            id: list;
            width: window.width - 820; height: window.height;
            model: jsonModel;
            delegate: NewsDelegate {}
        }
    }
    Component {
        id: quitButtonDelegate
        Item {
            width: categories.width; height: 60
            Text {
                text:		"Quit"
                font { family: "Helvetica"; pixelSize: 16; bold: true }
                anchors {
                    left:	parent.left;
		    leftMargin:	15;
                    verticalCenter: parent.verticalCenter;
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }
    }
    ScrollBar { scrollArea: list; height: list.height; width: 8; anchors.right: window.right }
    Rectangle { x: 180; height: window.height; width: 1; color: "#cccccc" }
}
