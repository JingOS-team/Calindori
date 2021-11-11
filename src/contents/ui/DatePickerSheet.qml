/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Bob <pengbo·wu@jijngos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

Kirigami.OverlaySheet {
    id: datePickerSheet

    property alias selectedDate: calendarMonth.selectedDate
    property alias selectedHour: calendarMonth.selectorHour
    property alias selectedMinutes: calendarMonth.selectorMinutes
    property string headerText
    property var calendarMonth
    property var selectedHour
    property var selectedMinutes

    signal datePicked
    signal timePicked

    function initWidgetState() {
        calendarMonth.initWidgetState()
    }

    ColumnLayout {
        Layout.preferredWidth: childrenRect.width + datePickerSheet.rightPadding + datePickerSheet.leftPadding
        PickerMonthView {
            id: calendarMonth

            selectorHour : selectedHour
            selectorMinutes : selectedMinutes
            Layout.alignment: Qt.AlignHCenter
        }
    }

    footer: RowLayout {

        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: "OK"

            onClicked: {
                if (calendarMonth.isWheelViewShowing) {
                    calendarMonth.initWidgetState()
                    calendarMonth.setSelectDate()
                } else {
                    calendarMonth.setSelectTime()
                    datePickerSheet.datePicked();
                    datePickerSheet.timePicked();
                    datePickerSheet.close();
                }
            }
        }
        Controls2.ToolButton {
            text: "Cancel"

            onClicked: datePickerSheet.close()
        }
    }
}
