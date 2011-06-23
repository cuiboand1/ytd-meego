#include "sharing.h"
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QUrl>
#include <QDebug>

Sharing::Sharing(QObject *parent) :
    QObject(parent), facebookId("175388745824052"), facebookToken("") {

}

void Sharing::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void Sharing::setFacebookToken(const QString &token) {
    facebookToken = token;
    emit facebookTokenChanged();
}

//void Sharing::setTwitterToken(const QString &token, const QString &secret) {
//    twitterToken = token;
//    twitterSecret = secret;
//}

void Sharing::postToFacebook(const QString &videoId, const QString &title, const QString &description, const QString &message) {
    /* Helper method that posts HTTP POST requests */

    QByteArray id;
    id = videoId.toAscii();

    QByteArray playerUrl;
    playerUrl = "http://www.youtube.com/watch?v=" + id;

    QByteArray embedUrl;
    embedUrl = "http://www.youtube.com/e/" + id;

    QByteArray thumbUrl;
    thumbUrl = "http://i.ytimg.com/vi/" + id + "/hqdefault.jpg";

    QByteArray postData;

    postData = "access_token=" + facebookToken.toAscii()
            + "&message=" + message.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?")
            + "&link=" + playerUrl
            + "&source=" + embedUrl
            + "&picture=" + thumbUrl
            + "&name=" + title.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?")
            + "&description=" + description.toAscii().toPercentEncoding(" \n\t#[]{}=+$&*()<>@|',/!\":;?")
            + "&attribution=via cuteTube on the Nokia N900";

//    qDebug() << postData;

    QNetworkRequest request(QUrl("https://graph.facebook.com/me/feed"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QNetworkReply* reply = nam->post(request, postData);
    connect(reply, SIGNAL(finished()), this, SLOT(postFinished()));
    connect(this, SIGNAL(postSuccessful()), this, SIGNAL(postedToFacebook()));
    connect(this, SIGNAL(postForbidden()), this, SIGNAL(renewFacebookToken()));
}

void Sharing::postFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray statusText = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
//    qDebug() << "Status is:" << statusCode << ":" << statusText;
    if ((statusCode == 200) || (statusCode == 201)) {
        emit postSuccessful();
    }
    else if (statusCode == 401) {
        emit postForbidden();
    }
    else {
        emit alert(tr("Error - Server repsonse is: ") + statusText);
    }
    reply->deleteLater();
}

