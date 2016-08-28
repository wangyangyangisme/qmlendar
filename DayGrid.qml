import QtQuick 2.0
import QtQml 2.2
import QtQuick.Layouts 1.0
import Material 0.2
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import QtQml.Models 2.2
import "Utils.js" as Utils

Rectangle  {
    id: grid

    property string text
    property date date
    property var eventList
    property bool locked

    width: 140; height: 75
    color: Utils.addOpacity(Qt.tint(Theme.backgroundColor, Qt.rgba(192, 192, 192, 0.2) ), locked ? 0.7 : 1);

    signal gridClicked(date date)
    signal eventClicked(date date, var event)
    signal eventChanged()
    MouseArea {
        anchors.fill: parent
        onClicked: {
            grid.gridClicked(date);
            console.log(date.toLocaleDateString() + "  Clicked.");
        }
    }

    Column {
        anchors.fill: parent
        Label {
            id: daylabel
            text: grid.text
            font.weight: Font.Bold
            font.pixelSize: Units.dp(16)
        }
        Repeater {
            model: eventList
            delegate:
                Button{
                    implicitHeight: Units.dp(24)
                    height: Units.dp(24)
                    width: parent.width
                    text: ((modelData.type === 9) ? qsTr("File: %1") : "%1").arg(modelData.name)
                    backgroundColor: Palette.colors[modelData.color]["500"]
                    onClicked: {
                        grid.eventClicked(date, modelData);
                    }
                }
        }
    }

    DropArea {
        anchors.fill: parent
        onEntered: {
            console.log(Utils.config().drag);
            if (Utils.config().drag === 0){
                drag.accepted = false;
                return false;
            }
        }
        onDropped: {
            for (var i in drop.urls)
                attachmentManager.AttachFile(date, drop.urls[i]);
            eventChanged();
        }
    }

    Rectangle {
        id: selectedRect
        anchors.fill: parent
        opacity: 0
        border.color: Theme.accentColor
        border.width: 5
        color:  Theme.primaryColor
        radius: 5
    }

    state: "normal"
    states: [
            State {
                name: "disabled"
                PropertyChanges { target: grid; opacity: "0.5"; }
            },
            State {
                name: "selected"
                PropertyChanges { target: selectedRect; opacity: 0.3; }
            }
    ]
}
