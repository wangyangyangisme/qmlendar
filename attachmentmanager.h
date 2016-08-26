#ifndef ATTACHMENTMANAGER_H
#define ATTACHMENTMANAGER_H

#include <QObject>
#include <QUrl>
#include <QDate>

class AttachmentManager : public QObject
{
    Q_OBJECT
public:
    explicit AttachmentManager(QObject *parent = 0);

signals:

public slots:
    QString AttachFile(QDateTime date, QUrl url);
    QUrl getFileURI(QString name, QString fingerPrint);
    void removeFile(QString name, QString fingerPrint);
};

#endif // ATTACHMENTMANAGER_H
