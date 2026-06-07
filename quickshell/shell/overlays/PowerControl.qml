import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.services
import qs.theme
import qs.widgets

PanelWindow {
    id: window

    // ==========================================
    // LAYER & WINDOW CONFIG
    // ==========================================
    WlrLayershell.namespace: "quickshell-power-control"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Anchor to fill screen for the dim/blur effect, or specific area
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: overlayState.powerControlActive || backdrop.opacity > 0
    

    function close() {
        console.log(window.parent)
        overlayState.powerControlActive = false
    }

    Shortcut {
        sequence: "Escape"
        onActivated: close()
        enabled: overlayState.powerControlActive
    }

    // ==========================================
    // UI LAYOUT
    // ==========================================
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.alpha(Colors.bg, 0.1)
        opacity: overlayState.powerControlActive ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: close()
        }
    }

    Rectangle {
        id: content
        focus: overlayState.powerControlActive
        anchors.centerIn: parent

        readonly property real padding: 6

        width: mainLayout.implicitWidth + padding * 2
        height: mainLayout.implicitHeight + padding * 2
        color: Colors.bg

        radius: 16
        
        SystemClock {
            id: clock
        }

        readonly property double currentTime: clock.date.getTime() / 1000

        function formatDuration(seconds) {
            if (seconds < 0) return "0s";
            
            const units = [
                { label: "y",  secs: 31536000 },
                { label: "mo", secs: 2592000  },
                { label: "w",  secs: 604800   },
                { label: "d",  secs: 86400    },
                { label: "h",  secs: 3600     },
                { label: "m",  secs: 60       }
            ];

            for (let i = 0; i < units.length; i++) {
                if (seconds >= units[i].secs) {
                    const value = Math.floor(seconds / units[i].secs);
                    const remainder = seconds % units[i].secs;
                    
                    if (i + 1 < units.length) {
                        const nextValue = Math.floor(remainder / units[i+1].secs);
                        if (nextValue > 0) {
                            return value + units[i].label + " " + nextValue + units[i+1].label;
                        }
                    }
                    return value + units[i].label;
                }
            }
            return Math.floor(seconds) + "s";
        }


        ColumnLayout {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 32
            width: Math.max(timeRow.implicitWidth, buttonGrid.implicitWidth)

            RowLayout {
                id: timeRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 32

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Uptime"
                        color: Colors.subtext0
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: content.formatDuration(content.currentTime - SystemMonitor.bootTimestamp)
                        color: Colors.text
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Rectangle {
                    width: 1
                    height: 24
                    color: Qt.alpha(Colors.text, 0.1)
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "OS Install"
                        color: Colors.subtext0
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: content.formatDuration(content.currentTime - SystemMonitor.osInstallTimestamp)
                        color: Colors.text
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            GridLayout {
                id: buttonGrid
                columns: 3
                rows: 2
                rowSpacing: 2
                columnSpacing: 2
                Layout.alignment: Qt.AlignHCenter

            component Btn: Rectangle {
                id: button

                property string icon
                property string label
                property color activeColor: Colors.text
                property real size: 120
                
                readonly property bool active: mouseArea.containsMouse || button.activeFocus

                implicitWidth: size
                implicitHeight: size
                
                color: button.active ? Qt.alpha(button.activeColor, 0.15) : "transparent"
                radius: 12

                signal action
                
                IconColored {
                    id: iconItem
                    icon: button.icon
                    size: 48
                    color: button.active ? button.activeColor : Colors.text
                    anchors.centerIn: parent
                    
                    // Slightly offset the icon upwards when active to make room for label
                    anchors.verticalCenterOffset: button.active ? -10 : 0
                    
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on anchors.verticalCenterOffset {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    text: button.label
                    color: Colors.text
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    anchors.top: iconItem.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    opacity: button.active ? 1 : 0
                    scale: button.active ? 1 : 0.8
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: button.action()
                }
            }

            Btn {
                icon: "lucide-lock-keyhole"
                label: "Lock"
                activeColor: Colors.sapphire
                onAction: {
                    console.log(content.currentTime - SystemMonitor.bootTimestamp)
                }
            }
            Btn {
                icon: "lucide-log-out"
                label: "Logout"
                activeColor: Colors.lavender
            }
            Btn {
                icon: "lucide-moon"
                label: "Sleep"
                activeColor: Colors.green
            }
            Btn {
                icon: "lucide-orbit"
                label: "Hibernate"
                activeColor: Colors.peach
            }
            Btn {
                icon: "lucide-rotate-ccw"
                label: "Reboot"
                activeColor: Colors.maroon
                onAction: rebootProcess.running = true
            }
            Btn {
                icon: "lucide-power"
                label: "Shutdown"
                activeColor: Colors.red
                onAction: shutdownProcess.running = true
            }
        }
    }
    }


    IpcHandler {
        target: "power-control"

        function open() {
            overlayState.powerControlActive = true
        }
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    // ==========================================
    // ANIMATIONS
    // ==========================================
    // Add entrance/exit transitions here
}
