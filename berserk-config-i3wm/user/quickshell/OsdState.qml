pragma Singleton

import QtQuick
import Quickshell

// Shared state for the on-screen-display popup (volume/brightness feedback).
// A static bar.sh can only ever print text - this is a transient, animated
// overlay that appears on change and fades itself out.
Singleton {
    property bool visible: false
    property string icon: ""
    property real value: 0 // 0..1

    function show(icon_, value_) {
        icon = icon_;
        value = Math.max(0, Math.min(1, value_));
        visible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: OsdState.visible = false
    }
}
