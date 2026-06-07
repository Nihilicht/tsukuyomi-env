import QtQuick
import QtQuick.Layouts
import qs.widgets

Pill {
    id: root

    // We use a RowLayout by default for ItemPill to mimic IconPill's behavior
    // but allowing any children.
    property alias spacing: layout.spacing
    property alias leftPadding: layout.anchors.leftMargin
    property alias rightPadding: layout.anchors.rightMargin
    
    // Alias the layout itself for width calculations in children
    property alias layout: layout

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 4
    }
    
    // Override the data property to point to the layout's data
    default property alias contentData: layout.data
}
