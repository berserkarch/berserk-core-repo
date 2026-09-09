import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Layout mirrors ~/berserk-config-dwm's dwm+dwmbar bar exactly:
// left = tags, right = updates cpu battery mem wlan ip clock (in that order).
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData
    visible: BarState.visible

    anchors {
        left: true
        right: true
        bottom: true
    }

    // bh = fonts->h + 2 + vertpadbar + borderpx*2 = 17 + 2 + 11 + 4, from dwm.c/config.def.h
    implicitHeight: 34
    color: Colors.barBg

    Item {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Workspaces {}
            Taskbar {}
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Updates {}
            Volume {}
            Cpu {}
            Battery {}
            Memory {}
            Brightness {}
            Network {}
            Ip {}
            Clock {}
            Tray { barWindow: bar }
            Notifications {}
        }
    }

    // Declared before the content popups so they map on top of it.
    ScrimPopup {
        anchorWindow: bar
    }

    Osd {
        anchorWindow: bar
    }

    CalendarPopup {
        anchorWindow: bar
    }

    RevShellPopup {
        anchorWindow: bar
    }

    SysMonPopup {
        anchorWindow: bar
    }

    UpdatesPopup {
        anchorWindow: bar
    }

    NetworkPopup {
        anchorWindow: bar
    }

    VolumePopup {
        anchorWindow: bar
    }

    NotifPopup {
        anchorWindow: bar
    }
}
