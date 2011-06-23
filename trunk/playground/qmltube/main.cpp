#include "qmlapplicationviewer.h"
#include "controller.h"
#include "youtube.h"
#include "sharing.h"
#include "downloadmanager.h"
#include "folderlistmodel.h"
#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QtDeclarative>
#include <QStringList>

//#ifdef Q_WS_MAEMO_5
//#include <QtOpenGL/QGLWidget>
//#endif

int main(int argc, char *argv[])
{
#ifdef Q_WS_MAEMO_5
    QApplication::setApplicationName(QString("FMRadio"));
#endif

    QApplication app(argc, argv);   
    Controller ct;
    YouTube yt;

    QStringList args = app.arguments();
    args.takeFirst();
    if (args.isEmpty()) {

        QmlApplicationViewer viewer;
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
        viewer.setAttribute(Qt::WA_NoSystemBackground);
        QDeclarativeContext *context = viewer.rootContext();
        ct.setView(&viewer);
        Sharing sh;
        DownloadManager dm;

        QNetworkAccessManager *manager = new QNetworkAccessManager();
        yt.setNetworkAccessManager(manager);
        dm.setNetworkAccessManager(manager);
        sh.setNetworkAccessManager(manager);

        context->setContextProperty("Controller", &ct);
        context->setContextProperty("DownloadManager", &dm);
        context->setContextProperty("YouTube", &yt);
        context->setContextProperty("Sharing", &sh);

        qmlRegisterType<QDeclarativeFolderListModel>("Models",1,0,"FolderListModel");

#ifdef Q_WS_MAEMO_5
        viewer.addImportPath(QString("/opt/qtm12/imports"));
        viewer.addPluginPath(QString("/opt/qtm12/plugins"));
        viewer.engine()->setOfflineStoragePath("/home/user/.config/cutetube");
        //        viewer.setViewport(new QGLWidget());

        QDir path;
        path.setPath("/home/user/.config/cutetube");
        if (!path.exists()) {
            path.mkpath("/home/user/.config/cutetube");
        }
        path.setPath("/home/user/MyDocs/.cutetube");
        if (!path.exists()) {
            path.mkpath("/home/user/MyDocs/.cutetube");
        }
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
	/*
	 * NPM: TODO: below, note badness w/ using /home/meego, which works
	 * for tablet, but not for netbook UX after vfirstboot allows user
	 * to be set changed from default 'meego'
	 */
//      viewer.addImportPath(QString("/opt/qtm12/imports")); 
//      viewer.addPluginPath(QString("/opt/qtm12/plugins"));
        viewer.engine()->setOfflineStoragePath("/home/meego/.config/cutetube");
        //        viewer.setViewport(new QGLWidget());

        QDir path;
        path.setPath("/home/meego/.config/cutetube");
        if (!path.exists()) {
            path.mkpath("/home/meego/.config/cutetube");
        }
        path.setPath("/home/meego/.cutetube");
        if (!path.exists()) {
            path.mkpath("/home/meego/.cutetube");
        }
#endif /* Q_WS_MAEMO_5 */
        QStringList proxyList = ct.getProxyFromDB();
        QString proxyHost = proxyList.first();
        if (!proxyHost.isEmpty()) {
            int proxyPort = proxyList.last().toInt();
            QNetworkProxy proxy;
            proxy.setType(QNetworkProxy::HttpCachingProxy);
            proxy.setHostName(proxyHost);
            proxy.setPort(proxyPort);
            QNetworkProxy::setApplicationProxy(proxy);
        }

        QString locale = ct.getLanguage();
        QString languagePath;
#ifdef Q_WS_MAEMO_5
        languagePath = "/opt/usr/share/qmltube/qml/qmltube/i18n/qml_" + locale;
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
        languagePath = "/opt/qmltube/qml/qmltube/i18n/qml_" + locale;
	// on linux, the original code below seems to only work when cd'd
	// to source or build directory in other directories, it fails.
	//languagePath = viewer.engine()->baseUrl().toLocalFile().append("qml/qmltube/i18n/qml_" + locale);
#else // fallback for neither Q_WS_X11 nor Q_WS_MAEMO_5 (the orig cutetube code)
        languagePath = viewer.engine()->baseUrl().toLocalFile().append("qml/qmltube/i18n/qml_" + locale);
#endif /* Q_WS_MAEMO_5 */
        QTranslator translator;
        if (translator.load(languagePath)) {
            app.installTranslator(&translator);
        }

        viewer.setMainQmlFile(QLatin1String("qml/qmltube/main.qml"));
        viewer.showExpanded();

        return app.exec();
    }

    else if (args.first() == ("--play")) {
        /* Get the video URL and play the video */

        QString playerUrl = args.at(1);
        QString videoId = playerUrl.split("v=").at(1).split("&").at(0);
        QString quality = "hq";
        if (args.length() > 2) {
            if (args.at(2) == "m") {
                quality = "mobile";
            }
        }
        ct.getMediaPlayerFromDB();
        QObject::connect(&yt, SIGNAL(gotVideoUrl(QString)), &ct, SLOT(playVideo(QString)));
        QObject::connect(&yt, SIGNAL(videoUrlError()), &app, SLOT(quit()));
        QObject::connect(&ct, SIGNAL(playbackStarted(QString)), &app, SLOT(quit()));
        yt.setPlaybackQuality(quality);
        yt.getVideoUrl(videoId);

        return app.exec();
    }
    else {
        qWarning() << "Invalid arguments";
        exit(1);
    }
}
