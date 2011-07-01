#include "youtube.h"
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QString>
#include <QRegExp>
#include <QUrl>
#include <QDebug>
#include <QMap>
#include <QStringList>
#include <QTimer>

YouTube::YouTube(QObject *parent) :
    QObject(parent), developerKey("AI39si6x9O1gQ1Z_BJqo9j2n_SdVsHu1pk2uqvoI3tVq8d6alyc1og785IPCkbVY3Q5MFuyt-IFYerMYun0MnLdQX5mo2BueSw"), playbackFormat(18) {
    pbMap["720p"] = 22;
    pbMap["480p"] = 35;
    pbMap["360p"] = 34;
    pbMap["hq"] = 18;
    pbMap["mobile"] = 5;
}

void YouTube::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void YouTube::setPlaybackQuality(const QString &quality) {
    playbackFormat = pbMap.value(quality, 18);
}

void YouTube::setUserCredentials(const QString &user, const QString &token) {
    setCurrentUser(user);
    setAccessToken(token);
}

void YouTube::setCurrentUser(const QString &user) {
    currentUser = user;
    emit currentUserChanged();
}

void YouTube::setAccessToken(const QString &token) {
    accessToken = token;
    emit accessTokenChanged();
}

void YouTube::uploadVideo(const QString &filename, const QString &title, const QString &description, const QString &tags, const QString &category, const bool &isPrivate) {

    emit uploadStatusChanged("preparing");
    fileToBeUploaded = new QFile(filename);
    if (!fileToBeUploaded->exists()) {
        emit uploadStatusChanged("failed");
        return;
    }

    QUrl url("http://uploads.gdata.youtube.com/resumable/feeds/api/users/default/uploads");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:media=\"http://search.yahoo.com/mrss/\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<media:group>\n" \
                   "<media:title>" + title.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</media:title>\n" \
                   "<media:description>\n" + description.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "\n\n" +
#ifdef Q_WS_MAEMO_5
                   "Uploaded via cuteTube\n</media:description>\n"
#elif (defined(Q_WS_X11))	// NPM: aka, MeeGo 
                   "Uploaded via cuteTube for MeeGo\n</media:description>\n"
#else
                   "Uploaded via cuteTube on Symbian\n</media:description>\n"
#endif
                   "<media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\">\n" + category.toAscii() + "\n</media:category>\n" \
                   "<media:keywords>" + tags.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</media:keywords>\n" \
                   "</media:group>\n" \
                   "</entry>");

    if (isPrivate) {
        int index = xml.lastIndexOf("<");
        xml.insert(index, "<yt:private/>\n");
    }

    QNetworkRequest request(url);
    request.setRawHeader("Host", "uploads.gdata.youtube.com");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/atom+xml; charset=UTF-8");
    request.setHeader(QNetworkRequest::ContentLengthHeader, xml.length());
    request.setRawHeader("Authorization", "AuthSub token=" + accessToken.toAscii());
    request.setRawHeader("GData-Version", "2");
    request.setRawHeader("X-Gdata-Key", "key=" + developerKey);
    request.setRawHeader("Slug", filename.split("/").last().toAscii());
    uploadReply = nam->post(request, xml);
    connect(uploadReply, SIGNAL(finished()), this, SLOT(setUploadUrl()));
}

void YouTube::setUploadUrl() {
    if (uploadReply->error())
        return;

    int statusCode = uploadReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray statusText = uploadReply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
    //qDebug() << "Status is:" << statusCode << ":" << statusText;
    if (statusCode == 200) {
        uploadUrl = QUrl(uploadReply->rawHeader("Location"));
        //        qDebug() << uploadUrl;
        performVideoUpload();
    }
    else {
        emit alert(tr("Error - Server repsonse is: ") + statusText);
        emit uploadStatusChanged("failed");
    }
}

void YouTube::performVideoUpload() {
    uploadRetries = 3;

    fileToBeUploaded->open(QIODevice::ReadOnly);
    QNetworkRequest request(uploadUrl);
    request.setRawHeader("Host", "uploads.gdata.youtube.com");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
    request.setHeader(QNetworkRequest::ContentLengthHeader, fileToBeUploaded->size());
    uploadReply = nam->put(request, fileToBeUploaded);
    connect(uploadReply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(updateUploadProgress(qint64,qint64)));
    connect(uploadReply, SIGNAL(finished()), this, SLOT(uploadFinished()));
    emit uploadStatusChanged("started");
    uploadTime.start();
}

