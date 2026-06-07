import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: root

    // ==========================================
    // API
    // ==========================================
    property int liquidSide: Sizing.LiquidSide.None
    property color bgColor: "transparent"
    property color bgHoverColor: Colors.surface0 // Default hover
    property real baseRadius: 4
    property real fullRadius: height / 2

    // Content management
    default property alias contentData: contentContainer.data
    property alias contentLayout: contentContainer

    // Interaction
    readonly property bool hovered: mouseArea.containsMouse
    signal clicked(var mouse)
    signal secondaryClicked(var mouse)
    signal scrolled(var wheel)

    // ==========================================
    // LOGIC
    // ==========================================
    readonly property bool roundLeft: liquidSide === Sizing.LiquidSide.Left || liquidSide === Sizing.LiquidSide.Both
    readonly property bool roundRight: liquidSide === Sizing.LiquidSide.Right || liquidSide === Sizing.LiquidSide.Both

    // Background Styling
    color: root.bgColor
    
    // Liquid Rounding
    topLeftRadius: root.roundLeft ? root.fullRadius : root.baseRadius
    bottomLeftRadius: root.roundLeft ? root.fullRadius : root.baseRadius
    topRightRadius: root.roundRight ? root.fullRadius : root.baseRadius
    bottomRightRadius: root.roundRight ? root.fullRadius : root.baseRadius

    implicitWidth: contentContainer.implicitWidth
    implicitHeight: Sizing.islandHeight

    Rectangle {
        id: hoverOverlay
        anchors.fill: parent
        color: root.bgHoverColor
        opacity: root.hovered ? 1 : 0
        scale: root.hovered ? 1 : 0.95
        
        // Match the root rounding
        topLeftRadius: root.topLeftRadius
        bottomLeftRadius: root.bottomLeftRadius
        topRightRadius: root.topRightRadius
        bottomRightRadius: root.bottomRightRadius

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                root.secondaryClicked(mouse);
            } else {
                root.clicked(mouse);
            }
        }
        onWheel: (wheel) => root.scrolled(wheel)
    }
}
