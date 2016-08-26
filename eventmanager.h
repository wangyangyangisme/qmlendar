#ifndef EVENTMANAGER_H
#define EVENTMANAGER_H

#include <QObject>
#include "eventitem.h"

class EventManager : public QObject
{
    Q_OBJECT
public:
    explicit EventManager(QObject *parent = 0);
    void debug();
    Q_INVOKABLE QString eventsForDate(const QDate &date);
    Q_INVOKABLE void modify(const QString &event, const QString &action);
    static void establishConnection();

signals:

public slots:
};

#endif // EVENTMANAGER_H
