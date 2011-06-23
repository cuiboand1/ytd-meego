import QtQuick 1.0

 Rectangle {
     id: progressbar

     property int minimum: 0
     property int maximum: 100
     property int value: 0
     property alias received : progressbar.value
     property alias total : progressbar.maximum

     width: 150
     height: 80
     radius: 10
     gradient: Gradient {
         GradientStop { id: gradient1; position: 0.0; color: _GRADIENT_COLOR_HIGH }
         GradientStop { id: gradient2; position: 0.7; color: _GRADIENT_COLOR_LOW }
     }
     border.width: 2
     border.color: _ACTIVE_COLOR_LOW
     opacity: 0.7
     smooth: true
     clip: true


     Rectangle {
         id: highlight

         property int widthDest: ((progressbar.width * (value - minimum)) / (maximum - minimum))

         anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
         width: highlight.widthDest
         radius: 10
         gradient: Gradient {
             GradientStop { id: gradient3; position: 0.0; color: _ACTIVE_COLOR_HIGH }
             GradientStop { id: gradient4; position: 0.7; color: _ACTIVE_COLOR_LOW }
         }
         smooth: true

         Behavior on width { SmoothedAnimation { velocity: 1200 } }
     }

     Text {
         anchors { centerIn: progressbar }
         color: _TEXT_COLOR
         font.pixelSize: _STANDARD_FONT_SIZE
         font.bold: true
         text: Math.floor((value - minimum) / (maximum - minimum) * 100) + '%'
     }
 }
