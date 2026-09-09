import QtQuick
import Quickshell.Services.Pipewire
import ".."

// Not part of dwmbar's bar.sh. Left click opens a draggable slider popup for
// precise control, right click toggles mute, scroll still nudges it - both
// trigger the floating OSD.
Badge {
    id: root
    property var sink: Pipewire.defaultAudioSink

    leftText: {
        if (!sink || !sink.audio) return "󰝟 --";
        const pct = Math.round(sink.audio.volume * 100);
        if (sink.audio.muted) return "󰝟 " + pct + "%";
        if (sink.audio.volume > 0.66) return "󰕾 " + pct + "%";
        if (sink.audio.volume > 0.33) return "󰖀 " + pct + "%";
        return "󰕿 " + pct + "%";
    }
    leftBg: Colors.badgeBlack
    leftFg: Colors.badgeOrange
    interactive: true
    active: Popups.current === "volume"
    activeColor: Colors.badgeOrange

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (root.sink && root.sink.audio) {
                root.sink.audio.muted = !root.sink.audio.muted;
                OsdState.show(root.sink.audio.muted ? "󰝟" : "󰕾", root.sink.audio.muted ? 0 : root.sink.audio.volume);
            }
            return;
        }
        Popups.toggle("volume", root.mapToItem(null, root.width / 2, 0).x);
    }

    onWheel: wheel => {
        if (!root.sink || !root.sink.audio) return;
        const step = 0.05;
        const delta = wheel.angleDelta.y > 0 ? step : -step;
        root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + delta));
        OsdState.show("󰕾", root.sink.audio.volume);
    }
}
