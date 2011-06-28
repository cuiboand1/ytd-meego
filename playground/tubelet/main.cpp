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

#ifdef Q_WS_X11		// NPM: aka, MeeGo 
#include <QtOpenGL/QGLWidget>	// needed for viewer.setViewport(new QGLWidget()) below.
//#include <QtOpenGL/QGLFormat>
#endif /* Q_WS_X11 */

int main(int argc, char *argv[])
{
#ifdef Q_WS_MAEMO_5
    QApplication::setApplicationName(QString("tubelet"));
#endif
#ifdef Q_WS_X11		// NPM: aka, MeeGo 
    QApplication::setApplicationName(QString("tubelet"));
    // NPM: unless '--raster' command-line option given, this gets
    // overriden by using viewer.setViewport(new QGLWidget()) below
    QApplication::setGraphicsSystem("raster"); 
#endif

    QApplication app(argc, argv);   
    Controller ct;
    YouTube yt;
    bool browser_mode = true;	// NPM
    bool opengl_mode  = true;	// NPM

    QStringList args = app.arguments();
    args.takeFirst();
    if (!args.isEmpty()) {
      QString arrrh = args.first();
      if (arrrh == ("--play")) {
	browser_mode = false;
	args.takeFirst();
	if (!arrrh.isEmpty()) {
	  arrrh = args.first();
	  if (arrrh == ("--raster")) {
	    opengl_mode = false;
	  }
	}
      }
      else if (arrrh == ("--raster")) {
	opengl_mode = false;
      }
      else {
	qWarning() << "Invalid arguments";
	exit(1);
      }
    }

    if (browser_mode) {
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
        viewer.engine()->setOfflineStoragePath("/home/user/.config/tubelet");
        //        viewer.setViewport(new QGLWidget());

        QDir path;
        path.setPath("/home/user/.config/tubelet");
        if (!path.exists()) {
            path.mkpath("/home/user/.config/tubelet");
        }
        path.setPath("/home/user/MyDocs/.tubelet");
        if (!path.exists()) {
            path.mkpath("/home/user/MyDocs/.tubelet");
        }
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo 
//      viewer.addImportPath(QString("/opt/qtm12/imports")); 
//      viewer.addPluginPath(QString("/opt/qtm12/plugins"));
        viewer.engine()->setOfflineStoragePath(QDir::homePath() + "/.config/tubelet");

	if (opengl_mode) {
	  // NPM: trying to understand what these all do as suggested by
	  // http://doc.qt.nokia.com/latest/qt-embeddedlinux-opengl.html
	  // and http://meego.gitorious.org/meego-ux/meego-qml-launcher/blobs/master/src/launcherwindow.cpp#line355
	  // --> LauncherWindow::doSwitchToGLRendering()
	  //
	  // http://doc.qt.nokia.com/latest/qglformat.html#defaultFormat
	  // "Returns the default QGLFormat for the application. All QGLWidget objects that are created use this format unless another format is specified, e.g. when they are constructed."
	  QGLFormat format = QGLFormat::defaultFormat();
	  // http://doc.qt.nokia.com/latest/qglformat.html#setSampleBuffers
	  // "If enable is true, a GL context with multisample buffer support is picked; otherwise ignored."
	  format.setSampleBuffers(false);
	  // http://doc.qt.nokia.com/latest/qglwidget.html#QGLWidget-3
	  // "The format argument specifies the desired rendering options. If the underlying OpenGL/Window system cannot satisfy all the features requested in format, the nearest subset of features will be used. After creation, the format() method will return the actual format obtained. The widget will be invalid if the system has no OpenGL support."
	  QGLWidget* glw = new QGLWidget(format);
	  if (glw->isValid()) {
	    viewer.setViewport(glw);
	    // http://doc.qt.nokia.com/latest/qabstractscrollarea.html#setHorizontalScrollBarPolicy
	    viewer.setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	    // http://doc.qt.nokia.com/latest/qabstractscrollarea.html#verticalScrollBarPolicy-prop
	    viewer.setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	    // http://doc.qt.nokia.com/latest/qgraphicsview.html#ViewportUpdateMode-enum
	    // "When any visible part of the scene changes or is reexposed, QGraphicsView will update the entire viewport. This approach is fastest when QGraphicsView spends more time figuring out what to draw than it would spend drawing (e.g., when very many small items are repeatedly updated). This is the preferred update mode for viewports that do not support partial updates, such as QGLWidget, and for viewports that need to disable scroll optimization."
	    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

	    // http://doc.qt.nokia.com/latest/qt.html#WidgetAttribute-enum
	    // Qt::WA_OpaquePaintEvent -- "The use of WA_OpaquePaintEvent provides a small optimization by helping to reduce flicker on systems that do not support double buffering and avoiding computational cycles necessary to erase the background prior to painting. Note: Unlike WA_NoSystemBackground, WA_OpaquePaintEvent makes an effort to avoid transparent window backgrounds. This flag is set or cleared by the widget's author."
	    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
	    // http://doc.qt.nokia.com/latest/qt.html#WidgetAttribute-enum
	    // Qt::WA_NoSystemBackground -- "Indicates that the widget has no background, i.e. when the widget receives paint events, the background is not automatically repainted. Note: Unlike WA_OpaquePaintEvent, newly exposed areas are never filled with the background (e.g., after showing a window for the first time the user can see "through" it until the application processes the paint events). This flag is set or cleared by the widget's author."
	    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
	    // http://doc.qt.nokia.com/latest/qframe.html#setFrameStyle
	    viewer.setFrameStyle(QFrame::NoFrame); //QFrame draws nothing
	  }
	  else {
	    qWarning() << "Unable to create QGLWidget: suggest trying '--raster' command-line option.";
	  }
	}

        QDir path;
        path.setPath(QDir::homePath() + "/.config/tubelet");
        if (!path.exists()) {
            path.mkpath(QDir::homePath() + "/.config/tubelet");
        }
        path.setPath(QDir::homePath() + "/.tubelet");
        if (!path.exists()) {
            path.mkpath(QDir::homePath() + "/.tubelet");
        }
#endif /* defined(Q_WS_X11) */
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
        languagePath = "/opt/tubelet/qml/qmltube/i18n/qml_" + locale;
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
	//viewer.showExpanded();
	viewer.showFullScreen();

        return app.exec();
    }
    else { //NPM: else play mode
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
}
