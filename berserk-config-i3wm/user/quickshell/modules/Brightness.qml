import QtQuick
import Quickshell.Io
import ".."

// Not part of dwmbar's bar.sh. Only shows up on real laptop hardware with a
// backlight device; hidden on this VM. Scroll to adjust, via brightnessctl.
Badge {
    id: root
    property real pct: 1
    property bool available: false

    visible: available
    leftText: "󰃟 " + Math.round(pct * 100) + "%"
    leftBg: Colors.badgeBlack
    leftFg: Colors.badgeYellow
    interactive: true

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: queryProc.running = true
    }

    Process {
        id: queryProc
        command: ["sh", "-c", "ls /sys/class/backlight/*/max_brightness >/dev/null 2>&1 && brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim();
                if (v === "") {
                    root.available = false;
                    return;
                }
                root.available = true;
                root.pct = parseFloat(v) / 100;
            }
        }
    }

    onWheel: wheel => {
        const step = 5;
        const delta = wheel.angleDelta.y > 0 ? "+" + step + "%" : step + "%-";
        setProc.command = ["brightnessctl", "set", delta];
        setProc.running = true;
        requeryTimer.restart();
        OsdState.show("󰃟", root.pct);
    }

    Process {
        id: setProc
    }

    Timer {
        id: requeryTimer
        interval: 200
        onTriggered: queryProc.running = true
    }
}
