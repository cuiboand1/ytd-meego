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
import "content"

Rectangle {
    id: window
    width: 800; height: 480

    property string currentFeed: "top_rated"
    property bool loading: feedModel.status == XmlListModel.Loading

    RssFeeds { id: rssFeeds }

    // NPM: use XmlListModel using relative XPath ( http://www.w3.org/TR/xpath20/ )
    // expression queries to retrieve feed information from YT 2.0 Feed
    // see http://code.google.com/apis/youtube/2.0/developers_guide_protocol_video_feeds.html
    // and http://doc.qt.nokia.com/latest/qml-xmllistmodel.html
    // and http://doc.qt.nokia.com/latest/qml-xmlrole.html
    XmlListModel {
            id: feedModel
            source: "http://gdata.youtube.com/feeds/api/standardfeeds/" + window.currentFeed + "?v=2&alt=atom"
            query: "/feed/entry"
            namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; \
                declare namespace yt='http://gdata.youtube.com/schemas/2007'; \
                declare namespace media='http://search.yahoo.com/mrss/';"
            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "link"; query: "link[4]/@href/string()" }
	    // NPM: note 'isKey: true' for future incremental reloading,
	    // see http://doc.qt.nokia.com/latest/qml-xmllistmodel.html#using-key-xml-roles
            XmlRole { name: "published"; query: "published/string()"; isKey: true; }
            XmlRole { name: "description"; query: "media:group/media:description/string()" }
            XmlRole { name: "thumbnail"; query: "media:group/media:thumbnail[5]/@url/string()" }
            XmlRole { name: "duration"; query: "media:group/yt:duration/@seconds/string()" }
            XmlRole { name: "numLikes"; query: "yt:rating/@numLikes/string()" }
            XmlRole { name: "author"; query: "author/name/string()" }
        }
//    XmlListModel {
//        id: feedModel
//        source: "http://" + window.currentFeed
//        query: "/rss/channel/item"

//        XmlRole { name: "title"; query: "title/string()" }
//        XmlRole { name: "link"; query: "link/string()" }
//        XmlRole { name: "description"; query: "description/string()" }
//    }

    Row {
        Rectangle {
            width: 180; height: window.height
            color: "#efefef"

            ListView {
                focus: true
                id: categories
                anchors.fill: parent
                model: rssFeeds
                footer: quitButtonDelegate
                delegate: CategoryDelegate {}
                highlight: Rectangle { color: "steelblue" }
                highlightMoveSpeed: 9999999
            }
            ScrollBar {
                scrollArea: categories; height: categories.height; width: 8
                anchors.right: categories.right
            }
        }
        ListView {
            id: list
            width: window.width - 180; height: window.height
            model: feedModel
            delegate: NewsDelegate {}
        }
    }
    Component {
        id: quitButtonDelegate
        Item {
            width: categories.width; height: 60
            Text {
                text: "Quit"
                font { family: "Helvetica"; pixelSize: 16; bold: true }
                anchors {
                    left: parent.left; leftMargin: 15
                    verticalCenter: parent.verticalCenter
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
