#ifndef CUTEAPP_H
#define CUTEAPP_H

#include <QApplication>
#include <QObject>
#include <X11/Xlib.h>

class CuteApp : public QApplication {

public:
    explicit CuteApp(QApplication *parent = 0) {
            QApplication(parent);
            EFObject *efo = new EFObject();
            installEventFilter(efo);
    }

protected:
    bool x11EventFilter(XEvent *event) {
        XClientMessageEvent *cm = (XClientMessageEvent *) event;
        return QApplication::x11EventFilter(event);
    }

};

class EFObject : public QObject {

public:
    explicit EFObject(QObject *parent = 0) {
        QObject(parent);
    }

protected:
    bool eventFilter(QObject *obj, QEvent *event) {
        if (QApplication::focusWidget() == eventWidget) {
            return true;
        }
        return false;
    }

    void setEventWidget(QWidget *widget) {
        eventWidget = widget;
    }

private:
    QWidget *eventWidget;

};

#endif // CUTEAPP_H
