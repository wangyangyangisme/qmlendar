import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.calendar 1.0
import Material 0.2
import QtQml 2.2
import "Utils.js" as Utils


Item {
    id: pageMonth
    width: 920
    height: 550
    property date selectedDate
    property bool locked : Utils.config().locked
    onLockedChanged: {
        selectorRow.visible = (locked === false);
        grid.year = grid.year + 1;
        grid.year = grid.year - 1;
    }
    onSelectedDateChanged: {
        grid.month = selectedDate.getMonth();
        monthbox.currentIndex = grid.month;
        grid.year = selectedDate.getFullYear();
        yearbox.value = grid.year;
    }

    anchors.fill: parent

    Column {
        RowLayout {
            id: selectorRow
            IconButton {
                iconName: "navigation/chevron_left"
                onClicked:
                    selectedDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() - 1, selectedDate.getDate());
            }
            SpinBox {
                id: yearbox
                from: 1970
                to: 4712
                editable: true
                up.indicator: IconButton {
                    iconName: "content/add"
                    x: yearbox.mirrored ? 0 : parent.width - width
                    z: 10
                    height: parent.height
                    implicitWidth: 40
                    implicitHeight: 40
                }
                down.indicator: IconButton {
                    iconName: "content/remove"
                    x: yearbox.mirrored ? parent.width - width : 0
                    z: 10
                    height: parent.height
                    implicitWidth: 40
                    implicitHeight: 40
                }
                textFromValue: function(value) {
                    return value;
                }
                onValueChanged: {
                    var newDate = new Date(selectedDate);
                    newDate.setFullYear(yearbox.value);
                    selectedDate = newDate;
                }
            }
            ListModel {
                id: monthModel
                Component.onCompleted: {
                    for (var i = 0; i < 12; i++) {
                        append( { key: Qt.locale().monthName(i, Locale.LongFormat), value: i} );
                    }
                }
            }
            ComboBox {
                id: monthbox
                model: monthModel
                textRole: "key"
                Layout.preferredWidth: 0.4 * parent.width
                onActivated: {
                    var newDate = new Date(selectedDate);
                    newDate.setMonth(currentIndex);
                    selectedDate = newDate;
                }
            }
            IconButton {
                iconName: "navigation/chevron_right"
                onClicked:
                    selectedDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, selectedDate.getDate());
            }
            visible: (locked === false)
        }
        ColumnLayout {
            Layout.fillWidth: true

            DayOfWeekRow {
                id: weekRow
                locale: grid.locale
                Layout.fillWidth: true
                delegate: Label {
                    text: model.shortName
                    font: weekRow.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MonthGrid {
                id: grid
                Layout.fillWidth: true
                delegate: DayGrid {
                    text: model.day
                    date: model.date
                    locked: pageMonth.locked
                    eventList: JSON.parse(eventManager.eventsForDate(model.date))
                    state: model.month === grid.month ? (model.date.getDate() === selectedDate.getDate() ? "selected" : "normal") : "disabled"
                    onGridClicked: {
                        var x = (selectedDate.getTime() === date.getTime());
                        selectedDate = date;
                        if (x) {
                            eventEditingPopup.close();
                            eventEditingPopup.event = Utils.blankevent(date);
                            eventEditingPopup.action = "add";
                            eventEditingPopup.show();
                        }
                    }
                    onEventClicked: {
                        selectedDate = date;
                        eventEditingPopup.close();
                        eventEditingPopup.event = event;
                        eventEditingPopup.action = "edit";
                        eventEditingPopup.show();
                    }
                    onEventChanged: {
                        grid.year = grid.year + 1;
                        grid.year = grid.year - 1;
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        selectedDate = new Date();
    }

    EventEditingPopup {
        id: eventEditingPopup
        event: Utils.blankevent(new Date())
        onAccepted: {
            //console.log(JSON.stringify(event));
            eventManager.modify(JSON.stringify(event), action);
            grid.year = grid.year + 1;
            grid.year = grid.year - 1;
            eventEditingPopup.close();
        }
    }

    Snackbar {
        id: pageSnackbar
    }
    ActionButton {
        id: addButton
        anchors {
            right: parent.right
            bottom: pageSnackbar.top
            margins: Units.dp(32)
        }
        z: 100
        action: Action {
            id: addContent
            onTriggered: {
                eventEditingPopup.close();
                eventEditingPopup.event = Utils.blankevent(selectedDate);
                eventEditingPopup.action = "add";
                eventEditingPopup.show();
            }
        }
        iconName: "content/add"
    }
}
