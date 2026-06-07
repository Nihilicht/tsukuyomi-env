import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import qs.theme

Item {
    id: root

    property string icon
    property color color: Colors.text
    property real size: 14

    implicitWidth: size
    implicitHeight: size

    IconImage {
        id: iconImg
        source: "file://" + Quickshell.shellPath("assets/icons/" + root.icon + ".svg")
        anchors.centerIn: parent
        implicitSize: root.size
        mipmap: true
        visible: false
    }

    MultiEffect {
        source: iconImg
        anchors.fill: iconImg
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
    }
}
