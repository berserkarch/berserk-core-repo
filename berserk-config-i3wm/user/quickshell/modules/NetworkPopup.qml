import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

// Native network status panel (device/state/connection + nearby wifi via
// nmcli), opened instead of spawning nm-connection-editor.
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

    implicitWidth: 380
    implicitHeight: content.implicitHeight + 20
    color: "transparent"
    property bool shown: NetworkPopupState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    property var devices: []
    property var wifiNets: []

    Timer {
        interval: 3000
        running: NetworkPopupState.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            devProc.running = true;
            wifiProc.running = true;
        }
    }

    Process {
        id: devProc
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    const p = line.split(":");
                    if (p.length < 4 || p[1] === "loopback")
                        continue;
                    out.push({ device: p[0], type: p[1], state: p[2], conn: p.slice(3).join(":") });
                }
                popup.devices = out;
            }
        }
    }

    Process {
        id: wifiProc
        command: ["sh", "-c", "timeout 2 nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;
                    const p = line.split(":");
                    if (p.length < 3 || !p[0])
                        continue;
                    out.push({ ssid: p[0], signal: p[1], security: p[2] || "open" });
                }
                popup.wifiNets = out;
            }
        }
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

            Text {
                text: "network devices"
                color: Colors.badgeBlue
                font.family: "Iosevka"
                font.pointSize: 9
                font.bold: true
                renderType: Text.NativeRendering
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.badgeGrey }

            Repeater {
                model: popup.devices

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: modelData.state.startsWith("connected") ? Colors.badgeGreen : Colors.badgeDim
                    }
                    Text { Layout.preferredWidth: 70; text: modelData.device; color: Colors.badgeWhite; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.preferredWidth: 70; text: modelData.type; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.fillWidth: true; text: modelData.conn; color: Colors.badgeBlue; elide: Text.ElideRight; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                }
            }

            Text {
                visible: popup.wifiNets.length > 0
                text: "nearby wifi"
                color: Colors.badgeBlue
                font.family: "Iosevka"
                font.pointSize: 9
                font.bold: true
                renderType: Text.NativeRendering
                Layout.topMargin: 6
            }

            Rectangle { visible: popup.wifiNets.length > 0; Layout.fillWidth: true; height: 1; color: Colors.badgeGrey }

            Repeater {
                model: popup.wifiNets

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true

                    Text { Layout.fillWidth: true; text: modelData.ssid; color: Colors.badgeWhite; elide: Text.ElideRight; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.preferredWidth: 40; text: modelData.signal + "%"; color: Colors.badgeGreen; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.preferredWidth: 60; text: modelData.security; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 7; renderType: Text.NativeRendering }
                }
            }
        }
    }
}
