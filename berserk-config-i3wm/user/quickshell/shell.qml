//@ pragma UseQApplication
// UseQApplication is required for SystemTray context menus (QsMenuAnchor.open()).
// Without it quickshell runs as a QGuiApplication and menu opens error out
// ("not started in QApplication mode"). Changing this pragma needs a full
// quickshell restart, not just a hot reload.

import QtQuick
import Quickshell
import Quickshell.Io
import "modules" as Modules

ShellRoot {
    IpcHandler {
        target: "bar"
        function toggle(): void {
            BarState.visible = !BarState.visible;
        }
    }

    IpcHandler {
        target: "revshell"
        function toggle(): void {
            Popups.toggle("revshell");
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Modules.Bar {}
        }
    }
}
