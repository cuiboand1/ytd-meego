# Add more folders to ship with the application, here
content.source = jsoncontent/
content.target = .
js_lib.source = ytjson.js
js_lib.target = .
qml_top.source = jsontube.qml
qml_top.target = .
DEPLOYMENTFOLDERS = content js_lib qml_top

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE7F9C976

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# Define QMLJSDEBUGGER to allow debugging of QML in debug builds
# (This might significantly increase build time)
# DEFINES += QMLJSDEBUGGER

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable. 
# CONFIG += mobility
# MOBILITY +=

INCLUDES += qmlapplicationviewer
# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
