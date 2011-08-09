#include "qmlapplicationviewer.h"
#include "controller.h"
#include "youtube.h"
#include "dailymotion.h"
#include "vimeo.h"
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
// NPM: HACK/WORKAROUND FOR QT 4.7. Need to setup networking to not puke on
// SSL errors, which prevented Bugzibit example from working with
// https://bugs.meego.com due to its SSL implementation and certificate.
// This workaround will not be necessary at some point per Thiago's comment
// "QSslSocket does not send the Server Name Identification SSL extension
// [in Qt 4.7] ... QSslSocket in Qt 4.8 does send SNI now."  (
// http://lists.meego.com/pipermail/meego-dev/2011-May/482965.html
// http://lists.meego.com/pipermail/meego-dev/2011-May/482968.html ). For
// details on technique, see
// http://www.developer.nokia.com/Community/Wiki/Why_does_QML_require_QDeclarativeNetworkAccessManagerFactory
// http://www.qtcentre.org/threads/21470-SSL-Problem
class MyNetworkAccessManager : public QNetworkAccessManager {
public:
  MyNetworkAccessManager ();
  MyNetworkAccessManager (QObject *parent);

protected:
  QNetworkReply *createRequest(Operation op, const QNetworkRequest &req, QIODevice *outgoingData = 0);
};

MyNetworkAccessManager::MyNetworkAccessManager () {
}
MyNetworkAccessManager::MyNetworkAccessManager (QObject *parent) {
}
QNetworkReply *MyNetworkAccessManager::createRequest ( Operation op, const QNetworkRequest &req, QIODevice *outgoingData ) {
    QSslConfiguration config = req.sslConfiguration();
    config.setPeerVerifyMode(QSslSocket::VerifyNone);
    config.setProtocol(QSsl::TlsV1);
    QNetworkRequest request(req);
    request.setSslConfiguration(config);
    return QNetworkAccessManager::createRequest(op, request, outgoingData);
    //NPM: Alternative implementation, which is more of a hack?
    //QNetworkReply* reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    //reply->ignoreSslErrors();
    //return reply;
}

class MyNetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory {
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};
QNetworkAccessManager *MyNetworkAccessManagerFactory::create(QObject *parent) {
    QNetworkAccessManager *nam = new MyNetworkAccessManager(parent); // NPM:
    qDebug() << "MyNetworkAccessManagerFactory::create()'d nam=" << nam;
    //TODO: make this work with proxyHost below
//    if (!proxyHost.isEmpty()) {
//        qDebug() << "Created QNetworkAccessManager using proxy" << (proxyHost + ":" + QString::number(proxyPort));
//        QNetworkProxy proxy(QNetworkProxy::HttpCachingProxy, proxyHost, proxyPort);
//        nam->setProxy(proxy);
//    }
    return nam;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);   
    QApplication::setApplicationName(QString("cuteTube"));
    /* NPM: note these are stack-allocated objects and can't be placed in
       lexical proximity to their uses because they'll be out of scope,
       potentially, by the time they are referenced again. */
    Controller ct;
    YouTube yt;
    DailyMotion daily;
    Vimeo vimeo;
    Sharing sh;
    DownloadManager dm;
    QmlApplicationViewer viewer;

    bool browser_mode = true;	// NPM
    bool opengl_mode  = true;	// NPM

#ifdef Q_WS_X11		// NPM: aka, MeeGo 
    // NPM: unless '--raster' command-line option given, this gets
    // overriden by using viewer.setViewport(new QGLWidget()) below
    QApplication::setGraphicsSystem(QString::fromLatin1("raster")); 
#endif /* defined(Q_WS_X11) */
#ifdef MEEGO_EDITION_HARMATTAN
    QApplication::setFont(QFont("Nokia Pure Text", 16));
#endif /* defined(MEEGO_EDITION_HARMATTAN) */
#ifdef MEEGO_HAS_POLICY_FRAMEWORK
    // http://harmattan-dev.nokia.com/unstable/beta/api_refs/xml/daily-docs/libresourceqt/
    ResourcePolicy::ResourceSet* mySet = new ResourcePolicy::ResourceSet("player");
    mySet->setAlwaysReply();
    ResourcePolicy::AudioResource *audioResource = new ResourcePolicy::AudioResource("player");
    audioResource->setProcessID(QCoreApplication::applicationPid());
    audioResource->setStreamTag("media.name", "*");
    mySet->addResourceObject(audioResource);
    mySet->addResource(ResourcePolicy::VideoPlaybackType);
    QObject::connect(mySet, SIGNAL(resourcesGranted(QList<ResourcePolicy::ResourceType>)), &ct, SLOT(notifyResourcesGranted()));
    QObject::connect(mySet, SIGNAL(resourcesDenied()), &ct, SLOT(notifyResourcesDenied()));
    mySet->acquire();
    QObject::connect(mySet, SIGNAL(lostResources()), &ct, SLOT(notifyResourcesLost()));
