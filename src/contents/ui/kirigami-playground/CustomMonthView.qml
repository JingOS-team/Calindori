/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Bob <pengbo·wu@jingos.com>
 *
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kirigami 2.15 as Kirigami
import org.kde.calindori 0.1 as Calindori

Item {
    id: customMonthView

    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: (popup.width - popup.commMargin * 2) / 7
    property date selectedDate: new Date()
    property string displayedMonthName
    property int displayedYear
    property var applicationLocale: Qt.locale()
    property alias selectorHour: timeSelectWheelView.hourNumber
    property alias selectorMinutes: timeSelectWheelView.minutesNumber
    property var daysModel
    property bool is24HourFormat: timezoneProxy.isSystem24HourFormat
    property bool showHeader: false
    property bool showMonthName: true
    property bool showYear: true
    property bool isWheelViewShowing: false
    property bool pmSelected

    width: parent.width
    height: childrenRect.height

    ParallelAnimation{
        id: parallelLeft

        NumberAnimation { target: monthHeader; property: "x"; from: 10; to: 0; duration: 200 }
        NumberAnimation { target: monthHeader; property: "opacity";from: 0; to: 1; duration: 200 }
    }

    ParallelAnimation{
        id: parallelRight

        NumberAnimation { target: monthHeader; property: "x"; from: -10; to: 0; duration: 200 }
        NumberAnimation { target: monthHeader; property: "opacity";from: 0; to: 1; duration: 200 }
    }


    ColumnLayout {

        RowLayout {
            id: selectedTimeHeading

            Layout.preferredWidth: parent.width
            anchors.top: parent.top
            anchors.topMargin: 12 * appScale

            TimeSelectWheelView {
                id: timeSelectWheelView

                anchors.left: parent.left

                //hourNumber: selectorHour
                pmSelected: customMonthView.pmSelected
                is24HourFormat: customMonthView.is24HourFormat
                //minutesNumber: selectorMinutes
            }
        }

        ColumnLayout {
            anchors.top: selectedTimeHeading.bottom
            anchors.topMargin: 25 * appScale

            spacing: 12 * appScale

            Item {
                id: selectedDayHeading

                height: popup.width / 14
                width: popup.width - (popup.commMargin * 2)
                //Layout.preferredWidth: parent.width
                Kirigami.Icon {
                    id:swith_img

                    width: 22 * appScale
                    height: 22 * appScale

                    Layout.alignment: Qt.AlignLeft
                    anchors.verticalCenter:parent.verticalCenter

                    source: isWheelViewShowing ? "qrc:/assets/calendar_selected.png" : "qrc:/assets/calendar_switch.png"
                    color: isDarkTheme ? majorForeground : transparent

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

                Item{
                    id: monthHeader

                    anchors.centerIn: parent
                    width: childrenRect.width
                    height:22 * appScale
                    RowLayout {
                        anchors.verticalCenter:parent.verticalCenter
                        layoutDirection: !_eventController.getRegionTimeFormat() ? Qt.LeftToRight : Qt.RightToLeft
                        Text {
                            id: monthText

                            visible: showMonthName
                            font.pixelSize: 14 * appFontSize
                            text: displayedMonthName
                            font.bold: true
                            color: majorForeground
                        }

                        Text {
                            visible: showYear
                            font.pixelSize: 14 * appFontSize
                            text: _eventController.getRegionTimeFormat() ? displayedYear + "年" : displayedYear
                            font.bold: true
                            color: majorForeground
                        }
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

                Row {
                    id: rowMonthChange
                    width:childrenRect.width
                    height:22 * appScale
                    anchors.right:parent.right

                    Kirigami.Icon {
                        anchors.verticalCenter:parent.verticalCenter

                        width: 22 * appScale
                        height: 22 * appScale

                        source: "qrc:/assets/arrow_left.png"
                        color: isDarkTheme ? majorForeground : transparent

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                mm.goPreviousMonth()
                                updateWheelViewData()
                                parallelLeft.running = true
                            }
                        }
                    }

                    Kirigami.Icon {
                        anchors.verticalCenter:parent.verticalCenter

                        width: 22 * appScale
                        height: 22 * appScale

                        source: "qrc:/assets/arrow_right.png"
                        color: isDarkTheme ? majorForeground : transparent

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                mm.goNextMonth()
                                updateWheelViewData()
                                parallelRight.running = true
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

                        width: customMonthView.dayRectWidth - 10 * appScale

                        Controls2.Label {
                            id: weekLabel

                            anchors.centerIn: parent

                            color: minorForeground
                            text: customMonthView.applicationLocale.dayName(((model.index + customMonthView.applicationLocale.firstDayOfWeek) % customMonthView.days), Locale.ShortFormat)
                            font.pixelSize: 11 *appFontSize
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
                        onNextMonth: {
                            parallelRight.running = true
                        }

                        onPreviousMonth: {
                            parallelLeft.running = true
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
                anchors.top: grid.bottom
                Layout.fillWidth: true

                height: popup.width / 16
                color:"transparent"
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
