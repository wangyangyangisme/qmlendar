#include "eventmanager.h"
#include <QDebug>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

EventManager::EventManager(QObject *parent) : QObject(parent)
{
    establishConnection();
}

bool event_react_to(QJsonObject a, QDateTime d){
    int m_type = a["type"].toInt();
    QString m_typeMask = a["mask"].toString();
    QDateTime startDate = QDateTime::fromMSecsSinceEpoch(a["startDate"].toString().toLongLong() );
    QDateTime endDate = QDateTime::fromMSecsSinceEpoch(a["endDate"].toString().toLongLong() );
    if (m_type == 0)
        return (startDate.date() <= d.date() && d.date() <= endDate.date());
    else if (m_type == 1){
        if (!(startDate.date() <= d.date() && d.date() <= endDate.date()) ) return false;
        QStringList myList = m_typeMask.split(" ", QString::SkipEmptyParts);
        for (const QString &i :myList){
            if (d.date().dayOfWeek() % 7 == i.toInt()) return true;
        }
        return false;
    }
    else if (m_type == 2){
        if (!(startDate.date() <= d.date() && d.date() <= endDate.date()) ) return false;
        return (d.date().day() == m_typeMask.toInt());
    }
    else if (m_type == 9){
        return (startDate.date() <= d.date() && d.date() <= endDate.date());
    }
    return false;
}


QString EventManager::eventsForDate(const QDate &date) {
    const QString queryStr = QString::fromUtf8("SELECT rowid, * FROM Event WHERE '%1' >= startDate AND '%1' <= endDate").arg(date.toString("yyyy-MM-dd"));
    QSqlQuery query(queryStr);
    if (!query.exec())
        qFatal("Query failed");

    QJsonArray events;
    while (query.next()) {
        QJsonObject a;
        a["id"] = query.value("rowid").toInt();
        a["name"] = query.value("name").toString();
        a["type"] = query.value("type").toInt();
        a["mask"] = query.value("mask").toString();
        a["color"] = query.value("color").toString();//QColor(query.value("color").toInt()).name(QColor::HexArgb);
        QDateTime startDate;
        startDate.setDate(query.value("startDate").toDate());
        startDate.setTime(QTime(0, 0).addSecs(query.value("startTime").toInt()));
        a["startDate"] = QString::number(startDate.toMSecsSinceEpoch() );

        QDateTime endDate;
        endDate.setDate(query.value("endDate").toDate());
        endDate.setTime(QTime(0, 0).addSecs(query.value("endTime").toInt()));
        a["endDate"] = QString::number(endDate.toMSecsSinceEpoch() );
        if (event_react_to(a, QDateTime(date)) )
            events.append(a);
    }
    qDebug() << queryStr;
    qDebug() << QJsonDocument(events).toJson(QJsonDocument::Compact);
    return QJsonDocument(events).toJson(QJsonDocument::Compact);
}

void EventManager::modify(const QString &eventString, const QString &action) {
    QJsonObject event = QJsonDocument::fromJson(eventString.toUtf8()).object();

    int m_id = event["id"].toInt();
    QString m_name = event["name"].toString();
    int m_type = event["type"].toInt();
    QString m_mask = event["mask"].toString();
    QString m_color = event["color"].toString();
    QDateTime m_start = QDateTime::fromMSecsSinceEpoch(event["startDate"].toString().toLongLong());
    QString m_startDate = m_start.date().toString(Qt::ISODate);
    int m_startTime = m_start.time().msecsSinceStartOfDay() / 1000;
    QDateTime m_end = QDateTime::fromMSecsSinceEpoch(event["endDate"].toString().toLongLong());
    QString m_endDate = m_end.date().toString(Qt::ISODate);
    int m_endTime = m_end.time().msecsSinceStartOfDay() / 1000;

    QString queryStr;
    if (action == "add") {
        queryStr = QString::fromUtf8("INSERT INTO Event VALUES('%1', %2, '%3', '%4', %5, '%6', %7, '%8')")
                .arg(m_name, QString::number(m_type), m_mask, m_startDate, QString::number(m_startTime),
                     m_endDate, QString::number(m_endTime), m_color);
    }
    else if (action == "edit") {
        queryStr = QString::fromUtf8("UPDATE Event SET name = '%1', type = %2, mask = '%3', startDate = '%4', " \
                                       "startTime = %5, endDate = '%6', endTime = %7, color = '%8' " \
                                       "WHERE rowid = %9")
                .arg(m_name, QString::number(m_type), m_mask, m_startDate, QString::number(m_startTime),
                     m_endDate, QString::number(m_endTime), m_color, QString::number(m_id));
    }
    else if (action == "delete"){
        queryStr = QString::fromUtf8("DELETE FROM Event WHERE rowid = %1").arg(QString::number(m_id));
    }
    QSqlQuery query;
    qDebug() << queryStr;
    if (!query.exec(queryStr)){
        qDebug() << query.lastError();
        qFatal("Query failed");
    }
}

void EventManager::debug() {
    for (int i = 1; i <= 31; ++ i){
        QDate tmp(2016,8,i);
        qDebug() << tmp << ":";
        qDebug() << eventsForDate(tmp);
        auto qs = QJsonDocument::fromJson(eventsForDate(tmp).toUtf8()).array();
        for (auto i : qs){
            qDebug() << i.toObject()["name"].toString() << ";";
        }
        //qDebug() << endl;
    }
}

void EventManager::establishConnection(){
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("./events.db");
    if (!db.open()) {
        qFatal("Cannot open database");
        return;
    }

    QSqlQuery query;
    // We store the time as seconds because it's easier to query.
    /*query.exec("create table Event (name TEXT, type INT, mask TEXT, startDate DATE, startTime INT, endDate DATE, endTime INT, color TEXT)");
    query.exec("insert into Event values('Grocery shopping', 0, '', '2016-08-01', 36000, '2016-08-01', 39600, 'red')");
    query.exec("insert into Event values('Ice skating', 1, '0 2 4 6 ', '2016-08-01', 57600, '2026-08-01', 61200, 'cyan')");
    query.exec("insert into Event values('Doctor''s appointment', 0, '', '2016-08-15', 57600, '2016-08-15', 63000, 'amber')");
    query.exec("insert into Event values('Conference', 0, '', '2016-08-24', 32400, '2016-08-28', 61200, 'deepOrange')");
    query.exec("insert into Event values('Rock', 2, '21', '2016-01-01', 32400, '2017-01-21', 61200, 'grey')");
    query.exec("insert into Event values('a.pdf', 9, '', '2016-08-21', 32400, '2017-01-21', 61200, 'indigo')");*/

    return;
}
