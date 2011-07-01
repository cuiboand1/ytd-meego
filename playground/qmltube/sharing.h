#ifndef SHARING_H
#define SHARING_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QFile>

class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;

class Sharing : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString facebookToken
               READ getFacebookToken
               WRITE setFacebookToken
               NOTIFY facebookTokenChanged)
    Q_PROPERTY(QString facebookId
               READ getFacebookId
               NOTIFY facebookIdChanged)

public:
    explicit Sharing(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    QString getFacebookToken() const { return facebookToken; }
    QString getFacebookId() const { return facebookId; }

public slots:
    void setFacebookToken(const QString &token);
//    void setTwitterToken(const QString &token, const QString &secret);
    void postToFacebook(const QString &site, const QString &videoId, const QString &title, const QString &description, const QString &message, const QString &thumb);


private slots:
    void postFinished();

private:
    QNetworkAccessManager *nam;
    QString facebookId;
    QString facebookToken;
//    QString twitterToken;
//    QString twitterSecret;

signals:
    void alert(const QString &message);
    void facebookTokenChanged();
    void facebookIdChanged();
//    void twitterTokenChanged();
    void postSuccessful();
    void postForbidden();
    void renewFacebookToken();
//    void renewTwitterToken();
    void postedToFacebook();
};

#endif // SHARING_H
