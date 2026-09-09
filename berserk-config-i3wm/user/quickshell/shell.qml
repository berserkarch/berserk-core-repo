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
