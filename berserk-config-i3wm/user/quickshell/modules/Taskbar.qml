import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import ".."

// Open-windows list for the CURRENTLY FOCUSED workspace only, driven by
// `i3-msg -t get_tree` (no dedicated "window" type in Quickshell.I3, so the raw
// IPC tree is walked directly). Click to focus, middle-click to close.
RowLayout {
    id: root
    spacing: 4

    property var windows: []

    // Follow i3's focus chain (each node's focus[0] = its focused child) from the
    // root down to the focused workspace, returning that workspace's name. Works
    // even when the focused workspace is empty (chain ends at the workspace node).
    function focusedWsName(tree) {
        let node = tree;
        let ws = null;
        while (node) {
            if (node.type === "workspace")
                ws = node.name;
            if (!node.focus || node.focus.length === 0)
                break;
            const nextId = node.focus[0];
            const kids = (node.nodes || []).concat(node.floating_nodes || []);
            node = kids.find(k => k.id === nextId) || null;
        }
        return ws;
    }

    // Collect windows, but only those under the target (focused) workspace.
    function collect(node, out, curWs, targetWs) {
        if (node.type === "workspace")
            curWs = node.name;
        if (node.window !== undefined && node.window !== null && curWs === targetWs) {
            const cls = (node.window_properties && node.window_properties.class) || "";
            const name = node.name || "";
            // quickshell's own windows (bar, popups) have no window class at
            // all and title themselves "quickshell" - keep them off their own taskbar.
            if (cls.toLowerCase() !== "quickshell" && name.toLowerCase() !== "quickshell") {
                out.push({
                    id: node.id,
                    name: name,
                    cls: cls,
                    focused: node.focused === true
                });
            }
        }
        const kids = (node.nodes || []).concat(node.floating_nodes || []);
        for (const c of kids)
            collect(c, out, curWs, targetWs);
    }

    // A pending re-fetch requested while one is already in flight - so an event
    // that lands mid-fetch still triggers a fresh read (avoids a stale highlight).
    property bool refetchQueued: false
    function refresh() {
        if (treeProc.running)
            root.refetchQueued = true;
        else
            treeProc.running = true;
    }

    // Event-driven: a long-lived `i3-msg -m -t subscribe` streams every window
    // AND workspace event (Quickshell.I3.rawEvent only fired on workspace/output
    // events, so same-workspace focus changes lagged). Each event = one JSON
    // line; refresh on every line. Restarts itself if the stream ever dies.
    Process {
        id: eventProc
        command: ["i3-msg", "-m", "-t", "subscribe", "[\"window\",\"workspace\"]"]
        running: true
        stdout: SplitParser {
            onRead: root.refresh()
        }
        onRunningChanged: {
            if (!running)
                eventProc.running = true;
        }
    }

    // Low-frequency fallback for changes that don't emit an i3 event (e.g. a
    // window retitling itself) and to seed the initial list.
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: treeProc
        command: ["i3-msg", "-t", "get_tree"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const tree = JSON.parse(text);
                    const target = root.focusedWsName(tree);
                    const out = [];
                    root.collect(tree, out, null, target);
                    root.windows = out;
                } catch (e) {
                    // ignore a malformed/partial tree, keep last good list
                }
            }
        }
        onRunningChanged: {
            if (!running && root.refetchQueued) {
                root.refetchQueued = false;
                treeProc.running = true;
            }
        }
    }

    Process { id: focusProc }
    Process { id: killProc }

    Repeater {
        model: root.windows

        delegate: Item {
            id: winItem
            required property var modelData

            implicitWidth: rowContent.implicitWidth + 12
            implicitHeight: 23

            Rectangle {
                anchors.fill: parent
                radius: 3
                color: winItem.modelData.focused ? Colors.badgeBlue : Colors.badgeGrey
                // badgeGrey and the bar's own badgeBlack background are too
                // close to tell apart - give unfocused pills a visible edge.
                border.width: winItem.modelData.focused ? 0 : 1
                border.color: Colors.badgeDim
                // Smooth focus transitions.
                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }

            RowLayout {
                id: rowContent
                anchors.centerIn: parent
                spacing: 4

                IconImage {
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14
                    // Cap the render buffer - some app icons resolve to large
                    // SVGs and Qt warns "requested buffer size is too big"
                    // when rendered without a bound.
                    implicitSize: 14
                    asynchronous: true
                    source: Quickshell.iconPath(winItem.modelData.cls.toLowerCase(), true)
                    visible: source != ""
                }

                Text {
                    text: winItem.modelData.name.length > 22 ? winItem.modelData.name.slice(0, 22) + "…" : winItem.modelData.name
                    color: winItem.modelData.focused ? Colors.badgeBlack : Colors.badgeWhite
                    font.family: "Iosevka"
                    font.pointSize: 8
                    renderType: Text.NativeRendering
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton) {
                        killProc.command = ["i3-msg", "[con_id=" + winItem.modelData.id + "] kill"];
                        killProc.running = true;
                    } else {
                        focusProc.command = ["i3-msg", "[con_id=" + winItem.modelData.id + "] focus"];
                        focusProc.running = true;
                    }
                }
            }
        }
    }
}
