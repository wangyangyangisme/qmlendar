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

    width: 140; height: 80
    color: "transparent"

    signal gridClicked(date date)
    signal eventClicked(date date, var event)
    signal eventChanged()
    MouseArea {
        anchors.fill: parent
        onClicked: function(){
            grid.gridClicked(date);
            console.log(date.toLocaleDateString() + "  Clicked.");
        }
    }

    /*ListModel {
        id: eventModel
        source:
    }*/

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
                /*ListItem.Standard*/Button{
                    implicitHeight: Units.dp(24)
                    height: Units.dp(24)
                    width: parent.width
                    text: ((modelData.type === 9) ? qsTr("File: %1") : "%1").arg(modelData.name)
                    //textColor: Theme.dark.textColor
                    backgroundColor: Palette.colors[modelData.color]["500"]
                    onClicked: function(){
                        grid.eventClicked(date, modelData);
                    }
                }
        }
    }

    DropArea {
        anchors.fill: parent
        //keys: ["text/plain"]
        onDropped: {
            for (var i in drop.urls)
                eventManager.modify(Utils.pr(attachmentManager.AttachFile(date, drop.urls[i])), "add");
            eventChanged();
            //console.log(date.toLocaleDateString() + "  " + drop.urls);
            //attachmentManager.AttachFile(date, drop.urls);
        }
    }

    Rectangle {
        id: selectedRect
        anchors.fill: parent
        //anchors.centerIn: parent
        //width: 1 * Math.min(parent.width, parent.height)
        //height: width
        //visible: eventManager.eventsForDate(date).length > 0
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
