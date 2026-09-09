import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

// Plain workspace numbers, driven by i3's authoritative `i3-msg -t
// get_workspaces` rather than Quickshell.I3 (whose cached workspace list drifted
// out of sync - it kept showing workspaces i3 had already destroyed). Refreshed
// instantly off the same `-m -t subscribe` workspace-event stream the taskbar
// uses, with a slow poll fallback. Click switches with `i3-msg workspace number`.
RowLayout {
    id: root
    spacing: 10

    property var workspaces: []

    property bool refetchQueued: false
    function refresh() {
        if (wsProc.running)
            root.refetchQueued = true;
        else
            wsProc.running = true;
    }

    Process {
        id: eventProc
        command: ["i3-msg", "-m", "-t", "subscribe", "[\"workspace\"]"]
        running: true
        stdout: SplitParser {
            onRead: root.refresh()
        }
        onRunningChanged: {
            if (!running)
                eventProc.running = true;
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: wsProc
        command: ["i3-msg", "-t", "get_workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const arr = JSON.parse(text);
                    // i3 already sorts by num; keep name/num/state we need.
                    root.workspaces = arr.map(w => ({
                        name: w.name,
                        num: w.num,
                        focused: w.focused === true,
                        urgent: w.urgent === true,
                        visible: w.visible === true
                    }));
                } catch (e) {
                    // keep last good list on a malformed read
                }
            }
        }
        onRunningChanged: {
            if (!running && root.refetchQueued) {
                root.refetchQueued = false;
                wsProc.running = true;
            }
        }
    }

    Process { id: switchProc }

    Repeater {
        model: root.workspaces

        delegate: Item {
            id: ws
            required property var modelData

            implicitWidth: label.implicitWidth
            implicitHeight: label.implicitHeight + 4

            Text {
                id: label
                anchors.centerIn: parent
                text: ws.modelData.name
                font.family: "Iosevka"
                font.pointSize: 10
                renderType: Text.NativeRendering
                color: ws.modelData.urgent ? Colors.badgeRed
                     : ws.modelData.focused ? Colors.badgeGreen
                     : ws.modelData.visible ? Colors.badgeWhite
                     : Colors.badgeDim
                // Smooth color fade as focus/visibility changes.
                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }

            // Focus underline - grows from the center and fades in/out.
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: ws.modelData.focused ? label.implicitWidth : 0
                height: 2
                radius: 1
                color: Colors.badgeGreen
                opacity: ws.modelData.focused ? 1 : 0
                Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 160 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    switchProc.command = ["i3-msg", "workspace", "number", ws.modelData.num.toString()];
                    switchProc.running = true;
                }
            }
        }
    }
}
