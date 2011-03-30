#-------------------------------------------------
#
# Project created by QtCreator 2011-03-01T06:11:58
#
#-------------------------------------------------

QT       += core gui declarative opengl

TARGET = TubeBook
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp

OTHER_FILES += \
    qmltube/Page.qml \
    qmltube/HorizontalGradient.qml \
    qmltube/BookBehavior.qml \
    qmltube/Book.qml \
    main.qml \
    TubeModel.qml

RESOURCES += \
    qmltube/qmlbook.qrc \
    resources.qrc

unix:!symbian {
    maemo5 {
        target.path = /opt/usr/bin
    } else {
        target.path = /usr/local/bin
    }
    INSTALLS += target
}