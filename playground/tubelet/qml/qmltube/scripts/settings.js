function getDatabase() {
    return openDatabaseSync("cuteTube", "0.1", "Settings", 100000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS accounts(username TEXT UNIQUE, password TEXT, isDefault INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS searches(searchterm TEXT UNIQUE)');
                    tx.executeSql('DROP TABLE IF EXISTS downloads');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS savedDownloads (filePath TEXT UNIQUE, playerUrl TEXT, title TEXT, thumbnail TEXT, convert INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS archive (filePath TEXT UNIQUE, title TEXT, thumbnail TEXT, quality TEXT, isNew INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS oauth(service TEXT UNIQUE, token TEXT, secret TEXT)');
                    if (getSetting("resetSettings") == "unknown") {
                        tx.executeSql('DROP TABLE IF EXISTS settings');
                        tx.executeSql('CREATE TABLE settings(setting TEXT UNIQUE, value TEXT)');
                    }
                    if (getSetting("addDateToArchive") == "unknown") {
                        tx.executeSql('ALTER TABLE archive ADD COLUMN date INTEGER');
                    }
                    setDefaultSettings();
                });
}

function addOrEditAccount(username, password, isDefault) {
    /* Add a new account to the database, or replace exitsing one if key (username) exists */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       if (isDefault == 1) {
                           // If new/edited account is set as default, set all other isDefault to 0
                           tx.executeSql('UPDATE accounts SET isDefault = 0;');
                       }
                       var rs = tx.executeSql('INSERT OR REPLACE INTO accounts VALUES (?,?,?);', [ username, password, isDefault ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function deleteAccount(username) {
    /* Delete the account with matching username from the database */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('DELETE FROM accounts WHERE username = ?;', [ username ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function getAccount(username) {
    /* Retreive an existing account */

    var db = getDatabase();
    var res = [];
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM accounts WHERE username = ?;', [ username ]);
                       if (rs.rows.length > 0) {
                           res = [ rs.rows.item(0).username, rs.rows.item(0).password, rs.rows.item(0).isDefault ];
                       }
                       else {
                           res = "unknown";
                       }
                   }
                   );
    //console.log(res);
    return res
}

function getDefaultAccount() {
    /* Retrieve the default account username and password */

    var db = getDatabase();
    var res = "unknown";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT username, password FROM accounts WHERE isDefault = 1;');
                       if (rs.rows.length > 0) {
                           res = [ rs.rows.item(0).username, rs.rows.item(0).password ];
                       }
                       else {
                           // Fallback if no account is set as default
                           var accounts = getAllAccounts();
                           if (accounts.length > 0) {
                               res = [ accounts[0][0], accounts[0][1] ];
                           }
                       }
                   });
    //console.log(res);
    return res
}

function getAllAccounts() {
    /* Retrieve all accounts from the database */

    var db = getDatabase();
    var res = [];
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM accounts;');
                       if (rs.rows.length > 0) {
                           for(var i = 0; i < rs.rows.length; i++) {
                               res[i] = [ rs.rows.item(i).username, rs.rows.item(i).password, rs.rows.item(i).isDefault ];
                           }
                       }
                   }
                   );
    //console.log(res);
    return res
}

function setDefaultSettings() {
    /* Set defaults if no settings exist */

    var settings = [ [ "playbackQuality", "hq" ],
                    [ "downloadQuality", "hq" ],
                    [ "downloadStatus", "queued" ],
                    [ "downloadPath", Controller.isSymbian ? "E:/Videos/" : "/home/meego/Downloads/" ], // NPM, changed from maemo's /home/user/MyDocs dir
                    [ "categoryFeedOne", "MostRecent"],
                    [ "categoryFeedTwo", "MostViewed"],
                    [ "categoryOrder", "relevance"],
                    [ "safeSearch", "none" ],
                    [ "screenOrientation", "automatic" ],
                    [ "mediaPlayer", "cuteTube Player" ],
                    [ "searchOrder", "relevance" ],
                    [ "theme", "nightred" ],
                    [ "language", "en" ],
                    [ "proxy", ":"],
                    [ "widgetFeedOne", "_MOST_RECENT_FEED" ],
                    [ "widgetFeedTwo", "_MOST_VIEWED_FEED" ],
                    [ "widgetFeedThree", "archive" ],
                    [ "widgetFeedFour", "_NEW_SUB_VIDEOS_FEED" ],
                    [ "resetSettings", "no"],
                    [ "addDateToArchive", "no"] ];

    for (var i = 0; i < settings.length; i++) {
        var setting = settings[i][0];
        if (getSetting(setting) == "unknown") {
            var value = settings[i][1];
            setSetting(setting, value);
        }
    }
}

function setSetting(setting, value) {
    /* Add a new (setting, value) or replace if key (setting) exists */

    var db = getDatabase();
    var res= "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [ setting, value ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function getSetting(setting) {
    /* Retrieve the value for the setting argument */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [ setting ]);
                       if (rs.rows.length > 0) {
                           res = rs.rows.item(0).value;
                       }
                       else {
                           res = "unknown";
                       }
                   }
                   );
    //console.log(res);
    return res
}

function getSearches() {
    /* Retrieve all saved searches from the database */

    var db = getDatabase();
    var res = [];
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM searches;');
                       if (rs.rows.length > 0) {
                           for(var i = 0; i < rs.rows.length; i++) {
                               res[i] = rs.rows.item(i).searchterm;
                           }
                       }
                   }
                   );
    //console.log(res);
    return res
}

