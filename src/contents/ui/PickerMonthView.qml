/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import org.kde.calindori 0.1

CustomMonthView {
    id: root

    signal nextMonth
    signal previousMonth

    Layout.preferredHeight: childrenRect.height
    Layout.preferredWidth: childrenRect.width

    showHeader: false
    showMonthName: true
    displayedYear: mm.year
    displayedMonthName: _appLocale.standaloneMonthName(mm.month - 1)
    daysModel: mm
    is24HourFormat: mm.is24HourFormat()

    applicationLocale: _appLocale
    selectedDate: _eventController.localSystemDateTime()
    currentDate: _eventController.localSystemDateTime()

    onNextMonth: mm.goNextMonth()
    onPreviousMonth: mm.goPreviousMonth()

    DaysOfMonthModel {
        id: mm
        year: selectedDate.getFullYear()
        month: selectedDate.getMonth() + 1
    }
}
