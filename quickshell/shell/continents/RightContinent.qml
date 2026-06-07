import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.services
import qs.widgets
import qs.theme
import qs.utils

Rectangle {
    id: root
    
    anchors.right: parent.right
    anchors.top: parent.top

    implicitWidth: layout.implicitWidth + 8
    implicitHeight: Sizing.barHeight

    bottomLeftRadius: 20

    component Separator: Rectangle {
        width: 1
        height: 16
        color: Colors.surface1
        Layout.alignment: Qt.AlignVCenter
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        spacing: 2

        RowLayout {
            id: networkGroup
            spacing: 2

            Loader {
                active: NetworkService.isAnyConnected
                visible: active
                sourceComponent: ItemPill {
                    bgColor: Colors.bg1
                    liquidSide: Sizing.LiquidSide.Left
                    spacing: 5

                    implicitWidth: layout.implicitWidth + leftPadding + rightPadding + spacing
                    leftPadding: 3
                    rightPadding: 3

                    readonly property real rateWidth: 47.5

                    RowLayout {
                        spacing: 2
                        Layout.preferredWidth: rateWidth

                        IconColored {
                            icon: "lucide-arrow-down-to-line"
                            color: Colors.teal
                            size: 14
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }
                        Text {
                            text: NetworkService.formatSpeed(SystemMonitor.rxRate)
                            font.pixelSize: 10
                            color: Colors.text
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    RowLayout {
                        spacing: 2
                        Layout.preferredWidth: rateWidth

                        IconColored {
                            icon: "lucide-arrow-up-from-line"
                            color: Colors.peach
                            size: 14
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }
                        Text {
                            text: NetworkService.formatSpeed(SystemMonitor.txRate)
                            font.pixelSize: 10
                            color: Colors.text
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            Loader {
                active: NetworkService.isWiredConnected
                visible: active
                sourceComponent: IconPill {
                    icon: "lucide-network"
                    iconColor: Colors.mauve
                    bgColor: Colors.bg1
                    implicitWidth: implicitHeight
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    liquidSide: {
                        const idx = Layout.visibleIndex(parent);
                        const len = Layout.visibleCount(parent.parent);
                        if (idx === len - 1) return Sizing.LiquidSide.Right;
                        return Sizing.LiquidSide.None
                    }
                }
            }

            Loader {
                active: NetworkService.wifiHardwareEnabled
                visible: active
                sourceComponent: IconPill {
                    icon: NetworkService.getWifiIcon()
                    iconColor: {
                        if (!NetworkService.wifiEnabled) return Colors.red;
                        if (NetworkService.isWifiConnected) return Colors.green;
                        return Colors.yellow;
                    }
                    bgColor: Colors.bg1
                    implicitWidth: implicitHeight
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    liquidSide: {
                        const idx = Layout.visibleIndex(parent);
                        const len = Layout.visibleCount(parent.parent);
                        if (len === 1) return Sizing.LiquidSide.Both;
                        if (idx === len - 1) return Sizing.LiquidSide.Right;
                        return Sizing.LiquidSide.None
                    }
                }
            }
        }

        Separator { visible: Layout.visibleCount(networkGroup) > 0 }

        RowLayout {
            id: audioGroup
            spacing: 2

            IconPill {
                icon: AudioService.getSpeakerIcon()
                label: Math.round(AudioService.speakerVolume) + "%"
                iconColor: AudioService.speakerMuted ? Colors.red : Colors.blue
                bgColor: Colors.bg1
                implicitWidth: 50
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                liquidSide: Sizing.LiquidSide.Left
                
                onClicked: AudioService.toggleSpeakerMute()
                onScrolled: (wheel) => AudioService.adjustSpeakerVolume(wheel.angleDelta.y)
            }

            IconPill {
                icon: AudioService.getMicIcon()
                label: Math.round(AudioService.micVolume) + "%"
                iconColor: AudioService.micMuted ? Colors.red : Colors.green
                bgColor: Colors.bg1
                implicitWidth: 50
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                liquidSide: Sizing.LiquidSide.Right
                
                onClicked: AudioService.toggleMicMute()
                onScrolled: (wheel) => AudioService.adjustMicVolume(wheel.angleDelta.y)
            }
        }

        Separator {}

        RowLayout {
            id: quickActions
            spacing: 2

            IconPill {
                icon: "lucide-focus"
                iconColor: Colors.teal
                bgColor: Colors.bg1
                implicitWidth: implicitHeight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                liquidSide: Sizing.LiquidSide.Left
            }

            IconPill {
                icon: "lucide-pipette"
                iconColor: Colors.mauve
                bgColor: Colors.bg1
                implicitWidth: 24
                implicitHeight: implicitWidth
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            IconPill {
                icon: "lucide-clipboard"
                iconColor: Colors.green
                bgColor: Colors.bg1
                implicitWidth: implicitHeight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            IconPill {
                icon: "lucide-command"
                iconColor: Colors.yellow
                bgColor: Colors.bg1
                implicitWidth: implicitHeight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            IconPill {
                icon: "lucide-settings-2"
                iconColor: Colors.lavender
                bgColor: Colors.bg1
                implicitWidth: implicitHeight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                liquidSide: Sizing.LiquidSide.Right
            }
        }

        Separator {}

        IconPill {
            id: powerBtn
            icon: "lucide-power"
            iconColor: Colors.red
            bgColor: Colors.bg.darker(2)
            implicitWidth: implicitHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            liquidSide: Sizing.LiquidSide.Both

            onClicked: window.overlayState.powerControlActive = !window.overlayState.powerControlActive
        }
    }
}