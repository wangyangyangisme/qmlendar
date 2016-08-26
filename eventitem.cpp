#include "eventitem.h"
#include <QMetaEnum>
#include <QDebug>

EventItem::EventItem(QObject *parent) : QObject(parent)
{
    setType(EventRepeatableType::Weekly);
    QMetaEnum metaEnum = QMetaEnum::fromType<EventItem::EventRepeatableType>();
    //qDebug() << metaEnum.valueToKey(type() );
}

bool EventItem::react_to(QDateTime d){
    if (m_type == EventRepeatableType::None)
        return (startDate().date() <= d.date() && d.date() <= endDate().date());
    else if (m_type == EventRepeatableType::Weekly){
        if (!(startDate().date() <= d.date() && d.date() <= endDate().date()) ) return false;
        QStringList myList = m_typeMask.split(" ", QString::SkipEmptyParts);
        for (const QString &i :myList){
            if (d.date().dayOfWeek() == i.toInt() + 1) return true;
        }
        return false;
    }
    return false;
}
