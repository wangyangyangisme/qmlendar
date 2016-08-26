import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.calendar 1.0
import Material 0.2
import QtQml 2.2
import "Utils.js" as Utils


Item {
    id: pageMonth
    property date selectedDate
    onSelectedDateChanged: {
        grid.month = selectedDate.getMonth();
        monthbox.currentIndex = grid.month;
        grid.year = selectedDate.getFullYear();
        yearbox.value = grid.year;
    }

    anchors.fill: parent

    Column {
        RowLayout {
            IconButton {
                iconName: "navigation/chevron_left"
                onClicked:
                    selectedDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() - 1, selectedDate.getDate());
            }
            MySpinBox {
                id: yearbox
                from: 1970
                to: 4712
                editable: true
                textFromValue: function(value) {
                    return value;
                }
                onValueChanged: function(){
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
                onActivated: function(index){
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
                    eventList: JSON.parse(eventManager.eventsForDate(model.date))
                    state: model.month === grid.month ? (model.date.getDate() === selectedDate.getDate() ? "selected" : "normal") : "disabled"
                    onGridClicked: function(date){
                        var x = (selectedDate.getTime() === date.getTime());
                        selectedDate = date;
                        if (x) {
                            eventEditingPopup.close();
                            eventEditingPopup.event = Utils.blankevent(date);
                            eventEditingPopup.action = "add";
                            eventEditingPopup.show();
                        }
                    }
                    onEventClicked: function(date, event){
                        selectedDate = date;
                        eventEditingPopup.close();
                        eventEditingPopup.event = event;
                        eventEditingPopup.action = "edit";
                        eventEditingPopup.show();
                    }
                    onEventChanged: function(){
                        grid.year = grid.year + 1;
                        grid.year = grid.year - 1;
                    }
                }
            }
        }
    }
    Component.onCompleted: function(){
        selectedDate = new Date();
    }

    EventEditingPopup {
        id: eventEditingPopup
        event: Utils.blankevent(new Date())
        onAccepted: function(){
            console.log(JSON.stringify(event));
            eventManager.modify(JSON.stringify(event), action);
            grid.year = grid.year + 1;
            grid.year = grid.year - 1;
            eventEditingPopup.close();
        }
    }

    Snackbar {
        id: snackbar
    }
    ActionButton {
        anchors {
            right: parent.right
            bottom: snackbar.top
            margins: Units.dp(32)
        }

        action: Action {
            id: addContent
            onTriggered: function(){
                eventEditingPopup.close();
                eventEditingPopup.event = Utils.blankevent(selectedDate);
                eventEditingPopup.action = "add";
                eventEditingPopup.show()
            }
        }
        iconName: "content/add"
    }
}
