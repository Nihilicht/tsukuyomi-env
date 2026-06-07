import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.theme
import qs.widgets

Rectangle {
    id: root
    
    // ==========================================
    // API & STATE
    // ==========================================
    property int maxVisibleItems: 5
    
    readonly property int effectiveMaxVisible: Math.max(maxVisibleItems, 2)
    readonly property int itemCount: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values.length : 0
    readonly property bool overflowing: itemCount > effectiveMaxVisible
    
    // State for the expanded dropdown
    property bool expanded: false
    
    // Logic: If overflowing, we show (max - 1) icons to leave room for the counter
    readonly property int visibleItemCount: overflowing ? (effectiveMaxVisible - 1) : Math.min(itemCount, effectiveMaxVisible)
    
    // Calculate exact width needed for visible icons and their 6px gaps
    readonly property real targetTrayWidth: {
        if (visibleItemCount <= 0) return 0;
        return (visibleItemCount * 16) + ((visibleItemCount - 1) * 6);
    }
    
    visible: itemCount > 0
    width: itemCount > 0 ? trayRow.width + trayRow.anchors.rightMargin * 2 : 0
    height: Sizing.islandHeight
    radius: height / 2
    color: Colors.bg
    
    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

    // Merging mask for the bottom corners
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.radius
        color: Colors.bg
        opacity: popupBackground.popupScaleY
        visible: opacity > 0
    }

    // ==========================================
    // COMPONENTS
    // ==========================================
    component TrayIconDelegate: Item {
        id: trayItemRoot

        property var trayItem
        property bool shouldBeVisible: true

        width: shouldBeVisible ? 16 : 0
        height: 16

        // Animate scale and opacity for main bar, visible handles popup
        opacity: shouldBeVisible ? 1.0 : 0.0
        scale: shouldBeVisible ? 1.0 : 0.0

        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        Rectangle {
            id: dot
            anchors.fill: parent
            radius: width / 2
            color: mouseArea.containsMouse ? Colors.surface1 : Colors.bg1

            property real hoverFactor: mouseArea.containsMouse ? 1.1 : 1.0
            transform: Scale {
                origin.x: dot.width / 2; origin.y: dot.height / 2;
                xScale: dot.hoverFactor; yScale: dot.hoverFactor
            }

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on hoverFactor { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 12
                source: trayItemRoot.trayItem ? trayItemRoot.trayItem.icon : ""
                mipmap: true
            }
        }

        QsMenuAnchor {
            id: menuAnchor
            anchor.window: window
            anchor.item: trayItemRoot
            menu: trayItemRoot.trayItem ? trayItemRoot.trayItem.menu : null
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: (mouse) => {
                if (!trayItemRoot.trayItem) return;

                if (mouse.button === Qt.LeftButton) {
                    if (trayItemRoot.trayItem.isMenuOnly || trayItemRoot.trayItem.onlyMenu) {
                        menuAnchor.open();
                    } else if (typeof trayItemRoot.trayItem.activate === "function") {
                        trayItemRoot.trayItem.activate();
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    if (typeof trayItemRoot.trayItem.secondaryActivate === "function") {
                        trayItemRoot.trayItem.secondaryActivate();
                    }
                } else if (mouse.button === Qt.RightButton) {
                    if (trayItemRoot.trayItem.menu) {
                        menuAnchor.open();
                    } else if (typeof trayItemRoot.trayItem.contextMenu === "function") {
                        trayItemRoot.trayItem.contextMenu(mouse.x, mouse.y);
                    } else if (typeof trayItemRoot.trayItem.activate === "function") {
                        trayItemRoot.trayItem.activate();
                    }
                }
            }
        }
    }

    // ==========================================
    // RENDER
    // ==========================================
    Row {
        id: trayRow
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        layoutDirection: Qt.RightToLeft

        ListView {
            id: trayList
            width: root.targetTrayWidth
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: width > 0
            orientation: ListView.Horizontal
            layoutDirection: Qt.RightToLeft
            interactive: false
            model: SystemTray.items
            spacing: 6
            
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

            add: Transition {
                NumberAnimation { property: "scale"; from: 0; duration: 300; easing.type: Easing.OutBack }
                NumberAnimation { property: "opacity"; from: 0; duration: 300 }
            }
            
            remove: Transition {
                NumberAnimation { property: "scale"; to: 0; duration: 300; easing.type: Easing.InBack }
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
            }
            
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.OutQuint }
            }

            delegate: TrayIconDelegate {
                trayItem: modelData
                shouldBeVisible: index < root.visibleItemCount
            }
        }

        // Overflow Button
        Item {
            id: overflowCounter
            width: root.overflowing ? 16 : 0
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: width > 0
            
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: (counterMouseArea.containsMouse || root.expanded) ? Colors.surface1 : "transparent"
                
                Behavior on color { ColorAnimation { duration: 200 } }

                IconColored {
                    anchors.centerIn: parent
                    icon: root.expanded ? "lucide-chevron-up" : "lucide-chevron-down"
                    size: 14
                    color: Colors.subtext0
                }
            }

            MouseArea {
                id: counterMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    grab.active = !grab.active;
                    root.expanded = !root.expanded;
                }
            }
        }
    }

    PopupWindow {
        id: popup
        visible: root.expanded || popupBackground.popupScaleY > 0.01
        anchor.window: window
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        
        implicitWidth: root.width
        implicitHeight: layoutContent.implicitHeight + 12
        
        color: "transparent"

        onVisibleChanged: {
            if (!visible && root.expanded) {
                root.expanded = false;
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ popup, window ]

            onCleared: {
                root.expanded = false;
            }
        }

        Rectangle {
            id: popupBackground
            anchors.fill: parent
            color: Colors.bg
            radius: root.height / 2
            
            opacity: root.expanded ? 1.0 : 0.0
            property real popupScaleY: root.expanded ? 1.0 : 0.0
            transform: Scale { yScale: popupBackground.popupScaleY; origin.y: 0 }
            
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
            Behavior on popupScaleY { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
            
            // Mask the top corners to be flat, matching the TrayIsland bottom
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: Colors.bg
            }
        }

        ColumnLayout {
            id: layoutContent
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6
            
            Flow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                layoutDirection: Qt.RightToLeft
                    
                Repeater {
                    model: SystemTray.items
                    
                    delegate: TrayIconDelegate {
                        trayItem: modelData
                        shouldBeVisible: (index >= root.visibleItemCount) && root.expanded
                        visible: index >= root.visibleItemCount
                    }
                }
            }
        }
    }
}
