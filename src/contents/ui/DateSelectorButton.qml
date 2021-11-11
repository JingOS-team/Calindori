/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.0 as Kirigami

Controls2.ToolButton {
    id: root

    property date selectorDate
    property string selectorTitle
    property var selectorHour
    property var selectorMinutes
    property var selectorPm
    property var textColor

    signal timePicked
    signal dateChanged

    implicitWidth: Kirigami.Units.gridUnit * 5

    onClicked: {
        datePickerSheet.selectedDate = (selectorDate != undefined && !isNaN(root.selectorDate)) ? selectorDate : _eventController.localSystemDateTime()
        datePickerSheet.open()
        datePickerSheet.initWidgetState()
        datePickerSheet.selectedHour = selectorHour
        datePickerSheet.selectedMinutes = selectorMinutes
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.6
        font.pixelSize: 14 * appFontSize
        color: textColor
        text: {
            if (selectorDate != undefined && !isNaN(root.selectorDate)) {
                if (_eventController.getRegionTimeFormat() == true) {
                    var year = selectorDate.toLocaleDateString(_appLocale, "yyyy")
                    var mon = selectorDate.toLocaleDateString(_appLocale, "M")
                    var day = selectorDate.toLocaleDateString(_appLocale, "d")
                    return year + "年" + mon + "月" + day + "日"
                } else {
                    return selectorDate.toLocaleDateString(_appLocale, "MMM d,yyyy")
                }
            } else {
                return "-"
            }
        }
        onTextChanged: {
            var x;

            if (selectorDate != undefined && !isNaN(root.selectorDate)) {
                if(_eventController.getRegionTimeFormat() == true) {
                    var year = selectorDate.toLocaleDateString(_appLocale, "yyyy")
                    var mon = selectorDate.toLocaleDateString(_appLocale, "M")
                    var day = selectorDate.toLocaleDateString(_appLocale, "d")
                    x = year + "年" + mon + "月" + day + "日"
                } else {
                    x = selectorDate.toLocaleDateString(_appLocale, "MMMd,yyyy")
                }
            } else {
                x = "-"
            }
            var b = x === text
        }
    }

    DatePickerSheet {
        id: datePickerSheet

        headerText: root.selectorTitle

        onDatePicked: root.selectorDate = selectedDate

        onTimePicked: {
            root.selectorHour = selectedHour
            root.selectorMinutes = selectedMinutes
            root.timePicked(selectorHour, selectorMinutes)
        }
    }
}
