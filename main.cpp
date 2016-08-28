#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <attachmentmanager.h>
#include <eventmanager.h>
#include <applicationmanager.h>
#include <QTranslator>
#include <QLocale>
#include <QQuickView>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQuickStyle::setStyle("Material");

    AttachmentManager attachmentManager;
    engine.rootContext()->setContextProperty("attachmentManager", &attachmentManager);

    EventManager eventManager;
    engine.rootContext()->setContextProperty("eventManager", &eventManager);

    eventManager.attachmentManager = &attachmentManager;
    attachmentManager.eventManager = &eventManager;

    ApplicationManager applicationManager;
    applicationManager.addShortcut("lock", "Ctrl+L");
    engine.rootContext()->setContextProperty("applicationManager", &applicationManager);

    app.installTranslator(applicationManager.loadTranslate() );

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
