pragma Singleton

import Quickshell

Singleton {
    property bool visible: false
    property int count: 0      // dunst history count (badge)
    property var items: []     // parsed history entries for the popup
}
