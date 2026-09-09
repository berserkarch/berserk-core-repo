import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import ".."

// Draggable volume slider - click the Volume badge to open. Scroll on the
// badge still works too, but a slider is the more discoverable/precise way
// to actually set a level rather than nudge it 5% at a time.
PopupWindow {
    id: popup
    property var anchorWindow
    property var sink: Pipewire.defaultAudioSink

    anchor.window: anchorWindow
    // Position centered under the button that opened it, clamped on-screen.
    anchor.rect.x: {
        const bw = anchorWindow ? anchorWindow.width : 1920;
        return Math.max(5, Math.min(bw - implicitWidth - 5, Popups.anchorX - implicitWidth / 2));
    }
    anchor.rect.y: -implicitHeight - 6

    implicitWidth: 240
    implicitHeight: content.implicitHeight + 20
    color: "transparent"
    property bool shown: VolumeState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    PwObjectTracker {
        objects: popup.sink ? [popup.sink] : []
    }

    function setFromX(x, width) {
        if (!popup.sink || !popup.sink.audio)
            return;
        const v = Math.max(0, Math.min(1.5, x / width));
        popup.sink.audio.volume = v;
        if (v > 0)
            popup.sink.audio.muted = false;
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
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: !popup.sink || !popup.sink.audio ? "volume" : (popup.sink.audio.muted ? "muted" : Math.round(popup.sink.audio.volume * 100) + "%")
                    color: Colors.badgeOrange
                    font.family: "Iosevka"
                    font.pointSize: 10
                    font.bold: true
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 20
                    radius: 3
                    color: (popup.sink && popup.sink.audio && popup.sink.audio.muted) ? Colors.badgeRed : Colors.badgeGrey

                    Text {
                        anchors.centerIn: parent
                        text: "mute"
                        color: Colors.badgeWhite
                        font.family: "Iosevka"
                        font.pointSize: 7
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (popup.sink && popup.sink.audio)
                                popup.sink.audio.muted = !popup.sink.audio.muted;
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20

                readonly property real frac: (popup.sink && popup.sink.audio) ? Math.min(1, popup.sink.audio.volume) : 0

                Rectangle {
                    id: track
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: 3
                    color: Colors.badgeGrey

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        radius: 3
                        width: parent.width * parent.parent.parent.frac
                        color: (popup.sink && popup.sink.audio && popup.sink.audio.muted) ? Colors.badgeDim : Colors.badgeOrange
                    }
                }

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    color: Colors.badgeWhite
                    anchors.verticalCenter: track.verticalCenter
                    x: track.x + track.width * parent.frac - width / 2
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -6
                    anchors.bottomMargin: -6
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => popup.setFromX(mouse.x, width)
                    onPositionChanged: mouse => {
                        if (pressed)
                            popup.setFromX(mouse.x, width);
                    }
                    onWheel: wheel => {
                        if (!popup.sink || !popup.sink.audio)
                            return;
                        const step = 0.05;
                        const delta = wheel.angleDelta.y > 0 ? step : -step;
                        popup.sink.audio.volume = Math.max(0, Math.min(1.5, popup.sink.audio.volume + delta));
                    }
                }
            }
        }
    }
}
