#ifndef VIMEO_H
#define VIMEO_H

#include <QObject>

class QNetworkAccessManager;
class QNetworkReply;

class Vimeo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentUser
               READ getCurrentUser
               NOTIFY currentUserChanged)
    Q_PROPERTY(QString accessToken
               READ getAccessToken
               NOTIFY accessTokenChanged)
    Q_PROPERTY(QString tokenSecret
               READ getTokenSecret
               NOTIFY tokenSecretChanged)
    Q_PROPERTY(QString clientId
               READ getClientId
               NOTIFY clientIdChanged)
    Q_PROPERTY(QString clientSecret
               READ getClientSecret
               NOTIFY clientSecretChanged)
public:
    explicit Vimeo(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    QString getCurrentUser() const { return currentUser; }
    QString getAccessToken() const { return accessToken; }
    QString getTokenSecret() const { return tokenSecret; }
    QString getClientId() const { return clientId; }
    QString getClientSecret() const { return clientSecret; }

public slots:
    void setUserCredentials(const QString &user, const QString &token, const QString &secret);
    void getVideoUrl(const QString &id);
    void addToFavourites(const QString &url, const QString &header);
    void deleteFromFavourites(const QString &url, const QString &header);
    void addToPlaylist(const QString &url, const QString &header);
    void deleteFromPlaylist(const QString &url, const QString &header);
    void createNewPlaylist(const QString &url, const QString &header);
    void deletePlaylist(const QString &url, const QString &header);
    void subscribeToChannel(const QString &url, const QString &header);
    void unsubscribeToChannel(const QString &url, const QString &header);
    void addComment(const QString &url, const QString &header);

private slots:
    void setCurrentUser(const QString &user);
    void setAccessToken(const QString &token);
    void setTokenSecret(const QString &secret);
    void postRequest(const QString &url, const QString &header);
    void deleteRequest(const QString &url, const QString &header);
    void postFinished();
    void parseVideoPage();
    void checkVideoUrl();

private:
    QNetworkAccessManager *nam;
    QString clientId;
    QString clientSecret;
    QString accessToken;
    QString tokenSecret;
    QString currentUser;


signals:
    void gotVideoUrl(const QString &videoUrl);
    void videoUrlError();
    void alert(const QString &message);
    void currentUserChanged();
    void accessTokenChanged();
    void tokenSecretChanged();
    void clientIdChanged();
    void clientSecretChanged();
    void addedToFavourites();
    void deletedFromFavourites();
    void addedToPlaylist();
    void deletedFromPlaylist();
    void playlistCreated();
    void playlistDeleted();
    void subscribed();
    void unsubscribed();
    void commentAdded();
    void postSuccessful();
    void postFailed();
};

#endif // VIMEO_H
