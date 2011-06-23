function toggleMenu() {
    /* Toggle the state of the menu */

    if (menuLoader.source == "") {
        menuLoader.source = "MenuList.qml";
        menuTimer.interval = 3000;
    }
    else {
        menuLoader.item.state = "";
        menuTimer.interval = 600;
    }
    menuTimer.running = true;
}
