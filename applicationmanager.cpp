#include "applicationmanager.h"
#include <QWindow>
#include <QDebug>
#include <QFile>
#include <Windows.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <thirdparty/qglobalshortcut/src/qglobalshortcut.h>

ApplicationManager::ApplicationManager(QObject *parent) : QObject(parent) {
    this->shortCutSignalMapper = new QSignalMapper(this);
    connect(shortCutSignalMapper, SIGNAL(mapped(const QString &)),
                this, SIGNAL(shortcutTriggered(const QString &)));
    connect(this, SIGNAL(shortcutTriggered(const QString &)),
                this, SLOT(test2(const QString &)));
}

void ApplicationManager::addShortcut(QString name, QString KeySequence) {
    QGlobalShortcut *gs = new QGlobalShortcut;
    gs->setKey(QKeySequence(KeySequence));
    connect(gs, SIGNAL(activated()), shortCutSignalMapper, SLOT(map()));
    shortCutSignalMapper->setMapping(gs, name);
    connect(gs, SIGNAL(activated()), this, SLOT(test()));
}

void ApplicationManager::test() {
    qDebug() << " test message";
}
void ApplicationManager::test2(const QString &name) {
    qDebug() << " test message 2 " << name;
}

QString ApplicationManager::loadConfig() {
    QFile file("config.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        qFatal("Failed");
    QByteArray line = file.readLine();
    file.close();
    return line;
}

void ApplicationManager::saveConfig(QString conf) {
    QFile file("config.json");
    if (!file.open(QIODevice::WriteOnly  | QIODevice::Text))
        qFatal("Failed");
    QTextStream out(&file);
    out << conf;
    file.close();
    qDebug() << conf;
}

void ApplicationManager::changeLangauge(QString lang) {
    if (lang == "en_US") {
        translator->load("en_US", "./i18n");
        QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedStates));
    }
    else if (lang == "zh_CN") {
        translator->load("zh_CN", "./i18n");
        QLocale::setDefault(QLocale(QLocale::Chinese, QLocale::China));
    }
}

QTranslator* ApplicationManager::loadTranslate() {
    translator = new QTranslator;
    int lang = QJsonDocument::fromJson(loadConfig().toUtf8()).object()["lang"].toInt();
    if (lang == 0) {
        translator->load("en_US", "./i18n");
        QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedStates));
    }
    else if (lang == 1) {
        translator->load("zh_CN", "./i18n");
        QLocale::setDefault(QLocale(QLocale::Chinese, QLocale::China));
    }
    return translator;
}
