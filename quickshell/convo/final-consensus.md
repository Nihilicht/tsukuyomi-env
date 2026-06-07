# Quickshell Design Consensus & Final Updates

This document summarizes the final architectural and technical decisions for the Quickshell project based on the design discussion.

## 1. Core Architecture
- **Root**: `shell.qml` serves as the `ShellRoot`, registering all windows and global states.
- **TopBar (Exclusion Zone)**: An invisible `PanelWindow` that only exists to reserve space with the Wayland compositor. No visual content is rendered here.
- **ScreenFrame (Visual Shell)**: A single `PanelWindow` anchored to all four edges of the screen. It renders the top bar UI, side/bottom rails, and the "liquid" inverted corners.
- **Input Masking**: Precise `inputRegion` carving is used on the `ScreenFrame` to ensure only the frame rails and corners capture input, leaving the rest of the screen fully interactive for applications.

## 2. File Structure
```
~/.config/quickshell/
├── shell.qml                      # ShellRoot & Window registration
├── assets/
│   └── icons/                     # SVG icons (lucide, fa, custom)
├── bar/
│   ├── TopBar.qml                 # Invisible exclusion zone
│   ├── ScreenFrame.qml            # Main visual layer (Frame + Top UI)
│   ├── continents/                # Grouped UI (SysInfo, SysActions)
│   └── islands/                   # Modular widgets (Clock, Toggles, Tray)
├── services/
│   └── SystemMetrics.qml          # Single Process poller (CPU, GPU, RAM, etc.)
├── overlays/
│   └── ...                        # Independent windows (Network, Volume, etc.)
├── widgets/
│   └── ...                        # Reusable primitives (MetricChip, LiquidCorner)
└── theme/
    ├── Palette.qml                # Catppuccin Mocha colors
    ├── Sizing.qml                 # Layout constants (rail width, radius)
    └── Animations.qml             # Global easing and durations
```

## 3. Technical Implementation
- **Liquid Corners**: Implemented using **GLSL ShaderEffect** (SDF-based) for maximum GPU efficiency and smooth antialiasing.
- **Animations**:
    - **Overlays**: Animate `width/height` and `opacity`.
    - **Radius Animation**: Overlays animate their corner radius from `0` (sharp) to `Theme.cornerRadius` (liquid) during entrance to simulate "growing" out of the frame.
- **Service Strategy**: 
    - Use native Quickshell plugins for `Hyprland`, `NetworkManager`, and `Wireplumber`.
    - Use a single centralized `SystemMetrics.qml` singleton for polling CPU, GPU, RAM, Thermals, and Disk usage via a single `Process` call every 1 second.
- **Icons**: SVG icons are stored in `assets/icons/`. They are rendered using `Image` and tinted via `ColorOverlay` to allow dynamic recoloring based on system state (e.g., thermal thresholds).

## 4. Visual Elements
- **Color Palette**: Strictly **Catppuccin Mocha**.
- **Archipelago Layout**:
    - **Left Continent**: System metric chips.
    - **Center Island**: Caffeine Toggle → Clock (Center) → DND Toggle.
    - **Right Continent**: System actions and power menu triggers.
- **Seamless Connectivity**: Overlays are visually "connected" to the frame through precise geometric alignment (`Theme.railWidth` margins) and shared design tokens, rather than technical IPC.
