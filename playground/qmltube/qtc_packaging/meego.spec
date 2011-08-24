Name: qmltube
Summary: YouTube, Dailymotion and vimeo client.
Version: 1.11.1
Release: 1
License: GPL
Group: Applications/Multimedia
Requires(post): desktop-file-utils
Requires(post): /bin/touch
Requires(postun): desktop-file-utils
BuildRequires:  pkgconfig(QtCore) >= 4.6.0
BuildRequires:  pkgconfig(QtOpenGL)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  qt-mobility-devel  
BuildRequires:  libqt-devel
BuildRequires:  libqtopengl-devel  
BuildRequires:  libresourceqt-devel  
BuildRequires:  desktop-file-utils
BuildRequires: gettext
Requires: libqtcore4  
Requires: qt-mobility
Requires: libqtopengl
Requires: libresourceqt
Requires: gst-plugins-good
Requires: gst-plugins-base
Requires: gst-plugins-bad-free
Requires: gst-plugins-bad-free-extras
Requires: gst-vabuffer
Requires: qtgst-qmlsink
# %define _unpackaged_files_terminate_build 0

%description
Qmltube originates from Maemo's cutetube-qml, a YouTube, Dailymotion and
vimeo client. This package is a Meego/Linux/Harmattan port and improvement
of the original. See http://wiki.meego.com/tubelet-and-cutetube-port for
details.

%prep
%setup -q

%build
# You can leave this empty for use with Qt Creator.

%install
rm -rf %{buildroot}
make INSTALL_ROOT=%{buildroot} install
## NPM: hack-way of getting qtcreator "shadow build" to work with the spec file.
## Note that this assumes that we're "in" the shadow build directory, e.g.
## ~/%name-build-meego-meego-netbook-ia32-1_2_0_Release/ and at the same level exists a directory
## ~/%name .
mkdir     --parents --verbose        %{buildroot}%{_datadir}/applications
install -m644 ../%name/%name.desktop %{buildroot}%{_datadir}/applications
mkdir     --parents --verbose        %{buildroot}%{_datadir}/icons/hicolor/64x64/apps
install -m644 ../%name/%name.png     %{buildroot}%{_datadir}/icons/hicolor/64x64/apps
mkdir     --parents --verbose                                   %{buildroot}%{_datadir}/doc/%name
install -m644 ../%name/qtc_packaging/debian_harmattan/README    %{buildroot}%{_datadir}/doc/%name
install -m644 ../%name/qtc_packaging/debian_harmattan/changelog %{buildroot}%{_datadir}/doc/%name
install -m644 ../%name/qtc_packaging/debian_harmattan/copyright %{buildroot}%{_datadir}/doc/%name

%post
touch --no-create %{_datadir}/icons/hicolor
if [ -x %{_bindir}/gtk-update-icon-cache ]; then
  %{_bindir}/gtk-update-icon-cache --quiet %{_datadir}/icons/hicolor || :
fi

%postun
touch --no-create %{_datadir}/icons/hicolor
if [ -x %{_bindir}/gtk-update-icon-cache ]; then
  %{_bindir}/gtk-update-icon-cache --quiet %{_datadir}/icons/hicolor || :
fi

%clean
rm -rf %{buildroot}

