import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// Not part of dwmbar's bar.sh (dwm has no systray), but a genuinely useful
// addition - live app tray icons that quickshell can host natively.
RowLayout {
    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property SystemTrayItem modelData

            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.fill: parent
                asynchronous: true
                source: trayItem.modelData.icon
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.window: Window.window
                anchor.rect: Qt.rect(trayItem.mapToItem(null, 0, 0).x, 0, trayItem.width, trayItem.height)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayItem.modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                        menuAnchor.open();
                    }
                }
            }
        }
    }
}
