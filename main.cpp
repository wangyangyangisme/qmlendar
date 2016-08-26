#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <attachmentmanager.h>
#include <eventitem.h>
#include <eventmanager.h>
#include <QTranslator>
#include <QLocale>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQuickStyle::setStyle("Material");

    QTranslator qtTranslator;
    //bool a = qtTranslator.load("zh_CN", "./i18n");
    //app.installTranslator(&qtTranslator);
    QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedStates));

    AttachmentManager attachmentManager;
    engine.rootContext()->setContextProperty("attachmentManager", &attachmentManager);

    EventManager eventManager;
    //eventManager.debug();
    engine.rootContext()->setContextProperty("eventManager", &eventManager);

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
