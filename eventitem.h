#ifndef EVENTITEM_H
#define EVENTITEM_H

#include <QObject>
#include <QDate>
#include <QColor>

class EventItem : public QObject
{
    Q_OBJECT

public:
    int id;

    enum EventRepeatableType{
        None,
        Weekly
    };
    Q_ENUM(EventRepeatableType)

    EventRepeatableType m_type;
    QString m_typeMask;
    Q_PROPERTY(EventRepeatableType type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString typeMask READ typeMask WRITE setTypeMask NOTIFY typeMaskChanged)

    QDateTime m_startDate, m_endDate;
    Q_PROPERTY(QDateTime startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDateTime endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)

    QString m_name;
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    QColor m_color;
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    void setType(const EventRepeatableType a){
        if (m_type != a){
            m_type = a;
            emit typeChanged();
        }
    }
    EventRepeatableType type() const{
        return m_type;
    }
    void setTypeMask(const QString a){
        if (m_typeMask != a){
            m_typeMask = a;
            emit typeMaskChanged();
        }
    }
    QString typeMask() const{
        return m_typeMask;
    }

    void setStartDate(const QDateTime a){
        if (m_startDate != a){
            m_startDate = a;
            emit startDateChanged();
        }
    }
    QDateTime startDate() const{
        return m_startDate;
    }

    void setEndDate(const QDateTime a){
        if (m_endDate != a){
            m_endDate = a;
            emit endDateChanged();
        }
    }
    QDateTime endDate() const{
        return m_endDate;
    }

    void setName(const QString a){
        if (m_name != a){
            m_name = a;
            emit nameChanged();
        }
    }
    QString name() const{
        return m_name;
    }

    void setColor(const QColor a){
        if (m_color != a){
            m_color = a;
            emit colorChanged();
        }
    }

    QColor color() const{
        return m_color;
    }

    explicit EventItem(QObject *parent = 0);
    Q_INVOKABLE bool react_to(QDateTime date);

signals:
    void typeChanged();
    void typeMaskChanged();
    void startDateChanged();
    void endDateChanged();
    void nameChanged();
    void colorChanged();

public slots:
};

#endif // EVENTITEM_H
