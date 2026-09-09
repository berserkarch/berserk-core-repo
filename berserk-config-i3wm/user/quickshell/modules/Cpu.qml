import QtQuick
import Quickshell.Io
import ".."

// Mirrors dwmbar's cpu() - /proc/loadavg 1min value in a CPU|value pill.
// Click opens a live process monitor - a static status string can't do that.
Badge {
    id: root
    property real load: 0

    leftText: "CPU"
    leftBg: Colors.badgeGreen
    leftFg: Colors.badgeBlack
    rightText: load.toFixed(2)
    rightBg: Colors.badgeGrey
    rightFg: Colors.badgeWhite
    interactive: true
    active: Popups.current === "sysmon" && SysMonState.sortBy === "cpu"
    activeColor: Colors.badgeGreen
    onClicked: {
        if (SysMonState.visible && SysMonState.sortBy === "cpu") {
            SysMonState.visible = false;
        } else {
            SysMonState.sortBy = "cpu";
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
        command: ["sh", "-c", "cat /proc/loadavg"]
        stdout: StdioCollector {
            onStreamFinished: root.load = parseFloat(text.trim().split(" ")[0])
        }
    }
}
