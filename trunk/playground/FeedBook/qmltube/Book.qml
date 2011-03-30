/**************************************************************************
**
** Copyright (C) 2011 Martin Grimme  <martin.grimme _AT_ gmail.com>
** Copyright (C) 2011 Niels  Mayer   <niels.mayer   _AT_ gmail.com>
**
** This file is part of QmlBook, a book browsing framework for QML
**
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

// Book component holding four pages that can be switched.
// This is the low-level implementation of the book.
// Combine with BookBehavior as child to make it more like a real book.
//
Item {

    // Loads a page into the "book"
    //
    function loadPage(idx, page) {
        if (idx >= repeater.model.count) {
	    repeater.model.append({ "page"           : page,
	                            "workAroundQtBug": 0 });
        } else {
            repeater.model.setProperty(idx, "page", page);
            // Qt 4.7.0 needs this to update the pages...
	    repeater.model.setProperty(0, "workAroundQtBug", 0);
        }
    }

    property alias pageDelegate: repeater.delegate
    property alias smooth: smoothener.enabled
    property double progress
    property double croppedProgress: Math.max(0.0, Math.min(progress, 1.0))
    property bool fromRight: true


    // model view for the four pages
    Repeater {
        id: repeater
        model: ListModel { }
    }


    Behavior on progress {
        id: smoothener
        enabled: true
        SmoothedAnimation { velocity: 2 }
    }
}
