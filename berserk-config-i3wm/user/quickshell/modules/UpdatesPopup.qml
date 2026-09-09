import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Lists pending package updates (checkupdates output, already gathered by
// Updates.qml into UpdatesState). Actually running `pacman -Syu` needs a sudo
// password prompt, which this bar deliberately doesn't try to do - this is
// informational, opened natively instead of spawning a terminal.
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
    implicitHeight: Math.min(content.implicitHeight + 20, 400)
    color: "transparent"
    property bool shown: UpdatesState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

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

        Flickable {
            anchors.fill: parent
            anchors.margins: 10
            contentHeight: content.implicitHeight
            clip: true

            ColumnLayout {
                id: content
                width: parent.width
                spacing: 4

                Text {
                    text: UpdatesState.count === 0 ? "fully updated" : UpdatesState.count + " pending update" + (UpdatesState.count === 1 ? "" : "s")
                    color: UpdatesState.count === 0 ? Colors.badgeGreen : Colors.badgeWhite
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

                Repeater {
                    model: UpdatesState.packages

                    delegate: Text {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData
                        color: Colors.badgeBlue
                        wrapMode: Text.Wrap
                        font.family: "Iosevka"
                        font.pointSize: 8
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
