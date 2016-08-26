import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Material 0.2

ApplicationWindow {
    visible: true
    width: 1080
    height: 700
    title: qsTr("Calendar Test")

    initialPage: Page{
        title: qsTr("PageMonth")
        PageMonth{

        }
    }
    /*initialPage: Page {
        title: " RRR "
        TestPage {
            anchors.fill: parent
        }
    }*/
}
