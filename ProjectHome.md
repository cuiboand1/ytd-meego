# YTD-Meego Introduction  #

This project is a port of http://ytd-android.googlecode.com , providing a QtQuick-based Meego Handset application that captures video, uploads it via Google App Engine, then submits the video to a YouTube Direct instance (http://youtube-direct.googlecode.com).

The purpose of youtube-direct is best described in articles such as:
http://gigaom.com/video/youtube-direct-abc7/
http://www.digitaltrends.com/computing/youtube-direct-is-helping-media-find-free-videos/

[CitizenJournalismWithYoutubeDirectForMeego](CitizenJournalismWithYoutubeDirectForMeego.md) describes the specifics of porting the YouTube direct Android application to the MeeGo Handset reference platform, the Nokia N900, which is the first target of this application. Note that no N900-specific APIs are used: the intent is that YTD-Meego work on any platform supporting Qt Mobility 1.2 and providing the appropriate platform specific hardware adaptations needed by Qt Mobility.

## Project Goals: ##

A complete and released implementation should provide the following features of the ytd-android application:

  * [Integration with Meego's Account Manager for ease of authentication (the application prompts the user to select a configured Google / Gmail account on the mobile device)](http://code.google.com/p/ytd-meego/issues/detail?id=2)
  * [Automatic synchronization of assignment list (submission ideas) from the !YouTube-Direct JSON assignment feed](http://code.google.com/p/ytd-meego/issues/detail?id=3)
  * [Notification display upon discovery of new assignments](http://code.google.com/p/ytd-meego/issues/detail?id=4)
  * [Video recording and upload to a specific submission idea](http://code.google.com/p/ytd-meego/issues/detail?id=5)
  * [Upload of a video selected from the gallery](http://code.google.com/p/ytd-meego/issues/detail?id=6)
  * [Geolocation tagging of submitted videos](http://code.google.com/p/ytd-meego/issues/detail?id=7)

## Project Status ##

Schedule: [Issue Tracker](http://code.google.com/p/ytd-meego/issues/list)

## Post Elopcalyptic<sup>1</sup> Results ##

[qmltube: Port/fork of cutetube-qml for Linux and MeeGo](http://www.nielsmayer.com/bin/view/MeeGo/QmlTube) whose source-code is checked-in to this project: see http://ytd-meego.googlecode.com/svn/trunk/playground/qmltube . Review: http://my-meego.com/software/applications.php?fldAuto=35&faq=2

See also other QML experiments involving YouTube API in http://ytd-meego.googlecode.com/svn/trunk/playground/ for example,

<a href='http://www.youtube.com/watch?feature=player_embedded&v=nQoDcVPynLA' target='_blank'><img src='http://img.youtube.com/vi/nQoDcVPynLA/0.jpg' width='425' height=344 /></a>
<a href='http://www.youtube.com/watch?feature=player_embedded&v=fx_EJtCu46U' target='_blank'><img src='http://img.youtube.com/vi/fx_EJtCu46U/0.jpg' width='425' height=344 /></a>

## Future ##

The following seem like much better approaches, since they don't require any special app-engine foo, which is a serious show-stopper because App-Engine is very "1st generation" and difficult:

  * http://apiblog.youtube.com/2012/07/lets-hear-it-from-your-users.html
  * http://code.google.com/p/youtube-direct-lite/
  * https://developers.google.com/youtube/youtube_upload_widget

## Footnotes ##

1. The Elopcalypse: http://www.engadget.com/2011/02/11/nokia-execs-given-the-boot-in-microsoft-centered-reorganization/