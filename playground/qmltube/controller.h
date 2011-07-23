#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QProcess>
#include <QSqlRecord>

#ifdef MEEGO_EDITION_HARMATTAN
#include <qmsystem2/qmdisplaystate.h> //NPM: for "MeeGo::QmDisplayState *"
#endif /* defined(MEEGO_EDITION_HARMATTAN) */

class QWidget;

#include "qmlapplicationviewer.h"

class Controller : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isSymbian
               READ osIsSymbian
               NOTIFY osChanged)
    Q_PROPERTY(bool isHarmattan
               READ osIsHarmattan
               NOTIFY osChanged)
    Q_PROPERTY(bool isMaemo
               READ osIsMaemo
               NOTIFY osChanged)

public:
    explicit Controller(QObject *parent = 0);

    void setView(QmlApplicationViewer* view);
    bool osIsSymbian() const;
    bool osIsHarmattan() const;
    bool osIsMaemo() const;

public slots:

    QString getLanguage() const;
    void setOrientation(const QString &orient);
    QStringList getInstalledMediaPlayers() const;
    bool widgetInstalled() const;
    bool xTubeInstalled() const;
    void setMediaPlayer(const QString &player);
    QString getMediaPlayer() const { return mediaPlayer; }
    void doNotDisturb(bool videoPlaying);
#ifdef MEEGO_EDITION_HARMATTAN
    void preventBlanking();	/* NPM */
#endif /* defined(MEEGO_EDITION_HARMATTAN) */
    void getMediaPlayerFromDB();
    QStringList getProxyFromDB() const;
    void toggleState();
    void minimize();
    void playVideo(const QString &url);
    void deleteVideo(const QString &path);
    void convertToAudio(const QString &input);
    QString archiveFileExists(const QString &filePath, const QString &archivePath) const;
    bool pathExists(const QString &path);
    QString homePath() const;		/* NPM */
    void copyToClipboard(const QString &url);

private slots:
    void conversionFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QmlApplicationViewer *m_view;
    QString mediaPlayer;
    QProcess *converter;
    QString inputFile;
    QString outputFile;
    bool isSymbian;
    bool isHarmattan;		/* NPM */
    bool isMaemo;		/* NPM */
    QObject *qparent;		/* NPM */
    QTimer *blankingtimer;	/* NPM */
#ifdef MEEGO_EDITION_HARMATTAN
    MeeGo::QmDisplayState *displaystate; /* NPM */
#endif /* defined(MEEGO_EDITION_HARMATTAN) */

signals:
    void osChanged();
    void alert(const QString &message);
    void conversionStarted();
    void conversionCompleted();
    void conversionFailed();
    void playbackStarted(const QString &url);
};

#endif // CONTROLLER_H