void YouTube::updateUploadProgress(qint64 bytesSent, qint64 bytesTotal) {
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

void YouTube::resumeVideoUpload() {
    uploadRetries--;

    QByteArray rangeHeader = uploadReply->rawHeader("Range");
    QByteArray startByte = rangeHeader.split('-').last();
    QByteArray locationHeader = uploadReply->rawHeader("Location");

    //qDebug() << rangeHeader << startByte << locationHeader;

    if (locationHeader.length() > 0) {
        uploadUrl = QUrl(locationHeader);
    }

    fileToBeUploaded->open(QIODevice::ReadOnly);
    int fs = fileToBeUploaded->size();
    QByteArray fileSize = QByteArray::number(fs);
    QByteArray endByte = QByteArray::number(fs - 1);
    QByteArray range(startByte + '-' + endByte + '/' + fileSize);
    QNetworkRequest request(uploadUrl);
    request.setRawHeader("Host", "uploads.gdata.youtube.com");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
    request.setHeader(QNetworkRequest::ContentLengthHeader, fs - startByte.toInt());
    request.setRawHeader("Content-Range", range);
    uploadReply = nam->put(request, fileToBeUploaded);
    connect(uploadReply, SIGNAL(uploadProgress(qint64,qint64)), this, SIGNAL(updateUploadProgress(qint64,qint64)));
    connect(uploadReply, SIGNAL(finished()), this, SLOT(uploadFinished()));
    emit uploadStatusChanged("started");
}

void YouTube::abortVideoUpload() {
    uploadReply->abort();
    fileToBeUploaded->close();
    emit uploadStatusChanged("aborted");
}

void YouTube::uploadFinished() {
    fileToBeUploaded->close();

    if (uploadReply->error()) {
        if (uploadReply->error() == QNetworkReply::OperationCanceledError) {
            emit uploadStatusChanged("aborted");
            return;
        }
        else {
            int statusCode = uploadReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            if (statusCode == 308) {
                if (uploadRetries > 0) {
                    emit uploadStatusChanged("interrupted");
                    QTimer::singleShot(3000, this, SLOT(resumeVideoUpload()));
                }
                else {
                    emit uploadStatusChanged("failed");
                }
            }
        }
    }
    else {
        emit uploadStatusChanged("completed");
    }
}

void YouTube::postRequest(const QUrl &url, const QByteArray &xml) {
    /* Helper method that posts HTTP POST requests */

    QNetworkRequest request(url);
    request.setRawHeader("Host", "gdata.youtube.com");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/atom+xml");
    request.setHeader(QNetworkRequest::ContentLengthHeader, xml.length());
    request.setRawHeader("Authorization", "AuthSub token=" + accessToken.toAscii());
    request.setRawHeader("GData-Version", "2");
    request.setRawHeader("X-Gdata-Key", "key=" + developerKey);
    QNetworkReply* reply = nam->post(request, xml);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void YouTube::postFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        emit alert(tr("Error - YouTube server unreachable"));
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray statusText = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
    //    qDebug() << "Status is:" << statusCode << ":" << statusText;
    if ((statusCode == 200) || (statusCode == 201)) {
        emit postSuccessful();
    }
    else if ((statusText == "Bad Request") || ((statusText == "Forbidden") && !(currentUser == ""))) {
        emit postFailed();
    }
    else {
        emit alert(tr("Error - Server repsonse is: ") + statusText);
    }
    disconnect(this, SIGNAL(postSuccessful()), 0, 0);
    disconnect(this, SIGNAL(postFailed()), 0, 0);
    reply->deleteLater();
}

void YouTube::deleteRequest(const QUrl &url) {
    /* Helper method that posts HTTP DELETE requests */

    QNetworkRequest request(url);
    request.setRawHeader("Host", "gdata.youtube.com");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/atom+xml");
    request.setRawHeader("Authorization", "AuthSub token=" + accessToken.toAscii());
    request.setRawHeader("GData-Version", "2");
    request.setRawHeader("X-Gdata-Key", "key=" + developerKey);
    QNetworkReply* reply = nam->deleteResource(request);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
}

void YouTube::addToFavourites(const QString &videoId) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/default/favorites");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\">\n" \
                   "<id>" + videoId.toAscii() + "</id>\n" \
                   "</entry>");
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(addedToFavourites()));
    connect(this, SIGNAL(postFailed()), this, SIGNAL(videoInFavourites()));
}

void YouTube::deleteFromFavourites(const QString &favouriteId) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/" + currentUser + "/favorites/" + favouriteId);
    deleteRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(deletedFromFavourites()));
}

void YouTube::addToPlaylist(const QString &videoId, const QString &playlistId) {
    QUrl url("http://gdata.youtube.com/feeds/api/playlists/" + playlistId);
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<id>" + videoId.toAscii() + "</id>\n" \
                   "</entry>");
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(addedToPlaylist()));
}

void YouTube::deleteFromPlaylist(const QString &playlistId, const QString &playlistVideoId) {
    QUrl url("http://gdata.youtube.com/feeds/api/playlists/" + playlistId + "/" + playlistVideoId);
    deleteRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(deletedFromPlaylist()));
}

void YouTube::createNewPlaylist(const QString &title, const QString &description, const bool &isPrivate) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/default/playlists");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<title>" + title.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</title>\n" \
                   "<summary>" + description.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</summary>\n" \
                   "</entry>");
    if (isPrivate) {
        int index = xml.lastIndexOf("<");
        xml.insert(index, "<yt:private/>\n");
    }
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(playlistCreated()));
}

