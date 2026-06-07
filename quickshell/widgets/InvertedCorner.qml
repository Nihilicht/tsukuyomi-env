import QtQuick
import QtQuick.Shapes

import qs.theme

Item {
    id: root

    // ==========================================
    // API
    // ==========================================
    property real size: 20
    width: size
    height: size

    property bool flipX: false
    property bool flipY: false
    property color color: Colors.bg

    // Explicit endpoints for the curve. Defaults to the axis-aligned corner points.
    property point p1: Qt.point(flipX ? 0 : width, flipY ? height : 0)
    property point p2: Qt.point(flipX ? width : 0, flipY ? 0 : height)

    // ==========================================
    // LOGIC
    // ==========================================
    
    // The "inner corner" where the two straight lines meet.
    readonly property point corner: Qt.point(flipX ? width : 0, flipY ? height : 0)
    
    // The "outer corner" used to pull the Bezier control points.
    readonly property point target: Qt.point(flipX ? 0 : width, flipY ? 0 : height)

    // Dynamic "liquid" tension factors. 
    // We use asymmetric tension based on the ratio of dimensions to create 
    // a "stretched liquid" effect that responds to the difference.
    readonly property real maxDim: Math.max(Math.abs(p1.x - corner.x), Math.abs(p2.y - corner.y), 1)
    
    // Tension factors for horizontal and vertical axes (0.5 is base liquid)
    readonly property real tensionX: 0.575 * (Math.abs(p1.x - corner.x) / maxDim)
    readonly property real tensionY: 0.575 * (Math.abs(p2.y - corner.y) / maxDim)

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4 
        
        // This transform ensures that the (0,0) position of the component 
        // always refers to the "inner corner" meeting point.
        transform: Translate {
            x: root.flipX ? -root.width : 0
            y: root.flipY ? -root.height : 0
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"

            // Move to the first endpoint (horizontal reach)
            PathMove { x: root.p1.x; y: root.p1.y }

            // Line to the 90-degree meeting point
            PathLine { x: root.corner.x; y: root.corner.y }

            // Line to the second endpoint (vertical reach)
            PathLine { x: root.p2.x; y: root.p2.y }

            // The "Liquid" Cubic Bezier back to the start
            PathCubic {
                x: root.p1.x
                y: root.p1.y
                
                // Control point 1 (near p2): pulled towards INNER corner for concavity
                control1X: root.p2.x + (root.corner.x - root.p2.x) * root.tensionX
                control1Y: root.p2.y + (root.corner.y - root.p2.y) * root.tensionY
                
                // Control point 2 (near p1): pulled towards INNER corner for concavity
                control2X: root.p1.x + (root.corner.x - root.p1.x) * root.tensionX
                control2Y: root.p1.y + (root.corner.y - root.p1.y) * root.tensionY
            }
        }
    }
}
