#include "downloadmanager.h"

#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QRegExp>
#include <QDebug>
#include <QMap>
#include <QList>
#include <QUrl>

DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent), downloading(false) {
    dlMap["720p"] = 22;
    dlMap["480p"] = 35;
    dlMap["360p"] = 34;
    dlMap["hq"] = 18;
    dlMap["mobile"] = 5;

    connect(this, SIGNAL(gotVideoUrl(QUrl)), this, SLOT(performDownload(QUrl)));
}

void DownloadManager::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void DownloadManager::setDownloadQuality(const QString &quality) {
    downloadFormat = dlMap.value(quality, 18);
}

void DownloadManager::getVideoUrl(const QString &playerUrl) {
    QString url = playerUrl;
    QString videoId = url.split("v=").last().split("&").first();
    QString pageUrl = "http://www.youtube.com/get_video_info?&video_id=" + videoId.toAscii() + "&el=detailpage&ps=default&eurl=&gl=US&hl=en";
    downloadReply = nam->get(QNetworkRequest(QUrl(pageUrl)));
    connect(downloadReply, SIGNAL(finished()), this, SLOT(parseVideoPage()));
}

void DownloadManager::parseVideoPage() {
    if (downloadReply->error()) {
        emit statusChanged("failed");
        return;
    }
    QMap<int, QByteArray> formats;
    QByteArray response = QByteArray::fromPercentEncoding(downloadReply->readAll());
    int pos = response.indexOf("fmt_url_map=") + 12;
    int pos2 = response.indexOf("&allow_ratings", pos);
    int pos3 = response.indexOf("&leanback", pos);
    if ((pos3 > 0) && (pos3 < pos2)) {
        pos2 = pos3;
    }
    response = response.mid(pos, pos2 - pos);
    QList<QByteArray> parts = response.split('|');
    int key = parts.first().toInt();
    for (int i = 1; i < parts.length(); i++) {
        QByteArray part = parts[i];
        QList<QByteArray> keyAndValue = part.split(',');
        QByteArray url = keyAndValue.first();
        formats[key] = url;
        key = keyAndValue.last().toInt();
    }
    QList<int> flist;
    flist << 22 << 35 << 34 << 18 << 5;
    QByteArray videoUrl = "";
    QString quality;
    int index = flist.indexOf(downloadFormat);
    while ((videoUrl == "") && (index < flist.size())) {
        videoUrl = formats.value(flist.at(index), "");
        quality = dlMap.key(flist.at(index));
        index++;
    }
    if (!videoUrl.startsWith("http")) {
        emit statusChanged("failed");
    }
    else {
        emit gotVideoUrl(QUrl::fromEncoded(videoUrl));
        emit qualityChanged(quality);
    }
}

void DownloadManager::getDMVideoUrl(const QString &link) {
    downloadReply = nam->get(QNetworkRequest(QUrl(link)));
    connect(downloadReply, SIGNAL(finished()), this, SLOT(parseDMVideoPage()));
}

void DownloadManager::parseDMVideoPage() {
    if (downloadReply->error()) {
        emit statusChanged("failed");
        return;
    }

    QString response(downloadReply->readAll());
    QString videoUrl = response.split("type=\"video/x-m4v\" href=\"").at(1).split('"').at(0);
//    qDebug() << videoUrl;
    if (!videoUrl.startsWith("http")) {
        emit statusChanged("failed");
    }
    else {
        emit gotVideoUrl(QUrl(videoUrl));
    }
}

void DownloadManager::getVimeoVideoUrl(const QString &link) {
    downloadReply = nam->get(QNetworkRequest(QUrl(link)));
    connect(downloadReply, SIGNAL(finished()), this, SLOT(parseVimeoVideoPage()));
}

void DownloadManager::parseVimeoVideoPage() {
    if (downloadReply->error()) {
        emit statusChanged("failed");
        return;
    }

    QString response(downloadReply->readAll());
    QByteArray id = response.split("\"id\":").at(1).split(',').first().toAscii();
    QByteArray signature = response.split("\"signature\":\"").at(1).split('"').first().toAscii();
    QByteArray timestamp = response.split("\"timestamp\":").at(1).split(',').first().toAscii();
//    qDebug() << "id: " + id << "signature: " + signature << "timestamp: " + timestamp;
    QString videoUrl;
    if ((id.isEmpty()) || (signature.isEmpty()) || (timestamp.isEmpty())) {
        emit statusChanged("failed");
    }
    else {
        videoUrl = "http://player.vimeo.com/play_redirect?quality=mobile&type=mobile_site&clip_id=" + id + "&time=" + timestamp + "&sig=" + signature;
        emit gotVideoUrl(QUrl(videoUrl));
    }
}

