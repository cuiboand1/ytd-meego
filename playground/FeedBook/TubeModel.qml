/**************************************************************************
**
** Copyright (C) 2011 Niels  Mayer   <niels.mayer   _AT_ gmail.com>
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
**
**************************************************************************/

import Qt 4.7

   // JSON Model should be built-in but following hack is required,
   // see http://bugreports.qt.nokia.com/browse/QTBUG-1211
   // http://mobilephonedevelopment.com/qt-qml-tips/#Consuming%20JSON%20Data
   ListModel {                 // http://doc.qt.nokia.com/4.7-snapshot/qml-listmodel.html
       id: jsonModel;
       signal loadCompleted();

       function showFeed(feedName) {
           var xhr = new XMLHttpRequest();
	   // processes result of request below asynchronously, updating
	   // jsonModel with new results.
	   xhr.onreadystatechange = function() {
	       if (xhr.readyState == XMLHttpRequest.DONE) {
		   //console.log("showFeed(): responseText" + xhr.responseText);
		   jsonModel.clear();
		   var jsresp = JSON.parse(xhr.responseText);
		   var entries = jsresp.feed.entry;
		   var len = entries.length
		   for (var i = 0; i < len; i++) {
		       var obj = entries[i];
		       //              console.log("showFeed(): " + i + " : " + JSON.stringify(obj));
		       // pull out only specifically needed info & create a "flat"
		       // model, otherwise views of complex and deep model, gets
		       // very wonky (bug in view of complex model w/ nested
		       // lists?)
		       jsonModel.append( {
		       	           number:
			       i + 1,
		       	           videoid:
			       (function() {
				   try {
				       return(obj.media$group.yt$videoid.$t);
				   }
				   catch(e) { return(""); }})(),
				   thumbnail:
			       (function() {
				   try {
				       return(obj.media$group.media$thumbnail[0].url);
				   }
				   catch(e) { return(""); }})(),
				   duration:
			       (function() {
				   try {
				       return(parseInt(obj.media$group.yt$duration.seconds));
				   }
				   catch(e) { return(-1); }})(),
				   numLikes:
			       (function() {
				   try {
				       return(parseInt(obj.yt$rating.numLikes));
				   }
				   catch(e) { return(-1); }})(),
				   numDislikes:
			       (function() {
				   try {
				       return(parseInt(obj.yt$rating.numDislikes));
				   }
				   catch(e) { return(-1); }})(),
				   favoriteCount:
			       (function() {
				   try {
				       return(parseInt(obj.yt$statistics.favoriteCount));
				   }
				   catch(e) { return(-1); }})(),
				   viewCount:
			       (function() {
				   try {
				       return(parseInt(obj.yt$statistics.viewCount));
				   }
				   catch(e) { return(-1); }})(),
				   author:
			       (function() {
				   try {
				       return(obj.media$group.media$credit[0].$t);
				   }
				   catch(e) { return("N/A"); }})(),
				   published:
			       (function() {
				   try {
				       return(obj.published.$t);
				   }
				   catch(e) { return(""); }})(),
				   title:
			       (function() {
				   try {
				       return(obj.title.$t);
				   }
				   catch(e) { return("(no title)"); }})(),
				   description:
			       (function() {
				   try {
				       return(obj.media$group.media$description.$t);
				   }
				   catch(e) { return (""); }})()
				   });
		   }
//		   window.loading = false; // stop the spinner at request completion ...
	       }
	   }

//	   window.loading = true;      // start the spinner at request start ...

	   // Send request, onreadystatechange above processes result
	   // asynchronously on receipt.
	   console.log("showFeed(): Calling GET http://gdata.youtube.com/feeds/api/standardfeeds/" + feedName +
		       "?v=2&alt=json");
	   xhr.open("GET",
		    "http://gdata.youtube.com/feeds/api/standardfeeds/" + feedName +
		    "?v=2&alt=json");
	   xhr.send();
       }

       Component.onCompleted: { // http://doc.qt.nokia.com/latest/qml-component.html
           showFeed("on_the_web"); //feed name from http://code.google.com/apis/youtube/2.0/developers_guide_protocol_video_feeds.html
           jsonModel.loadCompleted();
       }
   }

// A simple model of pages
// ListModel {
//     ListElement {
//         number: 1
//         ytid: 'PMD1k16baVE'
//     }
//     ListElement {
//         number: 2
//         ytid: '1V4AscLidWg'
//     }
//     ListElement {
//         number: 3
//         ytid: '-SQGJ0rfIEk'
//     }
//     ListElement {
//         number: 4
//         ytid: 'rmUpFUCkdQY'
//     }
//     ListElement {
//         number: 5
//         ytid: 'CQ9JdDAbKH0'
//     }
//     ListElement {
//         number: 6
//         ytid: 't2YBw96PsjY'
//     }
//     ListElement {
//         number: 7
//         ytid: 'xOF9fUMA5xo'
//     }
//     ListElement {
//         number: 8
//         ytid: 'SyKXLaf4QeE'
// 
//     }
//     ListElement {
//         number: 9
//         ytid: 'YWGYhsbVylc'
//     }
//     ListElement {
//         number: 10
//         ytid: 'DuWRxErcFI4'
//     }
// }
