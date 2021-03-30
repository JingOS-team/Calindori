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

    function notifyDateChanged() {
        var currentDate = new Date(yearNumber, monthNumber,
                                   popup.startDt.getDate(),
                                   popup.startDt.getHours(),
                                   popup.startDt.getMinutes(), 0)
        calendarMonth.selectedDate = currentDate
        popup.startDt = currentDate
    }

    RowLayout {
        width: popup.width / 2.74

        Item {
            id: yearRect

            anchors.left: parent.left

            width: popup.width / 2.74
            height: popup.width / 2.3

            WheelView {
                id: wheelView1

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: parent.height / 3 * 2

                bgShow: true
                model: [{
                        "display": "January",
                        "value": 0
                    }, {
                        "display": "February",
                        "value": 1
                    }, {
                        "display": "March",
                        "value": 2
                    }, {
                        "display": "April",
                        "value": 3
                    }, {
                        "display": "May",
                        "value": 4
                    }, {
                        "display": "June",
                        "value": 5
                    }, {
                        "display": "July",
                        "value": 6
                    }, {
                        "display": "August",
                        "value": 7
                    }, {
                        "display": "September",
                        "value": 8
                    }, {
                        "display": "October",
                        "value": 9
                    }, {
                        "display": "November",
                        "value": 10
                    }, {
                        "display": "December",
                        "value": 11
                    }]
                value: monthNumber
                pathItemCount: 3
                displayFontSize: theme.defaultFont.pointSize + 6

                onViewMove: {
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
                anchors.topMargin: 10

                width: yearRect.width / 2
                height: wheelView1.height / 3 + 36

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        monthNumber--
                        if (monthNumber < 0) {
                            monthNumber = 11
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 36
                    sourceSize.height: 36

                    source: "qrc:/assets/triangle_up.png"
                }
            }

            Item {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10

                width: yearRect.width / 2
                height: wheelView1.height / 3 + 36

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        monthNumber++
                        if (monthNumber > 11) {
                            monthNumber = 0
                        }
                        mm.setMonth(monthNumber + 1)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 36
                    sourceSize.height: 36

                    source: "qrc:/assets/triangle_down.png"
                }
            }
        }

        Item {
            anchors.left: yearRect.right
            anchors.leftMargin: 21

            width: popup.width / 2.74
            height: popup.width / 2.3

            WheelView {
                id: wheelView2

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: parent.height / 3 * 2

                starIndexZero: false
                bgShow: true
                pathItemCount: 3
                displayFontSize: theme.defaultFont.pointSize + 6
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
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView2.height / 3 + 36

                MouseArea {
                    anchors.fill: parent

                    onClicked: {

                        yearNumber--
                        if (yearNumber < 1900) {
                            yearNumber = 2100
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 36
                    sourceSize.height: 36

                    source: "qrc:/assets/triangle_up.png"
                }
            }

            Item {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                width: yearRect.width / 2
                height: wheelView2.height / 3 + 36

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        yearNumber++
                        if (yearNumber > 2100) {
                            yearNumber = 1900
                        }
                        mm.setYear(yearNumber)
                        notifyDateChanged()
                    }
                }

                Image {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    sourceSize.width: 36
                    sourceSize.height: 36

                    source: "qrc:/assets/triangle_down.png"
                }
            }
        }
    }
}