void DownloadManager::pauseDownload() {
    downloadReply->abort();
}

void DownloadManager::cancelDownload() {
    downloadReply->abort();
    output.remove();
    emit downloadCancelled();
}

void DownloadManager::startDownload(const QString &filePath, const QString &url) {
    setIsDownloading(true);
    output.setFileName(filePath + ".partial");
    if (output.exists()) {
//                qDebug() << "File exists";
        if (!output.open(QIODevice::Append)) {
                        qDebug() << "No write permissions";
            setIsDownloading(false);
            return;                 // skip this download
        }
    }
    else if (!output.open(QIODevice::WriteOnly)) {
//        qDebug() << "No write permissions";
        emit statusChanged("failed");
        setIsDownloading(false);
        return;                 // skip this download
    }

    if (url.contains("youtube")) {
        // It's a YouTube video, so we must get the URL from the web page

        getVideoUrl(url);
    }
    else if (url.contains("dailymotion")) {
        // It's a DailyMotion video, so we must get the URL from the web page

        getDMVideoUrl(url);
    }
    else if (url.contains("vimeo")) {
        // It's a Vimeo video,  so we must get the URL from the web page

        getVimeoVideoUrl(url);
    }
    else {
        performDownload(QUrl(url));
    }
}

void DownloadManager::performDownload(const QUrl &videoUrl) {
//        qDebug() << videoUrl;
    QNetworkRequest request(videoUrl);

    if (output.size() > 0) {
        request.setRawHeader("Range", "bytes=" + QByteArray::number(output.size()) + "-"); // Set 'Range' header if resuming a download
    }

    downloadReply = nam->get(request);
    emit statusChanged("downloading");
    downloadTime.start();
    connect(downloadReply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(updateProgress(qint64,qint64)));
    connect(downloadReply, SIGNAL(finished()), this, SLOT(downloadFinished()));
    connect(downloadReply, SIGNAL(readyRead()), this, SLOT(downloadReadyRead()));
}

void DownloadManager::updateProgress(qint64 bytesReceived, qint64 bytesTotal) {
    double speed = bytesReceived * 1000.0 / downloadTime.elapsed();
    QString unit;
    if (speed < 1024) {
        unit = "bytes/sec";
    } else if (speed < 1024*1024) {
        speed /= 1024;
        unit = "kB/s";
    } else {
        speed /= 1024*1024;
        unit = "MB/s";
    }

    emit progressChanged(bytesReceived, bytesTotal, QString::fromLatin1("%1 %2")
                         .arg(speed, 3, 'f', 1).arg(unit));
}

void DownloadManager::downloadFinished() {
    QUrl redirect = downloadReply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
//    qDebug() << redirect;
    if (!redirect.isEmpty()) {
        performDownload(redirect); // Follow redirect :P
    }
    else {
        output.close();
        setIsDownloading(false);
        QString status;
        if (downloadReply->error()) {
            if (downloadReply->error() == QNetworkReply::OperationCanceledError) {
                status = "paused";
            }
            else {
                output.remove();
                status = "failed";
            }
            emit statusChanged(status);
        }
        else {
            QString filename = output.fileName().left(output.fileName().lastIndexOf("."));
            int num = 1;
            bool fileSaved = output.rename(filename);
            while ((!fileSaved) && (num < 10)) {
                if (num == 1) {
                    filename = filename.insert(filename.lastIndexOf("."), "(" + QByteArray::number(num) + ")");
                }
                else {
                    filename = filename.replace(filename.lastIndexOf("(" + QByteArray::number(num - 1) + ")"), 3, "(" + QByteArray::number(num) + ")");
                }
                //                qDebug() << filename;
                fileSaved = output.rename(filename);
                num++;
            }
            emit downloadCompleted(filename);
        }
    }
}

void DownloadManager::downloadReadyRead() {
    output.write(downloadReply->readAll());
}
