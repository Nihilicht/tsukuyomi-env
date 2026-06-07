pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

QtObject {
    id: root

    readonly property var tracker: PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Speaker state
    readonly property real speakerVolume: sink?.audio.volume * 100 ?? 0
    readonly property bool speakerMuted: sink?.audio.muted ?? false
    readonly property bool hasSpeaker: sink !== null
    
    // Mic state
    readonly property real micVolume: source?.audio.volume * 100 ?? 0
    readonly property bool micMuted: source?.audio.muted ?? false
    readonly property bool hasMic: source !== null

    function getSpeakerIcon() {
        if (speakerMuted) return "lucide-volume-off";
        if (speakerVolume < 33) return "lucide-volume";
        if (speakerVolume < 66) return "lucide-volume-1";
        return "lucide-volume-2";
    }

    function getMicIcon() {
        return micMuted ? "lucide-mic-off" : "lucide-mic";
    }

    function toggleSpeakerMute() {
        if (sink) sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (source) source.audio.muted = !source.audio.muted;
    }

    function adjustSpeakerVolume(delta) {
        if (!sink) return;
        let steps = Math.max(1, Math.round(Math.abs(delta) / 120));
        let inc = 0.05 * steps;
        sink.audio.volume = Math.max(0, Math.min(1.0, sink.audio.volume + (delta > 0 ? inc : -inc)));
    }

    function adjustMicVolume(delta) {
        if (!source) return;
        let steps = Math.max(1, Math.round(Math.abs(delta) / 120));
        let inc = 0.05 * steps;
        source.audio.volume = Math.max(0, Math.min(1.0, source.audio.volume + (delta > 0 ? inc : -inc)));
    }
}
