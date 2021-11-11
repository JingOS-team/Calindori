/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2

Controls2.ToolButton {
    id: root

    property string selectorTitle
    property date selectorDate
    property int selectorHour
    property int selectorMinutes
    property bool selectorPm
    property string textColor
    property bool is24HourFormat

    implicitWidth: text.width

    onClicked: {
        timePickerSheet.hours = selectorHour
        timePickerSheet.minutes = selectorMinutes
        timePickerSheet.pm = selectorPm
        timePickerSheet.open()
    }

    Text {
        id: text

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        opacity: 0.6
        font.pixelSize: 14 * appFontSize
        color: textColor

        text: {
            selectorHour = is24HourFormat ? selectorHour : (selectorHour % 12 == 0 ? 12 : selectorHour % 12)
            var hour = selectorHour / 10 < 1 ? "0" + selectorHour : selectorHour
            var minutes = selectorMinutes / 10 < 1 ? "0" + selectorMinutes : selectorMinutes
            if (is24HourFormat) {
                return hour + ":" + minutes;
            }
            var pamStr = ""
            if (_eventController.getRegionTimeFormat() == true) {
                pamStr = selectorPm ? " 下午" : " 上午"
            } else {
                pamStr = selectorPm ? " PM" : " AM"
            }
            return hour + ":" + minutes + pamStr
        }
    }

    TimePickerSheet {
        id: timePickerSheet

        headerText: root.selectorTitle
        onDatePicked: {
            root.selectorHour = timePickerSheet.hours
            root.selectorMinutes = timePickerSheet.minutes
            root.selectorPm = timePickerSheet.pm
        }
    }
}
