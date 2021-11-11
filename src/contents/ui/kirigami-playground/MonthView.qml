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

/*
 * Component that displays the days of a month as a 6x7 table
 *
 * Optionally, it may display:
 * - a header on top of the table showing the current date
 * - inside each day cell, a small indicator in case that tasks
 *   exist for this day
 */
Item {
    id: root

    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: calendarMonthView.width / 7
    property date selectedDate: new Date()
    property string displayedMonthName
    property var displayedYear
    property var applicationLocale: Qt.locale()

    /**
     * A model that provides:
     *
     * 1. dayNumber
     * 2. monthNumber
     * 3. yearNumber
     */
    property var daysModel
    property bool showHeader: false
    property bool showMonthName: true
    property bool showYear: true

    width: mainWindow.width * 0.7

    function popShowMessage(model, incidenceAlarmsModel, jx) {
        popupEventEditor.rightBarY = jx.y - mainWindow.height / 14.8
        popupEventEditor.startDt = model.dtstart
        popupEventEditor.uid = model.uid
        popupEventEditor.incidenceData = model
        popupEventEditor.incidenceAlarmsModel = incidenceAlarmsModel
        popupEventEditor.loadNewDate()
        popupEventEditor.open()
    }

    function monthChanged() {//calendarHeader.startScaleAmination()
    }

    Component.onCompleted: {
        //rowMain.dayClickFindIndex(root.selectedDate)
        timer.running = true
    }

    Timer {
        id: timer
        interval: 100
        repeat: false
        running: false

        onTriggered: {
            rowMain.dayClickFindIndex(root.selectedDate)
        }
    }

    ColumnLayout {
        id: cView

        width: root.width
        Layout.fillWidth: true


        /**
         * Optional header on top of the table
         * that displays the current date and
         * the amount of the day's tasks
         */
        CustomCalendarHeader {
            id: calendarHeader

            Layout.topMargin: calendarMonthView.width / 16.75
            Layout.rightMargin: calendarMonthView.width / 21.6
            Layout.leftMargin: calendarMonthView.width / 26.8
            Layout.bottomMargin: calendarMonthView.width / 26.8

            yearNumber: displayedYear
        }


        /**
         * Styled week day names of the days' calendar grid
         * E.g.
         * Mon Tue Wed ...
         */
        RowLayout {
            id: rwDate

            Layout.fillWidth: true

            spacing: 0

            Repeater {
                model: root.days

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: weekLabel.height

                    width: root.dayRectWidth

                    Controls2.Label {
                        id: weekLabel

                        anchors.centerIn: parent

                        color: majorForeground
                        text: root.applicationLocale.dayName(
                                       ((model.index + root.applicationLocale.firstDayOfWeek)
                                        % root.days), Locale.ShortFormat)
                        font.pixelSize: 14 * appFontSize
                        opacity: model.index % 7 === 0 | model.index % 7 === 6 ? 0.3 : 1
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: (Qt.AlignHCenter | Qt.AlignBottom)

            /**
         * Grid that displays the days of a month (normally 6x7)
         */
            Grid {
                id: grid

                //Layout.fillWidth: true
                //anchors.top: rwDate.bottom
                //Layout.alignment: (Qt.AlignHCenter | Qt.AlignBottom)
                columns: root.days
                rows: root.weeks

                add: Transition {
                    id: amin

                    NumberAnimation {
                        target: grid
                        property: "y"
                        from: 10
                        to: 0
                        duration: 200
                    }

                    NumberAnimation {
                        target: grid
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }
                }

                Repeater {
                    id: repeater

                    model: root.daysModel

                    delegate: DayDelegate {
                        currentDate: root.currentDate
                        delegateWidth: root.dayRectWidth
                        delegateHeigh: (mainWindow.height - calendarHeader.height
                                        - rwDate.height) / 7
                        selectedDate: root.selectedDate

                        onNextMonthChanged: {
                            calendarHeader.startUpAmination()
                        }
                        
                        onPreviousMonthChanged: {
                            calendarHeader.startDownAmination()
                        }

                        onDayClicked: {
                            root.selectedDate = new Date(model.yearNumber,
                                                         model.monthNumber - 1,
                                                         model.dayNumber,
                                                         root.selectedDate.getHours(
                                                             ),
                                                         root.selectedDate.getMinutes(
                                                             ), 0)
                            rowMain.dayClickFindIndex(
                                        new Date(model.yearNumber,
                                                 model.monthNumber - 1,
                                                 model.dayNumber))
                        }
                    }
                }

                Component.onCompleted: {
                    grid.focus = true
                    grid.forceActiveFocus()
                }

                Keys.onPressed: {
                    if (event.key == Qt.Key_Left) {
                        calendarHeader.startDownAmination()
                        calendarMonthView.previousMonth()
                        event.accepted = true
                    } else if (event.key == Qt.Key_Right) {
                        calendarHeader.startUpAmination()
                        calendarMonthView.nextMonth()
                        event.accepted = true
                    } else if (event.key == Qt.Key_Up) {
                        calendarHeader.startDownAmination()
                        calendarMonthView.previousMonth()
                        event.accepted = true
                    } else if (event.key == Qt.Key_Down) {
                        calendarHeader.startUpAmination()
                        calendarMonthView.nextMonth()
                        event.accepted = true
                    }
                }
            }
        }
    }

    PopupEventEditor {
        id: popupEventEditor

        sourceView: cView
    }
}
