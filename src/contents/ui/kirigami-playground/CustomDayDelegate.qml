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
        id: cell

        width: dayDelegate.delegateWidth
        height: dayDelegate.delegateWidth / 1.25

        Item {
            id: dayButton

            anchors.fill: parent
            enabled: isCurrentMonth

            Rectangle {
                anchors.centerIn: parent
                anchors.top: parent.top

                width: dayDelegate.width / 1.3
                height: dayDelegate.width / 1.3

                visible: isCurrentMonth && highlight ? true : false
                color: "#E95B4E"
                radius: 9
            }

            Text {
                anchors.centerIn: parent

                opacity: isCurrentMonth ? 1 : 0.4

                visible: isCurrentMonth
                text: model.dayNumber
                color: highlight ? "white" : (isToday ? "red" : "black")
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent

                onClicked: dayDelegate.dayClicked()
            }
        }

        WheelHandler {
            target: dayDelegate
            enabled: true
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            property var contentX: 0
            property bool isReduce: false

            onActiveChanged: {
                popup.isTimeDataChanged = true
                dayDelegate.isWheeling = active
            }

            onWheel: {
                var wX = event.angleDelta.x
                if (wX != 0 & Math.abs(contentX) < Math.abs(wX)) {
                    contentX = wX
                } else if (wX != 0 & Math.abs(contentX) > Math.abs(wX)) {
                    isReduce = true
                }
                if (isReduce & wX == 0) {
                    if (contentX != 0) {
                        var count = parseInt(contentX / 250)
                        if (Math.abs(contentX) < 300) {
                            count = 1
                        }
                        isReduce = false
                        contentX = 0

                        if (count >= 1) {
                            mm.goNextMonth()
                            dayDelegate.isWheeling = false
                        } else if (count <= -1) {
                            mm.goPreviousMonth()
                            dayDelegate.isWheeling = false
                        }
                    }
                }
            }
        }

        MouseArea {
            property int validDistance: 120
            property bool isAdd: false
            property var contentY: 0
            property bool isReduce: false

            anchors.fill: parent

            hoverEnabled: true
            propagateComposedEvents: true

            onPressed: {
                popup.isTimeDataChanged = true
                pos1 = mouseX
            }

            onEntered: {
                cell.focus = true
                cell.forceActiveFocus()
                preventStealing = true
            }

            onExited: {
                cell.focus = false
                preventStealing = false
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

        Keys.onPressed: {
            if (event.key == Qt.Key_Left) {
                popup.isTimeDataChanged = true
                mm.goPreviousMonth()
                event.accepted = true
            } else if (event.key == Qt.Key_Right) {
                popup.isTimeDataChanged = true
                mm.goNextMonth()
                event.accepted = true
            }
        }
    }
}
