## NPM: TODO, use http://wiki.meego.com/index.php?title=Porting_Fremantle_Applications_to_Harmattan&oldid=44545#Store_QML_in_Filesystem_instead_of_Resources
## and see whether it prevents .svn files from being copied into install image.
# Add more folders to ship with the application, here
folder_01.source = qml/qmltube
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
#QML_IMPORT_PATH = "/opt/qtm12/imports/"

# Avoid auto screen rotation
#DEFINES += ORIENTATIONLOCK

# Needs to be defined for Symbian
DEFINES += NETWORKACCESS

## NPM workaround to missing define(MEEGO_EDITION_HARMATTAN) suggested by
## http://wiki.meego.com/index.php?title=Porting_Fremantle_Applications_to_Harmattan&oldid=44545#Harmattan_scope
exists($$QMAKE_INCDIR_QT"/../qmsystem2/qmkeys.h"):!contains(MEEGO_EDITION,harmattan): {
  MEEGO_VERSION_MAJOR     = 1
  MEEGO_VERSION_MINOR     = 2
  MEEGO_VERSION_PATCH     = 0
  MEEGO_EDITION           = harmattan
  DEFINES += MEEGO_EDITION_HARMATTAN

  ## Other harmattan-specific things:
  ## Add qmsystem2 http://apidocs.meego.com/1.2/qmsystem/main.html
  ## for MeeGo::QmDisplayState()::setBlankingPause(), etc.
  CONFIG += qmsystem2 \
  	    mobility
  MOBILITY+=multimedia 
}

symbian:TARGET.UID3 = 0xE2644EFA

# Define QMLJSDEBUGGER to allow debugging of QML in debug builds
# (This might significantly increase build time)
# DEFINES += QMLJSDEBUGGER

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable.
QT += sql \
    network \
    opengl \
    dbus

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    youtube.cpp \
    controller.cpp \
    downloadmanager.cpp \
    folderlistmodel.cpp \
    sharing.cpp \
    dailymotion.cpp \
    vimeo.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    debian/compat \
    debian/control \
    debian/copyright \
    debian/README \
    debian/rules \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

HEADERS += \
    youtube.h \
    controller.h \
    downloadmanager.h \
    folderlistmodel.h \
    sharing.h \
    dailymotion.h \
    vimeo.h
