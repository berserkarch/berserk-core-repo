import QtQuick
import Quickshell.Io
import ".."

// Detects the actual connection type via nmcli instead of only ever checking
// wifi (dwmbar's wlan() assumes wireless) - shows the ethernet icon when the
// primary connection is wired, wifi icon when it's wireless.
Badge {
    id: root
    property string kind: "none" // "wifi" | "ethernet" | "none"

    leftText: {
        if (kind === "ethernet") return "󰈀";
        if (kind === "wifi") return "󰤨";
        return "󰤭";
    }
    leftBg: Colors.badgeBlue
    leftFg: Colors.badgeBlack
    rightText: kind === "none" ? "Disconnected" : "Connected"
    rightBg: "transparent"
    rightFg: Colors.badgeBlue
    interactive: true
    active: Popups.current === "network"
    activeColor: Colors.badgeBlue
    onClicked: Popups.toggle("network", root.mapToItem(null, root.width / 2, 0).x)

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let kind = "none";
                for (const line of text.trim().split("\n")) {
                    const parts = line.split(":");
                    if (parts.length < 3 || !parts[2].startsWith("connected"))
                        continue;
                    if (parts[1] === "ethernet") {
                        kind = "ethernet";
                        break;
                    }
                    if (parts[1] === "wifi" && kind === "none") {
                        kind = "wifi";
                    }
                }
                root.kind = kind;
            }
        }
    }
}
