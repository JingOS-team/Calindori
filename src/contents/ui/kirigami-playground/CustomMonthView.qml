/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kirigami 2.3 as Kirigami
import org.kde.calindori 0.1 as Calindori

Item {
    id: customMonthView

    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: (popup.width - popup.commMargin * 2 - 80) / 7
    property date selectedDate: new Date()
    property string displayedMonthName
    property int displayedYear
    property var applicationLocale: Qt.locale()
    property alias selectorHour: timeSelectWheelView.hourNumber
    property alias selectorMinutes: timeSelectWheelView.minutesNumber
    property var daysModel
    property bool is24HourFormat
    property bool showHeader: false
    property bool showMonthName: true
    property bool showYear: true
    property bool isWheelViewShowing: false
    property bool pmSelected

    width: parent.width
    height: childrenRect.height

    ColumnLayout {

        RowLayout {
            id: selectedTimeHeading

            Layout.preferredWidth: parent.width
            anchors.top: parent.top
            anchors.topMargin: 12

            Text {
                anchors.top: parent.top
                anchors.left: parent.left

                font.pointSize: theme.defaultFont.pointSize + 2
                text: "Time"
                font.bold: true
            }

            TimeSelectWheelView {
                id: timeSelectWheelView

                anchors.right: parent.right

                hourNumber: selectorHour
                pmSelected: customMonthView.pmSelected
                is24HourFormat: customMonthView.is24HourFormat
                minutesNumber: selectorMinutes
            }
        }

        ColumnLayout {
            anchors.top: selectedTimeHeading.bottom
            anchors.topMargin: 25

            spacing: 20

            RowLayout {
                id: selectedDayHeading

                height: popup.width / 14

                RowLayout {
                    anchors.fill: parent

                    Text {
                        visible: showMonthName
                        font.pointSize: theme.defaultFont.pointSize + 2
                        text: displayedMonthName
                        font.bold: true
                    }

                    Text {
                        visible: showYear
                        font.pointSize: theme.defaultFont.pointSize + 2
                        text: displayedYear
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (isWheelViewShowing) {
                                initWidgetState()
                            } else {
                                setWheelViewVisible()
                            }
                        }
                    }
                }

                Image {
                    sourceSize.width: popup.width / 19.735
                    sourceSize.height: popup.width / 19.735

                    source: isWheelViewShowing ? "qrc:/assets/calendar_selected.png" : "qrc:/assets/calendar_normal.png"
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (isWheelViewShowing) {
                                initWidgetState()
                            } else {
                                setWheelViewVisible()
                            }
                        }
                    }
                }

                RowLayout {
                    id: rowMonthChange

                    Image {
                        sourceSize.width: popup.width / 14
                        sourceSize.height: popup.width / 14

                        source: "qrc:/assets/arrow_left.png"
                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                mm.goPreviousMonth()
                                updateWheelViewData()
                            }
                        }
                    }

                    Image {
                        sourceSize.width: popup.width / 14
                        sourceSize.height: popup.width / 14

                        source: "qrc:/assets/arrow_right.png"
                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                mm.goNextMonth()
                                updateWheelViewData()
                            }
                        }
                    }
                }
            }

            RowLayout {
                id: rwDate

                Repeater {
                    model: customMonthView.days

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: weekLabel.height

                        width: customMonthView.dayRectWidth - 10

                        opacity: 0.5

                        Controls2.Label {
                            id: weekLabel

                            anchors.centerIn: parent

                            color: Kirigami.Theme.textColor
                            text: customMonthView.applicationLocale.dayName(
                                      ((model.index
                                        + customMonthView.applicationLocale.firstDayOfWeek)
                                       % customMonthView.days),
                                      Locale.ShortFormat).substring(0, 1)
                            font.pointSize: theme.defaultFont.pointSize - 3
                        }
                    }
                }
            }

            Grid {
                id: grid

                anchors {
                    top: rwDate.bottom
                    topMargin: dayRectWidth / 3.4
                    left: parent.left
                    right: parent.right
                }

                columns: root.days
                rows: root.weeks

                Repeater {
                    model: root.daysModel

                    delegate: CustomDayDelegate {
                        currentDate: root.currentDate
                        selectedDate: root.selectedDate
                        delegateWidth: root.dayRectWidth

                        onDayClicked: {
                            popup.dateValueChanged("date", dayNumber)
                            root.selectedDate = new Date(model.yearNumber,
                                                         model.monthNumber - 1,
                                                         model.dayNumber,
                                                         root.selectedDate.getHours(),
                                                         root.selectedDate.getMinutes(), 0)
                            popup.startDt = new Date(model.yearNumber,
                                                     model.monthNumber - 1,
                                                     model.dayNumber,
                                                     root.selectedDate.getHours(),
                                                     root.selectedDate.getMinutes(), 0)
                        }
                    }
                }
            }

            DateSelectWheelView {
                id: dateSelectWheelView

                visible: isWheelViewShowing
                monthNumber: mm.month - 1
                yearNumber: mm.year
            }

            Rectangle {
                Layout.fillWidth: true

                height: popup.width / 16

                Kirigami.Separator {
                    anchors.bottomMargin: 25
                    anchors.bottom: parent.bottom

                    width: parent.width

                    color: "#767680"
                    opacity: 0.12
                }
            }
        }
    }

    function initWidgetState() {
        rowMonthChange.visible = true
        rwDate.visible = true
        grid.visible = true
        dateSelectWheelView.visible = false
        isWheelViewShowing = false
    }

    function setWheelViewVisible() {
        rowMonthChange.visible = false
        rwDate.visible = false
        grid.visible = false
        dateSelectWheelView.visible = true
        isWheelViewShowing = true
    }

    function setSelectTime() {
        root.selectorHour = timeSelectWheelView.hourNumber
        root.selectorMinutes = timeSelectWheelView.minutesNumber
    }

    function setSelectDate() {
        mm.setYear(dateSelectWheelView.yearNumber)
        mm.setMonth(dateSelectWheelView.monthNumber + 1)
    }

    function updateWheelViewData() {
        dateSelectWheelView.monthNumber = mm.month - 1
        dateSelectWheelView.yearNumber = mm.year
    }
}
