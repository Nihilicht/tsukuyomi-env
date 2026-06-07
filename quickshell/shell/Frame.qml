import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.theme
import qs.widgets
import qs.services
import qs.shell.continents
import qs.shell.islands

PanelWindow {
    id: window
    
    color: "transparent"

    WlrLayershell.namespace: "quickshell-frame"
    WlrLayershell.layer: overlayState.shouldShowTopBar ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.exclusiveZone: -1

    // If fullscreen: fade in when power is active, otherwise stay hidden.
    // If not fullscreen: always visible (1.0).
    property real visualOpacity: HyprlandService.isFullscreen ? (overlayState.shouldShowTopBar ? 1.0 : 0.0) : 1.0

    Behavior on visualOpacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
 
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        Region {
            x: leftContinent.x
            y: leftContinent.y
            width: leftContinent.width
            height: leftContinent.height
        }

        Region {
            x: workspaceIsland.x
            y: workspaceIsland.y
            width: workspaceIsland.width
            height: workspaceIsland.height
        }

        Region {
            x: centerIslands.x
            y: centerIslands.y
            width: centerIslands.width
            height: centerIslands.height
        }

        Region {
            x: rightContinent.x
            y: rightContinent.y
            width: rightContinent.width
            height: rightContinent.height
        }

        Region {
            x: trayIsland.x
            y: trayIsland.y
            width: trayIsland.width
            height: trayIsland.height
        }
    }

    // ==========================================
    // SIDE & BOTTOM RECTANGLES
    // ==========================================
    
    LeftContinent {
        id: leftContinent
        color: Colors.bg
        opacity: window.visualOpacity
    }

    WorkspaceIsland {
        id: workspaceIsland
        anchors.left: leftContinent.right
        anchors.leftMargin: 12
        y: Sizing.islandY
        opacity: window.visualOpacity
    }

    RowLayout {
        id: centerIslands
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter
        y: Sizing.islandY
        height: Sizing.islandHeight - 2
        opacity: window.visualOpacity

        IconPill {
            id: caffeineToggle
            icon: "fa-bolt-solid"
            iconSize: 10
            iconColor: Colors.subtext0
            bgColor: Colors.bg1
            implicitHeight: Sizing.islandHeight - 3
            implicitWidth: implicitHeight
            liquidSide: Sizing.LiquidSide.Both
        }

        TimeIsland {}

        IconPill {
            id: dndToggle
            icon: "fa-bell-solid"
            iconSize: 10
            iconColor: Colors.subtext0
            bgColor: Colors.bg1
            implicitHeight: Sizing.islandHeight - 3
            implicitWidth: implicitHeight
            liquidSide: Sizing.LiquidSide.Both
        }
    }

    TrayIsland {
        id: trayIsland
        anchors.right: rightContinent.left
        anchors.rightMargin: 12
        y: Sizing.islandY
        opacity: window.visualOpacity
    }

    RightContinent {
        id: rightContinent
        color: Colors.bg
        opacity: window.visualOpacity
    }

    InvertedCorner {
        size: 20
        x: leftContinent.width
        y: 0
        flipX: false
        flipY: false
        color: Colors.bg
        opacity: window.visualOpacity
    }

    InvertedCorner {
        size: 20
        x: window.width - rightContinent.width
        y: 0
        flipX: true
        flipY: false
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Left
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: Sizing.barHeight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Sizing.railWidth
        anchors.left: parent.left
        width: Sizing.railWidth
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Right
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: Sizing.barHeight
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: Sizing.railWidth
        anchors.right: parent.right
        width: Sizing.railWidth
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Bottom
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Sizing.railWidth
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Top-Left Inverted Corner
    InvertedCorner {
        size: 20
        x: Sizing.railWidth
        y: Sizing.barHeight
        flipX: false
        flipY: false
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Top-Right Inverted Corner
    InvertedCorner {
        size: 20
        x: window.width - Sizing.railWidth
        y: Sizing.barHeight
        flipX: true
        flipY: false
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Bottom-Left Inverted Corner
    InvertedCorner {
        size: 20
        x: Sizing.railWidth
        y: window.height - Sizing.railWidth
        flipX: false
        flipY: true
        color: Colors.bg
        opacity: window.visualOpacity
    }

    // Bottom-Right Inverted Corner
    InvertedCorner {
        size: 20
        x: window.width - Sizing.railWidth
        y: window.height - Sizing.railWidth
        flipX: true
        flipY: true
        color: Colors.bg
        opacity: window.visualOpacity
    }
}