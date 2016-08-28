import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Material 0.2
import "Utils.js" as Utils

ApplicationWindow {
    id: rootWindow
    visible: true
    width: 1080
    height: 650
    title: qsTr("Calendar Test")
    color: "transparent"

    MouseArea {
        id: mouseRegion
        anchors.fill: parent;
        property var clickPos: "1,1"
        propagateComposedEvents: true
        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            rootWindow.x += delta.x;
            rootWindow.y += delta.y;
        }
        z: -10
    }

    initialPage: Page{
        id: page
        title: qsTr("PageMonth")
        backgroundColor: (Utils.config().locked === 0) ? Theme.backgroundColor : "transparent"
        Loader {
            id: mainLoader
            anchors.fill: parent
            source: "PageMonth.qml"
        }
        //PageMonth {}
        Snackbar {
            id: snackbar
        }
        function refresh(){
            mainLoader.setSource("PageMonth.qml")
        }
        actions: [
            Action {
                iconName: "action/system_update_alt"
                name: qsTr("Drag")
                onTriggered: {
                    if (Utils.config().drag === 0) {
                        Utils.setConfig("drag", 1);
                        snackbar.open(qsTr("Drag and drop enabled."));
                    }
                    else {
                        Utils.setConfig("drag", 0);
                        snackbar.open(qsTr("Drag and drop disabled."));
                    }
                }
            },
            Action {
                iconName: "action/translate"
                name: qsTr("Langauge")
                onTriggered: {
                    if (Utils.config().lang === 0) {
                        Utils.setConfig("lang", 1);
                        applicationManager.changeLangauge("zh_CN");
                    }
                    else {
                        Utils.setConfig("lang", 0);
                        applicationManager.changeLangauge("en_US");
                    }
                    page.refresh();
                    console.log(Qt.locale().name);
                }
            },
            Action {
                id: lockButton
                iconName: "action/lock"
                name: qsTr("Lock")
                onTriggered: {
                    if (Utils.config().locked === 0) {
                        rootWindow.flags = rootWindow.flags | (Qt.FramelessWindowHint | Qt.WA_TranslucentBackground | Qt.WindowTransparentForInput /*| Qt.WindowStaysOnTopHint*/);
                        Utils.setConfig("locked", 1);
                    }
                    else {
                        rootWindow.flags = rootWindow.flags & ~(Qt.FramelessWindowHint | Qt.WA_TranslucentBackground | Qt.WindowTransparentForInput /*| Qt.WindowStaysOnTopHint*/);
                        Utils.setConfig("locked", 0);
                    }
                    page.backgroundColor = (Utils.config().locked === 0) ? Theme.backgroundColor : "transparent";
                    page.refresh();
                }
            }
        ]
        Connections {
            target: applicationManager
            onShortcutTriggered: {
                console.log(name);
                if (name === "lock") {
                    lockButton.trigger();
                }
            }
        }
    }

    Dialog {
        id: settingsDialog
    }
    Component.onCompleted: {
        Utils.setAppManager(applicationManager);
        Utils.setConfig(JSON.parse(applicationManager.loadConfig() ) );
    }

    onClosing: {
    }

}
