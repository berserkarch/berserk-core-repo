import QtQuick
import Quickshell.Io
import ".."

// Mirrors dwmbar's pkg_updates() - plain (no badge bg) icon + count, hourly check.
// Click opens a native popup listing the pending packages (no sudo/terminal -
// actually running the upgrade needs a password prompt this bar can't safely do).
Text {
    id: root
    property bool hovered: false

    color: hovered ? Colors.badgeWhite : (UpdatesState.checked && UpdatesState.count === 0) ? Colors.badgeGreen : Colors.badgeWhite
    font.family: "Iosevka"
    font.pointSize: 10
    renderType: Text.NativeRendering

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    // Active accent (top line) while the updates popup is open.
    Rectangle {
        anchors.bottom: parent.top
        anchors.bottomMargin: 1
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        radius: 1
        color: Colors.badgeGreen
        opacity: Popups.current === "updates" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: Popups.toggle("updates", root.mapToItem(null, root.width / 2, 0).x)
    }

    text: {
        if (!UpdatesState.checked) return " ...";
        return UpdatesState.count === 0 ? " Fully Updated" : " " + UpdatesState.count + " updates";
    }

    Timer {
        interval: 3600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", "timeout 20 checkupdates 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().length ? text.trim().split("\n") : [];
                UpdatesState.packages = lines;
                UpdatesState.count = lines.length;
                UpdatesState.checked = true;
            }
        }
    }
}
