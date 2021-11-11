/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami


/**
 * Month Day Delegate
 *
 * Controls the display of each day of a months' grid
 *
 * Expects a model that provides:
 *
 * 1. dayNumber
 * 2. monthNumber
 * 3. yearNumber
 */
Item {
    id: dayDelegate

    property var lableText
    property var pos1
    property date currentDate
    property int delegateWidth
    property int delegateHeigh
    property date selectedDate
    property bool highlight: (model.yearNumber == selectedDate.getFullYear())
                             && (model.monthNumber == selectedDate.getMonth(
                                     ) + 1)
                             && (model.dayNumber == root.selectedDate.getDate())
    property int currentYearNumber: model.yearNumber

    signal dayClicked
    signal nextMonthChanged
    signal previousMonthChanged

    width: childrenRect.width
    height: childrenRect.height

    Rectangle {
        width: dayDelegate.delegateWidth
        height: delegateHeigh

        color: settingMinorBackground

        Item {
            id: dayButton

            anchors.fill: parent
            enabled: isCurrentMonth

            Rectangle {
                id: bgRect

                anchors.centerIn: parent
                anchors.top: parent.top

                width: dayDelegate.width / 2
                height: width

                visible: isCurrentMonth && highlight ? true : false
                color: "#E95B4E"
                radius: width / 3.36
            }

            Text {
                id: dayNum

                anchors.centerIn: parent

                visible: isCurrentMonth
                opacity: highlight ? 1 : (model.index % 7 === 0 | model.index
                                          % 7 === 6 | !isCurrentMonth) ? 0.3 : 1
                text: model.dayNumber
                color: highlight ? "white" : (isToday ? "red" : majorForeground)
                font.pixelSize: highlight ? 22 * appFontSize : 19 * appFontSize
            }

            Rectangle {
                anchors {
                    top: highlight ? bgRect.bottom : dayNum.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                width: dayDelegate.width / 13.6
                height: width

                radius: width / 2
                color: "#E95B4E"
                visible: isCurrentMonth && model.incidenceCount > 0
            }
        }

        MouseArea {
            anchors.fill: parent

            preventStealing: true
            hoverEnabled: true

            onPressed: {
                pos1 = mouseY
            }

            onWheel: {
                if (wheel.angleDelta.y >= 100) {
                    dayDelegate.previousMonthChanged()
                    calendarMonthView.previousMonth()
                } else if (wheel.angleDelta.y <= -100) {
                    dayDelegate.nextMonthChanged()
                    calendarMonthView.nextMonth()
                }
            }

            onReleased: {
                if (mouseY - pos1 > 100) {
                    dayDelegate.previousMonthChanged()
                    calendarMonthView.previousMonth()
                } else if (mouseY - pos1 < -100) {
                    dayDelegate.nextMonthChanged()
                    calendarMonthView.nextMonth()
                } else {
                    if (isCurrentMonth)
                        dayDelegate.dayClicked()
                }
            }
        }

       
    
    }
    
}
