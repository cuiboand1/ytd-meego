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
import "../ytjson.js" as YTJSON

Item {
    id: delegate

    width: delegate.ListView.view.width; height: 60

    Text {
        text: name
        color: delegate.ListView.isCurrentItem ? "white" : "black"
        font { family: "Helvetica"; pixelSize: 16; bold: true }
        anchors {
            left: parent.left; leftMargin: 15
            verticalCenter: parent.verticalCenter
        }
    }

    BusyIndicator {
        scale: 0.6
        on: delegate.ListView.isCurrentItem && window.loading
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
    }

    Rectangle {
        width: delegate.width; height: 1; color: "#cccccc"
        anchors.bottom: delegate.bottom
        visible: delegate.ListView.isCurrentItem ? false : true;
    }
    Rectangle {
        width: delegate.width; height: 1; color: "white";
        visible: delegate.ListView.isCurrentItem ? false : true;
    }

    MouseArea {
        anchors.fill: delegate;
        onClicked: {
	    YTJSON.showFeed(feed);
            window.currentFeed = feed;
            delegate.ListView.view.currentIndex = index;
        }
    }
}
