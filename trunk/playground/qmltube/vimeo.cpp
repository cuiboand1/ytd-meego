#include "vimeo.h"
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QString>
#include <QUrl>
#include <QDebug>
#include <QStringList>

Vimeo::Vimeo(QObject *parent) :
    QObject(parent), clientId("a103802febba99b02f1e8ab31b53e9b3"), clientSecret("94441c03d12fc5ab") {
    emit clientIdChanged();
    emit clientSecretChanged();
}

void Vimeo::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void Vimeo::setUserCredentials(const QString &user, const QString &token, const QString &secret) {
    setCurrentUser(user);
    setAccessToken(token);
    setTokenSecret(secret);
}

void Vimeo::setCurrentUser(const QString &user) {
    currentUser = user;
    emit currentUserChanged();
}

void Vimeo::setAccessToken(const QString &token) {
    accessToken = token;
    emit accessTokenChanged();
}

void Vimeo::setTokenSecret(const QString &secret) {
    tokenSecret = secret;
    emit tokenSecretChanged();
}

void Vimeo::getVideoUrl(const QString &id) {
    QString url = "http://vimeo.com/" + id;
    QNetworkReply* reply = nam->get(QNetworkRequest(QUrl(url)));
    connect(reply, SIGNAL(finished()), this, SLOT(parseVideoPage()));
}

void Vimeo::parseVideoPage() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (reply->error()) {
        emit videoUrlError();
        reply->deleteLater();
        return;
    }
    QString response(reply->readAll());
//    qDebug() << response;
    QByteArray id = response.split("\"id\":").at(1).split(',').first().toAscii();
    QByteArray signature = response.split("\"signature\":\"").at(1).split('"').first().toAscii();
    QByteArray timestamp = response.split("\"timestamp\":").at(1).split(',').first().toAscii();
    //    qDebug() << "id: " + id << "signature: " + signature << "timestamp: " + timestamp;
    QString videoUrl;
    if ((id.isEmpty()) || (signature.isEmpty()) || (timestamp.isEmpty())) {
        emit videoUrlError();
        reply->deleteLater();
    }
    else {
        videoUrl = "http://player.vimeo.com/play_redirect?quality=mobile&type=mobile_site&clip_id=" + id + "&time=" + timestamp + "&sig=" + signature;
//        qDebug() << videoUrl;
        reply = nam->get(QNetworkRequest(QUrl(videoUrl)));
        connect(reply, SIGNAL(finished()), this, SLOT(checkVideoUrl()));
    }
}

void Vimeo::checkVideoUrl() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (reply->error()) {
        emit videoUrlError();
        reply->deleteLater();
        return;
    }
    QString redirect = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toString();
//    qDebug() << redirect;
    if (redirect.startsWith("http://av.vimeo.com")) {
        emit gotVideoUrl(redirect);
    }
    else {
        emit videoUrlError();
    }
    reply->deleteLater();
}

void Vimeo::postRequest(const QString &url, const QString &header) {
    /* Helper method that posts HTTP POST requests */

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("Authorization", header.toAscii());
    QNetworkReply* reply = nam->post(request, QByteArray());
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void Vimeo::postFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        emit alert(tr("Error - Vimeo server unreachable"));
        return;
    }

//    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
//    QByteArray statusText = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
//    qDebug() << "Status is:" << statusCode << ":" << statusText;
    QString response(reply->readAll());
//    qDebug() << response;
    if (response.contains("err\":")) {
        emit alert(tr("Error - ") + response.split("msg\":\"").at(1).split("\"").first());
    }
    else {
        emit postSuccessful();
    }
    disconnect(this, SIGNAL(postSuccessful()), 0, 0);
    disconnect(this, SIGNAL(postFailed()), 0, 0);
    reply->deleteLater();
}

void Vimeo::deleteRequest(const QString &url, const QString &header) {
    /* Helper method that posts HTTP DELETE requests */

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("Authorization", header.toAscii());
    QNetworkReply* reply = nam->deleteResource(request);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void Vimeo::addToFavourites(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(addedToFavourites()));
}

void Vimeo::deleteFromFavourites(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(deletedFromFavourites()));
}

void Vimeo::addToPlaylist(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(addedToPlaylist()));
}

void Vimeo::deleteFromPlaylist(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(deletedFromPlaylist()));
}

void Vimeo::addComment(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(commentAdded()));
}

void Vimeo::createNewPlaylist(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(playlistCreated()));
}

void Vimeo::deletePlaylist(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(playlistDeleted()));
}

void Vimeo::subscribeToChannel(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(subscribed()));
}

void Vimeo::unsubscribeToChannel(const QString &url, const QString &header) {
    postRequest(url, header);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(unsubscribed()));
}
