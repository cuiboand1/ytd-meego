#include "controller.h"
#include <QDeclarativeView>
#include <QDeclarativeEngine>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QApplication>
#include <QClipboard>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>
#include <QVariant>
#include <QString>
#include <QMap>
#include <QTranslator>
#include <QProcess>
#include <QDesktopServices>

#if (defined(Q_WS_MAEMO_5) || defined(Q_WS_X11))
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusInterface>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <QX11Info>
#endif /* (defined(Q_WS_MAEMO_5) || defined(Q_WS_X11)) */

Controller::Controller(QObject *parent) :
    QObject(parent) {
    converter = new QProcess(this);
    connect(converter, SIGNAL(started()), this, SIGNAL(conversionStarted()));
    connect(converter, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(conversionFinished(int, QProcess::ExitStatus)));
#ifdef Q_OS_SYMBIAN
    isSymbian = true;
#else
    isSymbian = false;
#endif
}

void Controller::setView(QmlApplicationViewer *view) {
    m_view = view;
}

void Controller::toggleState() {
    if (!m_view->isFullScreen()) {
        m_view->showFullScreen();
    }
    else {
        m_view->showMaximized();
    }
}

bool Controller::osIsSymbian() const {
    return isSymbian;
}

void Controller::keepDisplayOn() {
#ifdef Q_WS_MAEMO_5
    QDBusConnection systemDbusConnection = QDBusConnection::systemBus();
    QDBusInterface mceConnectionInterface("com.nokia.mce",
                                          "/com/nokia/mce/request",
                                          "com.nokia.mce.request",
                                          systemDbusConnection, this);
    mceConnectionInterface.call("req_display_blanking_pause");
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
    //NPM: suggested by meego-qml-launcher/src/launcherwindow.cpp to
    //inhibit screensaver in meego-ux. ... it's not freedesktop.org
    //standard and is meego specific, but there's no Q_WS_MEEGO to help
    //differentiate between generic X11 and Meego.
    bool m_inhibitScreenSaver = true;
    Atom inhibitAtom = XInternAtom(QX11Info::display(), "_MEEGO_INHIBIT_SCREENSAVER", false);
    XChangeProperty(QX11Info::display(),
		    m_view->winId(),
		    inhibitAtom,
		    XA_CARDINAL,
		    32,
		    PropModeReplace,
		    (unsigned char*)&m_inhibitScreenSaver,
		    1);
#endif	/* Q_WS_MAEMO_5 */
}

void Controller::doNotDisturb(bool videoPlaying) {
#ifdef Q_WS_MAEMO_5
    Atom atom = XInternAtom(QX11Info::display() , "_HILDON_DO_NOT_DISTURB", False);
    if (!atom) {
        qWarning("Unable to obtain _HILDON_DO_NOT_DISTURB. This example will only work "
                 "on a Maemo 5 device!");
        return;
    }

    if (videoPlaying) {
        long state = 1;
        XChangeProperty(
                    QX11Info::display(),
                    m_view->winId(),
                    atom,
                    XA_INTEGER,
                    32,
                    PropModeReplace,
                    (unsigned char *) &state,
                    1);
    }
    else {
        XDeleteProperty(QX11Info::display(), m_view->winId(), atom);
    }
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
    //
    //NPM: TODO: Is there equivalent for X11 and MeeGo Netbook UX to turn off
    //extraneous notifications e.g. "Google Sync Completed" etc.
    //
#endif
}

QString Controller::getLanguage() const {
    QString langCode = "en";

    QSqlDatabase db;
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(m_view->engine()->offlineStoragePath().append("/Databases/63db502ea46fc7fe74e01e615d2c00d6.sqlite"));
    db.open();

    QSqlQuery query("select value from settings where setting = 'language'");
    QSqlRecord record = query.record();
    if (record.count() > 0) {
        while (query.next()) {
            langCode = query.value(0).toString();
        }
    }
    //        qDebug() << langCode;
    db.close();
    return langCode;
}

void Controller::setOrientation(const QString &orient) {
    if (orient == "automatic") {
        m_view->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    }
    else if (orient == "landscape") {
        m_view->setOrientation(QmlApplicationViewer::ScreenOrientationLockLandscape);
    }
    else if (orient == "portrait") {
        m_view->setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    }
}