#endif /* defined(MEEGO_HAS_POLICY_FRAMEWORK) */

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
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
        viewer.setAttribute(Qt::WA_NoSystemBackground);
        QDeclarativeContext *context = viewer.rootContext();
        ct.setView(&viewer);

	// Setup any QML-invoked networking to not puke on SSL errors, which prevented QML WebKit invoked
	// Bugzibit example from working with https://bugs.meego.com due to its SSL implementation and certificate.
	// suggested by http://www.developer.nokia.com/Community/Wiki/Why_does_QML_require_QDeclarativeNetworkAccessManagerFactory
	viewer.engine()->setNetworkAccessManagerFactory(new MyNetworkAccessManagerFactory); 
        QNetworkAccessManager *manager = new MyNetworkAccessManager();
        yt.setNetworkAccessManager(manager);
        dm.setNetworkAccessManager(manager);
        sh.setNetworkAccessManager(manager);
        daily.setNetworkAccessManager(manager);
        vimeo.setNetworkAccessManager(manager);

        context->setContextProperty("Controller", &ct);
        context->setContextProperty("DownloadManager", &dm);
        context->setContextProperty("YouTube", &yt);
        context->setContextProperty("Sharing", &sh);
        context->setContextProperty("DailyMotion", &daily);
        context->setContextProperty("Vimeo", &vimeo);

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
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo AND Harmattan
	// Even though Harmattan has /home/user/MyDocs it appears other apps store
	// local info in /home/user, e.g. /home/user/.qcamera /home/user/.facebook etc.
	// thus leave configuration directory location same for both MeeGo and Harmattan
        viewer.engine()->setOfflineStoragePath(QDir::homePath() + "/.config/cutetube");

        QDir path;
        path.setPath(QDir::homePath() + "/.config/cutetube");
        if (!path.exists()) {
            path.mkpath(QDir::homePath() + "/.config/cutetube");
        }

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
#elif defined(Q_WS_X11)		// NPM: aka, MeeGo & Harmattan, Linux
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

	/* NPM: the following sequence of ifdefs was viewer.showExpanded()
	   but it didn't do right thing on Harmattan, so replaced with ifdefs
	   below.... see: http://forum.meego.com/showthread.php?p=27001 
	   "Patch to get rid of "gray bar" in QtCreator's qmlapplicationviewer" .
	*/
#ifdef Q_OS_SYMBIAN
	viewer.showFullScreen();
#elif defined(Q_WS_MAEMO_5)
	viewer.showMaximized();
#elif defined(MEEGO_EDITION_HARMATTAN)
	viewer.showFullScreen();
#elif defined(Q_WS_MEEGO)
	viewer.showMaximized();
#else // desktop linux, meego netbook/tablet, etc.
	viewer.show();
#endif
        return app.exec();
    }
    else { //NPM: else play mode
        /* Get the video URL and play the video */

        ct.getMediaPlayerFromDB();
        QObject::connect(&ct, SIGNAL(playbackStarted(QString)), &app, SLOT(quit()));

        QString playerUrl = args.at(1);
        QString videoId;
        if (playerUrl.contains("youtube")) {

            QString quality = "hq";
            if (args.length() > 2) {
                if (args.at(2) == "m") {
                    quality = "mobile";
                }
            }
            videoId = playerUrl.split("v=").at(1).split("&").at(0);
            yt.setPlaybackQuality(quality);
            yt.getVideoUrl(videoId);
            QObject::connect(&yt, SIGNAL(gotVideoUrl(QString)), &ct, SLOT(playVideo(QString)));
            QObject::connect(&yt, SIGNAL(videoUrlError()), &app, SLOT(quit()));
        }
        else if (playerUrl.contains("dailymotion")) {
            videoId = playerUrl.split("/").last();
            daily.getVideoUrl(videoId);
            QObject::connect(&daily, SIGNAL(gotVideoUrl(QString)), &ct, SLOT(playVideo(QString)));
            QObject::connect(&daily, SIGNAL(videoUrlError()), &app, SLOT(quit()));
        }
        else if (playerUrl.contains("vimeo")) {
            videoId = playerUrl.split("/").last();
            vimeo.getVideoUrl(videoId);
            QObject::connect(&vimeo, SIGNAL(gotVideoUrl(QString)), &ct, SLOT(playVideo(QString)));
            QObject::connect(&vimeo, SIGNAL(videoUrlError()), &app, SLOT(quit()));
        }

        return app.exec();
    }
}
