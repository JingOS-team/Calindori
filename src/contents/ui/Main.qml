/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.15 as Kirigami
import org.kde.calindori 0.1 as Calindori
import jingos.display 1.0
import org.kde.plasma.private.digitalclock 1.0 as DC

Kirigami.ApplicationWindow {
    id: mainWindow

    width: mainWindow.screen.width
    height: mainWindow.screen.height

    property real appScale: JDisplay.dp(1.0)
    property real appFontSize: JDisplay.sp(1.0)

    property var majorForeground: Kirigami.JTheme.majorForeground
    property var minorForeground: Kirigami.JTheme.minorForeground
    property var settingMinorBackground: Kirigami.JTheme.settingMinorBackground
    property var cardBackground: Kirigami.JTheme.cardBackground
    property var highlightColor: Kirigami.JTheme.highlightColor
    property var dividerForeground: Kirigami.JTheme.dividerForeground
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"

    DC.TimeZoneFilterProxy {
        id: timezoneProxy
    }

    pageStack {
        initialPage: CalendarMonthPage {
            calendar: localCalendar

            onPageEnd: switchToMonthPage(lastDate, lastActionIndex)
        }
        defaultColumnWidth: Kirigami.Units.gridUnit * 60
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar
    }
}
