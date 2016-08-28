#ifndef ATTACHMENTMANAGER_H
#define ATTACHMENTMANAGER_H

#include <QObject>
#include <QUrl>
#include <QDate>
#include <eventmanager.h>

class AttachmentManager : public QObject
{
    Q_OBJECT
public:
    QObject* eventManager;
    explicit AttachmentManager(QObject *parent = 0);

signals:

public slots:
    void AttachFile(QDateTime date, QUrl url);
    QUrl getFileURI(QString name, QString fingerPrint);
    void removeFile(QString fingerPrint);
};

#endif // ATTACHMENTMANAGER_H
