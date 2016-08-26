QT += qml quick quickcontrols2 sql

CONFIG += c++11

SOURCES += main.cpp \
    attachmentmanager.cpp \
    eventitem.cpp \
    eventmanager.cpp

RESOURCES += qml.qrc
TRANSLATIONS = i18n/zh_CN.ts i18n/en_US.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    attachmentmanager.h \
    eventitem.h \
    eventmanager.h

OTHER_FILES += \
    *.qml

lupdate_only{
    SOURCES = *.qml
}
