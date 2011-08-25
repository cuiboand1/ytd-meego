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
BuildRequires:  libresourceqt-devel  
BuildRequires:  desktop-file-utils
BuildRequires: gettext
Requires: libqtcore4  
Requires: libqtopengl4
Requires: libqtgui4
Requires: qt-mobility
Requires: libresourceqt
Requires: gst-plugins-good
Requires: gst-plugins-base
Requires: gst-plugins-bad-free
Requires: gst-plugins-bad-free-extras
Requires: gst-vabuffer
Requires: qtgst-qmlsink
# ffmpeg is used for qmltube's "download as audio" functionality, 
# available via http://wiki.meego.com/MeeGo-Lem . Commented-out, since
# ffmpeg is not available on MeeGo and there's no point in holding up
# the entire install for a tiny bit of missing functionality. To enable, just add
# package 'ffmpeg' and dependencies to make the download as audio functionality work. 
# Requires: gstreamer-ffmpeg          ## e.g., Fedora's gstreamer-ffmpeg-0.10.11-1.fc14.i686
# Requires: ffmpeg                    ## e.g., Fedora's ffmpeg-0.6.3-1.fc14.i686
# Requires: ffmpeg-libs               ## e.g., Fedora's ffmpeg-libs-0.6.3-1.fc14.i686

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
## Cleanup subversion dirs that get copied to 'qml' directory so they don't get packaged
find %{buildroot}/opt/qmltube/qml -type d -name '.svn' -print -exec rm -rf {} \; || true
## Nuke copied emacs backup files...
find %{buildroot}/opt/qmltube/qml -type f -name '*[0-9]*~' -print -exec rm -f {} \; || true
## Nuke patch leftovers
find %{buildroot}/opt/qmltube/qml -type f -name '*.rej' -print -exec rm -f {} \; || true
find %{buildroot}/opt/qmltube/qml -type f -name '*.orig' -print -exec rm -f {} \; || true

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
%dir /opt/qmltube/qml/qmltube
/opt/qmltube/qml/qmltube/*.qml
%dir /opt/qmltube/qml/qmltube/ui-images
/opt/qmltube/qml/qmltube/ui-images/*.png
/opt/qmltube/qml/qmltube/ui-images/*.jpg
%dir /opt/qmltube/qml/qmltube/scripts
/opt/qmltube/qml/qmltube/scripts/*.js
%dir /opt/qmltube/qml/qmltube/i18n
/opt/qmltube/qml/qmltube/i18n/*.qm
/opt/qmltube/qml/qmltube/i18n/*.ts
/opt/qmltube/bin/qmltube

%pre
# Add pre-install scripts here.
/sbin/ldconfig # For shared libraries

%preun
# Add pre-uninstall scripts here.
# Add post-uninstall scripts here.
