#ifndef EVENTMANAGER_H
#define EVENTMANAGER_H

#include <QObject>
#include <attachmentmanager.h>
#include <QSqlQuery>

class EventManager : public QObject
{
    Q_OBJECT
public:
    QSqlDatabase db;
    QObject* attachmentManager;
    explicit EventManager(QObject *parent = 0);
    Q_INVOKABLE QString eventsForDate(const QDate &date);
    Q_INVOKABLE void modify(const QString &event, const QString &action);
    bool hasFileWithFingerprint(const QString &fingerprint);
    void establishConnection();
    void interruptConnection();
    Q_INVOKABLE void importDatabase(QUrl url);
    Q_INVOKABLE QUrl dbPath();
signals:

public slots:
};

#endif // EVENTMANAGER_H
