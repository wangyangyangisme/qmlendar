#ifndef APPLICATIONMANAGER_H
#define APPLICATIONMANAGER_H

#include <QObject>
#include <QSignalMapper>
#include <QTranslator>

class ApplicationManager : public QObject
{
    Q_OBJECT
public:
    QSignalMapper* shortCutSignalMapper;
    QTranslator* translator;
    explicit ApplicationManager(QObject *parent = 0);
    void addShortcut(QString name, QString KeySequence);
    Q_INVOKABLE QString loadConfig();
    Q_INVOKABLE void saveConfig(QString conf);
    Q_INVOKABLE void changeLangauge(QString lang);
    QTranslator* loadTranslate();
signals:
    void shortcutTriggered(const QString &name);
public slots:
    void test();
    void test2(const QString &name);
};

#endif // APPLICATIONMANAGER_H
