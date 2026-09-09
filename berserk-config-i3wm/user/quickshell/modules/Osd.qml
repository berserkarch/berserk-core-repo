import QtQuick
import Quickshell
import ".."

// Floating "toast" that appears above the bar on volume/brightness changes,
// then fades itself out. Anchored to the given window (the Bar).
PopupWindow {
    id: popup
    property var anchorWindow

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow ? anchorWindow.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: -implicitHeight - 6

    implicitWidth: 180
    implicitHeight: 46
    color: "transparent"
    property bool shown: OsdState.visible
    // Stay mapped through the fade-out so it animates away instead of snapping.
    visible: shown || card.opacity > 0.01

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 6
        color: Colors.badgeBlack
        border.color: Colors.badgeGrey
        border.width: 1

        transformOrigin: Item.Bottom
        opacity: popup.shown ? 1 : 0
        scale: popup.shown ? 1 : 0.9
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: OsdState.icon
                color: Colors.badgeWhite
                font.family: "Iosevka"
                font.pointSize: 12
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 100
                height: 6
                radius: 3
                color: Colors.badgeGrey
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    height: parent.height
                    radius: 3
                    color: Colors.badgeGreen
                    width: parent.width * OsdState.value
                    Behavior on width {
                        NumberAnimation { duration: 120 }
                    }
                }
            }
        }
    }
}
