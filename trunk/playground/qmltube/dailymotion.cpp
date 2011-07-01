#include "dailymotion.h"
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QString>
#include <QUrl>
#include <QDebug>
#include <QStringList>
#include <QDateTime>

DailyMotion::DailyMotion(QObject *parent) :
    QObject(parent), clientId("5dae8d881f02f2b4f641"), clientSecret("d08c9c72ed843cd4be501145cfa22bd0b2ff2775") {
    emit clientIdChanged();
    emit clientSecretChanged();
}

void DailyMotion::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void DailyMotion::setUserCredentials(const QString &user, const QString &aToken, const QString &rToken, const int &expiry) {
    setCurrentUser(user);
    setAccessToken(aToken);
    setRefreshToken(rToken);
    setTokenExpiry(expiry);
}

void DailyMotion::setCurrentUser(const QString &user) {
    currentUser = user;
    emit currentUserChanged();
}

void DailyMotion::setAccessToken(const QString &token) {
    accessToken = token;
    emit accessTokenChanged();
}

void DailyMotion::setRefreshToken(const QString &token) {
    refreshToken = token;
}

void DailyMotion::setTokenExpiry(int expiry) {
    tokenExpiry = expiry;
}

void DailyMotion::postRequest(const QUrl &url, const QByteArray &data) {
    /* Helper method that posts HTTP POST requests */

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", "OAuth " + accessToken.toAscii());
    QNetworkReply* reply = nam->post(request, data);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void DailyMotion::deleteRequest(const QUrl &url) {
    /* Helper method that posts HTTP DELETE requests */

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", "OAuth " + accessToken.toAscii());
    QNetworkReply* reply = nam->deleteResource(request);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void DailyMotion::postFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        emit alert(tr("Error - Dailymotion server unreachable"));
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray statusText = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
    //    qDebug() << "Status is:" << statusCode << ":" << statusText;
    if ((statusCode == 200) || (statusCode == 201)) {
        emit postSuccessful();
    }
    else {
        emit alert(tr("Error - ") + statusText);
    }
    disconnect(this, SIGNAL(postSuccessful()), 0, 0);
    disconnect(this, SIGNAL(postFailed()), 0, 0);
    reply->deleteLater();
}

void DailyMotion::addToFavourites(const QString &id) {
    QUrl url("https://api.dailymotion.com/video/" + id + "/like");
    postRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(addedToFavourites()));
}

void DailyMotion::deleteFromFavourites(const QString &id) {
    QUrl url("https://api.dailymotion.com/video/" + id + "/like");
    deleteRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(deletedFromFavourites()));
}

void DailyMotion::getVideoUrl(const QString &id) {
    QString url = "http://iphone.dailymotion.com/video/" + id;
    QNetworkReply* reply = nam->get(QNetworkRequest(QUrl(url)));
    connect(reply, SIGNAL(finished()), this, SLOT(parseVideoPage()));
}

void DailyMotion::parseVideoPage() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (reply->error()) {
        emit videoUrlError();
        return;
    }

    QString response(reply->readAll());
    QString videoUrl = response.split("type=\"video/x-m4v\" href=\"").at(1).split("\"").at(0);
    if (!videoUrl.startsWith("http")) {
        emit videoUrlError();
    }
    else {
        emit gotVideoUrl(videoUrl);
    }
}

void DailyMotion::uploadVideo(const QString &filename) {
    emit uploadStatusChanged("preparing");
    fileToBeUploaded = new QFile(filename);
    if (!fileToBeUploaded->exists()) {
        emit uploadStatusChanged("failed");
        return;
    }

    QNetworkRequest request(QUrl("https://api.dailymotion.com/file/upload"));
    request.setRawHeader("Authorization", "OAuth " + accessToken.toAscii());
    uploadReply = nam->get(request);
    connect(uploadReply, SIGNAL(finished()), this, SLOT(setUploadUrl()));
}

void DailyMotion::setUploadUrl() {
    if (uploadReply->error()) {
        emit uploadStatusChanged("failed");
        return;
    }

    int statusCode = uploadReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    //    QByteArray statusText = uploadReply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
    //qDebug() << "Status is:" << statusCode << ":" << statusText;
    if (statusCode == 200) {
        QString response(uploadReply->readAll().replace(" ", "").replace("\\", ""));
//        qDebug() << response;
        uploadUrl = QUrl(response.split("upload_url\":\"").at(1).split("\"").first());
//        qDebug() << uploadUrl;
        performVideoUpload();
    }
    else {
        emit uploadStatusChanged("failed");
    }
}

void DailyMotion::performVideoUpload() {
    fileToBeUploaded->open(QIODevice::ReadOnly);
    QNetworkRequest request(uploadUrl);
    request.setRawHeader("Authorization", "OAuth " + accessToken.toAscii());
    uploadReply = nam->post(request, fileToBeUploaded);
    connect(uploadReply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(updateUploadProgress(qint64,qint64)));
    connect(uploadReply, SIGNAL(finished()), this, SLOT(uploadFinished()));
    emit uploadStatusChanged("started");
    uploadTime.start();
}

void DailyMotion::updateUploadProgress(qint64 bytesSent, qint64 bytesTotal) {
    double speed = bytesSent * 1000.0 / uploadTime.elapsed();
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

    emit uploadProgressChanged(bytesSent, bytesTotal, QString::fromLatin1("%1 %2")
                               .arg(speed, 3, 'f', 1).arg(unit));
}

void DailyMotion::uploadFinished() {
    fileToBeUploaded->close();

    if (uploadReply->error()) {
        if (uploadReply->error() == QNetworkReply::OperationCanceledError) {
            emit uploadStatusChanged("aborted");
            return;
        }
        else {
            emit uploadStatusChanged("failed");
        }
    }
    else {
        QString response(uploadReply->readAll().replace(" ", ""));
//        qDebug() << response;
        QString uploadId = response.split("id\":\"").at(1).split("\"").first();
//        qDebug() << uploadId;
        emit waitingForMetadata(uploadId);
    }
}

void DailyMotion::setUploadMetadata(const QString &id, const QString &title, const QString &description, const QString &tags, const QString &category, const bool &isPrivate) {
    QUrl url("https://api.dailymotion.com/video/" + id);

    QByteArray p("false");
    if (isPrivate) {
        p = "true";
    }
    QByteArray metadata("title=" + title.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") \
                        + "&description=" + description.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") \
                        + "&tags=[" + tags.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") \
                        + "]&channel=" + category.toAscii() \
                        + "&private=" + p);
    postRequest(url, metadata);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(uploadCompleted()));
    connect(this, SIGNAL(postFailed()), this, SIGNAL(uploadFailed()));
}
