import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

// Notification bell - shows dunst's history count; click opens a history popup.
// Not part of dwmbar (a static string can't host a clickable history view).
Item {
    id: root
    implicitWidth: rowContent.implicitWidth
    implicitHeight: rowContent.implicitHeight
    property bool hovered: false

    // Poll dunst's history count for the badge (dunst has no push signal here).
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: countProc.running = true
    }

    Process {
        id: countProc
        command: ["sh", "-c", "dunstctl count history 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: NotifState.count = parseInt(text.trim()) || 0
        }
    }

    RowLayout {
        id: rowContent
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: ""
            color: root.hovered ? Colors.badgeWhite
                 : NotifState.count > 0 ? Colors.badgeBlue
                 : Colors.badgeDim
            font.family: "Iosevka"
            font.pointSize: 11
            renderType: Text.NativeRendering
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            visible: NotifState.count > 0
            text: NotifState.count
            color: Colors.badgeBlue
            font.family: "Iosevka"
            font.pointSize: 9
            renderType: Text.NativeRendering
        }
    }

    // Active accent (top line) while the notification history popup is open.
    Rectangle {
        anchors.bottom: rowContent.top
        anchors.bottomMargin: 1
        anchors.left: rowContent.left
        anchors.right: rowContent.right
        height: 2
        radius: 1
        color: Colors.badgeBlue
        opacity: Popups.current === "notif" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: Popups.toggle("notif", root.mapToItem(null, root.width / 2, 0).x)
    }
}
