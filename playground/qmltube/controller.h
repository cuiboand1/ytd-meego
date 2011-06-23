#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QProcess>
#include <QSqlRecord>

class QWidget;

#include "qmlapplicationviewer.h"

class Controller : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isSymbian
               READ osIsSymbian
               NOTIFY osChanged)

public:
    explicit Controller(QObject *parent = 0);

    void setView(QmlApplicationViewer* view);
    bool osIsSymbian() const;

public slots:

    QString getLanguage() const;
    void setOrientation(const QString &orient);
    QStringList getInstalledMediaPlayers() const;
    bool widgetInstalled() const;
    bool xTubeInstalled() const;
    void setMediaPlayer(const QString &player);
    QString getMediaPlayer() const { return mediaPlayer; }
    void doNotDisturb(bool videoPlaying);
    void keepDisplayOn();
    void getMediaPlayerFromDB();
    QStringList getProxyFromDB() const;
    void toggleState();
    void minimize();
    void playVideo(const QString &url);
    void deleteVideo(const QString &path);
    void convertToAudio(const QString &input);
    QString archiveFileExists(const QString &filePath, const QString &archivePath) const;
    bool pathExists(const QString &path);
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

signals:
    void osChanged();
    void alert(const QString &message);
    void conversionStarted();
    void conversionCompleted();
    void conversionFailed();
    void playbackStarted(const QString &url);
};

#endif // CONTROLLER_H
