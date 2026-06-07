pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick

import qs.services

QtObject {
    id: root

    // -- Device references --
    property var wifiDevice: null
    property var wiredDevice: null

    // -- Derived state --
    readonly property bool hasWifi: wifiDevice !== null
    readonly property bool hasWired: wiredDevice !== null
    readonly property bool isWiredConnected: wiredDevice && wiredDevice.state === ConnectionState.Connected
    readonly property bool isWifiConnected: wifiDevice && wifiDevice.state === ConnectionState.Connected
    readonly property bool isAnyConnected: isWiredConnected || isWifiConnected

    // -- Networking settings --
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool wifiEnabled: Networking.wifiEnabled

    function updateDevices() {
        let bestWifi = null;
        let bestWired = null;

        const deviceValues = Networking.devices.values;
        for (let i = 0; i < deviceValues.length; i++) {
            let device = deviceValues[i];
            if (!device) continue;

            if (device.type === DeviceType.Wifi) {
                if (!bestWifi || device.state === ConnectionState.Connected) {
                    bestWifi = device;
                }
            } else if (device.type === DeviceType.Wired) {
                if (!bestWired || device.state === ConnectionState.Connected) {
                    bestWired = device;
                }
            }
        }

        root.wifiDevice = bestWifi;
        root.wiredDevice = bestWired;
    }

    function formatSpeed(bytesPerSec) {
        const formatValue = (val) => {
            if (val < 10) return val.toFixed(2);
            if (val < 100) return val.toFixed(1);
            return Math.round(val).toString();
        };

        if (bytesPerSec < 1024) return `${formatValue(bytesPerSec)} B`;
        if (bytesPerSec < 1024 * 1024) return `${formatValue(bytesPerSec / 1024)} K`;
        if (bytesPerSec < 1024 * 1024 * 1024) return `${formatValue(bytesPerSec / (1024 * 1024))} M`;
        return `${formatValue(bytesPerSec / (1024 * 1024 * 1024))} G`;
    }

    function getWifiIcon() {
        if (!hasWifi || (wifiDevice && wifiDevice.state === ConnectionState.Unknown)) return "lucide-wifi-off";
        if (wifiDevice && wifiDevice.state !== ConnectionState.Connected) return "lucide-wifi-sync";

        if (wifiDevice.networks && wifiDevice.networks.values.length > 0) {
            const signal = wifiDevice.networks.values[0].signalStrength;
            if (signal < 0.25) return "wifi-s1";
            if (signal < 0.50) return "wifi-s2";
            if (signal < 0.75) return "wifi-s3";
        }
        return "wifi-s4";
    }

    // -- Connections & lifecycle --
    property var deviceTracker: Connections {
        target: Networking.devices
        function onObjectInsertedPost() { root.updateDevices(); }
        function onObjectRemovedPost() { root.updateDevices(); }
    }

    // Polling timer since Networking singleton properties in v0.3.0 lack signals
    property var refreshTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.updateDevices()
    }

    Component.onCompleted: root.updateDevices()
}
