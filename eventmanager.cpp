#include "eventmanager.h"
#include <QDebug>
#include <QFileInfo>
#include <QSqlError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>

EventManager::EventManager(QObject *parent) : QObject(parent) {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("./events.db");
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
    QSqlQuery query;
    if (!query.exec(queryStr))
        qFatal("Query failed");

    QJsonArray events;
    while (query.next()) {
        QJsonObject a;
        a["id"] = query.value("rowid").toInt();
        a["name"] = query.value("name").toString();
        a["type"] = query.value("type").toInt();
        a["mask"] = query.value("mask").toString();
        a["color"] = query.value("color").toString();
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
    if (!query.exec(queryStr)){
        qDebug() << query.lastError();
        qFatal("Query failed");
    }
    if (action == "delete" && m_type == 9) {
        if (!hasFileWithFingerprint(m_mask) ) {
            qobject_cast<AttachmentManager*>(attachmentManager)->removeFile(m_mask);
        }
    }
}

bool EventManager::hasFileWithFingerprint(const QString &fingerprint) {
      const QString queryStr = QString::fromUtf8("SELECT rowid FROM Event WHERE type = 9 AND mask = '%1' ").arg(fingerprint);
      QSqlQuery query;
      if (!query.exec(queryStr))
          qFatal("Query failed");
      if (query.next()){
          return true;
      }
      else {
          return false;
      }
}

void EventManager::establishConnection() {
    if (!db.open()) {
        qFatal("Cannot open database");
        return;
    }
    return;
}

void EventManager::interruptConnection() {
    db.close();
    return;
}

QUrl EventManager::dbPath(){
    QFileInfo fi("./events.db");
    return QUrl::fromLocalFile(fi.canonicalFilePath());
}

void EventManager::importDatabase(QUrl url) {
    interruptConnection();
    if (QFile::exists("./events.db")) {
        QFile::remove("./events.db");
    }
    QFile::copy(url.toLocalFile(), "./events.db");
    establishConnection();
}
