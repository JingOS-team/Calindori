/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.3 as Kirigami

ColumnLayout {
    id: root

    property var monthNumber: wheelView1.value
    property var yearNumber: wheelView2.value

    width: parent.width
    height: popup.width / 1.8
    function notifyDateChanged() {
        var currentDate = new Date(yearNumber, monthNumber,
                                   popup.startDt.getDate(),
                                   popup.startDt.getHours(),
                                   popup.startDt.getMinutes(), 0)
        calendarMonth.selectedDate = currentDate
        popup.startDt = currentDate
    }

    Item {

        anchors {
            top: parent.top
            topMargin: 20 * appScale
        }

        width: parent.width

        Item {
            id: yearRect

            anchors.left: parent.left
            anchors.leftMargin: 5

            width: popup.width / 2.5
            height: popup.width / 2.3

            WheelView {
                id: wheelView1

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: parent.height / 3 * 2

                bgShow: true
                model: [{
                        "display": i18n("January"),
                        "value": 0
                    }, {
                        "display": i18n("February"),
                        "value": 1
                    }, {
                        "display": i18n("March"),
                        "value": 2
                    }, {
                        "display": i18n("April"),
                        "value": 3
                    }, {
                        "display": i18n("May"),
                        "value": 4
                    }, {
                        "display": i18n("June"),
                        "value": 5
                    }, {
                        "display": i18n("July"),
                        "value": 6
                    }, {
                        "display": i18n("August"),
                        "value": 7
                    }, {
                        "display": i18n("September"),
                        "value": 8
                    }, {
                        "display": i18n("October"),
                        "value": 9
                    }, {
                        "display": i18n("November"),
                        "value": 10
                    }, {
                        "display": i18n("December"),
                        "value": 11
                    }]
                value: monthNumber
                pathItemCount: 3
                displayFontSize: 17

                onViewMove: {
                    popup.isTimeDataChanged = true
                    if (index !== monthNumber) {
                        popup.dateValueChanged("date", index)
                    }
                    monthNumber = index
                    mm.setMonth(monthNumber + 1)
                    notifyDateChanged()
                }
            }

            Item {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView1.height / 3 + 15 * appScale

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.isTimeDataChanged = true
                        monthNumber++
                        if (monthNumber > 11) {
                            monthNumber = 0
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 28 * appScale
                    sourceSize.height: 28 * appScale

                    source: "qrc:/assets/triangle_up.png"
                }
            }

            Item {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView1.height / 3 + 15 * appScale

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.isTimeDataChanged = true
                        monthNumber--
                        if (monthNumber < 0) {
                            monthNumber = 11
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 28 * appScale
                    sourceSize.height: 28 * appScale

                    source: "qrc:/assets/triangle_down.png"
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                property var contentY: 0
                property var pressedY: 0
                property bool isReduce: false
                hoverEnabled: true

                onEntered: {
                    preventStealing = true
                }

                onExited: {
                    preventStealing = false
                }

                onPressed: {
                    popup.isCoverArea = true
                    propagateComposedEvents = false
                    pressedY = mouseY
                    preventStealing = true
                }

                onReleased: {

                    popup.isCoverArea = false
                    propagateComposedEvents = true
                    preventStealing = false
                    var moveY = mouseY - pressedY
                    var count = parseInt(moveY / 40)
                    if (Math.abs(contentY) < 40 & Math.abs(contentY) > 10) {
                        count = 1
                    }
                    if (count >= 1) {
                        monthNumber = monthNumber - count
                        if (monthNumber < 0) {
                            monthNumber = 11
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    } else if (count <= -1) {
                        monthNumber = monthNumber + Math.abs(count)
                        if (monthNumber > 11) {
                            monthNumber = 0
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    }
                }
                onWheel: {
                    popup.isTimeDataChanged = true
                    var wY = wheel.angleDelta.y

                    if (wY == 120) {
                        monthNumber = monthNumber - 1
                        if (monthNumber < 0) {
                            monthNumber = 11
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                        return
                    } else if (wY == -120) {
                        monthNumber = monthNumber + 1
                        if (monthNumber > 11) {
                            monthNumber = 0
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                        return
                    }
                    if (wY != 0 & Math.abs(contentY) < Math.abs(wY)) {
                        contentY = wY
                    } else if (wY != 0 & Math.abs(contentY) > Math.abs(wY)) {
                        isReduce = true
                    }
                    if (isReduce & wY == 0) {
                        if (contentY != 0) {
                            var count = parseInt(contentY / 250)
                            if (Math.abs(contentY) < 300) {
                                count = 1
                            }
                            isReduce = false
                            contentY = 0
                            if (count >= 1) {
                                monthNumber = monthNumber - count
                                if (monthNumber < 0) {
                                    monthNumber = 11
                                }
                                mm.setMonth(monthNumber + 1)
                                notifyDateChanged()
                            } else if (count <= -1) {
                                monthNumber = monthNumber + Math.abs(count)
                                if (monthNumber > 11) {
                                    monthNumber = 0
                                }
                                mm.setMonth(monthNumber + 1)
                                notifyDateChanged()
                            }
                        }
                    }
                }
            }
        }

        Item {
            anchors.right: parent.right
            anchors.rightMargin: 5

            width: popup.width / 2.5
            height: popup.width / 2.3

            WheelView {
                id: wheelView2

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: parent.height / 3 * 2

                starIndexZero: false
                bgShow: true
                pathItemCount: 3
                displayFontSize: 17
                value: yearNumber

                model: {
                    var list = []
                    for (var i = 1900; i < 2100; i++)
                        list.push({
                                      "display": i + "",
                                      "value": i
                                  })
                    return list
                }

                onViewMove: {
                    popup.isTimeDataChanged = true
                    if (index !== yearNumber) {
                        popup.dateValueChanged("date", index)
                    }
                    yearNumber = index
                    mm.setYear(dateSelectWheelView.yearNumber)
                    notifyDateChanged()
                }
            }

            Item {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView2.height / 3 + 15 * appScale

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.isTimeDataChanged = true
                        yearNumber++
                        if (yearNumber > 2100) {
                            yearNumber = 1900
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 28 * appScale
                    sourceSize.height: 28 * appScale

                    source: "qrc:/assets/triangle_up.png"
                }
            }

            Item {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView2.height / 3 + 30

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        popup.isTimeDataChanged = true
                        yearNumber--
                        if (yearNumber < 1900) {
                            yearNumber = 2100
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 28 * appScale
                    sourceSize.height: 28 * appScale

                    source: "qrc:/assets/triangle_down.png"
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                property var contentY: 0
                property bool isReduce: false
                property var pressedY: 0
                hoverEnabled: true

                onEntered: {
                    preventStealing = true
                }

                onExited: {
                    preventStealing = false
                }

                onPressed: {
                    popup.isCoverArea = true
                    propagateComposedEvents = false
                    pressedY = mouseY
                    preventStealing = true
                }

                onReleased: {
                    popup.isCoverArea = false
                    propagateComposedEvents = true
                    preventStealing = false
                    var moveY = mouseY - pressedY
                    var count = parseInt(moveY / 40)
                    if (Math.abs(contentY) < 40 & Math.abs(contentY) > 10) {
                        count = 1
                    }
                    if (count >= 1) {
                        yearNumber = yearNumber - count
                        if (yearNumber < 1900) {
                            yearNumber = 2100
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    } else if (count <= -1) {
                        yearNumber = yearNumber + Math.abs(count)
                        if (yearNumber > 2100) {
                            yearNumber = 1900
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    }
                }
                
                onWheel: {
                    popup.isTimeDataChanged = true
                    var wY = wheel.angleDelta.y

                    if (wY == 120) {
                        yearNumber = yearNumber - 1
                        if (yearNumber < 1900) {
                            yearNumber = 2100
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                        return
                    } else if (wY == -120) {
                        yearNumber = yearNumber + 1
                        if (yearNumber > 2100) {
                            yearNumber = 1900
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                        return
                    }
                    if (wY != 0 & Math.abs(contentY) < Math.abs(wY)) {
                        contentY = wY
                    } else if (wY != 0 & Math.abs(contentY) > Math.abs(wY)) {
                        isReduce = true
                    }
                    if (isReduce & wY == 0) {
                        if (contentY != 0 & Math.abs(contentY) > 120) {
                            var count = parseInt(contentY / 250)
                            if (Math.abs(contentY) < 300) {
                                count = 1
                            }
                            isReduce = false
                            contentY = 0
                            if (count >= 1) {
                                yearNumber = yearNumber - count
                                if (yearNumber < 1900) {
                                    yearNumber = 2100
                                }
                                mm.setYear(yearNumber)
                                notifyDateChanged()
                            } else if (count <= -1) {
                                yearNumber = yearNumber + Math.abs(count)
                                if (yearNumber > 2100) {
                                    yearNumber = 1900
                                }
                                mm.setYear(yearNumber)
                                notifyDateChanged()
                            }
                        }
                    }
                }
            }
        }
    }
}
