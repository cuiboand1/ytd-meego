import QtQuick 1.0 
import MeeGo.Components 0.1 as MeeGo
import "scripts/mainscripts.js" as Scripts
import "scripts/settings.js" as Settings

MeeGo.Window { // see: ~/qtquick/ux/meego-ux-components/src/components/ux/Window.qml
    id: qApp;

    toolBarTitle: "Tubelet"

    Component {
        id: window;
	TubeletPage {}
    }

    Component.onCompleted: {
        console.log("TubeletPage loading...");
        switchBook( window );
    }
}
