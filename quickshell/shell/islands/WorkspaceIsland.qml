import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.theme
import qs.services
import qs.widgets

Rectangle {
    id: root
    
    width: workspaceRow.width + 12
    height: Sizing.islandHeight
    radius: height / 2
    color: Colors.bg

    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

    Row {
        id: workspaceRow
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: HyprlandService.magicExists ? 8 : 0
        
        Behavior on spacing { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

        // Minimalist Special Workspace Indicator
        Item {
            width: HyprlandService.magicExists ? 16 : 0
            height: 16
            visible: HyprlandService.magicExists
            anchors.verticalCenter: parent.verticalCenter
            
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

            Rectangle {
                id: specialRect
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: 2
                rotation: 45
                color: specialMouseArea.containsMouse ? Colors.specialWsHover : (HyprlandService.magicActive ? Colors.specialWsActive : Colors.specialWs)
                
                Behavior on color { ColorAnimation { duration: 300 } }

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: HyprlandService.magicActive
                    
                    ParallelAnimation {
                        NumberAnimation { target: specialRect; property: "scale"; from: 1.0; to: 1.2; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { target: specialRect; property: "radius"; from: 2; to: 3; duration: 1500; easing.type: Easing.InOutSine }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: specialRect; property: "scale"; from: 1.2; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { target: specialRect; property: "radius"; from: 3; to: 2; duration: 1500; easing.type: Easing.InOutSine }
                    }
                    
                    onRunningChanged: if (!running) {
                        specialRect.scale = 1.0;
                        specialRect.radius = 2;
                    }
                }
            }

            MouseArea {
                id: specialMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: HyprlandService.toggleSpecial()
            }
        }

        // Small Divider
        Rectangle {
            width: HyprlandService.magicExists ? 1 : 0
            height: 12
            color: Colors.text
            opacity: 0.2
            visible: HyprlandService.magicExists
            anchors.verticalCenter: parent.verticalCenter
            
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
        }

        Item {
            id: workspacesContainer
            width: allWorkspacesRow.width
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => HyprlandService.switchWorkspaceRelative(wheel.angleDelta.y)
            }

            Row {
                id: allWorkspacesRow
                spacing: 0
                
                Repeater {
                    id: workspacesRepeater
                    model: HyprlandService.totalWorkspaces
                    
                    Item {
                        property int wsIndex: index + 1
                        
                        readonly property var geo: HyprlandService.getItemGeometry(index, HyprlandService.smoothWindowStart, HyprlandService.smoothWindowEnd, HyprlandService.totalWorkspaces)
                        
                        width: geo.width + geo.spacing
                        height: 16
                        
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: parent.geo.width
                            height: width
                            radius: width / 2
                            color: slotMouseArea.containsMouse ? Colors.wsEmptyHover : Colors.wsEmpty
                            opacity: (slotMouseArea.containsMouse ? 1.0 : (0.5 + (parent.geo.overlap * 0.5))) * parent.geo.extOverlap

                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: parent.geo.width
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: parent.wsIndex === 10 ? "0" : parent.wsIndex.toString()
                            color: Colors.text
                            opacity: Math.max(0, (parent.geo.overlap - 0.75) * 4) * parent.geo.extOverlap
                            font.pixelSize: 10
                            font.bold: true
                            visible: parent.wsIndex <= 10 && parent.geo.overlap > 0.5 && parent.geo.extOverlap > 0
                        }
                        
                        MouseArea {
                            id: slotMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: HyprlandService.switchToWorkspace(parent.wsIndex)
                        }
                    }
                }
            }

            Rectangle {
                id: activeIndicator
                
                readonly property var geo: {
                    let targetIndex = Math.max(0, HyprlandService.smoothActiveWorkspace - 1);
                    let completeCount = Math.floor(targetIndex);
                    let remainder = targetIndex - completeCount;

                    let g1 = HyprlandService.getItemGeometry(completeCount, HyprlandService.smoothWindowStart, HyprlandService.smoothWindowEnd, HyprlandService.totalWorkspaces);
                    let g2 = HyprlandService.getItemGeometry(completeCount + 1, HyprlandService.smoothWindowStart, HyprlandService.smoothWindowEnd, HyprlandService.totalWorkspaces);

                    return {
                        overlap: g1.overlap * (1 - remainder) + g2.overlap * remainder,
                        extOverlap: g1.extOverlap * (1 - remainder) + g2.extOverlap * remainder
                    };
                }

                width: (8 + (geo.overlap * 8)) * geo.extOverlap
                height: width
                radius: width / 2
                color: indicatorMouseArea.containsMouse ? Colors.wsHover : Colors.wsActive
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: 200 } }
                
                MouseArea {
                    id: indicatorMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
                
                Text {
                    anchors.centerIn: parent
                    text: {
                        let ws = Math.round(HyprlandService.smoothActiveWorkspace);
                        if (ws <= 9) return ws.toString()
                        if (ws === 10) return "0"
                        return ""
                    }
                    color: Colors.bg
                    font.pixelSize: 10
                    font.bold: true
                    opacity: Math.max(0, (activeIndicator.geo.overlap - 0.75) * 4) * activeIndicator.geo.extOverlap
                    visible: Math.round(HyprlandService.smoothActiveWorkspace) <= 10 && activeIndicator.geo.extOverlap > 0
                }
                
                x: {
                    let totalX = 0;
                    let targetIndex = Math.max(0, HyprlandService.smoothActiveWorkspace - 1);
                    let completeCount = Math.floor(targetIndex);
                    
                    for (let i = 0; i < completeCount; i++) {
                        let g = HyprlandService.getItemGeometry(i, HyprlandService.smoothWindowStart, HyprlandService.smoothWindowEnd, HyprlandService.totalWorkspaces);
                        totalX += (g.width + g.spacing);
                    }
                    
                    let remainder = targetIndex - completeCount;
                    if (remainder > 0 && completeCount < HyprlandService.totalWorkspaces) {
                        let g = HyprlandService.getItemGeometry(completeCount, HyprlandService.smoothWindowStart, HyprlandService.smoothWindowEnd, HyprlandService.totalWorkspaces);
                        totalX += (g.width + g.spacing) * remainder;
                    }
                    
                    return totalX;
                }
                
                visible: HyprlandService.activeWorkspace > 0 && HyprlandService.activeWorkspace <= HyprlandService.totalWorkspaces
            }
        }
    }
}
