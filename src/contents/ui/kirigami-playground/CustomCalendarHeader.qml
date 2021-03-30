/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.calindori 0.1 as Calindori
import org.kde.kirigami 2.15 as Kirigami

ColumnLayout {
    id: customCalendarHeader

    property date headerDate
    property int yearNumber
    property var dayNumber
    property int headerTodosCount
    property int headerEventsCount
    property var applicationLocale: Qt.locale()
    property date currentDate: new Date()

    RowLayout {
        id: selectedDayHeading

        spacing: Kirigami.Units.largeSpacing

        RowLayout {

            NumberAnimation on scale {
                id: aminScale
                from: 0
                to: 1
                duration: 200
            }

            Controls2.Label {
                font.pointSize: theme.defaultFont.pointSize + 23
                text: monthView.displayedMonthName
            }

            Controls2.Label {
                id: yearNumberLa

                font.pointSize: theme.defaultFont.pointSize + 23
                text: yearNumber
            }
        }

        Rectangle {
            Layout.fillWidth: true
        }

        Kirigami.JIconButton {
            id: addReminder

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: selectedNumber.left
            anchors.rightMargin: calendarMonthView.width / 21

            implicitWidth: calendarMonthView.width / 24
            implicitHeight: calendarMonthView.width / 24

            source: "qrc:/assets/add_reminder.png"

            onClicked: {
                popupEventEditor.startDt = root.selectedDate
                popupEventEditor.initFirstData()
                popupEventEditor.open()
            }
        }

        Kirigami.JIconButton {
            id: selectedNumber

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            implicitWidth: calendarMonthView.width / 24
            implicitHeight: calendarMonthView.width / 24

            source: "qrc:/assets/today_number.png"

            Text {
                anchors.centerIn: parent

                text: currentDate.getDate()
                font.pixelSize: selectedNumber.width / 2 - 5
                color: "#99000000"
            }
            onClicked: {
                calendarMonthView.goToday()
            }
        }
    }

    function startScaleAmination() {
        aminScale.start()
    }
}
