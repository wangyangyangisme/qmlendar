#ifndef EVENTMANAGER_H
#define EVENTMANAGER_H

#include <QObject>
#include <attachmentmanager.h>

class EventManager : public QObject
{
    Q_OBJECT
public:
    QObject* attachmentManager;
    explicit EventManager(QObject *parent = 0);
    Q_INVOKABLE QString eventsForDate(const QDate &date);
    Q_INVOKABLE void modify(const QString &event, const QString &action);
    bool hasFileWithFingerprint(const QString &fingerprint);
    static void establishConnection();
signals:

public slots:
};

#endif // EVENTMANAGER_H
