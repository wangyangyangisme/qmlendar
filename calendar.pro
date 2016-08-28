QT += qml quick quickcontrols2 sql

CONFIG += c++11

SOURCES += main.cpp \
    attachmentmanager.cpp \
    eventmanager.cpp \
    applicationmanager.cpp \
    thirdparty/qglobalshortcut/src/qglobalshortcut.cc

RESOURCES += qml.qrc
TRANSLATIONS = i18n/zh_CN.ts i18n/en_US.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    attachmentmanager.h \
    eventmanager.h \
    applicationmanager.h \
    thirdparty/qglobalshortcut/src/qglobalshortcut.h

OTHER_FILES += \
    *.qml

lupdate_only{
    SOURCES = *.qml
}

win32:SOURCES += thirdparty/qglobalshortcut/src/qglobalshortcut_win.cc
unix:SOURCES  += thirdparty/qglobalshortcut/src/qglobalshortcut_x11.cc
macx:SOURCES  += thirdparty/qglobalshortcut/src/qglobalshortcut_macx.cc
