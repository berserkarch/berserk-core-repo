import QtQuick
import Quickshell.Services.UPower
import ".."

// Mirrors dwmbar's battery() - BAT|percentage pill, hidden if no battery.
Badge {
    id: root
    property var device: UPower.displayDevice

    visible: device !== null && device.isLaptopBattery
    leftText: "BAT"
    leftBg: Colors.badgeRed
    leftFg: Colors.badgeBlack
    rightText: device ? Math.round(device.percentage) + "%" : ""
    rightBg: Colors.badgeGrey
    rightFg: Colors.badgeWhite
}
