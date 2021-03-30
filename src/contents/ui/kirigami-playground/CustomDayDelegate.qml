/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: dayDelegate

    property var lableText
    property var pos1
    property date currentDate
    property int delegateWidth
    property date selectedDate
    property bool highlight: (model.yearNumber == selectedDate.getFullYear())
                             && (model.monthNumber == selectedDate.getMonth(
                                     ) + 1)
                             && (model.dayNumber == root.selectedDate.getDate())
    property int testValue: -1
    property bool isWheeling: false

    signal dayClicked

    width: childrenRect.width
    height: childrenRect.height

    Item {
        width: dayDelegate.delegateWidth
        height: dayDelegate.delegateWidth / 1.25

        Controls2.ToolButton {
            id: dayButton

            anchors.fill: parent
            enabled: isCurrentMonth

            Rectangle {
                anchors.centerIn: parent
                anchors.top: parent.top

                width: dayDelegate.width / 1.3
                height: dayDelegate.width / 1.3 - 3

                visible: isCurrentMonth && highlight ? true : false
                color: "#E95B4E"
                radius: 12
            }

            Text {
                anchors.centerIn: parent

                opacity: isCurrentMonth ? 1 : 0.4

                visible: isCurrentMonth
                text: model.dayNumber
                color: highlight ? "white" : (isToday ? "red" : "black")
                font.pointSize: theme.defaultFont.pointSize + 2
            }

            onClicked: dayDelegate.dayClicked()
        }

        WheelHandler {
            target: dayDelegate
            enabled: true
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onActiveChanged: {
                dayDelegate.isWheeling = active
            }

            onWheel: {
                if (dayDelegate.isWheeling) {
                    if (event.angleDelta.x > 120) {
                        mm.goNextMonth()

                        dayDelegate.isWheeling = false
                    } else if (event.angleDelta.x < -120) {
                        mm.goPreviousMonth()
                        dayDelegate.isWheeling = false
                    }
                }
            }
        }

        MouseArea {
            property int validDistance: 120
            property bool isAdd: false

            anchors.fill: parent

            hoverEnabled: true

            onPressed: {
                pos1 = mouseX
            }

            onReleased: {
                if (mouseX - pos1 < -50) {
                    mm.goNextMonth()
                    root.selectedDate = new Date(mm.year, mm.month - 1, 1,
                                                 root.selectedDate.getHours(),
                                                 root.selectedDate.getMinutes())
                } else if (mouseX - pos1 > 50) {
                    mm.goPreviousMonth()
                    root.selectedDate = new Date(mm.year, mm.month - 1, 1,
                                                 root.selectedDate.getHours(),
                                                 root.selectedDate.getMinutes())
                } else {
                    if (isCurrentMonth)
                        dayDelegate.dayClicked()
                }
            }
        }
    }
}
