import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.widgets
import qs.theme
import qs.services

Rectangle {
    id: root

    anchors.left: parent.left
    anchors.top: parent.top


    implicitWidth: layout.implicitWidth + 8
    implicitHeight: Sizing.barHeight

    bottomRightRadius: 20

    readonly property real itemWidth: 50

    // In-file component to avoid repetition
    component Chip: IconPill {
        id: chip
        bgColor: Colors.bg1
        implicitWidth: root.itemWidth
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        spacing: 2

        Chip {
            icon: "lucide-cpu"
            label: Math.round(SystemMonitor.cpuUsage) + "%"
            iconColor: Colors.cpu
            liquidSide: Sizing.LiquidSide.Left
        }

        Chip {
            icon: "lucide-gpu"
            label: Math.round(SystemMonitor.gpuUsage) + "%"
            iconColor: Colors.gpu
            liquidSide: Sizing.LiquidSide.None
        }

        Chip {
            icon: "lucide-memory-stick"
            label: Math.round(SystemMonitor.memUsage) + "%"
            iconColor: Colors.ram
            liquidSide: Sizing.LiquidSide.None
        }

        Chip {
            icon: "lucide-hard-drive"
            label: Math.round(SystemMonitor.diskUsage) + "%"
            iconColor: Colors.disk
            liquidSide: Sizing.LiquidSide.None
        }

        Chip {
            icon: "lucide-thermometer"
            label: Math.round(SystemMonitor.temperature) + "°C"
            iconColor: Colors.temp
            labelColor: SystemMonitor.temperature <= 50 ? Colors.green : (SystemMonitor.temperature <= 75 ? Colors.yellow : Colors.red)
            liquidSide: Sizing.LiquidSide.Right
        }
    }
}