void Controller::minimize() {
#ifdef Q_WS_MAEMO_5
    QDBusConnection bus = QDBusConnection::sessionBus();

    QDBusMessage message = QDBusMessage::createSignal("/", "com.nokia.hildon_desktop", "exit_app_view");
    bus.send(message);
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
    //
    //NPM: TODO: figure out what this means on X11 platform?
    //
#endif /* Q_WS_MAEMO_5 */
}

void Controller::setMediaPlayer(const QString &player) {
    mediaPlayer = player.toLower().replace(" ", "");
}

bool Controller::widgetInstalled() const {
    bool isInstalled = false;

#ifdef Q_WS_MAEMO_5
    if (QFile::exists("/usr/lib/hildon-desktop/qmltube-widget")) {
        isInstalled = true;
    }
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
    /*
     *NPM: TODO see if makes sense when using meego-youtube-panel to 
     *have this set to true since the panel is equiv to hildon cutetube widget.
     *qml/qmltube/HelpDialog.qml describes functionality enabled with this:
     *  "Choose which video feeds you would like to be able to access via
     *  the widget. The widget can be installed seperately (package name is
     *  qmltube-widget), and is displayed by selecting it from the list in
     *  the same way as any other homescreen widget."
     */
#endif /* Q_WS_MAEMO_5 */
    return isInstalled;
}

void Controller::getMediaPlayerFromDB() {
    QSqlDatabase db;
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(m_view->engine()->offlineStoragePath().append("/Databases/63db502ea46fc7fe74e01e615d2c00d6.sqlite"));
    db.open();

    QSqlQuery query("select value from settings where setting = 'mediaPlayer'");
    QSqlRecord record = query.record();
    QString player = "Media Player";
    if (record.count() > 0) {
        while (query.next()) {
            player = query.value(0).toString();
        }
        //        qDebug() << player;
    }
    if (player == "cuteTube Player") {
        player = "Media Player";
    }
    setMediaPlayer(player);
    db.close();
}

QStringList Controller::getProxyFromDB() const {
    QSqlDatabase db;
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(m_view->engine()->offlineStoragePath().append("/Databases/63db502ea46fc7fe74e01e615d2c00d6.sqlite"));
    db.open();

    QSqlQuery query;
    query.exec("insert or ignore into settings values ('proxy', ':')");
    query.exec("select value from settings where setting = 'proxy'");
    QSqlRecord record = query.record();
    QStringList proxy;
    QString result;
    if (record.count() > 0) {
        while (query.next()) {
            result = query.value(0).toString();
            proxy = result.split(":");
        }
        //        qDebug() << proxy;
    }
    else {
        proxy << "" << "";
    }
    //    qDebug() << proxy;
    db.close();
    return proxy;
}

bool Controller::xTubeInstalled() const {
    bool isInstalled = false;
    QString path;
#ifdef Q_WS_MAEMO_5
    path = "/opt/usr/share/qmltube/qml/qmltube/scripts/xtube.js";
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
    path = "/opt/tubelet/qml/qmltube/scripts/xtube.js";
    // on linux, the original code below seems to only work when cd'd
    // to source or build directory; in other directories, it fails...
    //path = m_view->engine()->baseUrl().toLocalFile().append("qml/qmltube/scripts/xtube.js");
#else // fallback for neither Q_WS_X11 nor Q_WS_MAEMO_5 (the orig cutetube code):
    path = m_view->engine()->baseUrl().toLocalFile().append("qml/qmltube/scripts/xtube.js");
#endif	/* Q_WS_MAEMO_5 */
    if (QFile::exists(path)) {
        isInstalled = true;
    }
    return isInstalled;
}

QStringList Controller::getInstalledMediaPlayers() const {
    QStringList playerList;
    playerList << "cuteTube Player";
#ifdef Q_OS_SYMBIAN		// NPM: "Media Player" choice is only valid for symbian
    playerList << "Media Player";
#endif /*Q_OS_SYMBIAN*/
    if ((QFile::exists("/usr/bin/mplayer"))) {
        playerList << "MPlayer";
    }
    if ((QFile::exists("/opt/kmplayer/bin/kmplayer")) || (QFile::exists("/usr/bin/kmplayer"))) {
        playerList << "KMPlayer";
    }
    if ((QFile::exists("/opt/smplayer/bin/smplayer")) || (QFile::exists("/usr/bin/smplayer"))) {
        playerList << "SMPlayer";
    }
    return playerList;
}

