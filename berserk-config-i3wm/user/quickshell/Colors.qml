// Catppuccin Mocha palette - mirrors ~/.config/polybar/mocha.ini
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo: "#f2cdcd"
    readonly property color pink: "#f5c2e7"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color maroon: "#eba0ac"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color sky: "#89dceb"
    readonly property color sapphire: "#74c7ec"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#bac2de"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay2: "#9399b2"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay0: "#6c7086"
    readonly property color surface2: "#585b70"
    readonly property color surface1: "#45475a"
    readonly property color surface0: "#313244"
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"

    // The dwm bar's BASE background is drawn by dwm itself with
    // scheme[SchemeNorm][ColBg] = config.def.h `black` = tokyonight #1a1b26
    // (dwm.c:1096-1098), NOT the tundra black - tundra's #111827 is only used by
    // the status *segments* (bar.sh's ^b$black^). So the PanelWindow background
    // uses this, while the pills below keep tundra's black.
    readonly property color barBg: "#1a1b26"

    // EXACT colors from the theme dwm's own bar (dwmbar/bar.sh) sources:
    // `. $HOME/.config/dwmbar/bar_themes/tundra`. Verbatim from that file.
    // (~/berserk-config-dwm/configs/dwmbar/bar_themes/tundra)
    readonly property color badgeBlack: "#111827"
    readonly property color badgeGreen: "#A8C5B3"
    readonly property color badgeWhite: "#E6EDF3"
    readonly property color badgeGrey: "#303542"
    readonly property color badgeBlue: "#A5B4FC"
    readonly property color badgeRed: "#FCA5A5"
    readonly property color badgeDarkblue: "#7f92ee"
    // tundra has no dim/orange/yellow (bar.sh has no Volume/Brightness/inactive
    // text). badgeDim = a muted slate between grey and white for inactive
    // workspace numbers; orange/yellow are soft pastels in tundra's warm family
    // (its red is #FCA5A5) for the Volume/Brightness accents.
    readonly property color badgeDim: "#565f73"
    readonly property color badgeOrange: "#FCC5A5"
    readonly property color badgeYellow: "#FCE5A5"
}
