import QtQuick
import ".."

// Two-segment "pill" module used by dwmbar's bar.sh (e.g. "CPU" | "1.22").
// Set only leftText for a single-segment badge (e.g. memory).
// Adds hover/press feedback and click/wheel signals - things a static xsetroot
// status string can never do.
Item {
    id: root
    implicitWidth: pillRow.implicitWidth
    implicitHeight: pillRow.implicitHeight

    property string leftText: ""
    property color leftBg: Colors.badgeBlack
    property color leftFg: Colors.badgeWhite
    property string rightText: ""
    property color rightBg: "transparent"
    property color rightFg: Colors.badgeWhite
    readonly property bool hasRight: rightText.length > 0
    property bool interactive: false
    property bool hovered: false
    // Set true while this badge's popup is open - draws a top accent line so it's
    // clear which button spawned the popup. Its color follows the badge accent.
    property bool active: false
    property color activeColor: Colors.badgeBlue

    signal clicked(var mouse)
    signal wheel(var wheel)

    function lighten(c) {
        return Qt.lighter(c, 1.35);
    }

    // "This popup came from here" indicator - a thin accent line in the gap
    // just above the pill (on the dark bar, so it shows regardless of pill color).
    Rectangle {
        anchors.bottom: pillRow.top
        anchors.bottomMargin: 2
        anchors.left: pillRow.left
        anchors.right: pillRow.right
        height: 2
        radius: 1
        color: root.activeColor
        opacity: root.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Row {
        id: pillRow
        spacing: 0

        Rectangle {
            color: root.hovered && root.interactive ? root.lighten(root.leftBg) : root.leftBg
            height: 23
            width: leftLabel.implicitWidth + 17

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                id: leftLabel
                anchors.centerIn: parent
                text: root.leftText
                color: root.leftFg
                font.family: "Iosevka"
                font.pointSize: 10
                font.bold: true
                renderType: Text.NativeRendering
            }
        }

        Rectangle {
            visible: root.hasRight
            color: (root.hovered && root.interactive && root.rightBg !== "transparent") ? root.lighten(root.rightBg) : root.rightBg
            height: 23
            width: rightLabel.implicitWidth + 17

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                id: rightLabel
                anchors.centerIn: parent
                text: root.rightText
                color: root.rightFg
                font.family: "Iosevka"
                font.pointSize: 10
                renderType: Text.NativeRendering
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.wheel(wheel)
    }
}
