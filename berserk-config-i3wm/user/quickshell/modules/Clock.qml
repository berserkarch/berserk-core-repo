import QtQuick
import Quickshell
import ".."

// Mirrors dwmbar's clock() - icon segment (darkblue) + HH:MM segment (blue).
// Click toggles a calendar popup - something a plain xsetroot string can't offer.
Badge {
    id: root
    leftText: "󱑆"
    leftBg: Colors.badgeDarkblue
    leftFg: Colors.badgeBlack
    rightBg: Colors.badgeBlue
    rightFg: Colors.badgeBlack
    interactive: true
    active: Popups.current === "calendar"
    activeColor: Colors.badgeBlue
    onClicked: Popups.toggle("calendar", root.mapToItem(null, root.width / 2, 0).x)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    rightText: {
        const h = clock.hours.toString().padStart(2, "0");
        const m = clock.minutes.toString().padStart(2, "0");
        return h + ":" + m;
    }
}
