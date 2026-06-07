import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.theme 

PanelWindow {
    id: root

    // 1. Layer & Namespace
    // We put it on the Top layer, but since it's transparent, it's just a spacer.
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-spacer"
    
    // 2. THE CRITICAL PART: Space Reservation
    // This tells Hyprland/Wayland to shift windows down by this amount.
    WlrLayershell.exclusiveZone: Sizing.barHeight - 6
    
    // 3. Positioning
    anchors {
        top: true
        left: true
        right: true
    }
    
    // 6. Invisible & Non-Interactive
    color: "transparent"
    
    // We use an empty Region mask to ensure clicks pass through this 
    // invisible spacer to whatever is behind it (like the ScreenFrame).
    mask: Region {} 
}