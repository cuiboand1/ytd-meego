<p align='center'><font size='5'><b>Citizen Journalism with YouTube-Direct for MeeGo</b></font></p>
<p align='center'><b>Niels P. Mayer ( <a href='http://www.nielsmayer.com'>http://www.nielsmayer.com</a> )</b></p>
<p align='center'><b>December 27, 2010</b></p>



The
[YouTube-Direct](http://youtube-direct.googlecode.com)
for MeeGo application integrates a number of traditionally separate
applications: a video recorder/still photo camera, GPS integration and
geotagging, combined with managing/uploading captured media to
YouTube-Direct sites. Organizations seeking public contribution by
"[citizen journalists](http://gigaom.com/video/youtube-direct-abc7/)" use
these sites to facilitate content collection from an increasing population
of video-enabled smart-phone users.

The [YTD-MeeGo](http://ytd-meego.googlecode.com) project seeks to build a
MeeGo application which represents an innovative use of the handheld
platform as a computational video camera, performing a unique combination
of functionality that wasn't possible prior to the confluence of cellular
networking integrated with handheld/touchscreen computer and video camera.

The implementation uses "Qt Quick" technology for rapid-prototyping and
delivering dynamic, modern touch GUIs. Qt Quick and QML is used to
implement most of the functionality of this project, utilizing
[prototype-based OOP](http://en.wikipedia.org/wiki/JavaScript#Prototype-based)
in the JavaScript language. However, there are areas where plugins or
native access to underlying platform functionality is not available in
QML. In these cases a "hybrid programming" technique will be used,
implemented in C++ or Python using QtMobility API, but providing
high-level JavaScript calls for use by QML files.

This article describes the architecture and design decisions porting the
[YouTube-Direct](http://youtube-direct.googlecode.com)
handheld application for the
[iPhone](http://ytd-iphone.googlecode.com)
/
[Android](http://ytd-android.googlecode.com) to
[MeeGo](http://meego.com), using
Qt Quick/QML
for the UI, and additional C++ or Python extensions for
handling HD video capture, geotagging, and uploading to a youtube-direct
enabled website.

As http://ytd-meego.googlecode.com is a new project, part of the purpose of
this article is to solicit feedback, project contributors and
domain-expertise on the architecture choices described. This document thus
serves as a detailed reference, with links, both for this project's
contributors, as well and others interested in programming MeeGo
multimedia applications with Qt Quick technology.

# YouTube Direct #

YouTube Direct (YTD) is an open source video submission platform using
[YouTube API](http://code.google.com/apis/youtube) and [Google App Engine](http://code.google.com/appengine/).
The web interface consists of two components, an
['iframe' based embeddable video uploader](http://ytd-demo.appspot.com/test.html),
and an administrator-only moderation panel. The following diagram gives an
overview of the [YTD architecture](http://code.google.com/p/youtube-direct/wiki/ArchitectureOverview):

<p align='center'><a href='http://code.google.com/p/youtube-direct/wiki/ArchitectureOverview'><img src='http://youtube-direct.googlecode.com/files/ytd_architecture_diagram.png' /></a></p>
<p align='center'><b>Figure 1: YTD Architecture</b></p>

For further details, see http://code.google.com/p/youtube-direct/wiki/GettingStarted

To support YTD on the MeeGo handset, this project seeks to port the
[YTD-Android Application](http://ytd-android.googlecode.com),
presented in Figure 3, on the right. Figure 2, on the left, is an
example of a customized web-application built on YTD for
[ABC7 News](http://ureport.abc7news.com).
Note in both interfaces the "Submission Ideas" listing: this is
implemented as a JSON "feed" (analogous to an RSS feed) where outgoing
requests for new video stories are made, and a categorization system under
which new stories can be submitted.

<p align='center'><a href='http://ureport.abc7news.com'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/Abc7-UReport-SmallSize.png' /></a><a href='http://ytd-android.googlecode.com'><img src='http://ytd-android.googlecode.com/files/ytd-screenshot-sm.png' /></a></p>
<p align='center'><b>Figure 2: ABC7 "ureport"; Figure 3: YTD-Android</b></p>

Porting YTD-Android to MeeGo consists of supporting the following major features from the [Android reference](http://code.google.com/p/ytd-android/source/browse/trunk):

  * [Integration with Account Manager for ease of authentication (the application prompts the user to select a configured Google / Gmail account on the mobile device)](http://code.google.com/p/ytd-meego/issues/detail?id=2)
    * [AndroidManifest.xml](http://code.google.com/p/ytd-android/source/browse/trunk/AndroidManifest.xml)
    * [Authorizer.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/Authorizer.java)
    * [GlsAuthorizer.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/GlsAuthorizer.java)
    * [Util.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/Util.java)
    * [SubmitActivity.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/SubmitActivity.java)
  * [Automatic synchronization of assignment list (submission ideas) from the !YouTube-Direct JSON assignment feed](http://code.google.com/p/ytd-meego/issues/detail?id=3)
    * [Assignment.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/db/Assignment.java)
    * [AssignmentArrayAdapter.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/AssignmentArrayAdapter.java)
    * [layout/main.xml](http://code.google.com/p/ytd-android/source/browse/trunk/res/layout/main.xml)
  * [Notification display upon discovery of new assignments](http://code.google.com/p/ytd-meego/issues/detail?id=4)
    * [AlarmActionReceiver.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/AlarmActionReceiver.java)
    * [AssignmentSyncService.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/AssignmentSyncService.java)
  * [Video recording and upload to a specific submission idea](http://code.google.com/p/ytd-meego/issues/detail?id=5)
    * [SubmitActivity.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/SubmitActivity.java)
    * [layout/main.xml](http://code.google.com/p/ytd-android/source/browse/trunk/res/layout/main.xml)
  * [Upload of a video selected from the gallery](http://code.google.com/p/ytd-meego/issues/detail?id=6)
    * [DetailsActivity.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/DetailsActivity.java)
    * [layout/details.xml](http://code.google.com/p/ytd-android/source/browse/trunk/res/layout/details.xml)
  * [Geolocation tagging of submitted videos](http://code.google.com/p/ytd-meego/issues/detail?id=7)
    * [SubmitActivity.java](http://code.google.com/p/ytd-android/source/browse/trunk/src/com/google/ytd/SubmitActivity.java)
    * [raw/gdata\_geo.xml](http://code.google.com/p/ytd-android/source/browse/trunk/res/raw/gdata_geo.xml)
    * [layout/submit.xml](http://code.google.com/p/ytd-android/source/browse/trunk/res/layout/submit.xml)

This remainder of this article seeks to answer how to implement these features on the MeeGo Handset platform.

# Related Work #

The Maemo Linux platform for the Nokia N900 has several YouTube uploader
applications. These are not YouTube direct clients, but do represent
existing applications that support mobile uploading of videos to YouTube.

  * [Nokia YouTube uploader for Maemo/n900](http://store.ovi.com/content/39065?clickSource=publisher+channel)
    * The YouTube Uploader allows you to directly upload videos to YouTube when using the Share functionality from the Camera (as a video recorder) or from the Media Player on your Nokia N900.   Video uploads only.

  * [PixelPipe for Maemo/N900](http://blog.pixelpipe.com/2009/10/17/enabling-the-nokia-n900-to-the-social-web-with-pixelpipe/)
    * Upload directly from N900 camera and gallery applications.
    * Background uploads.
    * Use N900′s Tag Cloud to send to specific services at the time of upload.

## Overlap with Maemo 5 and MeeGo 1.2 Sharing Framework ##

The Nokia YouTube uploader application mentioned above uses the platform
sharing facilities from Maemo.  There is also significant overlap between
ytd-meego and upcoming MeeGo 1.2 infrastructure's "Sharing Framework." As
mentioned in http://wiki.meego.com/Architecture#Upcoming_Features , the
"Sharing framework provides a unified API for sharing files via, e.g., BT,
email, web services. It includes webupload engine and an API for transfer
UI." Similar overlap exists with authentication, in that the sharing framework has
"Full integration with
[Accounts](http://gitorious.org/accounts-sso/pages/Overview_of_accounts_framework) and
[Single Sign-on](http://gitorious.org/accounts-sso/pages/Home)
in MeeGo.com."

The predecessor (an equivalent diagram couldn't be found for MeeGo at time of writing)
[Maemo Sharing Framework](http://wiki.maemo.org/Documentation/Maemo_5_Developer_Guide/Architecture/Imaging_and_Sharing)
provides media uploading to a variety of services:

<a href='Hidden comment: <p align="center">[http://wiki.maemo.org/images/0/0b/SharingAccounts.png]

Unknown end tag for &lt;/p&gt;

'></a>
<p align='center'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/SharingAccounts.png' /></p>
<p align='center'><b>Figure 4: Maemo Sharing Accounts</b></p>

The Maemo sharing GUI allows for any media captured on the device to be
selected and reliably uploaded to any provider that implements a
[sharing plugin](http://wiki.maemo.org/Documentation/Maemo_5_Developer_Guide/Using_Data_Sharing/Sharing_Plug-in):

<a href='Hidden comment: <p align="center">[http://wiki.maemo.org/images/4/49/SharingDialogInterface.png]

Unknown end tag for &lt;/p&gt;

'></a>
<p align='center'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/SharingDialogInterface.png' /></p>
<p align='center'><b>Figure 5: Maemo Sharing Dialog</b></p>

In the future, a well integrated youtube-direct "sharing plugin" written
for the MeeGo Sharing Framework could subsume the functionality of
ytd-meego: allowing arbitrary camera/video apps to output media for
sharing, and allowing the sharing framework to handle the particulars of
uploading that media to a given Internet sharing service.

Perhaps a "2.0" version of YTD-MeeGo could be implemented as a custom
plugin for the MeeGo Sharing Framework, assuming metadata such as
geotagging and notations are appropriately added to captured media. The
"assignment sheet" from youtube-direct sites is a dynamic source of "tags"
that the user must select and apply to the uploaded media as well. The
framework provides the following features to the handset platform:

  * [FEATURE: Share UI: Unified entry point to select a destination](http://bugs.meego.com/show_bug.cgi?id=8179)
    * Share UI that provides unified method for sharing different types of objects:
      1. File paths
      1. Tracker IRIs for file-backed ontologies
      1. Data URL-encoded objects (RFC 2397)
    * Displays sharing plugins supported by Web upload engine
    * Provides flexibility in destination methods implementation, by allowing multiple sharing methods per plugin and methods to dynamically change during execution
    * Provides full integration with Accounts and Single Sign-on in MeeGo.com

  * [FEATURE: Share: Web Upload Engine](http://bugs.meego.com/show_bug.cgi?id=8180)
    * Web Upload Engine that provides unified processing of uploads, including:
      1. Upload job queues
      1. Resizing of still images
      1. Metadata removal/replacement for images and videos
      1. Upload recovery after crashes/restart of the device
      1. Optional: video re-encoding
    * Provides reference share plugins for Facebook, YouTube, Picasa and Email
    * Full integration with Accounts and Single Sign-on in MeeGo.com
    * Process separation for upload plugins and integrated with Security Framework

  * [FEATURE: Transfer UI: Common transfer management](http://bugs.meego.com/show_bug.cgi?id=8181)
    * Transfer UI that provides integrated transfer visualization for all types of transfers:
      1. Uploading content to social networks (such as Facebook)
      1. Sharing to other devices (e.g., via Bluetooth)
      1. Downloading content via different applications (e.g., Browser, Feeds)
      1. Synchronizations (e.g., email, contacts, calendar)
    * Transfer UI provides common actions for all types of transfers
    * Transfer history preservation in Tracker; to ensure easy way to establish relationship between services and data and enablers for relevancy tracking

# GUI Technology: Qt Quick and QML #

YTD-MeeGo uses the latest in open-source dynamic touch interface technology:
[QML](http://en.wikipedia.org/wiki/QML) and [Qt Quick](http://doc.qt.nokia.com/4.7/qtquick.html).

Kate Alhola's
"[How to make modern Mobile applications with Qt Quick components](http://blogs.forum.nokia.com/blog/kate-alholas-forum-nokia-blog/2010/11/14/how-to-make-modern-mobile-applications-with-qt-quick-components)"
is an excellent introduction to Qt Quick explaining the evolution of
Nokia's touch interfaces beyond traditional "widget based" interfaces:

> MeeGo, was started from a clean sheet. Enhancing legacy toolkits,
> GTK+/Hildon or QWidgets, were insufficient to implement leading edge
> mobile user experience. The UI toolkit should be based on
> QGraphicsView/QGraphicsItem rather than old QWidgets. The new approach
> allowed us to take control of UI elements, transitions and animations
> inside of the toolkit. Now we had a possibility for a lot more complex
> animations in element level, animated dynamic layouts etc. (...)

> Qt Quick was part of Qt4.7 released October 2010. The Qt Quick can be
> considered a revolutionary step in UI implementation, even complex UIs were
> possible to implement with a few easy lines of Qml code. Qml is also easy
> to learn for UI designers used to work with web UI tools.

The article provides some example QML code and the screen-snapshot for the
code follows. Below, we see QML's [JSON](http://en.wikipedia.org/wiki/JSON)
syntax [JavaScript](http://en.wikipedia.org/wiki/ECMAScript) and some of the
declarative aspects of QML.  JSON syntax is used to declare the UI
hierarchy, such that the toplevel Page contains Flickable, which contains
Column, which in turn contains Button, LineEdit, Button, CheckBox, and
Switch.

```
     Component {
        id: catComponent
        Page {
          id:catPage
          Image {
            anchors.centerIn: parent
            source: "aureo600.jpg"
          }
        }
     }
     Component {
        id: dialogComponent
        Page {
          id:dialog
          Flickable {
            id: dialogscrolarea
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            anchors.leftMargin:50;anchors.rightMargin:50
            contentHeight: dialogcontent.height
            contentWidth: parent.width
            Column {
              id: dialogcontent
              anchors.left:parent.left;anchors.right:parent.right
              anchors.leftMargin:50;anchors.rightMargin:50
              spacing: 10
              Button {
                text: "Button 1"
                width: parent.width
              }
              LineEdit {
                id: line1
                width:parent.width
                anchors.left: parent.left; anchors.right: parent.Right
                promptText: "Enter text here"
              }
             Button {
                text: "ToggleButton"
                width:parent.width
                checkable:true
             }
             CheckBox {
                id: cbox
             }
             Switch {
                id: switch1
             
            }}
        }}
     }
```

<p align='center'><img src='http://blogs.forum.nokia.com//data/blogs/resources/300003/compo-11.png' /></p>
<p align='center'><b>Figure 6: GUI From Kate Alhola's QML example</b></p>

So far, that is certainly not remarkable or innovative:
[Motif's UIL](http://docs.hp.com/en/B1171-90145/ch04s01.html) was doing this
back in the late 80's. What's different is that traditional "widget"
interaction can be combined with "designed" photoshop-drawn interfaces, as
well as more modern dynamic, animated, and gesture-recognizing interfaces
appropriate to touch devices. Further, QML is a rich language and is
already capable-enough to write fully functioning applications entirely in
JavaScript. As such, QML provides a dynamic, high-level, object-oriented
language at the user-interface level, which was also observed as a good solution to
["declarative" GUI building with UIL in the late 80's](http://winterp.googlecode.com/svn/wiki/doc/papers/p45-mayer.pdf).

In the code example above, note the "declarative" aspects of the code,
which are implicit in the sizing constraints: for example, "parent.width"
sizes all the children to be the same size as their container, without
requiring explicit procedural code. The declarative style means one need
not worry about the procedural order of creating the UI elements and their
parentage.  With QML,
[Application state](http://doc.qt.nokia.com/4.7/qdeclarativestates.html) is
handled declaratively, as is
[keyboard-focus](http://doc.qt.nokia.com/4.7/qdeclarativefocus.html) and
dialog state.

Declarative layout allows conditional visibility coding, changing the
visibility of elements depending on the screen size and application
state/context. This can enable the same application, and the same
code-base, to support a wide range of device form factors and screen sizes.
Sizing of GUI elements can be declared relative to the toplevel window's size, which
[enables screen-size and resolution independent layout](http://wiki.forum.nokia.com/index.php/Device_Independent_Layout_for_QML).
Should the application need to target all manner of screen sizes from
desktop to handheld, very different GUI designs are needed: this can be
accomplished by creating multiple QML layouts, and using conditional
expressions to make the visibility of certain elements change depending on
the screen size.

## Rapid prototyping declarative GUIs with QML (and Pyside) ##

The overarching design goal of this application is to use "Qt Quick" to
create this application using "rapid prototyping" while also employing the
best-available visually-rich&dynamic, touch&gesture capable interfaces. That is, as much of
the project's programming will be attempted in QML.

This project's strategy is to reuse existing functionality and examples
from QtMobility to get the application running on MeeGo as quickly,
reliably, and with least effort/code. Issues of efficiency will be
considered "secondary" in that performance issues arising in testing, can
be resolved by recoding prototype interpreted code (either [Pyside](http://www.pyside.org/) or QML)
into C++.

One of the reasons for considering Pyside and not
going directly to C++ is rapid-prototyping and higher-level coding made
possible with
[Pyside's QtMobility](http://www.pyside.org/docs/pyside-mobility/) API. Eventually, high-level QML interfaces
will exist in QtMobility 1.2: The article
[Using QtMobility sensors and QML from PySide](http://developer.qt.nokia.com/wiki/Using_QtMobility_sensors_and_QML_from_PySide)
states: "In the future, Qt Mobility 1.2 (still not released as of December 2010) will have
[QML Plugins](http://doc.qt.nokia.com/qt-mobility-snapshot/qml-plugins.html),
but right now we have to write some glue code in Python."

Thus, as part of the rapid prototyping process, portions of YTD-meego may
need coding in Pyside. The API that arises between QML and Pyside can be
used to recode the Pyside portions in C++ should the need arise, for
example, to deliver a smaller application footprint, or to create an
application with fewer dependencies to maintain over time. The use of
Python in this project is not optimal, strictly pragmatic: for one, it is
wasteful to use two built-in interpreters and their associated overhead:
QML and Python, when QML is a fully capable language in its own right.  As
indicated above, the Pyside portions are also potentially just a stopgap
until QtMobility 1.2's QML plugins provide needed functionality directly
from QML.

For more information on using Pyside and QML:
  * [Nokia PySide Documentation](http://developer.qt.nokia.com/wiki/PySideDocumentation)
  * [MeeGo Development With Python: Qt, Mobility, And Touch](http://conference2010.meego.com/session/meego-development-python-qt-mobility-and-touch) ([presentation slides](http://conference2010.meego.com/sites/all/files/sessions/pyside-meegoconf_0.pdf))
  * [Run Custom QML Apps in your own Python-based "qmlviewer"](http://wiki.forum.nokia.com/index.php/Python_Harness_for_QML)

## A path we try not to take: Hybrid Programming in C++ and QML ##

Although this project is going to attempt to do as little C++ programming initially, good design observations are found in
Marko Mattila's blog about his
[experience in creating a hybrid QML/C++ application](http://zchydem.enume.net/2010/04/08/my-first-qt-quick-app-quickflickr/),
[quickflickr](http://gitorious.org/quickflickr/quickflickr/trees/master)
which suggests the following architecture for a Qt Quick application:
  * "Heavy lifting" in C++ and w/ QtMobility.
    * Not all QtMobility facilities have QML counterparts so many will need to be "wrapped" in C++ and made available to the QML-level as a high-level call.
  * QML for eye candy:
    * "there are developers implementing the “difficult stuff” in C++ side and then the UI designers do the eye-candy UIs using QML. In my opinion, many of the QML examples and demos do little bit too much in the QML side, such as they implement too much stuff using the JavaScript. On the other hand, I understand that the idea of demos is to demonstrate the power of QML, but I’m not sure how much designers would like work with JavaScript."
  * QML side only visualizes the data that comes from C++
    * don't implement too much logic in QML side.
  * QML calls C++ interfaces get data back from C++-side.
  * C++ provides data-models for rendering via QML
    * e.g.  display content of a model in a Flickable [ListView](http://doc.qt.nokia.com/4.7/qml-listview.html) only with a few lines of code:  a [ListView](http://doc.qt.nokia.com/4.7/qml-listview.html) item and delegate item.
  * C++ side creates UI by using [QDeclarativeView](http://doc.qt.nokia.com/4.7/qdeclarativeview.html) used for loading the main QML component constructing the UI.
    * The [QDeclarativeView](http://doc.qt.nokia.com/4.7/qdeclarativeview.html) is also used for accessing [QDeclarativeEngine](http://doc.qt.nokia.com/4.7/qdeclarativeengine.html) and the root context.

Mattila concludes with [lessons learned](http://zchydem.enume.net/2010/09/07/quickflickr-available-at-extras-testing/):
  * [XmlListModel](http://doc.qt.nokia.com/4.7/qml-xmllistmodel.html) doesn’t handle everything yet. It will be improved to support e.g. lists
  * Think when you are implementing delegates! QML is so easy to use that you can accidentally make stupid design decisions e.g. adding a one webview for each delegate:)
  * If something is not visible, then you don’t necessarily  need to create object, or start loading content from a web. Remember this is not always the case e.g. to give better UX you might need to define buffer for [ListView](http://doc.qt.nokia.com/4.7/qml-listview.html)s so that they know when to start loading images.
  * Prefer to use  models like [XmlListModel](http://doc.qt.nokia.com/4.7/qml-xmllistmodel.html) or [QAbstractItemModel](http://doc.qt.nokia.com/4.7/qabstractitemmodel.html) instead of using custom made models e.g. QList<QObject...>. I made this mistake and after removing the custom model and moving to use [XmlListModel](http://doc.qt.nokia.com/4.7/qml-xmllistmodel.html), I could get rid of hundreds of lines of C++ code.
  * Think well the C++ interface that is exposed to QML side. After I re-factored the C++ interface, the development cycle of adding a new flickr interface call and building the QML UI on top of that shortened remarkable.
  * On N900 I have problems to make Image element to load images. Everything else seems to work over the network, but occasionally Images just don’t get loaded.
  * Use QML if you want to  do your UI quickly!

For further details, see
[The latest documentation on Qt](http://doc.trolltech.com/4.7/index.html);
["Extending QML in C++"](http://doc.qt.nokia.com/4.7/qml-extending.html),
which has special section on calling qtscript back out of C++
["Reacting to C++ Objects Signals in Scripts"](http://doc.qt.nokia.com/4.7/scripting.html#reacting-to-c-objects-signals-in-scripts).
Xizhi (Steven) Zhu's article
[Hybrid application using QML and Qt C++](http://xizhizhu.blogspot.com/2010/10/hybrid-application-using-qml-and-qt-c.html)
is further helpful reading on this technique. Finally, regarding the above suggestion of using
[QAbstractItemModel](http://doc.qt.nokia.com/4.7/qabstractitemmodel.html),
a simpler approach for integrating C++ models with QML GUI code
[is to use RoleItemModel](http://wiki.forum.nokia.com/index.php/Using_QStandardItemModel_in_QML).

## GUI Components in Qt Quick ##

Qt Quick and QML don't provide a "widget" set in the traditional sense. If
one wants to develop with a certain look and feel, that is to be embodied
in the widget set itself, rather than being a part of Qt Quick or QML. This
flexibility can be problematic for rapid prototyping because there's no
"one right way to do things" and there are few reusable components or
patterns to help developers started. Qt Quick however, makes it easier to
implement UI designers Photoshop work and turn it into a real user
interface: http://labs.qt.nokia.com/2010/10/19/exporting-qml-from-photoshop-and-gimp/ .

However, with this flexibility, easy adherence to "user interface design
guidelines" is pushed to the GUI components used. These components are
manufacturer-specific with Qt Quick, and embodied within separate
[contributed, public/open and private GUI components](http://developer.qt.nokia.com/wiki/QtQuickOpenComponents).

A public project,
[Qt Quick Colibri](http://projects.forum.nokia.com/colibri)
is designed to provide reusable UI components suitable for
cross-platform use on Symbian, Maemo, MeeGo and Windows/Mac/Linux desktop
environments. It is designed to get developers started
with cross-platform Qt Quick / QML application development. Colibri
currently includes basic components such as buttons, scrollbars, and
sliders, and a few more advanced ones like histograms and album carousel.

[Thomas Perl's](http://thp.io/)
[Article on Qt Quick Colibri through Pyside](http://developer.qt.nokia.com/wiki/Utilizing_Qt_Quick_Colibri_in_PySide)
shows the same interface done without and with Qt Quick Colibri, with code examples:

<p align='center'><img src='http://farm6.static.flickr.com/5043/5226958058_6b5b91d1a3.jpg' /></p>
<p align='center'><b>Figure 7: Thomas Perl's plain QML example</b></p>

<p align='center'><img src='http://farm6.static.flickr.com/5287/5229084500_da49bab19f.jpg' /></p>
<p align='center'><b>Figure 8: Thomas Perl's example using Qt Quick Colibri</b></p>

In the future, correct "native" and platform-specific look-and-feel will be
provided by
[Qt Quick Components](http://developer.qt.nokia.com/wiki/Qt_Quick_Components),
which will bring cross platform components to QML, as an official Nokia
funded project to provide a consistent "native user experience" on Nokia
mobile platforms.

YTD-MeeGo will use whatever components, probably from Colibri, that will
help get the project off the ground as rapidly as possible, with the least
amount of code. The GUI needs of the YTD-Android application are
rudimentary "data browsers" combined with the usual buttons, menus,
etc. The data structures in YTD-MeeGo are designed to allow easy
presentation via preexisting
[QML Declarative Data models](http://doc.qt.nokia.com/4.7/qdeclarativemodels.html),
such as:

  * [Folder List Model](http://doc.qt.nokia.com/4.7/src-imports-folderlistmodel.html)
<p align='center'><img src='http://doc.qt.nokia.com/4.7/images/declarative-folderlistmodel.png' /></p>
<p align='center'><b>Figure 9: declarative folder list model</b></p>
  * [XML List Model](http://doc.qt.nokia.com/4.7/qml-xmllistmodel.html)
<p align='center'><img src='http://doc.qt.nokia.com/4.7/images/qml-xmllistmodel-example.png' /></p>
<p align='center'><b>Figure 10: QML List Model</b></p>
  * [List Model](http://doc.qt.nokia.com/4.7/qml-listmodel.html) and [List Element](http://doc.qt.nokia.com/4.7/qml-listelement.html)
    * Use a [ListView to display the ListModel](http://wiki.forum.nokia.com/index.php/Using_QML_ListView)
<p align='center'><img src='http://doc.qt.nokia.com/4.7/images/listmodel.png' /></p>
<p align='center'><b>Figure 11: List Model and List Element</b></p>
  * [Visual Item Model](http://doc.qt.nokia.com/4.7/qml-visualitemmodel.html)
<p align='center'><img src='http://doc.qt.nokia.com/4.7/images/visualitemmodel.png' /></p>
<p align='center'><b>Figure 12: Visual Item Model</b></p>
  * For details, see [QML View Elements](http://doc.qt.nokia.com/4.7/qml-view-elements.html)

## Browsing Captured Media in MeeGo Document Gallery ##

The [Tracker Subsystem](http://projects.gnome.org/tracker/) in MeeGo
provides
[configurable](http://linux.die.net/man/5/tracker.cfg)
indexing, meta-data extraction, and search capabilities for a variety of
data types. Tracker is a central repository for files and media, allowing data-sharing between applications,
while enabling
["Semantic Search"](http://en.wikipedia.org/wiki/Semantic_search)
via
[RDF](http://www.w3.org/RDF/)-based [ontologies](http://en.wikipedia.org/wiki/Ontology).
When storing captured media, Tracker is used for tagging media files with
meta-data, including Geolocation data.

The MeeGo Document Gallery, where videos and associated metadata are stored
for use by applications, has a QML interface available in QtMobility 1.2.  The
[Gallery QML Plugin](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/qml-gallery.html)
from "preview release" QtMobility 1.2 provides this functionality. The
[QML DocumentGalleryItem Element](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/qml-documentgalleryitem.html)
is where the file-type, e.g. video, is stored, the "progress" percentage in
uploading/downloading, alongside other file metadata. In conjunction with a
[QML DocumentGalleryModel Element](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/qml-documentgallerymodel.html),
the following QML browses image documents in the gallery using this functionality:
```
     import Qt 4.7
     import QtMobility.gallery 1.1
    
     Rectangle {
         width: 1024
         height: 768
    
         GridView {
             anchors.fill: parent
             cellWidth: 128
             cellHeight: 128
    
             model: DocumentGalleryModel {
                 rootType: DocumentGallery.Image
                 properties: [ "url" ]
                 filter: GalleryWildcardFilter {
                     property: "fileName";
                     value: "*.jpg";
                 }
             }
    
             delegate: Image {
                 source: url
                 width: 128
                 height: 128
             }
         }
     }
```

[A Qt Tracker Library](http://maemo.gitorious.org/maemo-af/libqttracker)
allows access to Tracker at the C++ level for any Tracker API's not covered by QML.

Note that Tracker is part of the not-yet-final MeeGo 1.2 Sharing Framework.
Yet to be completed features -- "Transfer history preservation in Tracker;
to ensure easy way to establish relationship between services and data." --
indicate unimplemented functionality:
  * [FEATURE: Transfer UI: Common transfer management](http://bugs.meego.com/show_bug.cgi?id=8181)
  * [FEATURE: Share UI: Unified entry point to select a destination](http://bugs.meego.com/show_bug.cgi?id=8179).

An alternative, for the tags part, is to use the underlying gstreamer [Tagreadbin](http://wiki.maemo.org/Documentation/Maemo_5_Developer_Guide/Architecture/Multimedia_Domain#Decodebin2.2FTagreadBin):
> Tracker ... can use high level GStreamer components ([decodebin2/tagreadbin](http://maemo.org/api_refs/5.0/5.0-final/gst-plugins-base-plugins-0.10/gst-plugins-base-plugins-tagreadbin.html)) to gather metadata from all supported media files. Tagreadbin can provide better performance than playbin2 by avoiding to plug decoders and utilize special codepath in parsers and demuxer for getting only metadata.

## MeeGo GeoClue Subsystem for Geolocation data ##

MeeGo provides [GeoClue](http://www.freedesktop.org/wiki/Software/GeoClue) for location services such as GPS, GSM Cell and
Wifi Network. The appropriate API for YTD-MeeGo is
[Qt Mobility's Location API](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/location-overview.html)
which provides a C++ programming interface. A
[Hybrid C++/QML example of using GPS](http://wiki.forum.nokia.com/index.php/Qt_C%2B%2B_and_QML_integration,_context_properties_and_GPS_compass)
provides examples showing how this functionality is coded with QtMobility 1.0.

YTD-MeeGo will seek to use the QtMobility 1.2
[QML Location Plugin](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/qml-location-plugin.html)
which provides high-level QML access to location data, hopefully at a
sufficient level that further hybrid C++ coding will not be
necessary. Unfortunately, this facility is not available, even in the just
released
[QtMobility 1.2 technology preview](http://labs.qt.nokia.com/2010/12/24/qt-mobility-1-2-technology-preview/):
"Location: Geoclue backend code is not enabled in TP package. (enabled in master code line)"

Compared to the complexities of the hybrid programming needed with
QtMobilility 1.0, the QML-only approach of QtMobility 1.2 is much more
concise. The
[QML PositionSource Element](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/qml-positionsource.html)
snippet below retrieves [NMEA](http://en.wikipedia.org/wiki/NMEA) format GPS data entirely in QML:

```
     import Qt 4.7
     import QtMobility.location 1.1
    
     Rectangle {
             id: page
             width: 350
             height: 350
             PositionSource {
                 id: positionSource
                 updateInterval: 1000
                 active: true
                 // nmeaSource: "nmealog.txt"
             }
             Column {
                 Text {text: "<==== PositionSource ====>"}
                 Text {text: "positioningMethod: "  + printableMethod(positionSource.positioningMethod)}
                 Text {text: "nmeaSource: "         + positionSource.nmeaSource}
                 Text {text: "updateInterval: "     + positionSource.updateInterval}
                 Text {text: "active: "     + positionSource.active}
                 Text {text: "<==== Position ====>"}
                 Text {text: "latitude: "   + positionSource.position.coordinate.latitude}
                 Text {text: "longitude: "   + positionSource.position.coordinate.longitude}
                 Text {text: "altitude: "   + positionSource.position.coordinate.altitude}
                 Text {text: "speed: " + positionSource.position.speed}
                 Text {text: "timestamp: "  + positionSource.position.timestamp}
                 Text {text: "altitudeValid: "  + positionSource.position.altitudeValid}
                 Text {text: "longitudeValid: "  + positionSource.position.longitudeValid}
                 Text {text: "latitudeValid: "  + positionSource.position.latitudeValid}
                 Text {text: "speedValid: "     + positionSource.position.speedValid}
             }
             function printableMethod(method) {
                 if (method == PositionSource.SatellitePositioningMethod)
                     return "Satellite";
                 else if (method == PositionSource.NoPositioningMethod)
                     return "Not available"
                 else if (method == PositionSource.NonSatellitePositioningMethod)
                     return "Non-satellite"
                 else if (method == PositionSource.AllPositioningMethods)
                     return "All/multiple"
                 return "source error";
             }
     }
```

## Reusing QtMobility 1.2's "declarative camera" Example ##

[QtMobility's declarative camera demo](http://doc.qt.nokia.com/qt-mobility/declarative-camera.html)
will form the basis for the "camera" parts of YTD-direct. Unfortunately,
similar to the situation with GPS data above, the camera is not yet
functional in the
[Qt Mobility 1.2 Technology Preview](http://labs.qt.nokia.com/2010/12/24/qt-mobility-1-2-technology-preview/):
"qml\_camera does not display an image." See the system architecture
section, below, titled "QtMobility 1.2 and the N900 Camera Component."

However, the "declarative camera" example will be added to YTD-meego as a
"stub" implementation, allowing prototyping of the GUI and the camera
interface part of the application. The example would be modified so that
the camera frame would come up when the application is put into
video-shooting mode, and instead of quitting camera mode, the user would be
returned to the application's top-level. The example
[QML-based GUI and code](http://doc.qt.nokia.com/qt-mobility/declarative-camera-declarative-camera-qml.html)
creates a camera GUI like this:

<p align='center'><img src='http://doc.qt.nokia.com/qt-mobility/images/qml-camera.png' /></p>
<p align='center'><b>Figure 13: Reusing GUI of QML camera</b></p>

Below, a snippet of code associated with the "declarative camera", to give
an example of the high-level programming associated with QML:

```
     PhotoPreview {
         id : photoPreview
         anchors.fill : parent
         onClosed: cameraUI.state = "PhotoCapture"
         focus: visible

         Keys.onPressed : {
             //return to capture mode if the shutter button is touched
             if (event.key == Qt.Key_CameraFocus) {
                 cameraUI.state = "PhotoCapture"
                 event.accepted = true;
             }
         }
     }

     Camera {
         id: camera
         x : 0
         y : 0
         width : 640
         height : 480
         focus : visible //to receive focus and capture key events
         flashMode: stillControls.flashMode
         whiteBalanceMode: stillControls.whiteBalance
         exposureCompensation: stillControls.exposureCompensation

         onImageCaptured : {
             photoPreview.source = preview
             stillControls.previewAvailable = true
             cameraUI.state = "PhotoPreview"
         }
     }
```

For details, see

  * [Declarative Camera Example Source](http://qt.gitorious.org/qt-mobility/qt-mobility/trees/master/examples/declarative-camera)
    * [QML Camera Capture Controls](http://doc.qt.nokia.com/qt-mobility/declarative-camera-capturecontrols-qml.html)
    * [QML Camera Focus Button](http://doc.qt.nokia.com/qt-mobility/declarative-camera-focusbutton-qml.html)
    * [QML Camera Photo Preview](http://doc.qt.nokia.com/qt-mobility/declarative-camera-photopreview-qml.html)
  * [C++ Camera Example Source](http://qt.gitorious.org/qt-mobility/qt-mobility/trees/master/examples/camera)

## Authentication and Access Control in QML ##

YTD Video uploads as well as any other operations that modify or write data
require authorization, which is done through an authentication token
submitted in the API request. For details, see:
http://code.google.com/apis/youtube/articles/youtube_mobileresources.html#security

[ClientLogin](http://code.google.com/apis/youtube/2.0/developers_guide_protocol_clientlogin.html#)
is the simplest method to use for mobile applications. For example, the YTD-Android application, uses the
[Android AccountManager](http://developer.android.com/reference/android/accounts/AccountManager.html)
to  obtain authentication tokens. In Qt, HTTP authentication is handled via
[QNetworkAccessManager](http://doc.qt.nokia.com/stable/qnetworkaccessmanager.html). An example
[shows how this is accomplished in a few lines of code in Qt](http://wiki.forum.nokia.com/index.php/HTTPAuthWithQNetMan).

An alternative and preferred standard is
[OAuth](http://code.google.com/apis/youtube/2.0/developers_guide_protocol_oauth.html)
, for which http://gdata-java-client.googlecode.com/ is an example Java client.
An example OAuth implementation using QML can be found at http://gitorious.org/qt-qml-demo-playground/qt-qml-demo-playground/trees/master/twitter-oauth :
  * http://gitorious.org/qt-qml-demo-playground/qt-qml-demo-playground/blobs/master/twitter-oauth/TwitterCore/OAuth.js
  * http://gitorious.org/qt-qml-demo-playground/qt-qml-demo-playground/blobs/master/twitter-oauth/TwitterCore/OAuth.qml
  * see also http://googlecodesamples.com/oauth_playground/

## JSON RPC in QML ##

The web component of the app will be implemented entirely in QML, using YouTube-Direct's JSON API:
  * http://code.google.com/p/youtube-direct/wiki/YTDAdminJSONAPI
    * In YTD v2.0, the admin backend is complemented with a JSON-RPC API that enables you to fetch all the data relating to assignments, submissions and configuration programmatically.
    * The admin API is based on the JSON-RPC protocol format. It is essentially a REST-ful POST request with a JSON payload. For more information on JSON-RPC - http://en.wikipedia.org/wiki/JSON-RPC.

http://bugreports.qt.nokia.com/browse/QTBUG-12117 suggests a JSON data
model for QML suggests a "design pattern" as workaround:

> It would be very convenient to have a JSON data model to use with QML's
> list view elements, instead of emulating a model using !XMLHttpRequest,
> regular JavaScript JSON support and ListModel. For example:
```
     Item {
         ListModel { id: listmodel }
         onCompleted: {
             var xhr = new XMLHttpRequest;
             xhr.open("GET", "http://service.com/api");
             xhr.onreadystatechange = function() {
                 if (xhr.readyState == XMLHttpRequest.DONE) {
                     var a = JSON.parse(xhr.responseText);
                     for (var b in a) {
                         var o = a[b];
                         listmodel.append({name: o.name, url: o.url});
                     }
                 }
             }
             xhr.send();
         }
     }
```

The above pattern is an example of how the interface to the YTD assignment
feed in YTD-MeeGo could be implemented.  An assignment feed is similar to
an RSS feed, except it uses JSON syntax rather than the more verbose and
tedious XML. An example of an Qt Quick application using such a feed is a
[Qt-Quick "twitter' client](http://projects.forum.nokia.com/QtQuickTwitterExample)
.  This constructs a data model that can be browsed by the
QML "XML List Model" introduced above:
[QtQuickTwitterExample Data Model](http://projects.forum.nokia.com/QtQuickTwitterExample/browser/twitter/content/TwitterModel.qml)
displaying the data present in the RSS in a GUI:

<p align='center'><img src='http://projects.forum.nokia.com/QtQuickTwitterExample/raw-attachment/wiki/WikiStart/Twitter-listview1.png' /></p>
<p align='center'><b>Figure 14: Reuse QtQuickTwitterExample GUI for displaying YTD Assignments</b></p>

A similar integration of QML models and JSON/RPC data from a webserver is
the XBMC Remote for the [X Box Media Center](http://xbmc.org/), which itself
has already been [ported to MeeGo](http://www.madeo.co.uk/?page_id=605):

  * http://gitorious.org/xbmc-qml-remote
  * http://gitorious.org/xbmc-qml-remote/pages/Home

<p align='center'><img src='http://www.meegoexperts.com/wp-content/uploads/2011/07/XBMC-Remote-Controller-Harmattan-Nokia-N950-meego-meegoexperts.png' /></p>
<p align='center'><b>Figure 15: XBMC QML Remote Example uses JSON RPC</b></p>

Some code examples from that app doing JSON/RPC entirely within QML:

http://gitorious.org/xbmc-qml-remote/xbmc-qml-remote/blobs/master/js/player.js
```
Player.prototype.cmd = function(cmd, param) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
                if (doc.readyState == XMLHttpRequest.DONE) {
                        //console.log(doc.responseText);
                }
        }

        doc.open("POST", "http://"+$().server+":" + $().port + "/jsonrpc");
        var str = '{"jsonrpc": "2.0", "method": "'+this.type+'Player.'+cmd+'",';
        if (param) {
                str += param + ","
        }
        str += ' "id": 1}';
        console.log(str);
        doc.send(str);
        return;
}
```

http://gitorious.org/xbmc-qml-remote/xbmc-qml-remote/blobs/master/js/library.js
```
Library.prototype.loadMovies = function () {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
                if (doc.readyState == XMLHttpRequest.DONE) {
                        //console.log(doc.responseText);

                        var result = JSON.parse(doc.responseText).result;
                        var movies = result.movies;
                        for (var i = 0; i < movies.length; i++){
                                //console.log(movies[i].thumb)
                                var thumb = "http://"+$().server+":" + $().port + "/images/DefaultAlbumCover.png";
                                if (movies[i].thumbnail) {
                                        thumb = "http://192.168.0.11:8080/vfs/" + movies[i].thumbnail;
                                }

                                movieModel.append({"id": movies[i].movieid, "name": movies[i].label, "thumb": thumb, "genre":  movies[i].genre, "duration": movies[i].runtime, "rating": movies[i].rating});
                        }
                }
        }

        doc.open("POST", "http://"+$().server+":" + $().port + "/jsonrpc");
        var str = '{"jsonrpc": "2.0", "method": "VideoLibrary.GetMovies", "params": { "start": 0, "fields": ["genre", "director", "trailer", "tagline", "plot", "plotoutline", "title", "originaltitle", "lastplayed", "showtitle", "firstaired", "duration", "season", "episode", "runtime", "year", "playcount", "rating"] }, "id": 1}';
        doc.send(str);

        return;
 }
```

## Resumable Uploading and Network Bearer Management ##

One of the issues with a youtube-direct client, noted in private comment by
YTD-Android author Jarek Wilkiewicz ([YouTube Developer Advocate at Google](http://www.slideshare.net/wjarek/building-video-applications-with-youtube-apis)), is that the error&retry logic in resumable
uploads need be robust: uploading large files while on the move, over flaky
and shifting networks is nontrivial.  This is handled by the
[YouTube API for resumable uploads](http://code.google.com/intl/ja/apis/youtube/2.0/developers_guide_protocol_resumable_uploads.html).
YTD-meego must work with this API and provide the retry and
partial-upload logic that is robust in the face of networking challenges.

http://code.google.com/apis/youtube/articles/youtube_mobileresources.html#uploading provides details:

> For mobile applications, [direct resumable uploading](http://code.google.com/apis/youtube/2.0/developers_guide_protocol_resumable_uploads.html#Resumable_uploads) is the most reliable choice since it enables an application to gracefully recover from connectivity failures and resume an upload from the point of failure. YouTube’s resumable uploading protocol leverages the HTTP 1.1 [Content-Range/Range](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.16) mechanism to transfer videos in chunks and, in the event of an interruption, to identify the number of bytes that were successfully transferred.

> While the actual video content is the most important component in an upload, video metadata is an integral part of the process since that metadata lets users locate videos in search and also enables other features described later in this article. In addition to common elements like a category, description, and title, mobile applications can easily include [geolocation](http://code.google.com/apis/youtube/2.0/reference.html#GeoRSS_elements_reference) data from the phone’s GPS device. These data let you provide location-based search or to plot video locations on a map. For video upload applications seeking to minimize user interaction, zero-metadata uploads are another option and more information about that is available from this Google I/O [talk](http://apiblog.youtube.com/2010/06/youtube-api-google-io-2010.html).

One of the issues for MeeGo and this this project is how do these long uploads work alongside
["Bearer Management"](http://doc.qt.nokia.com/qtmobility-1.2/bearer-management.html):

> The Bearer Management API controls the system's connectivity state. This
> incorporates simple information such as whether the device is online and
> how many interfaces exist. It also gives the application developer the
> ability to start and stop network interfaces and influences other
> connections specific details. Depending on the platform's capabilities it
> may even provide session management so that a network interface remains up
> for as long as clients have a registered interest in them while at the
> same time optimizing the interface's uptime.

Hopefully the integration is implicit at the QML level since "Bearer
Management" is integrated with
[Qt 4.7 QtNetwork library](http://doc.qt.nokia.com/qtmobility-1.2/qtnetwork.html)
providing connection manager and roaming support for
[QNetworkAccessManager](http://qt.nokia.com/doc/4.7/qnetworkaccessmanager.html).

## The road not taken: Hybrid WebKit with XQuery ##

[Nokia Qt Labs "videofeed"](http://qt.gitorious.org/qt-labs/graphics-dojo/trees/master/videofeed)
application suggests an alternative implementation strategy that probably
won't be used in this project, but is interesting to consider for this
class of application. The Nokia demo states: "Various video websites like
YouTube, Google Videos, TED provide the list of videos as RSS, Atom. The
demo extracts contents from the RSS using
[XQuery](http://doc.trolltech.com/4.7/xmlprocessing.html).
The list of feeds and the
[XQuery](http://developer.qt.nokia.com/wiki/XQueryTutorials)
used to extract contents is read in dynamically through
configuration files."

One of the configuration files,
[rss/youtube.xq](http://qt.gitorious.org/qt-labs/graphics-dojo/blobs/master/videofeed/rss/youtube.xq),
looks like:

```
  for $i in doc($uri)/rss/channel/item
      return fn:string-join( (
          $i/title/string(), 
          "author",
          $i/description/string(),
          "subtitle",
          $i/link/string(),
          $i/guid/string(),
          $i/pubDate/string(),
          "duration"
          ), " %%QT_DEMO_DELIM%% ")
```

Note that this technique also uses the high-overhead pathway of WebKit to
NPAPI to Flash just to display video; CSS transitions/animations are used
for display instead of the functionality provided in a "Qt Quick
Components" or "Qt Quick Colibri."  The above implementation also makes use
of WebKit for offline storage -- which is also an issue ytd-meego will
face.

It might be easiest to do the "web" part of the app this way, and enable
call-outs to QtMobility for playing or recording media, geotagging, etc. It
would be "cheating" to just drop an existing
[YTD web-application](http://ytd-demo.appspot.com/test.html)
directly into a WebKit 'iframe' inside the application, and then just
intercept the file selection/uploading part with a media file chosen by the
application. Of course, many a handheld "application" is just such a
custom-purpose web browser these days, so this option shouldn't be totally
ruled out as last resort.

The goal of this project, however, is to implement the functionality
"natively" in QML, rather than deliver a site-specific, customized web
browser. Furthermore, relying on WebKit is a very high-overhead way of
implementing the relatively trivial web interactions needed by this app,
most of which are outlined in this article.
[Discussion on the Qt-QML list](http://lists.qt.nokia.com/pipermail/qt-qml/2010-December/001948.html)
suggest WebKit adds about 10Mb to the application runtime, even when not
instantiating an actual WebView element.

On the other hand, perhaps such an approach will be needed anyways for
pragmatic reasons.  For example: needing to reuse an existing browser-based
authentication portal, such as cross-domain authentication from a main
'www' site to a separate 'ytd' site, and to handle other cross-application
and cross-domain cookies that need to be used by the custom handheld
application.

## QtMobility 1.2 and the N900 Camera Component ##

As the MeeGo Handset UX platform is under development, some of the media
infrastructure needed by this project is incomplete and not in a usable
state for application developers. In particular, camera functionality and
video recording will not be available until MeeGo 1.2, to be released April
2011. There are a number of issues delaying camera integration on MeeGo,
which were clarified in IRC by the N900 hardware adaptation lead Teemu
Tuominen:

> Tuesday, December 14, 2010 11:47:01 pm #meego: theodor:
> currently, the differences in kernel level are ... delaying camera
> integration.. since we have selected to support new architecture that
> cannot be accepted by meego reference kernel due its partly
> experimental.... To fully featurize camera in N900, MeeGo needs
> components that used to be closed binaries in Maemo side. I assume a
> bunch of 3rdParty agreements needs to be dealt differently with MeeGo,
> and can only hope that this is ongoing work.

The status of camera and GPS functionality on the n900 were discussed on
12/16/10 meeting on Nokia N900 Hardware Adaptation:

  * http://trac.tspre.org/meetbot/meego-meeting/2010/meego-meeting.2010-12-16-08.00.html
  * http://trac.tspre.org/meetbot/meego-meeting/2010/meego-meeting.2010-12-16-08.00.log.html

The camera features needed by YTD-MeeGo that are under implementation for MeeGo 1.2
include:

  * [FEATURE: camerabin support in GStreamer](http://bugs.meego.com/show_bug.cgi?id=7623)
    * See "GStreamer: Plugins for Video and Camera Subsystem" below.
  * [FEATURE: Camera](http://bugs.meego.com/show_bug.cgi?id=5461)
    * A Camera application is required to capture still images and record videos with the device.
  * [FEATURE: Camera subsystem](http://bugs.meego.com/show_bug.cgi?id=2743)
    * MeeGo to provide [V4L2](http://linux.bytesex.org/v4l2/) for Camera subsystem
    * Components are required on the kernel side: Media controller core, Primary and secondary sensor drivers (et8ek8 and smia-sensor), Flash and lens controller drivers (adp1653 and ad5820), OMAP3 ISP driver (isp-mod), OMAP34xx camera driver (omap34xxcam)
    * Available at http://gitorious.org/omap3camera/mainline

[Qt Mobility 1.2 Technology Preview](http://labs.qt.nokia.com/2010/12/24/qt-mobility-1-2-technology-preview/)
was just released December 24 2010, so it may be possible to develop and
test for some of the camera functionality ahead of the MeeGo 1.2
release. Unfortunately, this will not result in a functional camera:
"qml\_camera does not display an image." and developers are warned of the
status of the code.

What is useful for this project is the updated
[documentation on Qt Mobility 1.2](http://doc.qt.nokia.com/qtmobility-1.2.0-tp1/). The
software is now available for testing currently with a
[MeeGo repository](http://download.meego.com/live/devel:/qt-mtf:/qt-mobility:/1.2tp1/testing/)
and packages 'qt-mobility' and 'qt-mobility-examples' available for install via zypper.

## Prototyping Plan ##

As detailed above, the Camera subsystem, Tracker subsystem, and GeoClue
subsystems in MeeGo will not be fully functional until the 1.2
release. Therefore, the project will focus on porting YTD-android's
web-interactions using, at first, "canned test data" of manually tagged,
geolocated, and captured/encoded video. While the missing
QtMobility 1.2 functionality is solidified, the project can make progress
on login/authentication, resumable uploading, GUI for the
story/assignments, notification and selection, etc. Although
not-functional, the "declarative-camera" GUI can be integrated into the
application "early."  This will allow design of modal camera vs. browsing
activity intrinsic in the application. Since the idea is to extend the
"declarative camera" application to encompass YTD-meego's functionality,
the functioning example will eventually yield functioning viewfinder and
camera controls in YTD-meego.

Actual capture and compression of video will require a working v4l2
subsystem and GStreamer plugins for OMAP DSP support for on-the-fly video
compression. Until then "canned" video files can be used.  Likewise,
Geotagging support will require a working GeoClue subsystem. Until then,
"canned" GPS locations can be used...

# N900 Platform and Hardware Overview #

In order to better understand the issues in building and porting multimedia
applications to the MeeGo Handset, we first need to understand the deep
multimedia capabilities of the platform. The
[Nokia N900](http://www.nokiausa.com/find-products/phones/nokia-n900/specifications)
is the
[ARM reference platform for the Meego Handset](http://wiki.meego.com/ARM/N900), so below, are details on the hardware and
system level interfaces provided by the current
[MeeGo 1.1  Handset](http://meego.com/downloads/releases/1.1/meego-v1.1-handset) and upcoming 1.2 releases.

The following diagram describes the
[Nokia n900 Maemo "Multimedia Domain"](http://wiki.maemo.org/Documentation/Maemo_5_Developer_Guide/Architecture/Multimedia_Domain),
and should translate, roughly, to MeeGo on the same platform:

<a href='Hidden comment: <p align="center">[http://wiki.maemo.org/images/thumb/5/56/OMAP_architecture.png/800px-OMAP_architecture.png]

Unknown end tag for &lt;/p&gt;

'></a>
<p align='center'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/800px-OMAP_architecture.png' /></p>
<p align='center'><b>Figure 16: N900 Multimedia Architecture</b></p>

http://meego.com/developers/meego-architecture/meego-architecture-domain-view
describes MeeGo's "Multimedia domain": providing audio and video playback,
streaming, and imaging functionality to the system. It handles retrieval,
demuxing, decoding and encoding, seeking of audio and video data. It
includes the following subsystems under "Media Services" part of MeeGo Middleware:

  * Gstreamer provides cross platform, plugin-based framework for playback, streaming, and imaging.
  * PulseAudio handles audio inputs, post/pre processing, and outputs in a system.
  * Camera subsystem provides still and video camera functionality, including platform specific codecs and containers for GStreamer, metadata, and image post processing.
  * GStreamer-compatible codecs are supported for encoding / decoding of audio and video
  * GUPnP is an object-oriented framework for creating UPnP devices and control points, with extension libraries for IGD and A/V specifications

The source code for these components is located at http://meego.gitorious.org/maemo-multimedia .

## Pulseaudio: Connecting Audio Subsystem, Microphone and Speakers ##

The audio subsystem is depicted in the following diagram from
[Jyri Sarha's presentation "Practical Experiences from Using Pulseaudio in Embedded Handheld Device"](http://linuxplumbersconf.org/2009/slides/Jyri-Sarha-audio_miniconf_slides.pdf)
from the recent Linux Plumber's Conference:

<p align='center'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/N900-Pulseaudio-Configuration.png' /></p>
<p align='center'><b>Figure 17: MeeGo Pulseaudio Architecture</b></p>

A lively thread on the role of pulseaudio in a handset was started on the [Linux Audio Developers](http://lists.linuxaudio.org/listinfo/linux-audio-dev) and [Meego Handset](http://lists.meego.com/pipermail/meego-handset/) Lists, with notable replies by:
  * Marco Ballesio (Nokia Multimedia Architect): [LAD#1](http://lalists.stanford.edu/lad/2010/12/0164.html), [LAD#2](http://lalists.stanford.edu/lad/2010/12/0166.html)
  * [Kai Vehmanen](http://www.eca.cx/kv/) (Nokia MeeGo Telephony and [Ecasound](http://www.eca.cx/ecasound/) author): [LAD#3](http://lalists.stanford.edu/lad/2010/12/0168.html), [LAD#4 ](http://lalists.stanford.edu/lad/2010/12/0167.html), [LAD#5](http://lalists.stanford.edu/lad/2010/12/0170.html)

## GStreamer: Plugins for Video and Camera Subsystem Compression and Decompression ##

Dr. Stefan Kost's presentation on the
[MeeGo Multimedia Stack](http://elinux.org/images/d/d1/MeeGoMultimedia.pdf)
provides a good overview of the GStreamer framework, which enables
[DSP video processing via open-source APIs](http://www.eetimes.com/design/signal-processing-dsp/4004620/DSP-video-processing-via-open-sourceAPIs):

<p align='center'><a href='http://elinux.org/images/d/d1/MeeGoMultimedia.pdf'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/KostMeegoMultimediaGstreamer.png' /></a></p>
<p align='center'><b>Figure 18: MeeGo GStreamer Architecture</b></p>

Kost's presentation suggests the following subcomponents.
  * For still  and video capture via the camera, the GStreamer "camerabin" and "GStreamer elements for format conversion, metadata (XMP, EXIF), muxing, data routing."
  * For video editing, e.g. so that YTD-meego uploads a clip from a longer video: GStreamer "gnonlin" and "GStreamer components for muxing, demuxing, format conversion."
  * For metadata indexing and thumbnailing: "[Tagreadbin](http://maemo.org/api_refs/5.0/5.0-final/gst-plugins-base-plugins-0.10/gst-plugins-base-plugins-tagreadbin.html) (experimental)" and "GStreamer components for parsing, demuxing."

Unfortunately, such GStreamer support is not yet available in MeeGo 1.1 and
will appear with Qt Mobility 1.2 and MeeGo 1.2:

  * [FEATURE: camerabin support in GStreamer](http://bugs.meego.com/show_bug.cgi?id=7623)
    * still image capture with: arbitrary post processing, zooming, various resolutions.
    * 3A (autofocus, autowhitebalance and autoexposure): locking 3A settings
    * viewfinder with: arbitrary post processing
    * videocapture with: arbitrary post processing, zooming, various resolutions

## MeeGo Policy Framework ##

<p align='center'><a href='http://wiki.meego.com/images/Meego-policy-framework-developer-guide.pdf'><img src='http://ytd-meego.googlecode.com/svn/wiki/img/meego-policy-framework.png' /></a></p>
<p align='center'><b>Figure 19: MeeGo Policy Framework Architecture</b></p>

Marco Ballesio's,
[Policy Framework: A Flexible Way To Orchestrate Multiple Functionalities On MeeGo Devices](http://conference2010.meego.com/session/policy-framework-flexible-way-orchestrate-multiple-functionalities-meego-devices)
from the MeeGo 2010 conference outlines the role of the MeeGo
["Policy Framework"](http://wiki.meego.com/images/Meego-policy-framework-developer-guide.pdf):

> Functionalities like phone, camera, media player or navigator are often combined in MeeGo devices. Each of them corresponds to a device mode and defines thus an expected behavior pattern. MeeGo devices are expected to behave according to an active device mode and, as a consequence, the behavior of applications can be device mode dependent. The Policy Framework isolates and offloads as much as possible the mode based logic from the applications, making porting of mainstream desktop applications easy. The offloaded logic includes arbitration of media resource usage, management of media streams (routing, audio muting etc) and assignment of adequate resources in terms of memory and scheduling priority. The Policy Framework also isolates and offloads the HW adaptation from the applications and implements implicit, device mode dependent actions to handle events like calls or messages, improving the end-user-experience on handsets or other devices with slower user interaction mechanisms.

Still to be determined: how would ytd-meego interact with this Policy
Framework on a handset. For example: what happens if a phone call comes in
while you're shooting video? What forms of notifications, or
application-switching, are allowed while ytd-meego is being used? Will using
QtMobility API automatically make this application compliant?

Similar "Policy Framework" issues include preventing scheduling background tasks while
capturing media. For example a typical
[complaint over the Tracker subsystem](http://talk.maemo.org/showthread.php?t=61960) suggests,
alongside the fact that it won't be available until MeeGo 1.2, that
this project might best work-around using Tracker and use more traditional
APIs for managing media files:

> I would like it to index the new pictures/videos AFTER I've shot them, after LEAVING the application that made them. Not during...
> In general, while I'm doing the creation, I would want as little other system activity as possible. Real multi-tasking on a limited resource device only goes that far ... Ask Apple and Google.
> So while doing time critical stuff, I ideally want all non-critical stuff frozen.
> That would help the stuttering while filming.

# Future work enabled by a "Video 2.0" platform #

The new generation of hybrid video/computing platform such as the Nokia
N900 or N8 enable a whole different world of applications. For example the
["TranslatAR" project](http://vision.ece.ucsb.edu/~kleban/papers/translatAR.pdf)
which combines Optical Character Recognition with a computational camera
platform. Stanford University's
[FCam Project ](http://www-graphics.stanford.edu/papers/fcam/)
suggests other applications of
"[Camera 2.0](http://www-graphics.stanford.edu/projects/camera-2.0/)":
> "high dynamic range imaging, flash-noflash imaging, coded aperture and coded exposure imaging, photography under structured illumination, multi-perspective and panoramic stitching, digital photomontage, all-focus imaging, and light field imaging."

The YTD Application on a handset represents the first steps
towards "Video 2.0."  With the veracity of news and video footage always in
question, such platforms can make use of existing platform cryptography
libraries which can be applied to digitally signing an embedded timecode,
geotags and other information embedded in the video. Using cryptography, an
initial "chain of custody" on the video could be established, such as a
specific certificate issued by the news organization that ensures the
platform/software/submitter of the information are not forgeries. By
watermarking digital signatures of GPS geotags and a monotonically
increasing timecode into the video, edits, photoshopping and omissions to
that video become "provable." These are innovative uses of video that can
only be enabled by having a complete and robust mobile computing and
telecommunication platform like MeeGo built into the "video camera"

# Conclusion #

Please add your comments, in the comments section of this article, and if
you have something to contribute to the project, please volunteer. There's
a lot of code to write and a lot of different components to get working and
test on this promising, but evolving platform.