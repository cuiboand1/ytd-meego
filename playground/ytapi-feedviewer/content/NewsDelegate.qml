/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial Usage
** Licensees holding valid Qt Commercial licenses may use this file in
** accordance with the Qt Commercial License Agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Nokia.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.0

Item {
    id:		delegate;
    width:	delegate.ListView.view.width;
    height:	delegate.ListView.view.height/2;

        Image {
	    id:		thumbnailImage;
	    source:	thumbnail;
//	    smooth:	true;   
            fillMode:	Image.PreserveAspectFit;
	    anchors.top:	parent.top;
	    anchors.topMargin:	5;
	    anchors.left:	parent.left;
	    anchors.leftMargin: 5;
	    anchors.right:	parent.horizontalCenter;
        }
        Text {
            id:		durationText;
	    text:	" Duration: " + duration + " s.";
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
	    anchors.top:	thumbnailImage.top;
	    anchors.left:	parent.horizontalCenter;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
        }
        Text {
            id:		numLikesText;
	    text: " Likes: " + numLikes + " people."
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
	    anchors.top:	durationText.bottom;
	    anchors.left:	parent.horizontalCenter;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
        }
        Text {
            id:		authorText;
	    text:	" Posted By: " + author;
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
	    anchors.top:	numLikesText.bottom;
	    anchors.left:	parent.horizontalCenter;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
        }
        Text {
            id:		 publishedText;
	    text:	 " Published: " + published;
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
	    anchors.top:	authorText.bottom;
	    anchors.left:	parent.horizontalCenter;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
        }
        Text {
            id:		titleText;
            text:	title;
	    clip:	false;
	    wrapMode:   Text.WordWrap
            font { bold: true; family: "Helvetica"; pointSize: 16 }
	    anchors.top:	thumbnailImage.bottom;
	    anchors.left:	parent.left;
	    anchors.leftMargin: 5;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
        }
        Text {
            id:		descriptionText;
	    text:	description;
	    textFormat: Text.AutoText;
	    clip:	true;
	    elide:	Text.ElideRight;
	    wrapMode:   Text.WordWrap
            font { family:"Helvetica"; }
	    anchors.top:	titleText.bottom;
	    anchors.left:	parent.left;
	    anchors.leftMargin: 5;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 5;
	    anchors.bottom:	parent.bottom;
	    anchors.bottomMargin: 2;
        }
	Rectangle {
	    color:		"#cccccc";
	    anchors.top:	descriptionText.bottom;
	    anchors.left:	parent.left;
	    anchors.leftMargin: 1;
	    anchors.right:	parent.right;
	    anchors.rightMargin: 1;
	    anchors.bottom:	parent.bottom;
	    anchors.bottomMargin: 0;
    }

// to play the video file in external player, use Qt.openUrlExternally(mediafile)
// however, 'link' is itself a feed e.g.
// http://gdata.youtube.com/feeds/api/standardfeeds/us/top_rated/v/dMH0bHeiRNg?v=2
// within this feed is the link to the URL to display in a browser, e.g.
//   <link rel='alternate' type='text/html' href='http://www.youtube.com/watch?v=dMH0bHeiRNg&amp;feature=youtube_gdata'/>
// as well as other formats, e.g.:
//   <media:content url='http://www.youtube.com/v/dMH0bHeiRNg?f=standard&amp;app=youtube_gdata' type='application/x-shockwave-flash' medium='video' isDefault='true' expression='full' duration='360' yt:format='5'/>
//   <media:content url='rtsp://v5.cache7.c.youtube.com/CiQLENy73wIaGwnYRKJ3bPTBdBMYDSANFEgGUghzdGFuZGFyZAw=/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='360' yt:format='1'/><media:content url='rtsp://v3.cache8.c.youtube.com/CiQLENy73wIaGwnYRKJ3bPTBdBMYESARFEgGUghzdGFuZGFyZAw=/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='360' yt:format='6'/>
// Need to choose correct one and pass on to Qt.openUrlExternally().
//
// Perhaps initially, have single click render HTML URL containing flash or
// HTML5 YT webpage, and have long click render in media player.
    MouseArea {
        anchors.fill:	parent;
        onClicked:	{ //NPM-TODO: consolidate with onPressAndHold: code below....
	    console.log("onClicked: -------------" + link + "-------------");
	    var doc = new XMLHttpRequest();
	    doc.onreadystatechange = function() {
		if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
		    console.log("onClicked: HEADERS_RECEIVED");
		} else if (doc.readyState == XMLHttpRequest.DONE
			   && (doc.responseXML != null)) {
		    var a = doc.responseXML.documentElement;
		    var externalViewerCalled = false;
		    if ((a != null) && a.childNodes != null) {
			for (var i = 0; i < a.childNodes.length; ++i) {
			    if (a.childNodes[i].attributes != null) {
				var b = a.childNodes[i].attributes;
				for (var j = 0; j < b.length; ++j) {
				    if ((b[j] != null) && (b[j].value != null)
					&& ((b[j].value.indexOf("watch") != -1)
//					    || (b[j].value.indexOf("www.youtube.com/v") != -1)
					    )
					) {
					if (!externalViewerCalled) {
					    console.log("onClicked: calling Qt.openUrlExternally('" + a.childNodes[i].attributes[j].value + "')");
					    Qt.openUrlExternally(a.childNodes[i].attributes[j].value);
					    externalViewerCalled = true;
					}
					else {
					    console.log("onClicked: skipped opening" + a.childNodes[i].attributes[j].value);
					}
					break;
				    }
				    else { console.log("onClicked: skipped " + b[j].name + '=' + b[j].value); }
				}
			    }
			}
		    }
		}
		else if (doc.readyState == XMLHttpRequest.DONE) { // FAIL AND PUNT: open 'link' directly
		    console.log("onClicked: punting and calling Qt.openUrlExternally('" + link + "')");
		    Qt.openUrlExternally(link);
		}
	    }
	    doc.open("GET", link);
	    doc.send();
	}
        onPressAndHold:	{ //NPM-TODO: consolidate with onClicked: code above
	    console.log("onPressAndHold: -------------" + link + "-------------");
	    var doc = new XMLHttpRequest();
	    doc.onreadystatechange = function() {
		if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
		    console.log("onPressAndHold: HEADERS_RECEIVED");
		} else if ((doc.readyState == XMLHttpRequest.DONE)
			   && (doc.responseXML != null)) {
		    var a = doc.responseXML.documentElement;
		    var externalViewerCalled = false;
		    if ((a != null) && a.childNodes != null) {
			for (var i = 0; i < a.childNodes.length; ++i) {
			    if (a.childNodes[i].attributes != null) {
				var b = a.childNodes[i].attributes;
				for (var j = 0; (j < b.length); ++j) {
				    if ((b[j] != null) && (b[j].value != null)
					&& (b[j].value.indexOf(".3gp") != -1)
					) {
					if (!externalViewerCalled) {
					    console.log("onPressAndHold: calling Qt.openUrlExternally('" + a.childNodes[i].attributes[j].value + "')");
					    Qt.openUrlExternally(a.childNodes[i].attributes[j].value);
					    externalViewerCalled = true;
					}
					else {
					    console.log("onPressAndHold: skipped opening" + a.childNodes[i].attributes[j].value);
					}
					break;
				    }
				    else { console.log("onPressAndHold: skipped " + b[j].name + '=' + b[j].value); }
				}
			    }
			}
		    }
		}
		else if (doc.readyState == XMLHttpRequest.DONE) { // FAIL AND PUNT: open 'link' directly
		    console.log("onPressAndHold: punting abd calling Qt.openUrlExternally('" + link + "')");
		    Qt.openUrlExternally(link);
		}
	    }
	    doc.open("GET", link);
	    doc.send();
	}            
    }
}
