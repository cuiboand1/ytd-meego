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

import QtQuick 1.0
import "script.js" as Script

Item {
    id: delegate;
    width: delegate.ListView.view.width;
    height: delegate.ListView.view.height/2;

        Image {
	    id:		thumbnailImage;
	    source:	thumbnail
//	    smooth:	true;   
        fillMode:	Image.PreserveAspectFit;
	    anchors {
        top:	parent.top;
        topMargin:	5;
        left:	parent.left;
        leftMargin: 5;
        right:	parent.horizontalCenter;
	    }
    }
        Text {
            id:         durationText;
    	    text:	"Duration:  " + duration;
	        clip:	false;
            font { family:"Courier"; pointSize: 10; }
    	    anchors {
            top:	thumbnailImage.top;
            left:	parent.horizontalCenter;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:         numLikesText;
    	    text: "Likes/Dis: " + numLikes + " / " + numDislikes;
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
    	    anchors {
            top:	durationText.bottom;
            left:	parent.horizontalCenter;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:         favoriteText;
	    text:	"Fav/Views: " + favoriteCount + " / " + viewCount;
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
    	    anchors {
            top:	numLikesText.bottom;
            left:	parent.horizontalCenter;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:         authorText;
    	    text:	"Posted By: " + author;
	        clip:	false;
            font { family:"Courier"; pointSize: 10; }
    	    anchors {
            top:	favoriteText.bottom;
            left:	parent.horizontalCenter;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:          publishedText;
	    text:	 "Published: " + published;
	    clip:	false;
            font { family:"Courier"; pointSize: 10; }
    	    anchors {
            top:	authorText.bottom;
            left:	parent.horizontalCenter;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:         titleText;
            text:	title;
	    clip:	false;
	    wrapMode:   Text.WordWrap;
            font { bold: true; family: "Helvetica"; pointSize: 16 }
    	    anchors {
            top:	thumbnailImage.bottom;
            left:	parent.left;
            leftMargin: 5;
            right:	parent.right;
            rightMargin: 5;
    	    }
        }
        Text {
            id:         descriptionText;
    	    text:	    description;
    	    textFormat: Text.AutoText;
    	    clip:	true;
    	    elide:	Text.ElideRight;
    	    wrapMode:   Text.WordWrap;
            font { family:"Helvetica"; }
    	    anchors {
            top:	titleText.bottom;
            left:	parent.left;
            leftMargin: 5;
            right:	parent.right;
            rightMargin: 5;
            bottom:	parent.bottom;
            bottomMargin: 2;
	        }
        }
	Rectangle {
	    color:            "#cccccc";
	    anchors {
            top:	descriptionText.bottom;
            left:	parent.left;
            leftMargin: 1;
            right:	parent.right;
            rightMargin: 1;
            bottom:	parent.bottom;
            bottomMargin: 0;
	    }
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
// initially, have single click render HTML URL containing flash in WebView
// and have long click render in media player.
    MouseArea {
        anchors.fill:	parent;
        onClicked:	{
    	    console.log("onClicked: -------------  " + videoid + "  -------------");
    	    Script.onClicked(videoid);
    	}
        onPressAndHold:	{
    	    console.log("onPressAndHold: -------------  " + videoid + "  -------------");
    	    Script.onPressAndHold(videoid);
    	}            
    }
}
