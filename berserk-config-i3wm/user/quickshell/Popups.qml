pragma Singleton

import Quickshell

// Central manager for the bar's click-popups. Tracks which popup is open
// (`current`) and the x of the button that opened it (`anchorX`, in bar/screen
// coordinates) so the popup can position itself under that button and the
// button can show an "active" highlight. Only one popup is open at a time.
Singleton {
    property string current: ""   // name of the open popup ("" = none)
    property real anchorX: 960     // center-x of the opening button (bar coords)

    // True while any click-popup is open - drives the click-outside scrim.
    readonly property bool anyOpen: CalendarState.visible
        || SysMonState.visible
        || UpdatesState.visible
        || NetworkPopupState.visible
        || VolumeState.visible
        || RevShellState.visible
        || NotifState.visible

    function close(except) {
        if (except !== "calendar") CalendarState.visible = false;
        if (except !== "sysmon") SysMonState.visible = false;
        if (except !== "updates") UpdatesState.visible = false;
        if (except !== "network") NetworkPopupState.visible = false;
        if (except !== "volume") VolumeState.visible = false;
        if (except !== "revshell") RevShellState.visible = false;
        if (except !== "notif") NotifState.visible = false;
        current = "";
    }

    function stateFor(name) {
        switch (name) {
        case "calendar": return CalendarState;
        case "sysmon": return SysMonState;
        case "updates": return UpdatesState;
        case "network": return NetworkPopupState;
        case "volume": return VolumeState;
        case "revshell": return RevShellState;
        case "notif": return NotifState;
        }
        return null;
    }

    // Toggle a popup: if already open, close it; otherwise close every other
    // popup and open this one. `x` is the opening button's center-x (bar coords).
    function toggle(name, x) {
        const st = stateFor(name);
        if (!st)
            return;
        if (st.visible) {
            st.visible = false;
            current = "";
        } else {
            close(name);
            if (x !== undefined) anchorX = x;
            current = name;
            st.visible = true;
        }
    }

    // Open (never toggle-closed) a popup, closing the others. Used by SysMon,
    // where CPU and Memory share one popup but must be able to switch its mode
    // without the second click closing it.
    function open(name, x) {
        close(name);
        if (x !== undefined) anchorX = x;
        current = name;
        stateFor(name).visible = true;
    }
}
