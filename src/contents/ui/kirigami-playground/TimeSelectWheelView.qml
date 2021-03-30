/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.3 as Kirigami
import QtGraphicalEffects 1.15

RowLayout {
    id: timeRow

    property alias hourNumber: hourWheelView.value
    property alias minutesNumber: timeWheelVIew.value
    property bool is24HourFormat
    property int hourFormatNumber: is24HourFormat ? 24 : 12
    property bool pmSelected
    property var pos1

    width: popup.width - popup.commMargin * 2

    Rectangle {
        id: hourRect

        width: popup.width / 6.2
        height: width * 1.2
        color: "#1e767680"
        radius: 14

        WheelView {
            id: hourWheelView

            anchors.centerIn: parent
            anchors.fill: parent

            model: {
                var list = []
                for (var i = 0; i < hourFormatNumber; i++)
                    list.push({
                                  "display": (!is24HourFormat
                                              && i === 0 ? 12 + "" : i / 10 < 1 ? "0" + i : "" + i),
                                  "value": i
                              })
                return list
            }

            value: hourNumber

            pathItemCount: 1
            displayFontSize: theme.defaultFont.pointSize + 11

            onViewMove: {
                if (index !== hourNumber) {
                    popup.dateValueChanged("time", index)
                }
                hourNumber = index
                popup.startHour = hourNumber
            }
        }

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    hourNumber++
                    if (hourNumber > (hourFormatNumber - 1)) {
                        hourNumber = 0
                    }
                    popup.startHour = hourNumber
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter

                sourceSize.width: 36
                sourceSize.height: 36

                source: "qrc:/assets/triangle_up.png"
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    hourNumber--
                    if (hourNumber < 0) {
                        hourNumber = (hourFormatNumber - 1)
                    }
                    popup.startHour = hourNumber
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
        width: hourRect.width / 2.5
        height: hourRect.height

        Controls2.Label {
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter

            text: ":"
            font.pointSize: theme.defaultFont.pointSize + 10
            font.bold: true
        }
    }

    Rectangle {
        id: minuteRect

        width: popup.width / 6.2
        height: width * 1.2

        color: "#1e767680"
        radius: 14

        WheelView {
            id: timeWheelVIew

            anchors.centerIn: parent
            width: minuteRect.height / 1.25
            height: minuteRect.width / 1.2

            model: {
                var list = []
                for (var i = 0; i < 60; i++)
                    list.push({
                                  "display": (i / 10 < 1 ? "0" + i : "" + i),
                                  "value": i
                              })
                return list
            }
            value: minutesNumber

            pathItemCount: 1
            displayFontSize: theme.defaultFont.pointSize + 11

            onViewMove: {
                if (index !== minutesNumber) {
                    popup.dateValueChanged("time", index)
                }
                minutesNumber = index
                popup.startMinute = minutesNumber
            }
        }

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    minutesNumber++
                    if (minutesNumber > 59) {
                        minutesNumber = 0
                    }
                    popup.startMinute = minutesNumber
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                sourceSize.width: 36
                sourceSize.height: 36

                source: "qrc:/assets/triangle_up.png"
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    minutesNumber--
                    if (minutesNumber < 0) {
                        minutesNumber = 59
                    }
                    popup.startMinute = minutesNumber
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
        width: hourRect.width / 6.25
        height: hourRect.height

        visible: !is24HourFormat
    }

    Rectangle {
        id: timeFormat

        anchors.right: parent.right

        width: popup.width / 7.95
        height: minuteRect.height

        visible: !is24HourFormat
        color: "#1e767680"
        radius: 14

        Kirigami.Label {
            id: amLabel

            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            width: timeFormat.width
            height: timeFormat.height / 2.5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pointSize: theme.defaultFont.pointSize - 3
            opacity: pmSelected ? 0.3 : 1
            text: "AM"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pmSelected = false
                    popup.pmSelectorChanged(pmSelected)
                }
            }
        }

        Kirigami.Separator {
            anchors.centerIn: parent

            implicitWidth: timeFormat.width / 2
            implicitHeight: 1

            color: "black"
            opacity: 0.1
        }

        Kirigami.Label {
            id: pmLabel

            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: timeFormat.width
            height: timeFormat.height / 2.78
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pointSize: theme.defaultFont.pointSize - 3
            text: "PM"
            opacity: pmSelected ? 1 : 0.3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    popup.dateValueChanged("pm", pmSelected ? 1 : 0)
                    pmSelected = true
                    popup.pmSelectorChanged(pmSelected)
                }
            }
        }
    }
}
