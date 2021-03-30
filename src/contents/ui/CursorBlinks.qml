/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import QtQuick.Controls 2.1 as Controls
import org.kde.kirigami 2.7 as Kirigami
import org.kde.kirigami 2.15

Rectangle {
    id: cursorBg

    property var targetView: parent

    anchors.verticalCenter: parent.verticalCenter

    width: Kirigami.Units.devicePixelRatio * 2
    height: parent.height / 2

    color: "#FF3C4BE8"

    Connections {
        target: targetView
        onFocusChanged: cursorBg.visible = focus
    }

    Timer {
        id: cursorTimer

        interval: 700
        repeat: true
        running: targetView.focus

        onTriggered: {
            if (cursorTimer.running) {
                cursorBg.visible = !cursorBg.visible
            } else {
                cursorBg.visible = false
            }
        }
    }
}
