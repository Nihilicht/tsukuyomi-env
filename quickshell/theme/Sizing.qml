pragma Singleton
import QtQuick

QtObject {
    readonly property int railWidth: 6       // The visual "frame" width
    readonly property int barHeight: 30      // Height of the TopBar UI
    readonly property int islandHeight: 24   // Height of floating UI islands
    readonly property int islandY: (barHeight - islandHeight) / 2
    
    enum LiquidSide {
        None,
        Left,
        Right,
        Both
    }
}
