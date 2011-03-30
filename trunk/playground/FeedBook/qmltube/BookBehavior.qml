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

// Behavior component for putting inside a Book component.
// The BookBehavior holds the actual pages model and reacts on user interaction.
//
MouseArea {

    // Updates the set of pages that are displayed, based on the current offset.
    // Call this method when the pages model has changed.
    //
    function updatePages() {
        console.log("offset " + pageOffset);
        for (var i = 0; i < 4; i++) {
            parent.loadPage(i, behavior.model.get(pageOffset + i));
        }
    }

    // Advances to the next page.
    //
    function next() {
        if (pageOffset >= behavior.model.count - 4 && parent.progress > 0.5)
            return;

        parent.smooth = false;
        if (parent.progress > 0.5 && pageOffset < behavior.model.count - 4) {
            pageOffset += 2;
            updatePages();
        }
        parent.progress = 0.0;
        parent.fromRight = true;
        parent.smooth = true;
        parent.progress = 1.0;
    }

    // Goes back to the previous page.
    //
    function previous() {
        if (pageOffset == 0 && parent.progress < 0.5)
            return;

        parent.smooth = false;
        if (parent.progress < 0.5 && pageOffset > 0) {
            pageOffset -= 2;
            updatePages();
        }
        parent.progress = 1.0;
        parent.fromRight = false;
        parent.smooth = true;
        parent.progress = 0.0;
    }

    // current page offset in the pages
    property int pageOffset: 0

    // list model of all the pages
    property variant model: ListModel { }

    id: behavior
    anchors.fill: parent
    hoverEnabled: false


    Component.onCompleted: {
        updatePages();
    }


    onPressed: {
        parent.smooth = false;
        if (mouseX > parent.width / 2) {
            parent.fromRight = true;

            if (parent.progress > 0.5 && pageOffset < model.count - 4) {
                parent.progress = 0.0;
                pageOffset += 2;
                updatePages();
            }

        } else {
            parent.fromRight = false;

            if (parent.progress < 0.5 && pageOffset > 0) {
                parent.progress = 1.0;
                pageOffset -= 2;
                updatePages();
            }
        }
        console.log("from right: " + parent.fromRight);
        parent.smooth = true;
        console.log("page " + pageOffset);
    }

    onReleased: {
        if (parent.progress > 0.5) {
            parent.progress = 1.0;
        } else {
            parent.progress = 0.0;
        }
        parent.smooth = false;
    }

    onMousePositionChanged: {
        parent.progress = (width - mouseX) / width;
    }

}
