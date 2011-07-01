#ifndef DAILYMOTION_H
#define DAILYMOTION_H

#include <QObject>
#include <QUrl>
#include <QFile>
#include <QTime>

class QNetworkAccessManager;
class QNetworkReply;

class DailyMotion : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentUser
               READ getCurrentUser
               NOTIFY currentUserChanged)
    Q_PROPERTY(QString accessToken
               READ getAccessToken
               NOTIFY accessTokenChanged)
    Q_PROPERTY(QString refreshToken
               READ getRefreshToken
               NOTIFY refreshTokenChanged)
    Q_PROPERTY(QString tokenExpiry
               READ getTokenExpiry
               NOTIFY tokenExpiryChanged)
    Q_PROPERTY(QString clientId
               READ getClientId
               NOTIFY clientIdChanged)
    Q_PROPERTY(QString clientSecret
               READ getClientSecret
               NOTIFY clientSecretChanged)

public:
    explicit DailyMotion(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    QString getCurrentUser() const { return currentUser; }
    QString getAccessToken() const { return accessToken; }
    QString getRefreshToken() const { return refreshToken; }
    int getTokenExpiry() const { return tokenExpiry; }
    QString getClientId() const { return clientId; }
    QString getClientSecret() const { return clientSecret; }

public slots:
    void getVideoUrl(const QString &id);
    void setUserCredentials(const QString &user, const QString &aToken, const QString &rToken, const int &expiry);
    void addToFavourites(const QString &id);
    void deleteFromFavourites(const QString &id);
    void uploadVideo(const QString &filename);
    void setUploadMetadata(const QString &id, const QString &title, const QString &description, const QString &tags, const QString &category, const bool &isPrivate);

private slots:
    void setCurrentUser(const QString &user);
    void setAccessToken(const QString &token);
    void setRefreshToken(const QString &token);
    void setTokenExpiry(int expiry);
    void postRequest(const QUrl &url, const QByteArray &data = QByteArray());
    void deleteRequest(const QUrl &url);
    void postFinished();
    void parseVideoPage();
    void setUploadUrl();
    void performVideoUpload();
    void updateUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadFinished();

private:
    QNetworkAccessManager *nam;
    QString clientId;
    QString clientSecret;
    QString accessToken;
    QString refreshToken;
    int tokenExpiry;
    QString currentUser;
    QFile *fileToBeUploaded;
    QUrl uploadUrl;
    QTime uploadTime;
    QNetworkReply *uploadReply;


signals:
    void gotVideoUrl(const QString &videoUrl);
    void videoUrlError();
    void alert(const QString &message);
    void currentUserChanged();
    void accessTokenChanged();
    void clientIdChanged();
    void clientSecretChanged();
    void refreshTokenChanged();
    void tokenExpiryChanged();
    void postSuccessful();
    void postFailed();
    void addedToFavourites();
    void deletedFromFavourites();
    void uploadProgressChanged(qint64 bytesSent, qint64 bytesTotal, const QString &speed);
    void uploadStatusChanged(const QString &status);
    void uploadCompleted();
    void uploadFailed();
    void waitingForMetadata(const QString &id);
};

#endif // DAILYMOTION_H
