#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QUrl>
#include <QFile>
#include <QDir>
#include <QList>
#include <QTime>

class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;

class DownloadManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isDownloading
               READ isDownloading
               NOTIFY downloadingChanged)

public:
    explicit DownloadManager(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    bool isDownloading() const { return downloading; }

signals:

public slots:
    void setDownloadQuality(const QString &quality);
    void startDownload(const QString &filePath, const QString &url);
    void pauseDownload();
    void cancelDownload();

private slots:
    void parseVideoPage(QNetworkReply *reply);
    void parseDMVideoPage();
    void parseVimeoVideoPage();
    void getVideoUrl(const QString &playerUrl);
    void getDMVideoUrl(const QString &link);
    void getVimeoVideoUrl(const QString &link);
    void performDownload(const QUrl &videoUrl);
    void updateProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished();
    void downloadReadyRead();
    void setIsDownloading(const bool isDownloading) { downloading = isDownloading; emit downloadingChanged(); }

private:
    QNetworkAccessManager *nam;
    int downloadFormat;
    QHash<QString, int> dlMap;
    QFile output;
    QNetworkReply *downloadReply;
    QTime downloadTime;
    bool downloading;

signals:
    void alert(const QString &message);
    void gotVideoUrl(const QUrl &videoUrl);
    void downloadCompleted(const QString &filename);
    void downloadCancelled();
    void statusChanged(const QString &status);
    void progressChanged(qint64 bytesReceived, qint64 bytesTotal, const QString &speed);
    void qualityChanged(const QString quality);
    void downloadingChanged();
};

#endif // DOWNLOADMANAGER_H
