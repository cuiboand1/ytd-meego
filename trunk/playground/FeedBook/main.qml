/**************************************************************************
**
** Copyright (C) 2011 Niels  Mayer   <niels.mayer   _AT_ gmail.com>
** Copyright (C) 2011 Martin Grimme  <martin.grimme _AT_ gmail.com>
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
import QtWebKit 1.0 //'video'==instance of WebView below for display of youtube video
import "qmltube"

// This is a small demonstration of how to make a book with YouTube.
//
Rectangle {
    width:  640;
    height: 480;

    Book {
        anchors.fill: parent;

        pageDelegate: Page { //nb: Book's page properties are bound to "page" symbol in this scope
            // The page delegate may contain anything as contents; simple text,
            // images, or even complex QML hierarchies
            contents: Item {
                anchors.fill: parent;
		Text {
		    id:		titleText;
		    text:	(function() { try { return(page.title); }
			                      catch(e) { return(""); } })();
		    clip:	false;
		    wrapMode:   Text.WordWrap;
		    font {  bold: true; family: "Helvetica"; pointSize: 16 }
		    anchors {
			top:		parent.top;
			left:		parent.left;
			leftMargin:	5;
			right:		parent.right;
			rightMargin:	5;
		    }
		}

		Text {
		    id:         descriptionText;
		    text:	(function() { try { return(page.description); }
			                      catch(e) { return(""); } })();
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
		    }
		}
		WebView { // http://doc.qt.nokia.com/4.7-snapshot/qml-webview.html
		    id:			video;
		    //See http://code.google.com/apis/youtube/player_parameters.html#Parameters
		    //vq=small ==> 240p ==> corresponds to 'height:' below...
		    url:		(function() { try { return("http://www.youtube.com/watch_popup?v="
								   + page.videoid
								   + "&vq=small&fs=0&autoplay=0&loop=0&showsearch=0&rel=0&cc_load_policy=1#t=0m01s"); }
			                              catch(e) { return(""); } })();
		    anchors {
			left:	     parent.left;
			leftMargin:  5;
			right:	     parent.right;
			rightMargin: 5;
			bottom:      pagenumText.top;
		    }
		    width:		parent.width - 10; //width starts out at 640, giving two 320-5 px pages.
		    height:		240;
		    scale:		1.0;
		    settings.privateBrowsingEnabled:	true;
		    settings.autoLoadImages:		true;
		    settings.javascriptEnabled:		true;
		    settings.javaEnabled:		false;
		    settings.pluginsEnabled:		true;
		    settings.javascriptCanOpenWindows:	false;
		    settings.javascriptCanAccessClipboard: false;
		    onLoadFinished: function ()    { console.log("WebView loaded " + (page!=undefined) ? page.videoid : "???" ); }
		    onAlert:        function (msg) { console.log("WebView alert() signal: " + msg); }
		}         
		Text {
		    id:                                 pagenumText;
		    anchors.bottom:			parent.bottom;
                    anchors.bottomMargin:		2;
                    anchors.horizontalCenter:		parent.horizontalCenter;
                    width:				parent.width - 5;
                    horizontalAlignment:		(function() { try { return((page.number % 2 == 0)); }
			                               		      catch(e) { return(false); } })()
			                 		? Text.AlignRight
			                 		: Text.AlignLeft;
                    text:				"<i> "
							+ (function() { try { return(page.number); }
									catch(e) { return(""); } })()
							+ " </i>";
		    // click on the pagenumber to go to next/previous page
                    // TODO: make the number look like a button
		    MouseArea {	

			anchors.fill:			parent;
			onClicked: { 
			    if ((function() { try { return((page.number % 2 == 0)); }
					      catch(e) { return(false); } })()) {
				(function() { try { bookBehavior.next(); }
				              catch(e) { console.log(e); } })();
			    }
			    else {
				(function() { try { bookBehavior.previous(); }
				              catch(e) { console.log(e); } })();
			    }
			}
		    }
                }
            }
        }

        // The BookBehavior element handles user interaction and fills the
        // pages from a model
        BookBehavior {
            id: bookBehavior;
            model: TubeModel { }
        }
    }
}
