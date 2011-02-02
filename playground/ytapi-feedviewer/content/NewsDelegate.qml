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
// import Qt.multimedia 1.0

Item {
    id:		delegate;
    height:	column.height + 40;
    width:	delegate.ListView.view.width

    Column {
        id:	column;
	x:	20;
	y:	20;
        width:	parent.width - 40;

        Image {
	    id:		thumbnailImage;
	    width:	parent.width;
	    source:	thumbnail;
	    smooth:	true;   
            fillMode:	Image.PreserveAspectFit;
        }
        Text {
            id:		titleText;
            text:	title;
	    width:	parent.width;
	    wrapMode:	Text.WordWrap;
            font { bold: true; family: "Helvetica"; pointSize: 16 }
        }
        Text {
            id:		descriptionText;
            width:	parent.width;
	    text:	description;
            wrapMode:	Text.WordWrap;
            font { family:"Helvetica"; }
        }
        Text {
            id:		durationText;
            width:	parent.width;
	    text:	duration + " s.";
            font { family:"Courier"; pointSize: 8; }
        }
        Text {
            id:		numLikesText;
            width:	parent.width;
	    text: numLikes + " likes.";
            font { family:"Courier"; pointSize: 8; }
        }
        Text {
            id:		authorText;
            width:	parent.width;
	    text:	author;
            font { family:"Courier"; pointSize: 8; }
        }
        Text {
            id:		 publishedText;
	    width:	 parent.width;
	    text:	 published;
            font { family:"Courier"; pointSize: 8; }
        }
    }
    Rectangle {
        width:		parent.width;
	height:		1;
	color:		"#cccccc";
        anchors.bottom:	parent.bottom;
    }
    MouseArea {
        anchors.fill:	parent;
        onClicked:	{ console.log("clicked on " + link);
			Qt.openUrlExternally ( link );
	}
        onPressAndHold:	{ console.log("longtouch on " + link); }            
   }
}
