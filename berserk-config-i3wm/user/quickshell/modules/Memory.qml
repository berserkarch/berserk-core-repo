import QtQuick
import Quickshell.Io
import ".."

// Mirrors dwmbar's mem() - icon+value badge, black bg, "free -h" style.
// Red matches bar.sh's `^c$red^` (and the reference dwm screenshot).
Badge {
    id: root
    property real usedGb: 0

    leftText: " " + usedGb.toFixed(1) + "G"
    leftBg: Colors.badgeBlack
    leftFg: Colors.badgeRed
    interactive: true
    active: Popups.current === "sysmon" && SysMonState.sortBy === "mem"
    activeColor: Colors.badgeRed
    onClicked: {
        if (SysMonState.visible && SysMonState.sortBy === "mem") {
            SysMonState.visible = false;
        } else {
            SysMonState.sortBy = "mem";
            Popups.open("sysmon", root.mapToItem(null, root.width / 2, 0).x);
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", "grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                let total = 0, avail = 0;
                for (const line of text.trim().split("\n")) {
                    const m = line.match(/(\w+):\s*(\d+)/);
                    if (!m) continue;
                    if (m[1] === "MemTotal") total = parseInt(m[2]);
                    if (m[1] === "MemAvailable") avail = parseInt(m[2]);
                }
                root.usedGb = (total - avail) / 1024 / 1024;
            }
        }
    }
}
