import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import qs.theme
import qs.widgets

ItemPill {
    id: root

    // ==========================================
    // API
    // ==========================================
    property color iconColor: Colors.text
    property color labelColor: Colors.text
    property string icon
    property string label
    
    property int iconSize: 14
    property int fontSize: 10

    // ItemPill already has RowLayout and spacing/padding aliases
    spacing: root.label !== "" ? 6 : 0
    leftPadding: root.label !== "" ? 3 : 0
    rightPadding: root.label !== "" ? 3 : 0

    implicitWidth: layout.implicitWidth + (root.label !== "" ? 12 : 0)
    
    bgHoverColor: Qt.alpha(iconColor, 0.2)

    // ==========================================
    // RENDER
    // ==========================================
    IconColored {
        icon: root.icon
        color: root.iconColor
        size: root.iconSize
        Layout.fillWidth: root.label === ""
        Layout.alignment: root.label !== "" ? (Qt.AlignLeft | Qt.AlignVCenter) : Qt.AlignCenter
    }

    Loader {
        active: root.label !== ""
        visible: active
        Layout.fillWidth: active
        Layout.alignment: Qt.AlignVCenter
        sourceComponent: Text {
            text: root.label
            font.pixelSize: root.fontSize
            font.weight: Font.Normal
            color: root.labelColor
            horizontalAlignment: Text.AlignRight
        }
    }
}
