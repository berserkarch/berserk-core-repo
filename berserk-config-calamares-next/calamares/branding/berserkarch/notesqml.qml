/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   Copyright 2020, Anke Boersma <demm@kaosx.us>
 *   Copyright 2020, Adriaan de Groot <groot@kde.org>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

/* Some Calamares internals are available to all QML modules.
 * They live in the io.calamares namespace (filled programmatically
 * by Calamares). One of the internals that is exposed in the sub-
 * namespace io.calamares.ui is the Branding object, which can be used
 * to retrieve strings and paths and colors. For a full list, see
 * the documentation in `Qml.h`.
 */
import io.calamares.ui 1.0

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

Item {
    // Fill parent dimensions
    anchors.fill: parent

    // Black background for the entire component
    Rectangle {
        anchors.fill: parent
        color: "#23252e"
    }

    Flickable {
        id: flick
        anchors.fill: parent

        // Hide scrollbars completely
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOff
        }
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
        }

        TextArea {
            id: intro
            anchors.fill: parent
            font.pointSize: 14
            textFormat: Text.RichText
            antialiasing: true
            activeFocusOnPress: false
            wrapMode: Text.WordWrap

            // Center text both horizontally and vertically
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: "white"
            selectionColor: "#444444"  // Dark gray selection background
            selectedTextColor: "#ffffff"  // White s

            // Transparent background since parent Item has black background
            background: Rectangle {
                color: "transparent"
            }

            text: qsTr("<h3>%1</h3>
            <p>This is a pre-beta release.</p>
            <sub>A very first one even before a pre-release!</sub>"
            ).arg(Branding.string(Branding.VersionedName))
        }
    }
}
