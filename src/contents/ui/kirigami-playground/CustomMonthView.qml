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
    property int dayRectWidth: (popup.width - popup.commMargin * 2) / 7
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
            anchors.topMargin: 12 * appScale

            TimeSelectWheelView {
                id: timeSelectWheelView

                anchors.left: parent.left

                hourNumber: selectorHour
                pmSelected: customMonthView.pmSelected
                is24HourFormat: customMonthView.is24HourFormat
                minutesNumber: selectorMinutes
            }
        }

        ColumnLayout {
            anchors.top: selectedTimeHeading.bottom
            anchors.topMargin: 50 * appScale

            spacing: 20 * appScale

            RowLayout {
                id: selectedDayHeading

                height: popup.width / 14
                width: dayRectWidth
                Layout.preferredWidth: parent.width

                Image {
                    id:swith_img

                    sourceSize.width: 22
                    sourceSize.height: 22

                    Layout.alignment: Qt.AlignLeft
                    
                    source: isWheelViewShowing ? "qrc:/assets/calendar_selected.png" : "qrc:/assets/calendar_switch.png"

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
                    anchors{
                        left:swith_img.right
                        right:rowMonthChange.left
                    }

                    Layout.alignment: Qt.AlignHCenter

                    RowLayout{
                        anchors.horizontalCenter: parent.horizontalCenter

                        spacing: 5 * appScale

                        Text {
                            visible: showMonthName
                            font.pixelSize: 14
                            text: i18n(displayedMonthName)
                            font.bold: true
                        }

                        Text {
                            visible: showYear
                            font.pixelSize: 14
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
                }

                RowLayout {
                    id: rowMonthChange

                    Layout.alignment: Qt.AlignRight

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

                        Controls2.Label {
                            id: weekLabel

                            anchors.centerIn: parent

                            color: "#4D000000"
                            text: i18n(customMonthView.applicationLocale.dayName(
                                      ((model.index
                                        + customMonthView.applicationLocale.firstDayOfWeek)
                                       % customMonthView.days),
                                      Locale.ShortFormat))
                            font.pixelSize: 11
                            
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