function addSearchTerm(searchterm) {
    /* Add a new search term if it does not already exist */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('INSERT OR REPLACE INTO searches VALUES (?);', [ searchterm ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function clearSearches() {
    /* Delete all saved searches from the database */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('DELETE FROM searches;');
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function addVideoToArchive(video) {
    /* Add a new video to the archive */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('INSERT OR REPLACE INTO archive VALUES (?, ?, ?, ?, ?, ?);', [ video.filePath, video.title,
                                                                                                         video.thumbnail, video.quality, video.isNew, video.date ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function getArchiveVideo(filePath) {
    /* Retrieve the archive video with matching filePath from the database */

    var db = getDatabase();
    var res = "unknown";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM archive WHERE filePath=?;', [ filePath ]);
                       if (rs.rows.length > 0) {
                           res = [ rs.rows.item(0).filePath, rs.rows.item(0).title, rs.rows.item(0).thumbnail,
                                  rs.rows.item(0).quality, rs.rows.item(0).isNew, rs.rows.item(0).date ];
                       }
                   }
                   );
    //console.log(res);
    return res
}

function getAllArchiveVideos(column, order) {
    /* Retrieve all archive videos from the database */

    var db = getDatabase();
    var res = [];
    var downloadPath = getSetting("downloadPath");
    var path;
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM archive ORDER BY ' + column + ' ' + order + ';');
                       if (rs.rows.length > 0) {
                           for(var i = 0; i < rs.rows.length; i++) {
                               path = Controller.archiveFileExists(rs.rows.item(i).filePath, downloadPath);
                               if (path == "Not found") { // Check that the filepath exists
                                   deleteVideoFromArchive(rs.rows.item(i).filePath);
                               }
                               else {
                                   res[i] = [ rs.rows.item(i).filePath, rs.rows.item(i).title, rs.rows.item(i).thumbnail,
                                             rs.rows.item(i).quality, rs.rows.item(i).isNew, rs.rows.item(i).date ];
                                   if (path != "Unchanged") {
                                       res[i][0] = path;
                                       editArchiveVideo(rs.rows.item(i).filePath, "filePath", path);
                                   }
                               }
                           }
                       }
                   }
                   );
    //console.log(res);
    return res
}

function editArchiveVideo(filePath, attribute, newValue) {
    /* Set the attribute of the video with matching filePath to newValue */

    var attributes = [ "filePath", "title", "thumbnail", "quality", "isNew", "date" ];
    var video = getArchiveVideo(filePath);
    var modifiedVideo = {};
    for (var i = 0; i < attributes.length; i++) {
        modifiedVideo[attributes[i]] = video[i];
    }
    modifiedVideo[attribute] = newValue;
    if (!(modifiedVideo["date"] > 0)) {
        modifiedVideo["date"] = 0;
    }
    if (attribute == "filePath") {
        deleteVideoFromArchive(filePath);
    }
    addVideoToArchive(modifiedVideo);
}

function deleteVideoFromArchive(filePath) {
    /* Delete the video with matching filePath from the archive */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('DELETE FROM archive WHERE filePath = ?;', [ filePath ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function storeDownload(video) {
    /* Store a new download */

    var convert = video.convert ? 1 : 0;
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('INSERT OR REPLACE INTO savedDownloads VALUES (?, ?, ?, ?, ?);', [ video.filePath, video.playerUrl,
                                                                                                                video.title, video.thumbnail, convert ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function removeStoredDownload(filePath) {
    /* Delete the video with matching filePath from the stored downloads */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('DELETE FROM savedDownloads WHERE filePath = ? OR filePath = ?;', [ filePath, "" ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}

function restoreDownloads() {
    /* Restore all incomplete downloads */

    var downloadPath = getSetting("downloadPath");
    var db = getDatabase();
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM savedDownloads;');
                       if (rs.rows.length > 0) {
                           for(var i = 0; i < rs.rows.length; i++) {
                               var downloadItem = {
                                   title: rs.rows.item(i).title,
                                   thumbnail: rs.rows.item(i).thumbnail,
                                   playerUrl: rs.rows.item(i).playerUrl,
                                   status: "paused",
                               }
                               removeStoredDownload(rs.rows.item(i).filePath);
                               if (rs.rows.item(i).convert == 1) {
                                   addAudioDownload(downloadItem);
                               }
                               else {
                                   addDownload(downloadItem);
                               }
                           }
                       }
                   }
                   );
}

function saveAccessToken(service, token, secret) {
    var db = getDatabase();
    var result = false;
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('INSERT OR REPLACE INTO oauth VALUES (?, ?, ?);', [ service, token, secret ]);
                    if (rs.rowsAffected > 0) {
                        result = true;
                        if (service == "Facebook") {
                            Sharing.setFacebookToken(token);
                        }
                        else if (service == "Twitter") {
                            Sharing.setTwitterToken(token, secret);
                        }
                    }
                });
//    console.log(result);
    return result;
}

function getAccessToken(service) {
    var db = getDatabase();
    var accessToken = "unknown";
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT token, secret FROM oauth WHERE service = ?;', [ service ]);
                    if (rs.rows.length > 0) {
                        if (service == "Facebook") {
                            accessToken = rs.rows.item(0).token;
                        }
                        else if (service == "Twitter") {
                            accessToken = [ rs.rows.item(0).token, rs.rows.item(0).secret ];
                        }
                    }
                });
//    console.log(accessToken);
    return accessToken;
}

function deleteAccessToken(service) {
    /* Delete the access token for the service */

    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('DELETE FROM oauth WHERE service = ?;', [ service ]);
                       if (rs.rowsAffected > 0) {
                           res = "OK";
                       }
                       else {
                           res = "Error";
                       }
                   }
                   );
    //console.log(res);
    return res;
}





