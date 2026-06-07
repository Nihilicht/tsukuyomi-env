import QtQuick
import Quickshell

import qs.theme
import qs.widgets

ItemPill {
    id: root
        
    bgColor: Colors.bg
    liquidSide: Sizing.LiquidSide.Both

    implicitWidth: layout.implicitWidth + leftPadding + rightPadding
    leftPadding: 10
    rightPadding: leftPadding
    spacing: 5

    SystemClock {
        id: clock
    }

    Text {
        text: Qt.formatDate(clock.date, "MMM dd")
        color: Colors.lavender
        font.bold: true
        font.pixelSize: 11
    }

    // Small vertical separator
    Rectangle {
        width: 1
        height: 10
        color: Colors.overlay0
        opacity: 0.5
    }

    Text {
        text: Qt.formatTime(clock.date, "HH:mm")
        color: Colors.green
        font.bold: true
        font.pixelSize: 11
    }
}
