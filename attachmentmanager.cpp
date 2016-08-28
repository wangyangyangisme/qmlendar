#include "attachmentmanager.h"
#include <QDebug>
#include <QFile>
#include <QCryptographicHash>
#include <QDir>

QByteArray fileSHA256(const QString &fileName) {
    QFile f(fileName);
    if (f.open(QFile::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Sha256);
        if (hash.addData(&f)) {
            return hash.result();
        }
    }
    return QByteArray();
}

AttachmentManager::AttachmentManager(QObject *parent) : QObject(parent)
{

}

void AttachmentManager::AttachFile(QDateTime date, QUrl url) {
    QFileInfo fi(url.toLocalFile() );
    QString filename = fi.fileName();
    QString fingerPrint = QString(fileSHA256(url.toLocalFile()).toHex()).left(8);
    QString json = QString::fromUtf8("{\"id\":-1,\"name\":\"%1\",\"type\":9,\"mask\":\"%2\","
                                     "\"color\":\"%3\",\"startDate\":\"%4\",\"endDate\":\"%4\"}")
            .arg(filename, fingerPrint, "red", QString::number(date.toMSecsSinceEpoch()) );
    QDir dir("./storage/" + fingerPrint);
    if (!dir.exists()) dir.mkpath(".");
    QFile::copy(url.toLocalFile(), "./storage/" + fingerPrint + "/" + filename);
    qobject_cast<EventManager*>(eventManager)->modify(json, "add");
}

QUrl AttachmentManager::getFileURI(QString filename, QString fingerPrint) {
    QFileInfo fi("./storage/" + fingerPrint + "/" + filename);
    return QUrl::fromLocalFile(fi.canonicalFilePath());
}

void AttachmentManager::removeFile(QString fingerPrint) {
    QDir dir("./storage/" + fingerPrint);
    dir.removeRecursively();
}
