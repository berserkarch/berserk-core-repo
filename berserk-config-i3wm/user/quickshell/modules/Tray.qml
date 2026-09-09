import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// Not part of dwmbar's bar.sh (dwm has no systray), but a genuinely useful
// addition - live app tray icons that quickshell can host natively.
RowLayout {
    id: root
    spacing: 8

    // The bar's PanelWindow, passed in from Bar.qml. QsMenuAnchor needs a real
    // Quickshell window as its anchor (the old Window.window returned the raw Qt
    // window, which it rejects: "only supports types derived from Item").
    // NOTE: tray menus also require `//@ pragma UseQApplication` in shell.qml,
    // or QsMenuAnchor.open() errors out ("not started in QApplication mode").
    property var barWindow

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
                anchor.window: root.barWindow
                anchor.rect: Qt.rect(trayItem.mapToItem(null, 0, 0).x, 0, trayItem.width, trayItem.height)
                // Bar is bottom-anchored: open the menu UPWARD, above the icon.
                // Without this the menu drops below the bar, off-screen, so it
                // looked like the click "did nothing".
                anchor.edges: Edges.Top
                anchor.gravity: Edges.Top
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    // Standard tray convention - each button does its own thing:
                    //   left   = the app's primary action (Activate)
                    //   middle = secondary action
                    //   right  = context menu
                    // (Some apps have a broken Activate - e.g. flameshot's hangs -
                    // but that's the app's bug; use its right-click menu instead.)
                    const item = trayItem.modelData;
                    if (mouse.button === Qt.RightButton) {
                        if (item.hasMenu)
                            menuAnchor.open();
                    } else if (mouse.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else {
                        item.activate();
                    }
                }
            }
        }
    }
}
