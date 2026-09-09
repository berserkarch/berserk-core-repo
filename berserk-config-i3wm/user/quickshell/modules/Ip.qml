import QtQuick
import Quickshell
import ".."

// Mirrors dwmbar's get_ip() - IP|address pill, backed by the shared NetState
// (tun/VPN takes priority - that's the address that matters on a CTF box).
// Click copies the address to the clipboard.
Badge {
    id: root
    property bool justCopied: false

    leftText: NetState.isVpn ? "VPN" : "IP"
    leftBg: NetState.isVpn ? Colors.badgeGreen : Colors.badgeBlue
    leftFg: Colors.badgeBlack
    rightText: justCopied ? "copied!" : NetState.addr
    rightBg: Colors.badgeGrey
    rightFg: Colors.badgeWhite
    interactive: true
    onClicked: {
        Quickshell.clipboardText = NetState.addr;
        root.justCopied = true;
        copiedResetTimer.restart();
    }

    Timer {
        id: copiedResetTimer
        interval: 1200
        onTriggered: root.justCopied = false
    }
}
