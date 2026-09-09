import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// A real interactive calendar dropdown - the kind of thing that's simply not
// possible from a dwm status string, shown off here as a click on the clock.
PopupWindow {
    id: popup
    property var anchorWindow

    anchor.window: anchorWindow
    // Position centered under the button that opened it, clamped on-screen.
    anchor.rect.x: {
        const bw = anchorWindow ? anchorWindow.width : 1920;
        return Math.max(5, Math.min(bw - implicitWidth - 5, Popups.anchorX - implicitWidth / 2));
    }
    anchor.rect.y: -implicitHeight - 6

    implicitWidth: 220
    implicitHeight: 240
    color: "transparent"
    property bool shown: CalendarState.visible
    // Stay mapped through the close animation so the exit fade can play.
    visible: shown || card.opacity > 0.01

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0-11

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate();
    }
    function firstWeekday(y, m) {
        return new Date(y, m, 1).getDay(); // 0 = Sunday
    }
    function monthName(m) {
        return ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][m];
    }
    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11;
            viewYear -= 1;
        } else {
            viewMonth -= 1;
        }
    }
    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0;
            viewYear += 1;
        } else {
            viewMonth += 1;
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 6
        color: Colors.badgeBlack
        border.color: Colors.badgeGrey
        border.width: 1
        // Slide up out of the bar on open, back down into it on close, with a fade.
        opacity: popup.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        transform: Translate {
            y: popup.shown ? 0 : 28
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "‹"
                    color: Colors.badgeWhite
                    font.family: "Iosevka"
                    font.pointSize: 12
                    renderType: Text.NativeRendering
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.prevMonth()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: popup.monthName(popup.viewMonth) + " " + popup.viewYear
                    color: Colors.badgeGreen
                    font.family: "Iosevka"
                    font.pointSize: 10
                    font.bold: true
                    renderType: Text.NativeRendering
                }

                Text {
                    text: "›"
                    color: Colors.badgeWhite
                    font.family: "Iosevka"
                    font.pointSize: 12
                    renderType: Text.NativeRendering
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.nextMonth()
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    delegate: Text {
                        Layout.preferredWidth: 26
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Colors.badgeBlue
                        font.family: "Iosevka"
                        font.pointSize: 8
                        renderType: Text.NativeRendering
                    }
                }

                Repeater {
                    model: 42
                    delegate: Item {
                        required property int index
                        readonly property int dayNum: index - popup.firstWeekday(popup.viewYear, popup.viewMonth) + 1
                        readonly property bool valid: dayNum >= 1 && dayNum <= popup.daysInMonth(popup.viewYear, popup.viewMonth)
                        readonly property bool isToday: valid && dayNum === popup.today.getDate() && popup.viewMonth === popup.today.getMonth() && popup.viewYear === popup.today.getFullYear()

                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 22

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: parent.isToday ? Colors.badgeGreen : "transparent"
                            visible: parent.valid

                            Text {
                                anchors.centerIn: parent
                                text: parent.parent.valid ? parent.parent.dayNum : ""
                                color: parent.parent.isToday ? Colors.badgeBlack : Colors.badgeWhite
                                font.family: "Iosevka"
                                font.pointSize: 9
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