void Controller::playVideo(const QString &url) {
    //    qDebug() << url;
#ifdef Q_WS_MAEMO_5
    minimize();
    if (mediaPlayer == "mplayer") {
        QStringList args;
        args << "-cache" << "4096" << "-fs" << url;
        QProcess *player = new QProcess();
        connect(player, SIGNAL(finished(int, QProcess::ExitStatus)), player, SLOT(deleteLater()));
        player->start("/usr/bin/mplayer", args);
    }
    else {
        QDBusConnection bus = QDBusConnection::sessionBus();
        QDBusInterface dbus_iface("com.nokia." + mediaPlayer, "/com/nokia/" + mediaPlayer, "com.nokia." + mediaPlayer, bus);
        dbus_iface.call("mime_open", url);
    }
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
//  minimize();
    if (mediaPlayer == "mplayer") {
        QStringList args;
        args << "-cache" << "4096" << "-fs" << url;
        QProcess *player = new QProcess();
        connect(player, SIGNAL(finished(int, QProcess::ExitStatus)), player, SLOT(deleteLater()));
        player->start("/usr/bin/mplayer", args);
    }
    else if (mediaPlayer == "smplayer") {
        QStringList args;
        args << url;
        QProcess *player = new QProcess();
        connect(player, SIGNAL(finished(int, QProcess::ExitStatus)), player, SLOT(deleteLater()));
        player->start("/usr/bin/smplayer", args);
    }
    else {
        QDesktopServices::openUrl(QUrl::fromLocalFile(url));
    }
#else // from the orig cutetube code, probably for fallthrough for Q_OS_SYMBIAN
    if (url.startsWith("http://")) {
        QFile ytlink("E:/Videos/cutetube/cutetube.ram");
        ytlink.open(QIODevice::WriteOnly);
        ytlink.write(url.toAscii());
        ytlink.close();
        QDesktopServices::openUrl(QUrl::fromLocalFile(ytlink.fileName()));
    }
    else {
        QDesktopServices::openUrl(QUrl::fromLocalFile(url));
    }
#endif	/* Q_WS_MAEMOo5 */
    emit playbackStarted(url);
}

void Controller::deleteVideo(const QString &path) {
    if (QFile::exists(path)) {
        if (QFile::remove(path)) {
            emit alert(tr("Video(s) deleted from device"));
        }
        else {
            emit alert(tr("Unable to delete video(s) from device"));
        }
    }
    else {
        emit alert(tr("Video not found"));
    }
}

QString Controller::archiveFileExists(const QString &filePath, const QString &archivePath) const {
    QString result = "Not found";
    if (QFile::exists(filePath)) {
        result = "Unchanged";
    }
    else {
        QString newPath = archivePath;
        newPath.append(filePath.split("/").last());
        if (QFile::exists(newPath)) {
            result = newPath;
        }
    }
    return result;
}

bool Controller::pathExists(const QString &path) {
    QDir dir(path);
    return dir.exists();
}

void Controller::convertToAudio(const QString &input) {
    inputFile = input;
    QString ffmpeg = "/usr/bin/ffmpeg";
    QStringList args;
    outputFile = input;
    outputFile.replace(".mp4", ".m4a");
    args << "-i" << inputFile << "-acodec" << "copy" << "-y" << "-vn" << outputFile;

    converter->start(ffmpeg, args);
}

void Controller::conversionFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    if ((exitCode == 0) && (exitStatus == QProcess::NormalExit)) {
        QFile output(outputFile);
        if (output.size() > 0) {
            emit conversionCompleted();
            QFile::remove(inputFile);
        }
        else {
            emit conversionFailed();
            QFile::remove(outputFile);
        }
    }
    else {
        emit conversionFailed();
    }
}

// NPM replace 'folder: Controller.isSymbian ? "E:/" : "/home/meego/"' in FileChooserDialog.qml
QString Controller::homePath() const {
#ifdef Q_OS_SYMBIAN
  return ("E:/");
#else
  return QDir::homePath();
#endif
}

void Controller::copyToClipboard(const QString &url) {
    QApplication::clipboard()->setText(url);
    emit alert(tr("Copied to clipboard"));
}
