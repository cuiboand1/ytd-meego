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

// See http://code.google.com/apis/youtube/player_parameters.html#Parameters
var ytplayer_url    = "http://www.youtube.com/watch_popup?v=";
var ytplayer_params = "&fs=1&autoplay=1&loop=0&showsearch=0&rel=0&cc_load_policy=1#t=0m01s";

var download_p = false;	 //on webPageLoaded(), don't download, unless true.

//on click browse selected feed episode; TODO: attempt html5 version first.
function onClicked(videoid) {
    download_p = false;		//on webPageLoaded(), don't download
    feedtab.loading = true;
    var episode = ytplayer_url + videoid + ytplayer_params;
    console.log("onClicked: viewing ('" + episode + "')");
    videotab.url = episode; // display URL in WebView
//  QT.openUrlExternally(episode);
    feedtab.loading = false;

//     var self_feed =
//       "http://gdata.youtube.com/feeds/api/videos/"
// //	"http://youtube.com/get_video?video_id="
// 	+ videoid
// 	+ "?v=2&alt=jsonc";
// 
//     console.log("onClicked: id = '" + self_feed + "'");
// 
// 
//      var xhr = new XMLHttpRequest();
//      xhr.onreadystatechange = function() {
//  	if (xhr.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
//  	    console.log("onClicked: HEADERS_RECEIVED...");
//  	} else if (xhr.readyState == XMLHttpRequest.DONE
//  		   && (xhr.responseText != null)) {
//  	    console.log("onClicked: location=" + xhr.getResponseHeader("location") + "responseText=\n" + xhr.responseText + "\n");
//  	    var jsresp = JSON.parse(xhr.responseText);
//  	    var entries =  jsresp.data.content;
//  	    console.log("onClicked: entries\n" + JSON.stringify(entries) + "\n");
//  	    var url = null;
//  	    for (var i in entries) {
//  		url = entries[i];
//  		if (url.indexOf(".3gp") == (url.length - 4)) {
//  		    console.log("onClicked: mobile video entry " + i + "\n" + url);
//  //		    Qt.openUrlExternally(url);
//  //		    videotab.source = url;
//  		    videotab.url = url; // display URL in WebView
//  		    break;
//  		}
//  	    }
//  	    if ((url == null) || (url == entries[5])) {
//  		url = entries[5]; // default HTML
//  //		url = url.substring(0, url.indexOf('?f=')) + '.flv'; // + url.substring(url.indexOf('?f='));
//  		console.log("onClicked: flash video entry" + url + "\n");
//  //		Qt.openUrlExternally(url);
//  //		videotab.source = url;
//  		videotab.url = url; // display URL in WebView
//  
//  //		var doc = new XMLHttpRequest();
//  //		doc.onreadystatechange = function() {
//  //		    if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
//  //			console.log("onClicked: in " + url + " HEADERS_RECEIVED\n");
//  //			console.log(doc.getAllResponseHeaders());
//  //		    } else if (doc.readyState == XMLHttpRequest.DONE) {
//  ////			       && (doc.responseText != null)) 
//  //			console.log("onClicked: responseText\n\t" + doc.responseText + "\n\n");
//  ////			var a = doc.responseXML.documentElement;
//  ////			if ((a != null) && a.childNodes != null) {
//  ////			    for (var i = 0; (i < a.childNodes.length); ++i) {
//  ////				if (a.childNodes[i].attributes != null) {
//  ////				    var b = a.childNodes[i].attributes;
//  ////				    console.log("onClicked: in " + url + " DONE\n");
//  ////				    for (var j = 0; (j < b.length); ++j) {
//  ////					console.log("onClicked:\n\t" + b[j].name + '=' + b[j].value);
//  ////				    }
//  ////				}
//  ////			    }
//  ////			}
//  //		    }
//  //		}
//  //		doc.open("GET", url + ".swf"   );	
//  //		doc.send();
//  	    }
//  	}
//  		else if (xhr.readyState == XMLHttpRequest.DONE) {
//  		    console.log("onClicked: punting ..." );
//  		}
//  	    }
//  //     xhr.onreadystatechange = function() {
//  // 	if (xhr.readyState == XMLHttpRequest.DONE) {
//  // 	    console.log("onClicked: responseText" + xhr.responseText);
//  // 
//  // 	    var re = new RegExp('.*"fmt_url_map"\:\s+"([^"]+)".*');
//  // 	    var m = re.exec(xhr.responseText);
//  // 	    if (m == null) {
//  // 		console.log("No match");
//  // 	    } else {
//  // 		var s = "Match at position " + m.index + ":\n";
//  // 		for (i = 0; i < m.length; i++) {
//  // 		    s = s + m[i] + "\n";
//  // 		}
//  // 		console.log(s);
//  // 	    }
//  // 	    //	    var jsresp = JSON.parse(xhr.responseText);
//  // 	    //	    console.log("onClicked: response " + JSON.stringify(jsresp) + "\n\n");
//  // 	    //	    var episode =  jsresp.data.content["5"];
//  // 	    //console.log("onClicked: content " + JSON.stringify(episode) + "\n\n");
//  // 	    //Qt.openUrlExternally(episode);
//  // 	}
//  //     }
//  
//      // Send request, onreadystatechange above processes result
//      // asynchronously on receipt.
//      xhr.open("GET", self_feed);	
//      xhr.send();
}

