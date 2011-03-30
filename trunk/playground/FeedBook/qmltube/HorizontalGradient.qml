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


// QML doesn't support horizontal gradients, so we build our own.
//
Item {
    property alias gradient: horizGradient.gradient

    Rectangle {
        id: horizGradient
        width: parent.height
        height: parent.width
        anchors.centerIn: parent
        rotation: 270
    }
}
