import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import Qt.labs.calendar 1.0
import Material 0.2
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import QtQml 2.2
import "Utils.js" as Utils

Dialog {
    property string action
    property var event
    id: eventEditingPopup
    width: Units.dp(600)
    title: (action === "add") ? qsTr("Add event") : qsTr("Edit event")
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Units.dp(8)
    }
    ListItem.Standard {
        action: Icon {
            anchors.centerIn: parent
            name: "content/drafts"
        }
        content: RowLayout {
            width: parent.width
            spacing: 6
            TextField {
                id: nameField
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.7
                text: event.name
                placeholderText: qsTr("Event name")
                floatingLabel: true
                onEditingFinished: {
                    event.name = nameField.text;
                }
            }
            IconButton {
                width: Units.dp(40)
                height: Units.dp(40)
                iconName: "action/delete"
                onClicked:
                    deleteConfirm.show();
            }
            Rectangle {
                id: colorPickerButton
                width: Units.dp(40)
                height: Units.dp(40)
                radius: Units.dp(20)
                color: Palette.colors[event.color]["500"]
                border.width: Units.dp(2)
                border.color: Theme.alpha("#000", 0.26)
                Ink {
                    anchors.fill: parent
                    onClicked: colorPicker.show()
                }
            }
        }
    }
    ListItem.Standard {
        RowLayout {
            width: parent.width
            spacing: 6
            TextField {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.5
                readOnly: true
                placeholderText: qsTr("From date")
                floatingLabel: true
                text: (new Date(Number(event.startDate))).toLocaleDateString(Qt.locale())
            }
            IconButton {
                width: Units.dp(40)
                height: Units.dp(40)
                iconName: "action/date_range"
                onClicked: {
                    datePickerDialog.field = "startDate";
                    datePickerDialog.show();
                }
            }
            Button {
                Layout.preferredWidth: parent.width * 0.3
                text: (new Date(Number(event.startDate))).toLocaleTimeString(Qt.locale(), qsTr("hh:mm ap"))
                onClicked: {
                    timePickerDialog.field = "startDate";
                    timePickerDialog.show();
                }
            }
        }
    }
    ListItem.Standard {
        RowLayout {
            width: parent.width
            spacing: 6
            TextField {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.5
                readOnly: true
                placeholderText: qsTr("To date")
                floatingLabel: true
                text: (new Date(Number(event.endDate))).toLocaleDateString(Qt.locale())
            }
            IconButton {
                width: Units.dp(40)
                height: Units.dp(40)
                iconName: "action/date_range"
                onClicked: {
                    datePickerDialog.field = "endDate";
                    datePickerDialog.show();
                }
            }
            Button {
                Layout.preferredWidth: parent.width * 0.3
                text: (new Date(Number(event.endDate))).toLocaleTimeString(Qt.locale(), qsTr("hh:mm ap"))
                onClicked: {
                    timePickerDialog.field = "endDate";
                    timePickerDialog.show();
                }
            }
        }
    }

    ListItem.Standard {
        height: Units.dp(72)
        action: Icon {
            anchors.centerIn: parent
            name: "action/restore"
        }
        content: RowLayout {
            width: parent.width
            height: parent.height
            spacing: 6
            ComboBox {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.2
                id: repeatType
                model: [qsTr("Once"), qsTr("Weekly"), qsTr("Monthly")]
                currentIndex: event.type
                onActivated: {
                    event.type = currentIndex;
                    event.mask = "";
                    event = event;
                }
            }
            Grid {
                columns: 3
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.8
                id: weekDaySelector
                Repeater {
                    model: 7
                    delegate: CheckBox{
                        id: weekDayCheckBox
                        implicitHeight: Units.dp(24)
                        text: Qt.locale().standaloneDayName(modelData)
                        checked: event.mask.indexOf(modelData) !== -1
                        onClicked: {
                            if (weekDayCheckBox.checked && (event.mask.indexOf(modelData) === -1))
                                event.mask = event.mask + modelData + ' ';
                            if (weekDayCheckBox.checked === false && (event.mask.indexOf(modelData) !== -1))
                                event.mask = event.mask.replace(modelData + ' ', '');
                            event = event;
                        }
                    }
                }
                visible: repeatType.currentIndex === 1
            }
            ComboBox {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.3
                id: monthDaySelector
                model: Utils.getDayItems(new Date(Number(event.startDate)))
                currentIndex: ( (event.mask === "") ? (new Date(Number(event.startDate))).getDate() : Number(event.mask) ) - 1
                onActivated: {
                    event.mask = (currentIndex + 1).toString();
                    event = event;
                }
                visible: repeatType.currentIndex === 2
            }
        }
        visible: event.type !== 9
    }
    ListItem.Standard {
        action: Icon {
            anchors.centerIn: parent
            name: "editor/attach_file"
        }
        text: qsTr("File: %1").arg(event.name)
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
            Drag.mimeData: {"text/uri-list": attachmentManager.getFileURI(event.name, event.mask)}
        }
        visible: event.type === 9
    }
    Dialog {
        id: deleteConfirm
        hasActions: true
        positiveButtonText: qsTr("Delete")
        negativeButtonText: qsTr("Cancel")
        title: qsTr("Delete?")
        text: qsTr("Are your sure to delete this event?")
        onAccepted: {
            action = "delete";
            eventEditingPopup.accepted();
            eventEditingPopup.close();
        }
    }
    Dialog {
        id: datePickerDialog
        property string field
        hasActions: true
        positiveButtonText: qsTr("Done")
        negativeButtonText: qsTr("Cancel")
        contentMargins: 0
        floatingActions: true
        DatePicker {
            id: datePicker
            frameVisible: false
            dayAreaBottomMargin : Units.dp(48)
        }
        onAccepted: {
            var a = new Date(Number(event[field]));
            a.setFullYear(datePicker.selectedDate.getFullYear());
            a.setMonth(datePicker.selectedDate.getMonth());
            a.setDate(datePicker.selectedDate.getDate());
            event[field] = a.getTime().toString();
            event = event;
        }
    }
    TimePickerDialog {
        id: timePickerDialog
        property string field
        positiveButtonText: qsTr("Done")
        negativeButtonText: qsTr("Cancel")
        onTimePicked: function (date){
            var a = new Date(Number(event[field]));
            a.setHours(date.getHours() );
            a.setMinutes(date.getMinutes() );
            a.setSeconds(date.getSeconds() );
            event[field] = a.getTime().toString();
            event = event;
        }
    }
    Dialog {
        id: colorPicker
        title: qsTr("Pick color")
        hasActions: false
        Grid {
            columns: 7
            spacing: Units.dp(8)
            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]
                Rectangle {
                    width: Units.dp(30)
                    height: Units.dp(30)
                    radius: Units.dp(2)
                    color: Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? Units.dp(2) : 0
                    border.color: Theme.alpha("#000", 0.26)

                    Ink {
                        anchors.fill: parent
                        onPressed: {
                            event.color = modelData
                            event = event
                            colorPicker.close()
                        }
                    }
                }
            }
        }
    }

    hasActions: true
    positiveButtonText: (action === "add") ? qsTr("Add") : qsTr("Edit")
    negativeButtonText: qsTr("Cancel")
}
