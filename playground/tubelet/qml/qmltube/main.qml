import QtQuick 1.0 
import MeeGo.Components 0.1 as MeeGo
import "scripts/mainscripts.js" as Scripts
import "scripts/settings.js" as Settings

MeeGo.Window { // see: ~/qtquick/ux/meego-ux-components/src/components/ux/Window.qml
    id: qApp;

    toolBarTitle: "YouTube Toolbar"

    Component {
        id: window;
	CuteTubePage {}
    }

    Component.onCompleted: {
        console.log("CuteTubePage loading...");
        switchBook( window );
    }
}
