import QtQuick 2.0
import QtQuick.Controls 2.0
import Material 0.2

SpinBox {
    id: control
    up.indicator: IconButton {
        iconName: "content/add"
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
    }
    down.indicator: IconButton {
        iconName: "content/remove"
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
    }
}
