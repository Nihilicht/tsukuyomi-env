pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // -- Timestamps --
    property double bootTimestamp: 0
    property double osInstallTimestamp: 0

    // -- CPU --
    property real cpuUsage: 0
    property var cpuCores: []

    // -- GPU --
    property int gpuUsage: 0
    property real vramUsage: 0

    // -- Memory --
    property real memUsage: 0
    property real swapUsage: 0

    // -- Disk --
    property int diskUsage: 0

    // -- Temperature --
    property int temperature: 0
    property var temperatures: []

    // -- Network rates --
    property real rxRate: 0
    property real txRate: 0

    // -- Network info --
    property string networkDevice: ""
    property string networkIp: "—"
    property string networkGateway: "—"
    property string networkDns: "—"
    property string networkMac: "—"

    // -- Internal state --
    property var lastCpusIdle: []
    property var lastCpusTotal: []
    property real lastRx: 0
    property real lastTx: 0

    // -- Workers --
    property Process timestampProc: Process {
        command: ["bash", Quickshell.shellPath("scripts/timestamps.sh")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const stats = JSON.parse(this.text.trim());
                    root.bootTimestamp = stats.boot;
                    root.osInstallTimestamp = stats.osInstall;
                } catch (e) {
                    console.error("Failed to parse initial timestamps:", e);
                }
            }
        }
    }

    property Process sysProc: Process {
        command: ["bash", Quickshell.shellPath("scripts/sysinfo.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = this.text.trim();
                if (!data || data === "null") return;
                
                try {
                    const stats = JSON.parse(data);

                    // --- CPU Calculation (Cores + Total) ---
                    const currentUsage = stats.cpuRaw.map((lineRaw, i) => {
                        const line = String(lineRaw).trim();
                        if (!line) return 0;
                        
                        const parts = line.split(/\s+/);
                        if (parts.length < 5) return 0;

                        const stats_parts = parts.slice(1).map(Number);
                        const idle = stats_parts[3] + stats_parts[4];
                        const total = stats_parts.reduce((a, b) => a + b, 0);

                        const lastIdle = root.lastCpusIdle[i] || 0;
                        const lastTotal = root.lastCpusTotal[i] || 0;

                        const deltaIdle = idle - lastIdle;
                        const deltaTotal = total - lastTotal;

                        root.lastCpusIdle[i] = idle;
                        root.lastCpusTotal[i] = total;

                        if (deltaTotal <= 0) return 0;
                        return (deltaTotal - deltaIdle) / deltaTotal * 100;
                    });

                    if (currentUsage.length > 0) {
                        root.cpuUsage = currentUsage[0];
                        root.cpuCores = currentUsage.slice(1);
                    }
                    
                    // --- Memory (RAM + Swap) ---
                    if (stats.memory.ram.total > 0) {
                        root.memUsage = (stats.memory.ram.total - stats.memory.ram.available) / stats.memory.ram.total * 100;
                    }
                    if (stats.memory.swap.total > 0) {
                        root.swapUsage = (stats.memory.swap.total - stats.memory.swap.free) / stats.memory.swap.total * 100;
                    }
                    
                    // --- GPU (Busy + VRAM) ---
                    root.gpuUsage = stats.gpu.busy;
                    if (stats.gpu.vram.total > 0) {
                        root.vramUsage = stats.gpu.vram.used / stats.gpu.vram.total * 100;
                    }
                    
                    // --- Disk ---
                    if (stats.disk.total > 0) {
                        root.diskUsage = stats.disk.used / stats.disk.total * 100;
                    }
                    
                    // --- Temperatures ---
                    root.temperatures = stats.temps.map(t => Math.round(t / 1000));
                    if (root.temperatures.length > 0) {
                        root.temperature = root.temperatures[0];
                    }

                    // --- Network rates ---
                    if (root.lastRx > 0) {
                        const currentRx = stats.network.rxBytes - root.lastRx;
                        const currentTx = stats.network.txBytes - root.lastTx;
                        root.rxRate = (currentRx === 0) ? 0 : (0.5 * currentRx) + (0.5 * root.rxRate);
                        root.txRate = (currentTx === 0) ? 0 : (0.5 * currentTx) + (0.5 * root.txRate);
                    }
                    root.lastRx = stats.network.rxBytes;
                    root.lastTx = stats.network.txBytes;

                    // --- Network info ---
                    root.networkDevice = stats.network.device;
                    root.networkIp = stats.network.ip;
                    root.networkGateway = stats.network.gateway;
                    root.networkDns = stats.network.dns;
                    root.networkMac = stats.network.mac;
                    
                } catch (e) {
                    console.error("Failed to parse system stats:", e);
                }
            }
        }
    }

    property Timer pollTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: sysProc.running = true
    }
}
