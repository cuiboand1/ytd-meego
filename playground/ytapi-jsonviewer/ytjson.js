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
	    for (var i in entries) {
		var obj = entries[i];
//		console.log("showFeed(): " + i + " : " + JSON.stringify(obj));
		// pull out only specifically needed info & create a "flat"
		// model, otherwise views of complex and deep model, gets
		// very wonky (bug in view of complex model w/ nested
		// lists?)
		jsonModel.append({videoid:
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
	    maintab.loading = false; // stop the spinner at request completion ...
	    tabs.current = 1; // switch to tab showing Feed (TODO, make this a constant/enum?)
	}
    }

    maintab.loading = true;	// start the spinner at request start ...
    maintab.currentFeed = feedName;
    feedtab.title = "Feed: " + feedName;

    // Send request, onreadystatechange above processes result
    // asynchronously on receipt.
    console.log("showFeed(): Calling GET http://gdata.youtube.com/feeds/api/standardfeeds/" + feedName + "?v=2&alt=json");
    xhr.open("GET", "http://gdata.youtube.com/feeds/api/standardfeeds/" + feedName + "?v=2&alt=json");
    xhr.send();
}
