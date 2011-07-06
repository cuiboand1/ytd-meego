#ifndef SHARING_H
#define SHARING_H

#include <QObject>
#include <QtNetwork/QNetworkAccessManager>

class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;

class Sharing : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString facebookToken
               READ getFacebookToken
               NOTIFY facebookTokenChanged)
    Q_PROPERTY(QString facebookId
               READ getFacebookId
               NOTIFY facebookIdChanged)
    Q_PROPERTY(QString twitterId
               READ getTwitterId
               NOTIFY twitterIdChanged)
    Q_PROPERTY(QString twitterSecret
               READ getTwitterSecret
               NOTIFY twitterSecretChanged)
    Q_PROPERTY(QString twitterToken
               READ getTwitterToken
               NOTIFY twitterTokenChanged)
    Q_PROPERTY(QString twitterTokenSecret
               READ getTwitterTokenSecret
               NOTIFY twitterTokenChanged)

public:
    explicit Sharing(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    QString getFacebookToken() const { return facebookToken; }
    QString getFacebookId() const { return facebookId; }
    QString getTwitterId() const { return twitterId; }
    QString getTwitterSecret() const { return twitterSecret; }
    QString getTwitterToken() const { return twitterToken; }
    QString getTwitterTokenSecret() const { return twitterTokenSecret; }

public slots:
    void setFacebookToken(const QString &token);
    void setTwitterToken(const QString &token, const QString &secret);
    void postToFacebook(const QString &site, const QString &videoId, const QString &title, const QString &description, const QString &message, const QString &thumb);
    void postToTwitter(const QString &url, const QString &header, const QString &body);


private slots:
    void postFinished();

private:
    QNetworkAccessManager *nam;
    QString facebookId;
    QString facebookToken;
    QString twitterId;
    QString twitterSecret;
    QString twitterToken;
    QString twitterTokenSecret;

signals:
    void alert(const QString &message);
    void facebookTokenChanged();
    void facebookIdChanged();
    void twitterTokenChanged();
    void twitterIdChanged();
    void twitterSecretChanged();
    void postSuccessful();
    void postForbidden();
    void renewFacebookToken();
    void renewTwitterToken();
    void postedToFacebook();
    void postedToTwitter();
};

#endif // SHARING_H
