pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for "your" address, shared by the IP badge and the
// reverse-shell cheatsheet. Priority: tun/wg (VPN - the address that matters
// on HTB/THM/CTF boxes) > wired (eno/eth) > wifi (wlo/wlan). See MIGRATION.md.
Singleton {
    property string addr: "N/A"
    property bool isVpn: false
    property int port: 4444

    function pickAddr(text) {
        const ifaces = {};
        for (const line of text.trim().split("\n")) {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 4 || parts[2] !== "inet")
                continue;
            ifaces[parts[1]] = parts[3].split("/")[0];
        }
        const names = Object.keys(ifaces);
        const byPrefix = prefixes => names.find(n => prefixes.some(p => n.startsWith(p)));

        const tun = byPrefix(["tun", "wg"]);
        if (tun)
            return { addr: ifaces[tun], vpn: true };
        const wired = byPrefix(["en", "eth"]);
        if (wired)
            return { addr: ifaces[wired], vpn: false };
        const wifi = byPrefix(["wl"]);
        if (wifi)
            return { addr: ifaces[wifi], vpn: false };
        return { addr: names.length ? ifaces[names[0]] : "N/A", vpn: false };
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", "ip -o -4 addr show scope global 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const result = NetState.pickAddr(text);
                NetState.addr = result.addr || "N/A";
                NetState.isVpn = result.vpn;
            }
        }
    }
}