void YouTube::deletePlaylist(const QString &playlistId) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/" + currentUser + "/playlists/" + playlistId);
    deleteRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(playlistDeleted()));
}

void YouTube::subscribeToChannel(const QString &username) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/default/subscriptions");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<category scheme=\"http://gdata.youtube.com/schemas/2007/subscriptiontypes.cat\"\n" \
                   "term=\"channel\"/>\n" \
                   "<yt:username>" + username.toAscii() + "</yt:username>\n" \
                   "</entry>");
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(subscribed()));
}

void YouTube::unsubscribeToChannel(const QString &subscriptionId) {
    QUrl url("http://gdata.youtube.com/feeds/api/users/" + currentUser + "/subscriptions/" + subscriptionId);
    deleteRequest(url);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(unsubscribed()));
}

void YouTube::rateVideo(const QString &videoId, const QString &likeOrDislike) {
    QUrl url("http://gdata.youtube.com/feeds/api/videos/" + videoId + "/ratings");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<yt:rating value=\"" + likeOrDislike.toAscii() + "\"/>\n" \
                   "</entry>");
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(videoRated()));
    connect(this, SIGNAL(postFailed()), this, SIGNAL(cannotRate()));
}

void YouTube::addComment(const QString &videoId, const QString &comment) {
    QUrl url("http://gdata.youtube.com/feeds/api/videos/" + videoId + "/comments");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<content>" + comment.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</content>\n" \
                   "</entry>");
    postRequest(url, xml);
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(commentAdded()));
}

void YouTube::replyToComment(const QString &videoId, const QString &commentId, const QString &comment) {
    QUrl url("http://gdata.youtube.com/feeds/api/videos/" + videoId + "/comments");
    QByteArray xml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
                   "<entry xmlns=\"http://www.w3.org/2005/Atom\"\n" \
                   "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">\n" \
                   "<link rel=\"http://gdata.youtube.com/schemas/2007#in-reply-to\"\n" \
                   "type=\"application/atom+xml\"\n" \
                   "href=\"http://gdata.youtube.com/feeds/api/videos/" + videoId.toAscii() + "/comments/" + commentId.toAscii() + "\"/>\n" \
                   "<content>" + comment.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?") + "</content>\n" \
                   "</entry>");
    postRequest(url, xml);
}

void YouTube::getVideoUrl(const QString &videoId) {
    QString playerUrl = "http://www.youtube.com/get_video_info?&video_id=" + videoId + "&el=detailpage&ps=default&eurl=&gl=US&hl=en";
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(playerUrl));
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(parseVideoPage(QNetworkReply*)));
    manager->get(request);
}

void YouTube::parseVideoPage(QNetworkReply *reply) {
    QNetworkAccessManager *manager = qobject_cast<QNetworkAccessManager*>(sender());

    QMap<int, QByteArray> formats;
    QByteArray response = QByteArray::fromPercentEncoding(reply->readAll());
//        qDebug() << response;
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
        QByteArray url = keyAndValue.first().replace("%2C", ",");
        formats[key] = url;
        key = keyAndValue.last().toInt();
    }
    QList<int> flist;
    flist << 22 << 35 << 34 << 18 << 5;
    QByteArray videoUrl = "";
    int index = flist.indexOf(playbackFormat);
    while ((videoUrl == "") && index < flist.size()) {
        videoUrl = formats.value(flist.at(index), "");
        index++;
    }
    if (videoUrl.isEmpty()) {
        emit alert(tr("Error: Unable to retrieve video"));
        emit videoUrlError();
    }
    else {
        emit gotVideoUrl(QString(videoUrl));
    }
    //    qDebug() << videoUrl;
    reply->deleteLater();
    manager->deleteLater();
}

void YouTube::getLiveVideoUrl(const QString &videoId) {
    QString playerUrl = "http://www.youtube.com/get_video_info?&video_id=" + videoId + "&el=detailpage&ps=default&eurl=&gl=US&hl=en";
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(playerUrl));
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(parseLiveVideoPage(QNetworkReply*)));
    manager->get(request);
}

void YouTube::parseLiveVideoPage(QNetworkReply *reply) {
    QNetworkAccessManager *manager = qobject_cast<QNetworkAccessManager*>(sender());

    QByteArray response = reply->readAll();
    response = QByteArray::fromPercentEncoding(response.simplified().replace(QByteArray(" "), QByteArray("")));
//    qDebug() << response;
    int pos = response.indexOf("fmt_stream_map=") + 18;
    int pos2 = response.indexOf('|', pos);
    response = response.mid(pos, pos2 - pos);
    QByteArray videoUrl = response.replace(QByteArray("\\/"), QByteArray("/")).replace(QByteArray("\\u0026"), QByteArray("&")).replace(QByteArray("%2C"), QByteArray(","));
    if (!(videoUrl.startsWith("http"))) {
        emit alert(tr("Error: Unable to retrieve video"));
        emit videoUrlError();
    }
    else {
        emit gotVideoUrl(QString(videoUrl));
    }
//        qDebug() << videoUrl;
    reply->deleteLater();
    manager->deleteLater();
}


