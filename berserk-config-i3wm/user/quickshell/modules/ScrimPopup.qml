import QtQuick
import Quickshell
import ".."

// Click-outside-to-dismiss catcher. Quickshell's PopupWindow has no native
// outside-click dismissal. A PanelWindow scrim maps below app windows on
// i3/X11; a PopupWindow that maps on-demand ends up ABOVE the content popups
// (newer window). So this scrim stays permanently mapped - the content popups,
// which map later when opened, then stack above it - and its input region is
// toggled via `mask`: full (catches clicks) only while a popup is open, empty
// (clicks pass straight through to the desktop) when idle.
PopupWindow {
    id: scrim
    property var anchorWindow

    anchor.window: anchorWindow
    anchor.rect.x: 0
    anchor.rect.y: anchorWindow ? -(anchorWindow.screen.height - anchorWindow.height) : 0

    implicitWidth: anchorWindow ? anchorWindow.screen.width : 1
    implicitHeight: anchorWindow ? anchorWindow.screen.height - anchorWindow.height : 1
    color: "transparent"
    visible: true

    // Empty region while idle -> whole window is click-through. Full-area
    // region while a popup is open -> window catches clicks.
    mask: Popups.anyOpen ? activeMask : idleMask
    Item { id: fullArea; anchors.fill: parent }
    Region { id: activeMask; item: fullArea }
    Region { id: idleMask }

    MouseArea {
        anchors.fill: parent
        enabled: Popups.anyOpen
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: Popups.close("")
    }
}
