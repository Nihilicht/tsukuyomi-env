pragma Singleton
import QtQuick

QtObject {
    // ==========================================
    // 1. RAW PALETTE (Catppuccin Mocha)
    // ==========================================
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo:  "#f2cdcd"
    readonly property color pink:      "#f5c2e7"
    readonly property color mauve:     "#cba6f7"
    readonly property color red:       "#f38ba8"
    readonly property color maroon:    "#eba0ac"
    readonly property color peach:     "#fab387"
    readonly property color yellow:    "#f9e2af"
    readonly property color green:     "#a6e3a1"
    readonly property color teal:      "#94e2d5"
    readonly property color sky:       "#89dceb"
    readonly property color sapphire:  "#74c7ec"
    readonly property color blue:      "#89b4fa"
    readonly property color lavender:  "#b4befe"
    readonly property color text:      "#cdd6f4"
    readonly property color subtext1:  "#bac2de"
    readonly property color subtext0:  "#a6adc8"
    readonly property color overlay2:  "#9399b2"
    readonly property color overlay1:  "#7f849c"
    readonly property color overlay0:  "#6c7086"
    readonly property color surface2:  "#585b70"
    readonly property color surface1:  "#45475a"
    readonly property color surface0:  "#313244"
    readonly property color base:      "#1e1e2e"
    readonly property color mantle:    "#181825"
    readonly property color crust:     "#11111b"

    // ==========================================
    // 2. SEMANTIC TOKENS
    // ==========================================
    readonly property color accent: mauve
    readonly property color bg: mantle
    readonly property color bg1: bg.darker(1.25)
    // readonly property color border: surface1
    // readonly property color shadow: crust
    
    // ==========================================
    // 3. COMPONENT THEMES
    // ==========================================
    
    // Archipelago Layout (Continental/Island colors)
    // readonly property color islandBg: surface0
    // readonly property color continentBg: mantle
    
    // Workspaces
    readonly property color wsActive: blue
    readonly property color wsHover: mauve
    readonly property color wsOccupied: lavender
    readonly property color wsEmpty: surface0
    readonly property color wsEmptyHover: surface1

    readonly property color specialWs: red
    readonly property color specialWsActive: green
    readonly property color specialWsHover: yellow

    // SysInfo (Metric Chips)
    readonly property color cpu: blue
    readonly property color gpu: mauve
    readonly property color ram: green
    readonly property color disk: yellow
    readonly property color temp: red
    readonly property color netRx: teal
    readonly property color netTx: peach
}
