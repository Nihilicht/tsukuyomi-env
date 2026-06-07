pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

QtObject {
    id: root

    // -- Active Window Info --
    readonly property var activeWindow: Hyprland.focusedWindow
    readonly property string windowTitle: activeWindow?.title ?? ""
    readonly property string windowClass: activeWindow?.class ?? ""
    readonly property bool isFloating: activeWindow?.floating ?? false
    readonly property bool isFullscreen: activeWindow?.fullscreen ?? false

    // -- Workspace State --
    readonly property int activeWorkspace: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    
    readonly property int totalWorkspaces: {
        return Math.max(activeWorkspace, Hyprland.workspaces.values.reduce((max, ws) => {
            if (ws.id < 0) return max;
            return Math.max(max, ws.id);
        }, 0));
    }

    // -- Special Workspace (Magic) Logic --
    property bool magicActive: false
    readonly property bool magicExists: Hyprland.workspaces.values.some(ws => ws.name === "special:magic")

    property Connections hyprlandConn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecialv2") {
                const [id, wsName] = event.parse(3);
                if (wsName === "special:magic") {
                    root.magicActive = true;
                } else if (id === "") {
                    root.magicActive = false;
                }
            }
        }
    }

    // -- Sliding Window Logic (Minimalist Workspace UI) --
    readonly property int targetWindowStart: Math.max(0, Math.min(activeWorkspace - 1 - 2, totalWorkspaces - 6))
    readonly property int targetWindowEnd: Math.min(totalWorkspaces, Math.max(activeWorkspace - 1 + 3, 6))

    // -- Animated State --
    property real smoothWindowStart: targetWindowStart
    Behavior on smoothWindowStart { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
    
    property real smoothWindowEnd: targetWindowEnd
    Behavior on smoothWindowEnd { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
    
    property real smoothActiveWorkspace: activeWorkspace
    Behavior on smoothActiveWorkspace { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

    // -- Navigation Actions --
    function dispatch(cmd) { Hyprland.dispatch(cmd); }
    function switchToWorkspace(id) { Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`); }
    function toggleSpecial() { Hyprland.dispatch(`hl.dsp.workspace.toggle_special("magic")`); }
    function switchWorkspaceRelative(delta) {
        if (delta === 0) return;
        const steps = Math.max(1, Math.round(Math.abs(delta) / 120));
        const d = delta > 0 ? -steps : steps;

        let targetId = ((root.activeWorkspace + d - 1) % root.totalWorkspaces + root.totalWorkspaces) % root.totalWorkspaces + 1;
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${targetId}" })`);
    }

    // -- Geometry Helper --
    function getItemGeometry(index, windowStart, windowEnd, total) {
        const overlap = Math.max(0, Math.min(index + 1, windowEnd) - Math.max(index, windowStart));
        const nextOverlap = Math.max(0, Math.min(index + 2, windowEnd) - Math.max(index + 1, windowStart));

        const extStart = windowStart - 2;
        const extEnd = windowEnd + 2;
        const extOverlap = Math.max(0, Math.min(index + 1, extEnd) - Math.max(index, extStart));
        const nextExtOverlap = Math.max(0, Math.min(index + 2, extEnd) - Math.max(index + 1, extStart));

        const width = (8 + (overlap * 8)) * extOverlap;
        const spacing = (index === total - 1) ? 0 : ((4 + Math.max(overlap, nextOverlap) * 4) * nextExtOverlap);

        return { 
            overlap: overlap, 
            nextOverlap: nextOverlap, 
            extOverlap: extOverlap, 
            nextExtOverlap: nextExtOverlap, 
            width: width, 
            spacing: spacing 
        };
    }
}
