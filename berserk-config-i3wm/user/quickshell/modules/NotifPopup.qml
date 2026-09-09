import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

// Notification history - lists dunst's stored past notifications
// (`dunstctl history`), newest first. Header shows the count + a clear button.
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

    implicitWidth: 400
    implicitHeight: Math.min(content.implicitHeight + 20, 460)
    color: "transparent"
    property bool shown: NotifState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    // (Re)load history whenever the popup is opened.
    onVisibleChanged: if (visible) histProc.running = true

    Process {
        id: histProc
        command: ["sh", "-c", "dunstctl history 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    const raw = (j.data && j.data[0]) ? j.data[0] : [];
                    const out = raw.map(e => ({
                        summary: (e.summary && e.summary.data) || "",
                        body: (e.body && e.body.data) || "",
                        app: (e.appname && e.appname.data) || ""
                    }));
                    out.reverse(); // newest first
                    NotifState.items = out;
                } catch (e) {
                    NotifState.items = [];
                }
            }
        }
    }

    Process { id: clearProc }

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

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "notifications"
                    color: Colors.badgeBlue
                    font.family: "Iosevka"
                    font.pointSize: 9
                    font.bold: true
                    renderType: Text.NativeRendering
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: NotifState.items.length + " in history"
                    color: Colors.badgeDim
                    font.family: "Iosevka"
                    font.pointSize: 8
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 18
                    radius: 3
                    color: clearMa.containsMouse ? Colors.badgeRed : Colors.badgeGrey
                    Text {
                        anchors.centerIn: parent
                        text: "clear"
                        color: Colors.badgeWhite
                        font.family: "Iosevka"
                        font.pointSize: 7
                        renderType: Text.NativeRendering
                    }
                    MouseArea {
                        id: clearMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clearProc.command = ["dunstctl", "history-clear"];
                            clearProc.running = true;
                            NotifState.items = [];
                            NotifState.count = 0;
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.badgeGrey }

            Text {
                visible: NotifState.items.length === 0
                text: "no notifications"
                color: Colors.badgeDim
                font.family: "Iosevka"
                font.pointSize: 9
                renderType: Text.NativeRendering
            }

            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(listCol.implicitHeight, 380)
                contentHeight: listCol.implicitHeight
                clip: true
                visible: NotifState.items.length > 0

                ColumnLayout {
                    id: listCol
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: NotifState.items

                        delegate: Rectangle {
                            id: entry
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: itemCol.implicitHeight + 12
                            radius: 3
                            color: Colors.badgeGrey

                            ColumnLayout {
                                id: itemCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 8
                                spacing: 1

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: entry.modelData.summary
                                        color: Colors.badgeWhite
                                        font.family: "Iosevka"
                                        font.pointSize: 8
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        renderType: Text.NativeRendering
                                    }
                                    Text {
                                        text: entry.modelData.app
                                        color: Colors.badgeDim
                                        font.family: "Iosevka"
                                        font.pointSize: 7
                                        renderType: Text.NativeRendering
                                    }
                                }

                                Text {
                                    visible: text.length > 0
                                    text: entry.modelData.body
                                    color: Colors.badgeWhite
                                    opacity: 0.85
                                    font.family: "Iosevka"
                                    font.pointSize: 8
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
