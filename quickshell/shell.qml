//@ pragma UseQApplication

import QtQuick
import Quickshell

import qs.services
import qs.shell
import qs.shell.overlays

ShellRoot {
    id: root

    // Block 1: The Reservation System (Invisible)
    Variants {
        model: Quickshell.screens
        TopBar {
            required property var modelData
            screen: modelData
        }
    }

    // Block 2: The Visual Shell (Per-Screen)
    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData

            QtObject {
                id: screenState
                readonly property bool shouldShowTopBar: powerControlActive
                
                property bool powerControlActive: false
            }

            // Local state for this specific screen
            Frame {
                screen: modelData

                property alias overlayState: screenState
            }

            PowerControl {
                screen: modelData

                property alias overlayState: screenState
            }
        }
    }
}
