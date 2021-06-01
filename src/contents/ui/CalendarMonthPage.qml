/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.2

Kirigami.Page {
    id: root

    property alias selectedDate: calendarMonthView.selectedDate

    /**
     * @brief The active calendar, which is the host of todos, events, etc.
     *
     */
    property var calendar

    /**
     *  @brief The index of the last contextual action triggered
     *
     */
    property int latestContextualAction: -1

    /**
     *  @brief When set to a valid contextual action index, as soon as the page is loaded the corresponding contextual action is also opened
     *
     */
    property int loadWithAction: -1

    /**
    * @brief Emitted when the hosted SwipeView index is set to the first or the last container item
    *
    */
    signal pageEnd(var lastDate, var lastActionIndex)

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    padding: 0

    background: Item {}

    Rectangle {
        id: rowMain

        anchors.fill: parent
        anchors.top: parent.top

        signal setListViewItem(int index)
        signal dayClickFindIndex(date d)
        signal scheduleListViewClicked(var model, var incidenceAlarmsModel,var jx)
        signal eventAddCompleted
        signal eventCancelCompleted

        color : "#FFE8EFFF"

        CalendarMonthView {
            id: calendarMonthView

            anchors.left: parent.left

            width: parent.width * 0.7
            height: parent.height

            cal: root.calendar
            showHeader: true
            showMonthName: false
            showYear: false
        }

        CalendarScheduleView {
            id: calendarScheduleView

            anchors.left: calendarMonthView.right

            width: parent.width * 0.3
            height: parent.height
        }

        onDayClickFindIndex: {
            calendarScheduleView.positionListViewFromDate(d)
        }

        onSetListViewItem: {
            calendarScheduleView.setCurrentListViewIndex(index)
        }

        onScheduleListViewClicked: {
            calendarMonthView.popShowMessage(model, incidenceAlarmsModel,jx)
        }

        onEventAddCompleted: {
            calendarScheduleView.refreshListView()
        }

        onEventCancelCompleted: {
            calendarScheduleView.cancelHighLight()
        }
    }
}
