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

// Component for a book page. A Page is the delegate of the Tube's Repeater
// View. There are four pages, and depending on the page index and page turn
// progress, the parameters are different.
//
// Derive your page delegate from this component, and set the contents using the
// "contents" property.
//
Rectangle {

    property alias contents: pageContainer.children
    // page turn progress of the book
    property double progress

    progress: parent.croppedProgress
    clip: true
    color: "white"
    border.color: "#a0a0a0"
    border.width: 2

    x: {
        return parent.fromRight ? [0,
                                   parent.width / 2,
                                   parent.width - progress * parent.width,
                                   parent.width / 2][index]
                                : [0,
                                   0 + (1.0 - progress) * parent.width / 2,
                                   parent.width / 2 - width,
                                   parent.width / 2][index];
    }
    y: 0
    z: {
        return parent.fromRight ? [0, 2, 3, 1][index]
                                : [1, 3, 2, 0][index];
    }

    width: {
        return parent.fromRight ? [parent.width / 2,
                                   parent.width / 2 * (1.0 - progress),
                                   parent.width / 2 * progress,
                                   parent.width / 2][index]
                                : [parent.width / 2,
                                   parent.width / 2 * (1.0 - progress),
                                   parent.width / 2 * progress,
                                   parent.width / 2][index];
                }
    height: parent.height

    Item {
        id: pageContainer
        x: parent.parent.fromRight ? 0 : parent.width - width
        width: parent.parent.width / 2
        height: parent.parent.height
    }

    // shadow
    HorizontalGradient {
        x: {
            return parent.parent.fromRight ? [parent.width - width,
                                              0,
                                              parent.width - width + 1,
                                              parent.width * (1.0 - progress)][index]
                                           : [parent.width * (1.0 - progress) - width + 1,
                                              0,
                                              parent.width - width,
                                              0][index];
        }
        y: 0
        width: 20;
        height: parent.height

        Gradient {
            id: gradLeft
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.9; color: "#80000000" }
            GradientStop { position: 1.0; color: "#c0000000" }
        }

        Gradient {
            id: gradRight
            GradientStop { position: 0.0; color: "#c0000000" }
            GradientStop { position: 0.1; color: "#80000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }

        gradient: {
            return (index % 2 == 0) ? gradLeft: gradRight;
        }
    }

    // shine
    HorizontalGradient {
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        visible: (index % 2 == 0)

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00ffffff" }
            GradientStop { position: 0.5; color: "#00ffffff" }
            GradientStop { position: 0.8; color: "#60ffffff" }
            GradientStop { position: 1.0; color: "#00ffffff" }
        }
    }
}
