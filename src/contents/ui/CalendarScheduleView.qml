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

Rectangle {
    id: root

    property var currenSelectedUid
    property var currentDtstart
    property var currentListItem
    property var currentIndex
    property bool isPressedState: false
    property bool is24HourFormat: timezoneProxy.isSystem24HourFormat

    signal deleteClicked

    color: isDarkTheme ? "#FF1D1D1F" : "#FFE8EFFF"

    function positionListViewFromDate(d) {
        var index = incidenceModel.getIndexFromIncidence(d)
        currentListItem = control.itemAtIndex(index)
        if (index !== -1) {
            control.positionViewAtIndex(index, ListView.Beginning)
        }
    }

    function showAddAnim(currentUid){
        var index = incidenceModel.getIndexFromUuid(currentUid)
        if (index !== -1) {
            control.positionViewAtIndex(index, ListView.Beginning)
        }

        currentListItem = control.itemAtIndex(index)
        parallelAdd.running = true
    }

    function positionListViewFromMonth(d) {
        var index = incidenceModel.getIndexFromMonth(d)

        if (index !== -1) {
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
            if(currentListItem){
                currentListItem.color = "transparent"
            }
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

        Item {
            anchors.centerIn: parent
            width:childrenRect.width
            height:childrenRect.height

            Kirigami.Icon {
                id: noEventImage
                anchors{
                    top:parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                width: root.width / 4.85
                height: root.width / 4.85
                color: isDarkTheme ? majorForeground : "transparent"

                source: "qrc:/assets/none-event.png"
            }

            Kirigami.Label {
                anchors {
                    top: noEventImage.bottom
                    horizontalCenter: parent.horizontalCenter
                    topMargin: noEventImage.height / 4
                }

                width: root.width / 2
                wrapMode: Text.WordWrap
                horizontalAlignment: TextInput.AlignHCenter
                text: i18n("There is no schedule at present")
                font.pixelSize: 14 * appFontSize
                color: isDarkTheme ? "#4DF7F7F7" : "#4D3C3C43"
            }
        }
    }

    ParallelAnimation{
        id:parallelAdd

        running:false
        NumberAnimation { target: currentListItem; property: "opacity";from: 0; to: 1; duration: 75}
        NumberAnimation { target: currentListItem; property: "x"; from: currentListItem.x + currentListItem.width; to: currentListItem.x; duration: 75 }
    }

    ParallelAnimation {
        id:parallelDelete

        running:false
        NumberAnimation { target: currentListItem; property: "opacity";from: 1; to: 0; duration: 75}
        NumberAnimation { target: currentListItem; property: "x"; from: currentListItem.x; to: currentListItem.x + currentListItem.width; duration: 75 }

        onFinished:{
            currentListItem.color = "transparent"
            var vevent = {
                "uid": currenSelectedUid
            }
            _eventController.remove(localCalendar, vevent)
            control.positionViewAtIndex(currentIndex, ListView.Beginning)
            setCurrentListViewIndex(-1)
        }
    }

    ListView {
        id: control

        anchors {
            fill: parent
            margins: root.width / 19.3
            topMargin: root.width / 10 + 5
        }

        model: incidenceModel

        clip: true
        focus: true
        spacing: 5 *  appScale
        highlightFollowsCurrentItem: true
        visible: control.count !== 0

        Component.onCompleted: {
            control.currentIndex = -1
        }

        delegate: Rectangle {
            id: listItem

            width: ListView.view.width
            height: columnLayout.height + 15 * appFontSize

            color: ListView.isCurrentItem ? "#1e767680" : "transparent"
            radius: 10 * appFontSize

            Component.onCompleted: {
                var displayText = incidenceAlarmsModel ? incidenceAlarmsModel.displayText(0) : "-"
                incidenceAlarmsLabel.text = i18n(displayText)
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
                    control.focus = true
                    control.forceActiveFocus()
                    if (!isPressedState) {
                        listItem.color = "#0D000000"
                    }
                }

                onExited: {
                    control.focus = false
                    if (!isPressedState) {
                        listItem.color = (control.currentIndex == index) ? "#1e767680" : "transparent"
                    }
                }

                onCanceled: {
                    if (!isPressedState) {
                        listItem.color = (control.currentIndex == index) ? "#1e767680" : "transparent"
                    }
                }

                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        listItem.color = "#1e767680";
                        isPressedState = true
                        currentListItem = listItem
                        currentIndex = index
                        control.currentIndex = index
                        currenSelectedUid = model.uid
                        currentDtstart = model.dtstart
                        var jx = mapToItem(rowMain,scheduleLable.x,(scheduleLable.y + scheduleLable.height) / 2)
                        if (jx.y < 80 * appScale) {
                            jx = mapToItem(rowMain,scheduleLable.x,(scheduleLable.y + listItem.height / 2) - 20)
                        }
                        rowMain.scheduleListViewClicked(model, incidenceAlarmsModel, jx)
                    } else if (mouse.button == Qt.RightButton) {
                        listItem.color = "#1e767680";
                        isPressedState = true
                        currentListItem = listItem
                        currentIndex = index
                        control.currentIndex = index
                        currenSelectedUid = model.uid
                        currentDtstart = model.dtstart
                        var jx = mapToItem(listItem, mouse.x, mouse.y)
                        editDialogView.popup(listItem,(listItem.width - editDialogView.width) / 2,jx.y)
                    }
                }

                onPressAndHold: {
                    isPressedState = true
                    currentListItem = listItem
                    control.currentIndex = index
                    currenSelectedUid = model.uid
                    currentDtstart = model.dtstart
                    var jx = mapToItem(listItem, mouse.x, mouse.y)
                    editDialogView.popup(listItem,(listItem.width - editDialogView.width) / 2,jx.y)
                }
            }

            ColumnLayout {
                id: columnLayout

                anchors.top: parent.top
                anchors.topMargin: root.width / 25

                width: root.width / 1.11
                height: childrenRect.height

                spacing:3 * appScale

                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * appScale

                    Layout.preferredWidth: parent.width
                    Layout.fillWidth: true
                    height:scheduleLable.height

                    Kirigami.Separator {
                        Layout.preferredWidth: 3 * appScale
                        Layout.preferredHeight: scheduleLable.height

                        color: "#E95B4E"
                        radius: 2 * appScale
                    }

                    Kirigami.Label {
                        id: scheduleLable

                        anchors.left: parent.left
                        anchors.leftMargin: 10 * appScale
                        anchors.verticalCenter: parent.verticalCenter

                        Layout.preferredWidth: root.width / 1.28

                        text: model && model.summary
                        font.pixelSize: 14 * appFontSize
                        wrapMode: Text.Wrap
                        color: majorForeground
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 12

                    width:columnLayout.width
                    height:root.width / 18.125

                    spacing:3 * appScale

                    Image {
                        anchors.verticalCenter:parent.verticalCenter

                        width: 16 * appScale
                        height: 16 * appScale

                        source: "qrc:/assets/edit_event_summary.png"
                    }

                    Kirigami.Label {
                        id: startLable

                        text: "%1 %2".arg(model.displayStartDate).arg(model.displayStartTime)
                        font.pixelSize: 11 * appFontSize
                        color: minorForeground

                        Connections {
                            target: root
                            onIs24HourFormatChanged: {
                                startLable.text = "%1 %2".arg(model.displayStartDate).arg(model.displayStartTime)
                            }
                        }
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 12

                    width:columnLayout.width
                    height:root.width / 18.125

                    spacing:3 * appScale

                    Image {
                        anchors.verticalCenter:parent.verticalCenter

                        width: 16 * appScale
                        height: 16 * appScale

                        source: "qrc:/assets/event_alarm.png"
                    }

                    Kirigami.Label {
                        id: incidenceAlarmsLabel

                        font.pixelSize: 11 * appFontSize
                        color: minorForeground
                    }
                }

                Item {
                    height: 6 * appScale
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

                height: 36 * appScale

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 32
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5 * appScale

                    text: i18n(section)
                    color: "#E95B4E"
                    font.pixelSize: 15 * appFontSize
                    font.bold: true
                }
            }
        }
    }

    Kirigami.JPopupMenu {
        id: editDialogView
        width: 160 * appScale

        Action {
            text: i18n("Delete")
            icon.source:  "qrc:/assets/edit_delete_black.png"
            onTriggered: {
                deleteDialog.open()
            }
        }

        onClosed: {
            isPressedState = false
            currentListItem.color = "transparent"
        }
    }

    Kirigami.JDialog {
        id: deleteDialog

        property var titleContent
        property var msgContent

        signal dialogRightClicked
        signal dialogLeftClicked

        title: i18n("Delete")
        font.pixelSize: 14 * appFontSize
        text: i18n("Are you sure you want to delete this event?")
        rightButtonText: i18n("Delete")
        leftButtonText: i18n("Cancel")
        rightButtonTextColor:  "#FF3C4BE8"
        visible: false
        closePolicy: Popup.CloseOnEscape

        onRightButtonClicked: {
            currentListItem.color = "transparent"
            parallelDelete.running = true

            deleteDialog.close()

        }

        onLeftButtonClicked: {
            setCurrentListViewIndex(-1)
            deleteDialog.close()
        }
    }
}