var scrollX = null;
var scrollY = null;
function webPageLoaded() {
    // after WebView loaded with new video, switch to tab showing WebView
    tabs.current = 2;	  // (TODO, make this a constant/enum?)
//no need for this, just use watch_popup?v param showsearch=0&rel=0
//    //get rid of searchbox and youtube banner at top. --> 
//    scrollX = videotab.evaluateJavaScript("window.scrollX");
//    scrollY = videotab.evaluateJavaScript("window.scrollY");
//    console.log("scrollX ='" + scrollX + "' scrollY='" + scrollY + "'");
//    videotab.evaluateJavaScript('window.scrollX = 50; window.scrollY = -100;');
//    // videotab.heuristicZoom (100, -100, 1.0);
    if (download_p) {
	//NB: the following line of magic was stolen from the internets, actual copyright unknown (public domain??)
	//it saves the flv file playing in the Flash browser. Will break if HTML5??
	videotab.evaluateJavaScript('swfHTML=document.getElementById("movie_player").getAttribute("flashvars");w=swfHTML.split("&"); for(i=0;i<=w.length-1;i++) if(w[i].split("=")[0] == "fmt_url_map"){links=unescape(w[i].split("=")[1]);break;}abc = links.split(",");for(i=0;i<=abc.length-1;i++){fmt=abc[i].split("|")[0];if(fmt==5){url = abc[i].split("|")[1];window.location.href = url;}}'); 
    }
}

//on longclick, browse related feeds list
function onPressAndHold(videoid) {
    var episode = ytplayer_url + videoid + ytplayer_params;

    console.log("onClicked: viewing ('" + episode + "')");
    download_p = true;
    videotab.url = episode; // display URL in WebView

//    var related_feed =
//	"http://gdata.youtube.com/feeds/api/videos/"
//	+ videoid
//	+ "/related?v=2&alt=jsonc";
//    console.log("onPressAndHold: looking for related feeds '" + related_feed	+ "')");
//    var xhr = new XMLHttpRequest();
//    xhr.onreadystatechange = function() {
//	if (xhr.readyState == XMLHttpRequest.DONE) {
//	    console.log("onPressAndHold: responseText" + xhr.responseText);
//	    var jsresp = JSON.parse(xhr.responseText);
//	    var entries =  jsresp.data.items;
//	    jsonModel.clear();	// clear out previous items in feed
//	    for (var i in entries) {
//		var obj = entries[i];
//		console.log("onPressAndHold(): " + i + " : " + JSON.stringify(obj));
//		// pull out only specifically needed info & create a "flat"
//		// model, otherwise views of complex and deep model, gets
//		// very wonky (bug in view of complex model w/ nested
//		// lists?)
//		jsonModel.append({videoid:
//				     (function() {
//					 try {
//					     return(obj.media$group.yt$videoid.$t);
//					 }
//					 catch(e) { return(""); }})(),
//				  thumbnail:
//				     (function() {
//					 try {
//					     return(obj.media$group.media$thumbnail[0].url);
//					 }
//					 catch(e) { return(""); }})(),
//				  duration:
//				     (function() {
//					 try {
//					     return(parseInt(obj.media$group.yt$duration.seconds));
//					 }
//					 catch(e) { return(-1); }})(),
//             			  numLikes:
//				     (function() {
//					 try {
//					     return(parseInt(obj.yt$rating.numLikes));
//					 }
//					 catch(e) { return(-1); }})(),
//			          numDislikes:
//				     (function() {
//					 try {
//					     return(parseInt(obj.yt$rating.numDislikes));
//					 }
//					 catch(e) { return(-1); }})(),
//			          favoriteCount:
//				     (function() {
//					 try {
//					     return(parseInt(obj.yt$statistics.favoriteCount));
//					 }
//					 catch(e) { return(-1); }})(),
//			          viewCount:
//				     (function() {
//					 try {
//					     return(parseInt(obj.yt$statistics.viewCount));
//					 }
//					 catch(e) { return(-1); }})(),
//				  author:
//				     (function() {
//					 try {
//					     return(obj.media$group.media$credit[0].$t);
//					 }
//					 catch(e) { return("N/A"); }})(),
//				  published:
//				     (function() {
//					 try {
//					     return(obj.published.$t);
//					 }
//					 catch(e) { return(""); }})(),
//				  title:
//				     (function() {
//					 try {
//					     return(obj.title.$t);
//					 }
//					 catch(e) { return("(no title)"); }})(),
//				  description:
//				     (function() {
//					 try {
//					     return(obj.media$group.media$description.$t);
//					 }
//					 catch(e) { return (""); }})()
//					 });
//	    }
//	    feedtab.loading = false; // stop the spinner at request completion ...
//	}
//    }
//
//    feedtab.loading = true;	// start the spinner at request start ...
//
//    // Send request, onreadystatechange above processes result
//    // asynchronously on receipt.
//    xhr.open("GET", related_feed);	
//    xhr.send();
}


