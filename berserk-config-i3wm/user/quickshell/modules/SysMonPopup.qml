import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

// Native process monitor - click CPU or Memory to open, instead of spawning
// an external `top`/`htop` in a terminal. Top 10, sorted by whichever badge
// opened it (SysMonState.sortBy), refreshed every 2s while visible.
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

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    color: "transparent"
    property bool shown: SysMonState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    property var rows: []

    function parse(text) {
        const out = [];
        const lines = text.trim().split("\n");
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 4)
                continue;
            const pid = parts[0];
            const cpu = parts[1];
            const mem = parts[2];
            const comm = parts.slice(3).join(" ");
            out.push({ pid: pid, cpu: cpu, mem: mem, comm: comm });
        }
        return out;
    }

    Timer {
        interval: 2000
        running: SysMonState.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    // Re-fetch immediately (don't wait for the next 2s tick) when switching
    // between CPU and Memory while the popup is already open.
    Connections {
        target: SysMonState
        function onSortByChanged() {
            if (SysMonState.visible)
                proc.running = true;
        }
    }

    Process {
        id: proc
        command: ["sh", "-c", "ps -eo pid,%cpu,%mem,comm --sort=-%" + SysMonState.sortBy + " --no-headers | head -n 10"]
        stdout: StdioCollector {
            onStreamFinished: popup.rows = popup.parse(text)
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
            spacing: 4

            Text {
                text: "processes (top 10 by " + SysMonState.sortBy + ")"
                color: SysMonState.sortBy === "mem" ? Colors.badgeDarkblue : Colors.badgeGreen
                font.family: "Iosevka"
                font.pointSize: 9
                font.bold: true
                renderType: Text.NativeRendering
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.badgeGrey
            }

            RowLayout {
                Layout.fillWidth: true
                Text { Layout.preferredWidth: 55; text: "PID"; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 7; renderType: Text.NativeRendering }
                Text { Layout.preferredWidth: 50; text: "CPU%"; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 7; renderType: Text.NativeRendering }
                Text { Layout.preferredWidth: 50; text: "MEM%"; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 7; renderType: Text.NativeRendering }
                Text { Layout.fillWidth: true; text: "NAME"; color: Colors.badgeDim; font.family: "Iosevka"; font.pointSize: 7; renderType: Text.NativeRendering }
            }

            Repeater {
                model: popup.rows

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true

                    Text { Layout.preferredWidth: 55; text: modelData.pid; color: Colors.badgeWhite; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.preferredWidth: 50; text: modelData.cpu; color: Colors.badgeGreen; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text { Layout.preferredWidth: 50; text: modelData.mem; color: Colors.badgeDarkblue; font.family: "Iosevka"; font.pointSize: 8; renderType: Text.NativeRendering }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.comm.length > 22 ? modelData.comm.slice(0, 22) + "…" : modelData.comm
                        color: Colors.badgeWhite
                        font.family: "Iosevka"
                        font.pointSize: 8
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
