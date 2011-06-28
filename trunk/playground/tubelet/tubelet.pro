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
    sharing.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    debian/compat \
    debian/control \
    debian/copyright \
    debian/README \
    debian/rules

HEADERS += \
    youtube.h \
    controller.h \
    downloadmanager.h \
    folderlistmodel.h \
    sharing.h
