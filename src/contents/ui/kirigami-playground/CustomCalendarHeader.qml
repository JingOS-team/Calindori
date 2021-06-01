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
            spacing: Kirigami.Units.largeSpacing

            ParallelAnimation{
                id:parallelUp

                NumberAnimation { target: dateItem; property: "y"; from: 10; to: 0; duration: 200 }
                NumberAnimation { target: dateItem; property: "opacity";from: 0; to: 1; duration: 200 }
            }

            ParallelAnimation{
                id:parallelDown
                
                NumberAnimation { target: dateItem; property: "y"; from: -10; to: 0; duration: 200 }
                NumberAnimation { target: dateItem; property: "opacity";from: 0; to: 1; duration: 200 }
            }

            RowLayout {
                id:dateItem
                
                Controls2.Label {
                    font.pixelSize: 28
                    text: monthView.displayedMonthName
                    font.bold:true
                }

                Controls2.Label {
                    id: yearNumberLa

                    font.pixelSize: 28
                    text: yearNumber
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
        }

        Kirigami.JIconButton {
            id: addReminder

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            

            implicitWidth: 38 * appScale + 10
            implicitHeight: 38 * appScale  + 10

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
            anchors.right: addReminder.left
            anchors.rightMargin: 48 * appScale

            implicitWidth: 80 * appScale + 10
            implicitHeight: 35 * appScale + 10

            Text {
                anchors.centerIn: parent

                text: i18n("Today")
                font.pixelSize: 16
                // font.pixelSize: selectedNumber.width / 2 - 5
                color: "black"
            }

            onClicked: {
                calendarMonthView.goToday()
            }
        }
    }

    function startUpAmination() {
        parallelUp.running = true
    }

    function startDownAmination() {
        parallelDown.running = true
    }
}
