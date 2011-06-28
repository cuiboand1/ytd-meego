#ifndef YouTube_H
#define YouTube_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QUrl>
#include <QFile>

class QNetworkAccessManager;
class QNetworkReply;

class YouTube : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentUser
               READ getCurrentUser
               NOTIFY currentUserChanged)
    Q_PROPERTY(QString accessToken
               READ getAccessToken
               NOTIFY accessTokenChanged)
public:
    explicit YouTube(QObject *parent = 0);

    void setNetworkAccessManager(QNetworkAccessManager *manager);
    QString getCurrentUser() const { return currentUser; }
    QString getAccessToken() const { return accessToken; }

public slots:
    void login(const QString &username, const QString &password);
    void addToFavourites(const QString &videoId);
    void deleteFromFavourites(const QString &favouriteId);
    void addToPlaylist(const QString &videoId, const QString &playlistId);
    void deleteFromPlaylist(const QString &playlistId, const QString &playlistVideoId);
    void createNewPlaylist(const QString &title, const QString &description, const bool &isPrivate);
    void deletePlaylist(const QString &playlistId);
    void subscribeToChannel(const QString &username);
    void unsubscribeToChannel(const QString &subscriptionId);
    void rateVideo(const QString &videoId, const QString &likeOrDislike);
    void addComment(const QString &videoId, const QString &comment);
    void replyToComment(const QString &videoId, const QString &commentId, const QString &comment);
    void setPlaybackQuality(const QString &quality);
    void getVideoUrl(const QString &videoId);
    void uploadVideo(const QString &filename, const QString &title, const QString &description, const QString &tags, const QString &category, const bool &isPrivate);
    void abortVideoUpload();

private slots:
    void checkLogin();
    void setCurrentUser(const QString &user);
    void setAccessToken(const QByteArray &token);
    void setUploadUrl();
    void performVideoUpload();
    void resumeVideoUpload();
    void uploadFinished();
    void postRequest(const QUrl &url, const QByteArray &xml);
    void deleteRequest(const QUrl &url);
    void postFinished();
    void parseVideoPage(QNetworkReply *reply);

private:
    QNetworkAccessManager *nam;
    QFile *fileToBeUploaded;
    QUrl uploadUrl;
    int uploadRetries;
    QNetworkReply *uploadReply;
    QByteArray developerKey;
    QString accessToken;
    QString currentUser;
    int playbackFormat;
    QHash<QString, int> pbMap;
    QString message;

signals:
    void gotVideoUrl(const QString &videoUrl);
    void videoUrlError();
    void alert(const QString &message);
    void currentUserChanged();
    void accessTokenChanged(const QString &token);
    void postSuccessful();
    void postFailed();
    void addedToFavourites();
    void deletedFromFavourites();
    void videoInFavourites();
    void addedToPlaylist();
    void deletedFromPlaylist();
    void playlistCreated();
    void playlistDeleted();
    void subscribed();
    void unsubscribed();
    void uploadStarted();
    void commentAdded();
    void videoRated();
    void cannotRate();
    void updateUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadStatusChanged(const QString &status);
};

#endif // YouTube_H
