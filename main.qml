import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Material 0.2
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
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
                    page.refresh();
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
                    //console.log(Qt.locale().name);
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
            },
            Action {
                id: portButton
                iconName: "communication/import_export"
                name: qsTr("Import/Export")
                onTriggered: {
                    portDialog.show()
                }
            }
        ]
        Connections {
            target: applicationManager
            onShortcutTriggered: {
                if (name === "lock") {
                    lockButton.trigger();
                }
            }
        }
    }

    Dialog {
        id: portDialog
        title: qsTr("Import/Export")
        hasActions: false

        ListItem.Standard {
            action: Icon {
                anchors.centerIn: parent
                name: "editor/attach_file"
            }
            text: "events.db"

            MouseArea {
                id: dragMouseArea
                anchors.fill: parent
                drag.target: draggable
            }
            Item {
                id: draggable
                anchors.fill: parent
                Drag.active: dragMouseArea.drag.active
                Drag.hotSpot.x: 0
                Drag.hotSpot.y: 0
                Drag.dragType: Drag.Automatic
                Drag.supportedActions: Qt.CopyAction
                Drag.mimeData: {"text/uri-list": eventManager.dbPath()}
                Drag.onDragFinished: {
                    portDialog.close();
                }
            }
            DropArea {
                anchors.fill: parent
                onDropped: {
                    console.log(drop.urls[0]);
                    eventManager.importDatabase(drop.urls[0]);
                    page.refresh();
                    portDialog.close();
                }
            }
        }
    }
    Component.onCompleted: {
        Utils.setAppManager(applicationManager);
        Utils.loadConfig();
        page.refresh();
        //Utils.setConfig(JSON.parse(applicationManager.loadConfig() ) );
    }

    onClosing: {
    }

}
