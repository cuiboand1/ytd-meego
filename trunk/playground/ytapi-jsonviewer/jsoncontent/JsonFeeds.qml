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

ListModel {
    id: jsonFeeds

    // NPM: see http://code.google.com/apis/youtube/2.0/developers_guide_protocol_video_feeds.html#Standard_feeds
    ListElement { name: "Top Rated"; feed: "top_rated" }
    ListElement { name: "Top Favorites"; feed: "top_favorites" }
    ListElement { name: "Most Viewed"; feed: "most_viewed" }
    ListElement { name: "Most popular"; feed: "most_popular" }
    ListElement { name: "Most recent"; feed: "most_recent" }
    ListElement { name: "Most discussed"; feed: "most_discussed" }
    ListElement { name: "Most responded"; feed: "most_responded" }
    ListElement { name: "Recently featured"; feed: "recently_featured" }
    ListElement { name: "For mobile"; feed: "watch_on_mobile" }
}