%files 
%defattr(-,root,root,-)
%dir %{_datadir}/doc
%dir %{_datadir}/doc/qmltube
%{_datadir}/doc/qmltube/README
%{_datadir}/doc/qmltube/changelog
%{_datadir}/doc/qmltube/copyright
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/64x64
%dir %{_datadir}/icons/hicolor/64x64/apps
%{_datadir}/applications/%name.desktop
%{_datadir}/icons/hicolor/64x64/apps/%name.png
/opt/qmltube/bin/qmltube
/opt/qmltube/qml/qmltube/VimeoListDelegate.qml
/opt/qmltube/qml/qmltube/scripts/dailymotion.js
/opt/qmltube/qml/qmltube/scripts/sha1.js
/opt/qmltube/qml/qmltube/scripts/downloadscripts.js
/opt/qmltube/qml/qmltube/scripts/filter.js
/opt/qmltube/qml/qmltube/scripts/vimeo.js
/opt/qmltube/qml/qmltube/scripts/youtube.js
/opt/qmltube/qml/qmltube/scripts/menu.js
/opt/qmltube/qml/qmltube/scripts/videolistscripts.js
/opt/qmltube/qml/qmltube/scripts/createobject.js
/opt/qmltube/qml/qmltube/scripts/dateandtime.js
/opt/qmltube/qml/qmltube/scripts/mainscripts.js
/opt/qmltube/qml/qmltube/scripts/OAuth.js
/opt/qmltube/qml/qmltube/scripts/settings.js
/opt/qmltube/qml/qmltube/scripts/xtube.js
/opt/qmltube/qml/qmltube/scripts/videoinfoscripts.js
/opt/qmltube/qml/qmltube/ListHighlight.qml
/opt/qmltube/qml/qmltube/i18n/qml_en.qm
/opt/qmltube/qml/qmltube/i18n/base.qm
/opt/qmltube/qml/qmltube/i18n/qml_ru.qm
/opt/qmltube/qml/qmltube/i18n/qml_it.ts
/opt/qmltube/qml/qmltube/i18n/qml_pt.ts
/opt/qmltube/qml/qmltube/i18n/qml_ru.ts
/opt/qmltube/qml/qmltube/i18n/qml_de.ts
/opt/qmltube/qml/qmltube/i18n/qml_fi.qm
/opt/qmltube/qml/qmltube/i18n/qml_en.ts
/opt/qmltube/qml/qmltube/i18n/base.ts
/opt/qmltube/qml/qmltube/i18n/qml_nl.qm
/opt/qmltube/qml/qmltube/i18n/qml_pl.ts
/opt/qmltube/qml/qmltube/i18n/qml_nl.ts
/opt/qmltube/qml/qmltube/i18n/qml_pl.qm
/opt/qmltube/qml/qmltube/i18n/qml_fi.ts
/opt/qmltube/qml/qmltube/i18n/qml_de.qm
/opt/qmltube/qml/qmltube/i18n/qml_pt.qm
/opt/qmltube/qml/qmltube/i18n/qml_it.qm
/opt/qmltube/qml/qmltube/ExpandingImage.qml
/opt/qmltube/qml/qmltube/DMListDelegate.qml
/opt/qmltube/qml/qmltube/UserVideosView.qml
/opt/qmltube/qml/qmltube/AccountsDialog.qml
/opt/qmltube/qml/qmltube/LiveVideoListView.qml
/opt/qmltube/qml/qmltube/ChangeUserDialog.qml
/opt/qmltube/qml/qmltube/LineEdit.qml
/opt/qmltube/qml/qmltube/SettingsDialog.qml
/opt/qmltube/qml/qmltube/VimeoUserInfoDialog.qml
/opt/qmltube/qml/qmltube/DMPlaylists.qml
/opt/qmltube/qml/qmltube/WebDialog.qml
/opt/qmltube/qml/qmltube/VideoInfoView.qml
/opt/qmltube/qml/qmltube/HomeView.qml
/opt/qmltube/qml/qmltube/OAuthDialog.qml
/opt/qmltube/qml/qmltube/NewPlaylistDialog.qml
/opt/qmltube/qml/qmltube/XtubeInfoView.qml
/opt/qmltube/qml/qmltube/DMInfoView.qml
/opt/qmltube/qml/qmltube/VideoListView.qml
/opt/qmltube/qml/qmltube/DownloadList.qml
/opt/qmltube/qml/qmltube/DMUserVideosView.qml
/opt/qmltube/qml/qmltube/InboxDialog.qml
/opt/qmltube/qml/qmltube/ValueButton.qml
/opt/qmltube/qml/qmltube/UploadProgressDialog.qml
/opt/qmltube/qml/qmltube/DownloadListDelegate.qml
/opt/qmltube/qml/qmltube/NotificationArea.qml
/opt/qmltube/qml/qmltube/VimeoListView.qml
/opt/qmltube/qml/qmltube/ConfirmDeleteDialog.qml
/opt/qmltube/qml/qmltube/main.qml
/opt/qmltube/qml/qmltube/SubscriptionsView.qml
/opt/qmltube/qml/qmltube/ProgressBar.qml
/opt/qmltube/qml/qmltube/FileChooserDialog.qml
/opt/qmltube/qml/qmltube/SettingsListDialog.qml
/opt/qmltube/qml/qmltube/DMSubscriptionsList.qml
/opt/qmltube/qml/qmltube/VimeoPlaylistDialog.qml
/opt/qmltube/qml/qmltube/ToolButton.qml
/opt/qmltube/qml/qmltube/LiveVideoListDelegate.qml
/opt/qmltube/qml/qmltube/ConfirmExitDialog.qml
/opt/qmltube/qml/qmltube/HelpDialog.qml
/opt/qmltube/qml/qmltube/NoAccountDialog.qml
/opt/qmltube/qml/qmltube/SearchDelegate.qml
/opt/qmltube/qml/qmltube/TubeletPage.qml
/opt/qmltube/qml/qmltube/InboxDelegate.qml
/opt/qmltube/qml/qmltube/VideoListDialog.qml
/opt/qmltube/qml/qmltube/PlaybackDelegate.qml
/opt/qmltube/qml/qmltube/ui-images/facebookicon.png
/opt/qmltube/qml/qmltube/ui-images/closeiconred.png
/opt/qmltube/qml/qmltube/ui-images/travelicon.png
/opt/qmltube/qml/qmltube/ui-images/infoicon.png
/opt/qmltube/qml/qmltube/ui-images/deletearchiveicon.png
/opt/qmltube/qml/qmltube/ui-images/playlistsicon.png
/opt/qmltube/qml/qmltube/ui-images/rightarrowred.png
/opt/qmltube/qml/qmltube/ui-images/subscriptionsicon.png
/opt/qmltube/qml/qmltube/ui-images/tabred.png
/opt/qmltube/qml/qmltube/ui-images/audiodownloadiconlight.png
/opt/qmltube/qml/qmltube/ui-images/dislikeiconred.png
/opt/qmltube/qml/qmltube/ui-images/mobileicon.png
/opt/qmltube/qml/qmltube/ui-images/360picon.png
/opt/qmltube/qml/qmltube/ui-images/entertainmenticon.png
/opt/qmltube/qml/qmltube/ui-images/quiticon.png
/opt/qmltube/qml/qmltube/ui-images/nexticonlight.png
/opt/qmltube/qml/qmltube/ui-images/busy.png
/opt/qmltube/qml/qmltube/ui-images/likeicon.png
/opt/qmltube/qml/qmltube/ui-images/480piconlight.png
/opt/qmltube/qml/qmltube/ui-images/dragiconlight.png
/opt/qmltube/qml/qmltube/ui-images/deletefavouritesicon.png
/opt/qmltube/qml/qmltube/ui-images/dragiconlight2.png
/opt/qmltube/qml/qmltube/ui-images/repeaticonred.png
/opt/qmltube/qml/qmltube/ui-images/commenticonblue.png
/opt/qmltube/qml/qmltube/ui-images/onthewebiconlight.png
/opt/qmltube/qml/qmltube/ui-images/topfavoritesicon.png
/opt/qmltube/qml/qmltube/ui-images/peopleiconlight.png
/opt/qmltube/qml/qmltube/ui-images/gotoicon.png
/opt/qmltube/qml/qmltube/ui-images/pauseiconlight.png
/opt/qmltube/qml/qmltube/ui-images/dislikeiconblue.png
/opt/qmltube/qml/qmltube/ui-images/minimizeicon.png
/opt/qmltube/qml/qmltube/ui-images/downloadiconred.png
/opt/qmltube/qml/qmltube/ui-images/educationicon.png
/opt/qmltube/qml/qmltube/ui-images/busydialog.png
/opt/qmltube/qml/qmltube/ui-images/downloadicon.png
/opt/qmltube/qml/qmltube/ui-images/mostrecenticonlight.png
/opt/qmltube/qml/qmltube/ui-images/searchicon.png
/opt/qmltube/qml/qmltube/ui-images/480picon.png
/opt/qmltube/qml/qmltube/ui-images/mostviewedicon.png
/opt/qmltube/qml/qmltube/ui-images/subscriptionsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/likeiconlight.png
/opt/qmltube/qml/qmltube/ui-images/filmiconlight.png
/opt/qmltube/qml/qmltube/ui-images/autosicon.png
/opt/qmltube/qml/qmltube/ui-images/mobileiconlight.png
/opt/qmltube/qml/qmltube/ui-images/uploadsicon2.png
/opt/qmltube/qml/qmltube/ui-images/cutetubered.png
/opt/qmltube/qml/qmltube/ui-images/addicon2.png
/opt/qmltube/qml/qmltube/ui-images/mostdiscussediconlight.png
/opt/qmltube/qml/qmltube/ui-images/audioiconlight.png
/opt/qmltube/qml/qmltube/ui-images/twittericon.png
/opt/qmltube/qml/qmltube/ui-images/uploadsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/foldericonlight.png
/opt/qmltube/qml/qmltube/ui-images/rightarrow.png
/opt/qmltube/qml/qmltube/ui-images/educationiconlight.png
/opt/qmltube/qml/qmltube/ui-images/repeaticon.png
/opt/qmltube/qml/qmltube/ui-images/uploadsicon.png
/opt/qmltube/qml/qmltube/ui-images/downloadiconblue.png
/opt/qmltube/qml/qmltube/ui-images/mostpopulariconlight.png
/opt/qmltube/qml/qmltube/ui-images/ticknonelight.png
/opt/qmltube/qml/qmltube/ui-images/favouritesiconlight.png
/opt/qmltube/qml/qmltube/ui-images/hqiconlight.png
/opt/qmltube/qml/qmltube/ui-images/commenticonred.png
/opt/qmltube/qml/qmltube/ui-images/recentlyfeaturedicon.png
/opt/qmltube/qml/qmltube/ui-images/peopleicon.png
/opt/qmltube/qml/qmltube/ui-images/cutetubehires.png
/opt/qmltube/qml/qmltube/ui-images/dragicon.png
/opt/qmltube/qml/qmltube/ui-images/stopicon.png
/opt/qmltube/qml/qmltube/ui-images/playiconlight.png
/opt/qmltube/qml/qmltube/ui-images/entertainmenticonlight.png
/opt/qmltube/qml/qmltube/ui-images/newsicon.png
/opt/qmltube/qml/qmltube/ui-images/menu2.png
/opt/qmltube/qml/qmltube/ui-images/videodownloadicon.png
/opt/qmltube/qml/qmltube/ui-images/Thumbs.db
/opt/qmltube/qml/qmltube/ui-images/dislikeicon.png
/opt/qmltube/qml/qmltube/ui-images/howtoiconlight.png
/opt/qmltube/qml/qmltube/ui-images/newicon.png
/opt/qmltube/qml/qmltube/ui-images/background.png
/opt/qmltube/qml/qmltube/ui-images/tickblue.png
/opt/qmltube/qml/qmltube/ui-images/audiodownloadiconred.png
/opt/qmltube/qml/qmltube/ui-images/titlebar.png
/opt/qmltube/qml/qmltube/ui-images/mostpopularicon.png
/opt/qmltube/qml/qmltube/ui-images/rightarrowblue.png
/opt/qmltube/qml/qmltube/ui-images/settingsicon.png
/opt/qmltube/qml/qmltube/ui-images/dragicon2.png
/opt/qmltube/qml/qmltube/ui-images/inboxicon.png
/opt/qmltube/qml/qmltube/ui-images/nonprofiticon.png
/opt/qmltube/qml/qmltube/ui-images/traveliconlight.png
/opt/qmltube/qml/qmltube/ui-images/audioicon.png
/opt/qmltube/qml/qmltube/ui-images/foldericon.png
/opt/qmltube/qml/qmltube/ui-images/cutetube.png
/opt/qmltube/qml/qmltube/ui-images/pauseplaybackicon.png
/opt/qmltube/qml/qmltube/ui-images/mostviewediconlight.png
/opt/qmltube/qml/qmltube/ui-images/recentlyfeaturediconlight.png
/opt/qmltube/qml/qmltube/ui-images/filmicon.png
/opt/qmltube/qml/qmltube/ui-images/checkbox.png
/opt/qmltube/qml/qmltube/ui-images/backiconlight.png
/opt/qmltube/qml/qmltube/ui-images/onthewebicon.png
/opt/qmltube/qml/qmltube/ui-images/background2.png
/opt/qmltube/qml/qmltube/ui-images/commenticonlight.png
/opt/qmltube/qml/qmltube/ui-images/infoiconlight.png
/opt/qmltube/qml/qmltube/ui-images/animalsicon.png
/opt/qmltube/qml/qmltube/ui-images/mostdiscussedicon.png
/opt/qmltube/qml/qmltube/ui-images/myaccounticonlight.png
/opt/qmltube/qml/qmltube/ui-images/dislikeiconlight.png
/opt/qmltube/qml/qmltube/ui-images/musiciconlight.png
/opt/qmltube/qml/qmltube/ui-images/emptyrating.png
/opt/qmltube/qml/qmltube/ui-images/playicon.png
/opt/qmltube/qml/qmltube/ui-images/closeicon.png
/opt/qmltube/qml/qmltube/ui-images/minimizeiconlight.png
/opt/qmltube/qml/qmltube/ui-images/gamesicon.png
/opt/qmltube/qml/qmltube/ui-images/topratedicon.png
/opt/qmltube/qml/qmltube/ui-images/backicon.png
/opt/qmltube/qml/qmltube/ui-images/tickred.png
/opt/qmltube/qml/qmltube/ui-images/videosicon.png
/opt/qmltube/qml/qmltube/ui-images/videodownloadiconred.png
/opt/qmltube/qml/qmltube/ui-images/commenticon.png
/opt/qmltube/qml/qmltube/ui-images/newsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/mostrespondedicon.png
/opt/qmltube/qml/qmltube/ui-images/clipboardicon.png
/opt/qmltube/qml/qmltube/ui-images/deletediskicon.png
/opt/qmltube/qml/qmltube/ui-images/comedyicon.png
/opt/qmltube/qml/qmltube/ui-images/newiconlight.png
/opt/qmltube/qml/qmltube/ui-images/pencilicon.png
/opt/qmltube/qml/qmltube/ui-images/leftarrowblue.png
/opt/qmltube/qml/qmltube/ui-images/favouritesiconred.png
/opt/qmltube/qml/qmltube/ui-images/stoploadingicon.png
/opt/qmltube/qml/qmltube/ui-images/videodownloadiconlight.png
/opt/qmltube/qml/qmltube/ui-images/likeiconblue.png
/opt/qmltube/qml/qmltube/ui-images/autosiconlight.png
/opt/qmltube/qml/qmltube/ui-images/musicicon.png
/opt/qmltube/qml/qmltube/ui-images/gamesiconlight.png
/opt/qmltube/qml/qmltube/ui-images/deleteicon.png
/opt/qmltube/qml/qmltube/ui-images/menubuttonbackground.png
/opt/qmltube/qml/qmltube/ui-images/hqicon.png
/opt/qmltube/qml/qmltube/ui-images/accountsicon.png
/opt/qmltube/qml/qmltube/ui-images/sportsicon.png
/opt/qmltube/qml/qmltube/ui-images/audiodownloadiconblue.png
/opt/qmltube/qml/qmltube/ui-images/searchiconlight.png
/opt/qmltube/qml/qmltube/ui-images/error.jpg
/opt/qmltube/qml/qmltube/ui-images/nexticon.png
/opt/qmltube/qml/qmltube/ui-images/playlistsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/deleteiconlight.png
/opt/qmltube/qml/qmltube/ui-images/comedyiconlight.png
/opt/qmltube/qml/qmltube/ui-images/techicon.png
/opt/qmltube/qml/qmltube/ui-images/techiconlight.png
/opt/qmltube/qml/qmltube/ui-images/sportsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/mostsharediconlight.png
/opt/qmltube/qml/qmltube/ui-images/closeiconblue.png
/opt/qmltube/qml/qmltube/ui-images/deleteplaylistsicon.png
/opt/qmltube/qml/qmltube/ui-images/720picon.png
/opt/qmltube/qml/qmltube/ui-images/downloadiconlight.png
/opt/qmltube/qml/qmltube/ui-images/backicon2.png
/opt/qmltube/qml/qmltube/ui-images/ticknone.png
/opt/qmltube/qml/qmltube/ui-images/leftarrow.png
/opt/qmltube/qml/qmltube/ui-images/previousicon.png
/opt/qmltube/qml/qmltube/ui-images/repeaticonlight.png
/opt/qmltube/qml/qmltube/ui-images/mostrecenticon.png
/opt/qmltube/qml/qmltube/ui-images/likeiconred.png
/opt/qmltube/qml/qmltube/ui-images/mostsharedicon.png
/opt/qmltube/qml/qmltube/ui-images/repeaticonblue.png
/opt/qmltube/qml/qmltube/ui-images/addicon.png
/opt/qmltube/qml/qmltube/ui-images/nonprofiticonlight.png
/opt/qmltube/qml/qmltube/ui-images/tab.png
/opt/qmltube/qml/qmltube/ui-images/videosiconlight.png
/opt/qmltube/qml/qmltube/ui-images/leftarrowred.png
/opt/qmltube/qml/qmltube/ui-images/sorttitleicon.png
/opt/qmltube/qml/qmltube/ui-images/previousiconlight.png
/opt/qmltube/qml/qmltube/ui-images/myaccounticon.png
/opt/qmltube/qml/qmltube/ui-images/topratediconlight.png
/opt/qmltube/qml/qmltube/ui-images/ytliveicon.png
/opt/qmltube/qml/qmltube/ui-images/backiconred.png
/opt/qmltube/qml/qmltube/ui-images/howtoicon.png
/opt/qmltube/qml/qmltube/ui-images/tick.png
/opt/qmltube/qml/qmltube/ui-images/reloadicon.png
/opt/qmltube/qml/qmltube/ui-images/penciliconlight.png
/opt/qmltube/qml/qmltube/ui-images/twittericon2.png
/opt/qmltube/qml/qmltube/ui-images/720piconlight.png
/opt/qmltube/qml/qmltube/ui-images/favouritesiconblue.png
/opt/qmltube/qml/qmltube/ui-images/pauseicon.png
/opt/qmltube/qml/qmltube/ui-images/animalsiconlight.png
/opt/qmltube/qml/qmltube/ui-images/fullscreenicon.png
/opt/qmltube/qml/qmltube/ui-images/busydialogred.png
/opt/qmltube/qml/qmltube/ui-images/favouritesicon.png
/opt/qmltube/qml/qmltube/ui-images/mostrespondediconlight.png
/opt/qmltube/qml/qmltube/ui-images/360piconlight.png
/opt/qmltube/qml/qmltube/ui-images/ticklight.png
/opt/qmltube/qml/qmltube/ui-images/addiconlight.png
/opt/qmltube/qml/qmltube/ui-images/topfavoritesiconlight.png
/opt/qmltube/qml/qmltube/ui-images/menubuttonbackgroundred.png
/opt/qmltube/qml/qmltube/ui-images/audiodownloadicon.png
/opt/qmltube/qml/qmltube/ui-images/abouticon.png
/opt/qmltube/qml/qmltube/ui-images/pauseplaybackiconred.png
/opt/qmltube/qml/qmltube/ui-images/videodownloadiconblue.png
/opt/qmltube/qml/qmltube/AddCommentDialog.qml
/opt/qmltube/qml/qmltube/ScrollBar.qml
/opt/qmltube/qml/qmltube/YTSubscriptionsList.qml
/opt/qmltube/qml/qmltube/SubscriptionDelegate.qml
/opt/qmltube/qml/qmltube/PlaylistVideosView.qml
/opt/qmltube/qml/qmltube/AccountDelegate.qml
/opt/qmltube/qml/qmltube/AddToPlaylistDialog.qml
/opt/qmltube/qml/qmltube/CommentsDelegate.qml
/opt/qmltube/qml/qmltube/VimeoUserVideosView.qml
/opt/qmltube/qml/qmltube/SettingsDelegate.qml
/opt/qmltube/qml/qmltube/AboutDialog.qml
/opt/qmltube/qml/qmltube/ArchiveDelegate.qml
/opt/qmltube/qml/qmltube/PlaylistsView.qml
/opt/qmltube/qml/qmltube/AccountDetailsDialog.qml
/opt/qmltube/qml/qmltube/DMPlaylistVideosView.qml
/opt/qmltube/qml/qmltube/main_tubelet.qml
/opt/qmltube/qml/qmltube/DMListView.qml
/opt/qmltube/qml/qmltube/LabelBox.qml
/opt/qmltube/qml/qmltube/FileChooserDelegate.qml
/opt/qmltube/qml/qmltube/XtubeListView.qml
/opt/qmltube/qml/qmltube/XtubeVideoList.qml
/opt/qmltube/qml/qmltube/PushButton.qml
/opt/qmltube/qml/qmltube/UploadDialog.qml
/opt/qmltube/qml/qmltube/PlaylistDialog.qml
/opt/qmltube/qml/qmltube/YTListView.qml
/opt/qmltube/qml/qmltube/ArchiveListView.qml
/opt/qmltube/qml/qmltube/VideoPlaybackView.qml
/opt/qmltube/qml/qmltube/CloseButton.qml
/opt/qmltube/qml/qmltube/CheckBox.qml
/opt/qmltube/qml/qmltube/ProxyDialog.qml
/opt/qmltube/qml/qmltube/MyAccountView.qml
/opt/qmltube/qml/qmltube/VimeoPlaylists.qml
/opt/qmltube/qml/qmltube/VimeoInfoView.qml
/opt/qmltube/qml/qmltube/MessageBanner.qml
/opt/qmltube/qml/qmltube/MenuButton.qml
/opt/qmltube/qml/qmltube/SearchBar.qml
/opt/qmltube/qml/qmltube/PlaylistDelegate.qml
/opt/qmltube/qml/qmltube/DMPlaylistDialog.qml
/opt/qmltube/qml/qmltube/MenuBar.qml
/opt/qmltube/qml/qmltube/YTPlaylists.qml
/opt/qmltube/qml/qmltube/UserInfoDialog.qml
/opt/qmltube/qml/qmltube/TextEntryButton.qml
/opt/qmltube/qml/qmltube/VimeoPlaylistVideosView.qml
/opt/qmltube/qml/qmltube/XListDelegate.qml
/opt/qmltube/qml/qmltube/VimeoSubscriptionsList.qml
/opt/qmltube/qml/qmltube/VideoListDelegate.qml
/opt/qmltube/qml/qmltube/BusyDialog.qml
/opt/qmltube/qml/qmltube/ListFilter.qml

%pre
# Add pre-install scripts here.
/sbin/ldconfig # For shared libraries

%preun
# Add pre-uninstall scripts here.
# Add post-uninstall scripts here.
