/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.0 as Controls2

import QtQuick.Controls 2.12
import org.kde.calindori 0.1 as Calindori
import QtGraphicalEffects 1.15

Item {
    id: root

    property var currenSelectedUid
    property var currentDtstart
    property var currentListItem
    property bool isPressedState: false

    signal deleteClicked

    function positionListViewFromDate(d) {
        var index = incidenceModel.getIndexFromIncidence(d)

        if (index !== -1) {
            anim.running = false
            control.positionViewAtIndex(index, ListView.Beginning)

            anim.running = true
            control.positionViewAtIndex(index, ListView.Beginning)
        }
    }

    function positionListViewFromMonth(d) {
        var index = incidenceModel.getIndexFromMonth(d)

        if (index !== -1) {
            anim.running = false
            control.positionViewAtIndex(index, ListView.Beginning)

            anim.running = true
            control.positionViewAtIndex(index, ListView.Beginning)
        }
    }

    function refreshListView() {
        incidenceModel.loadIncidences()
        setCurrentListViewIndex(-1)
    }

    function cancelHighLight() {
        isPressedState = false
        setCurrentListViewIndex(-1)
    }

    function setCurrentListViewIndex(index) {
        if (index === -1) {
            isPressedState = false
            currentListItem.color = "transparent"
        }

        control.currentIndex = index
    }

    Calindori.IncidenceModel {
        id: incidenceModel

        calendar: localCalendar
        filterMode: 8
        filterHideCompleted: true
        appLocale: _appLocale
    }

    Item {
        anchors.fill: parent

        visible: !control.visible

        Image {
            id: noEventImage

            anchors.centerIn: parent

            sourceSize.width: root.width / 4.85
            sourceSize.height: root.width / 4.85

            source: "qrc:/assets/none-event.png"
        }

        Kirigami.Label {
            anchors {
                top: noEventImage.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: noEventImage.height / 4
            }

            text: "There is no schedule at present"
            font.pointSize: theme.defaultFont.pointSize
        }
    }

    ListView {
        id: control

        anchors {
            fill: parent
            margins: root.width / 19.3
            topMargin: root.width / 10
        }

        visible: control.count !== 0
        model: incidenceModel
        clip: true
        focus: true
        highlightFollowsCurrentItem: true

        NumberAnimation {
            id: anim
            target: control
            property: "opacity"
            from: 0
            to: 1
            duration: 300
        }

        Component.onCompleted: {
            control.currentIndex = -1
        }

        delegate: Rectangle {
            id: listItem

            width: ListView.view.width
            height: childrenRect.height

            color: ListView.isCurrentItem ? "#1e767680" : "transparent"
            radius: 15

            Component.onCompleted: {
                var displayText = incidenceAlarmsModel ? incidenceAlarmsModel.displayText(
                                                             0) : "-"
                incidenceAlarmsLabel.text = displayText
            }

            Calindori.IncidenceAlarmsModel {
                id: incidenceAlarmsModel

                alarmProperties: {
                    "calendar": localCalendar,
                    "uid": model.uid
                }
            }

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton
                preventStealing: false
                hoverEnabled: true

                onEntered: {
                    if (!isPressedState)
                        listItem.color = "#0D000000"
                }

                onExited: {
                    if (!isPressedState)
                        listItem.color = (control.currentIndex
                                          == index) ? "#1e767680" : "transparent"
                }

                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        isPressedState = true
                        currentListItem = listItem
                        control.currentIndex = index
                        currenSelectedUid = model.uid
                        currentDtstart = model.dtstart
                        rowMain.scheduleListViewClicked(model,
                                                        incidenceAlarmsModel)
                    } else if (mouse.button == Qt.RightButton) {
                        isPressedState = true
                        currentListItem = listItem
                        control.currentIndex = index
                        currenSelectedUid = model.uid
                        currentDtstart = model.dtstart
                        var jx = mapToItem(rowMain, mouse.x, mouse.y)
                        editDialogView.popup(rowMain, jx.x, jx.y)
                    }
                }

                onPressAndHold: {
                    isPressedState = true
                    currentListItem = listItem
                    control.currentIndex = index
                    currenSelectedUid = model.uid
                    currentDtstart = model.dtstart
                    var jx = mapToItem(rowMain, mouse.x, mouse.y)
                    editDialogView.popup(rowMain, jx.x, jx.y)
                }
            }

            ColumnLayout {
                id: columnLayout

                anchors.top: parent.top
                anchors.topMargin: root.width / 25

                width: root.width / 1.11

                spacing: 15

                RowLayout {

                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 22
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: scheduleLable.height
                    Layout.fillWidth: true

                    Kirigami.Separator {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: scheduleLable.height

                        color: "#E95B4E"
                        radius: 2
                    }

                    Kirigami.Label {
                        id: scheduleLable

                        anchors.left: parent.left
                        anchors.leftMargin: root.width / 32
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: root.width / 1.28

                        text: model && model.summary
                        font.pointSize: theme.defaultFont.pointSize + 2
                        wrapMode: Text.WrapAnywhere
                        color: "black"
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 12

                    Layout.fillWidth: true

                    Image {
                        width: root.width / 24.17
                        height: width
                        source: "qrc:/assets/edit_event_summary.png"
                    }

                    Kirigami.Label {
                        text: "%1 %2".arg(model.displayStartDate).arg(
                                  model.displayStartTime)
                        font.pointSize: theme.defaultFont.pointSize - 3
                        opacity: 0.6
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 12

                    Layout.fillWidth: true

                    Image {
                        width: root.width / 18.125
                        height: width

                        source: "qrc:/assets/event_alarm.png"
                    }

                    Kirigami.Label {
                        id: incidenceAlarmsLabel

                        font.pointSize: theme.defaultFont.pointSize - 3
                        opacity: 0.6
                    }
                }

                Item {
                    height: 6
                    Layout.fillWidth: true
                }
            }
        }

        section {
            property: "displayStartDateOfWeek"
            criteria: ViewSection.FullString
            labelPositioning: ViewSection.InlineLabels

            delegate: Item {
                Layout.fillWidth: true

                height: 80

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 32
                    anchors.bottom: parent.bottom

                    text: section
                    color: "#E95B4E"
                    font.pointSize: theme.defaultFont.pointSize + 3
                    font.bold: true
                }
            }
        }
    }

    EditDialogView {
        id: editDialogView

        onDeleteClicked: {
            deleteDialog.open()
        }

        onMenuClosed: {
            if (!deleteClick)
                setCurrentListViewIndex(-1)
        }
    }

    Kirigami.JDialog {
        id: deleteDialog

        property var titleContent
        property var msgContent

        signal dialogRightClicked
        signal dialogLeftClicked

        title: "Delete"
        font.pointSize: theme.defaultFont.pointSize
        text: "Are you sure you want to delete this event?"
        rightButtonText: qsTr("Delete")
        leftButtonText: qsTr("Cancel")
        visible: false
        closePolicy: Popup.CloseOnEscape

        onRightButtonClicked: {
            var vevent = {
                "uid": currenSelectedUid
            }
            _eventController.remove(localCalendar, vevent)

            var date = new Date(currentDtstart.getYear(),
                                currentDtstart.getMonth(), 1,
                                currentDtstart.getHours(),
                                currentDtstart.getMinutes())
            positionListViewFromMonth(date)
            setCurrentListViewIndex(-1)

            deleteDialog.close()
        }

        onLeftButtonClicked: {
            setCurrentListViewIndex(-1)
            deleteDialog.close()
        }
    }
}
