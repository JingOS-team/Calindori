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
import org.kde.calindori 0.1


/**
 * Calendar component that displays:
 *  - a header with current day's information
 *  - a table (grid) with the days of the current month
 *  - a set of actions to navigate between months
 * It offers vertical swiping
 */
Rectangle {
    id: root

    property var currentdDate: _eventController.localSystemDateTime()
    property alias selectedDate: monthView.selectedDate
    property alias displayedMonthName: monthView.displayedMonthName
    property alias displayedYear: monthView.displayedYear
    property alias showHeader: monthView.showHeader
    property alias showMonthName: monthView.showMonthName
    property alias showYear: monthView.showYear
    property var cal


    /**
     * @brief When set, we take over the handling of the container items indexes programmatically
     *
     */
    property bool manualIndexing: false

    signal nextMonth
    signal previousMonth
    signal goToday

    clip: true

    onNextMonth: {
        mm.goNextMonth()
        var date = new Date(mm.year, mm.month - 1, 1,
                            root.selectedDate.getHours(),
                            root.selectedDate.getMinutes())
        calendarScheduleView.positionListViewFromMonth(date)
    }

    onPreviousMonth: {
        mm.goPreviousMonth()
        var date = new Date(mm.year, mm.month - 1, 1,
                            root.selectedDate.getHours(),
                            root.selectedDate.getMinutes())
        calendarScheduleView.positionListViewFromMonth(date)
    }

    onGoToday: {
        mm.goCurrentMonth()
        root.selectedDate = _eventController.localSystemDateTime()
        calendarScheduleView.positionListViewFromMonth(root.selectedDate)
        calendarScheduleView.positionListViewFromDate(root.selectedDate)
    }

    function popShowMessage(model, incidenceAlarmsModel) {
        monthView.popShowMessage(model, incidenceAlarmsModel)
    }

    function notifyCalendarChanged(d) {
        mm.update()
        calendarScheduleView.positionListViewFromDate(d)
    }

    DaysOfMonthIncidenceModel {
        id: mm

        year: monthView.selectedDate.getFullYear()
        month: monthView.selectedDate.getMonth() + 1
        calendar: cal
    }

    MonthView {
        id: monthView

        anchors.left: parent.left

        daysModel: mm
        applicationLocale: _appLocale
        displayedYear: mm.year
        displayedMonthName: _appLocale.standaloneMonthName(mm.month - 1)
        selectedDate: _eventController.localSystemDateTime()
        currentDate: _eventController.localSystemDateTime()
    }
}
