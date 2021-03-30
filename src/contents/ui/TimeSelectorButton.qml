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

    onClicked: {
        timePickerSheet.hours = selectorHour
        timePickerSheet.minutes = selectorMinutes
        timePickerSheet.pm = selectorPm
        timePickerSheet.open()
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        opacity: 0.6
        font.pointSize: theme.defaultFont.pointSize + 2
        color: textColor

        text: {
            if (!isNaN(selectorDate)) {
                var textDt = selectorDate
                textDt.setHours(
                            is24HourFormat ? selectorHour : selectorHour % 12)
                textDt.setMinutes(selectorMinutes)
                textDt.setSeconds(0)

                return textDt.toLocaleTimeString(
                            _appLocale,
                            "HH:mm") + (!is24HourFormat ? (selectorPm ? " PM" : " AM") : "")
            } else {
                return "00:00"
            }
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
