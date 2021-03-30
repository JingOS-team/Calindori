/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.calindori 0.1 as Calindori
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15

Popup {
    id: popup

    property string uid
    property alias summary: eventSummary.text
    property var description: ""
    property alias startDt: eventDate.selectorDate
    property alias startHour: eventTime.selectorHour
    property alias startMinute: eventTime.selectorMinutes
    property alias startPm: eventTime.selectorPm
    property alias endDt: eventDate.selectorDate
    property alias endHour: eventTime.selectorHour
    property alias endMinute: eventTime.selectorMinutes
    property alias endPm: eventTime.selectorPm
    property var repeatType: _repeatModel.noRepeat
    property var repeatEvery: 1
    property var repeatStopAfter: -1
    property var allDay: false
    property var location: ""
    property var incidenceAlarmsModel
    property var incidenceData
    property alias upBarVisible: upBar.visible
    property var currentIndex
    property var screenWidth: mainWindow.width
    property var is24HourFormat: mm.is24HourFormat()
    property bool monthViewVisible
    property int commMargin: popup.width / 16
    property bool isDataChanged
    property bool isTimeDataChanged
    property var sourceView
    property var currentAlerTimeName
    property int collapseHeight: mainWindow.height / 2.5
    property int expandHeight: mainWindow.height / 1.2

    signal pmSelectorChanged(bool b)
    signal dateValueChanged(var type, int value)

    anchors.centerIn: parent

    width: mainWindow.width / 1920 * 620 + 80
    topMargin: mainWindow.height / 11.65
    leftMargin: mainWindow.width / 2.67
    contentHeight: expandHeight
    contentWidth: mainWindow.width / 1920 * 620
    padding: 40
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    modal: true
    focus: true
    closePolicy: isDataChanged | isTimeDataChanged ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
    Overlay.modal: Rectangle {
        color: "transparent"
    }

    onDateValueChanged: {

    }

    onPmSelectorChanged: {
        startPm = b
    }

    onClosed: {
        rowMain.setListViewItem(-1)
    }

    onOpened: {
        isDataChanged = false
        isTimeDataChanged = false
        calendarMonth.visible = false
        setCollapseHeight()
        calendarMonth.initWidgetState()
        calendarMonth.updateWheelViewData()
    }

    Calindori.IncidenceAlarmsModel {
        id: localAlarmsModel

        alarmProperties: {
            "calendar": localCalendar,
            "uid": popup.uid
        }
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar
    }

    function loadNewDate() {
        var newDt

        if (incidenceData) {
            newDt = incidenceData.dtstart
        } else {
            newDt = startDt
            newDt.setMinutes(newDt.getMinutes(
                                 ) + _calindoriConfig.eventsDuration)
            newDt.setSeconds(0)
        }

        eventDate.selectorDate = newDt
        eventTime.selectorHour = newDt.getHours()
        eventTime.selectorMinutes = newDt.getMinutes()

        calendarMonth.selectedDate = newDt
        calendarMonth.selectorHour = newDt.getHours()
        calendarMonth.selectorMinutes = newDt.getMinutes()

        var displayNameTrim = incidenceAlarmsModel.displayText(0).replace(" ",
                                                                          "")
        currentAlerTimeName = displayNameTrim
        eventAlert.text = displayNameTrim
        popup.upBarVisible = false
        rightBar.visible = true
        calendarMonth.pmSelected = startPm

        titleLabel.text = "Edit event"
        calendarMonth.visible = false
        monthViewVisible = false
        setCollapseHeight()
    }

    function initFirstData() {
        startDt = calendarMonthView.selectedDate
        startHour = startDt.getHours()
        startMinute = startDt.getMinutes()

        calendarMonth.selectorHour = startDt.getHours()
        calendarMonth.selectorMinutes = startDt.getMinutes()
        calendarMonth.selectedDate = startDt

        uid = ""
        localAlarmsModel.removeAll()
        incidenceAlarmsModel = localAlarmsModel
        currentAlerTimeName = "None"
        eventAlert.text = "None"
        popup.upBarVisible = false
        rightBar.visible = false
        calendarMonth.pmSelected = startPm
        incidenceData = null

        titleLabel.text = "New event"

        calendarMonth.visible = false
        monthViewVisible = false
        setCollapseHeight()
    }

    function setCollapseHeight() {
        popup.contentHeight = collapseHeight
    }

    function setExpandHeight() {
        popup.contentHeight = expandHeight
    }

    Rectangle {
        id: upBar

        anchors.top: parent.top
        anchors.topMargin: -8
        anchors.right: parent.right
        anchors.rightMargin: 125

        width: 20
        height: 20

        visible: false
        rotation: 45
    }

    Rectangle {
        id: rightBar

        width: 20
        height: 20

        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: -8

        visible: false
        rotation: 45
    }

    background: Rectangle {
        id: background

        color: "transparent"
    }

    contentItem: Rectangle {
        id: contentItem

        anchors.centerIn: parent
        implicitWidth: parent.width

        radius: 24

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 40
            samples: 25
            color: "#1A000000"
            verticalOffset: 10
            spread: 0
        }

        ShaderEffectSource {
            id: eff

            width: fastBlur.width
            height: fastBlur.height

            visible: false
            sourceRect: Qt.rect(mainWindow.width / 2.6 + 20,
                                mainWindow.height / 11.65 + 40, width, height)
            sourceItem: sourceView
        }

        FastBlur {
            id: fastBlur

            width: mainWindow.width
            height: expandHeight

            source: eff
            radius: 144
            cached: true
            visible: false
        }

        Rectangle {
            id: maskRect

            anchors.fill: fastBlur

            visible: false
            clip: true
        }

        OpacityMask {
            id: mask

            anchors.fill: maskRect

            visible: true
            opacity: 0.1
            source: fastBlur
            maskSource: maskRect
        }

        RowLayout {
            id: rowTitle

            anchors {
                top: parent.top
                topMargin: popup.commMargin
                left: parent.left
                right: parent.right
                leftMargin: popup.commMargin
                rightMargin: popup.commMargin
            }

            Kirigami.Label {
                id: titleLabel

                text: "New Event"
                font.pointSize: theme.defaultFont.pointSize + 11
            }

            Kirigami.Separator {
                color: "transparent"
                Layout.fillWidth: true
            }

            Kirigami.JIconButton {
                id: eventCacel

                anchors.right: eventConfirm.left
                anchors.rightMargin: popup.width / 9.25

                width: popup.width / 14
                height: popup.width / 14.74

                source: "qrc:/assets/event_cancel.png"

                onClicked: {
                    rowMain.eventCancelCompleted()
                    popup.close()
                }
            }

            Kirigami.JIconButton {
                id: eventConfirm

                anchors.right: parent.right

                width: popup.width / 14
                height: popup.width / 14.74

                source: "qrc:/assets/event_confirm.png"
                enabled: isDataChanged | isTimeDataChanged

                opacity: enabled ? 1 : 0.4

                onClicked: {

                    var mSummary = popup.summary == "" ? "New schedule" : popup.summary
                    var vevent = {
                        "uid": popup.uid,
                        "startDate": popup.startDt,
                        "summary": mSummary,
                        "description": popup.description,
                        "startHour": (popup.startHour + (!is24HourFormat
                                                         && popup.startPm ? 12 : 0)),
                        "startMinute": popup.startMinute,
                        "allDay": popup.allDay,
                        "location": popup.location,
                        "endDate": popup.endDt,
                        "endHour": (popup.startHour + (!is24HourFormat
                                                       && popup.startPm ? 12 : 0)),
                        "endMinute": popup.endMinute,
                        "alarms": incidenceAlarmsModel.alarms(),
                        "periodType": popup.repeatType,
                        "repeatEvery": popup.repeatEvery,
                        "stopAfter": popup.repeatStopAfter
                    }

                    var validation = _eventController.validate(vevent)

                    if (validation.success) {
                        _eventController.addEdit(localCalendar, vevent)
                        rowMain.eventAddCompleted()
                        calendarMonthView.notifyCalendarChanged(popup.startDt)
                    } else {
                        showPassiveNotification(validation.reason)
                    }
                    popup.close()
                }
            }
        }

        ScrollView {
            id: scroll

            anchors.bottom: blankRect.top
            anchors.bottomMargin: -10
            anchors.top: rowTitle.bottom
            anchors.topMargin: popup.width / 14.42

            width: parent.width
            height: parent.height

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            clip: true

            ColumnLayout {
                id: columnLayout

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: popup.commMargin
                    rightMargin: popup.commMargin
                }

                width: parent.width

                RowLayout {
                    height: expandHeight / 100 * 9
                    Layout.fillWidth: true

                    Item {

                        width: parent.width
                        height: parent.height
                        Layout.fillWidth: true

                        Image {
                            id: summaryIcon

                            anchors.verticalCenter: parent.verticalCenter

                            sourceSize.width: popup.width / 19.375
                            sourceSize.height: popup.width / 18.235

                            source: "qrc:/assets/edit_event_summary.png"
                        }

                        TextField {
                            id: eventSummary

                            anchors {
                                left: summaryIcon.right
                                leftMargin: popup.width / 31
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            maximumLength: 50
                            text: incidenceData ? incidenceData.summary : ""
                            font.pointSize: theme.defaultFont.pointSize + 2
                            placeholderText: "Title"

                            background: Rectangle {
                                color: "transparent"
                            }
                            cursorDelegate: CursorBlinks {
                                targetView: eventSummary
                            }

                            onTextChanged: {
                                isDataChanged = true
                            }
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            width: parent.width

                            color: "#767680"
                            opacity: 0.12
                        }
                    }
                }

                RowLayout {
                    height: expandHeight / 100 * 9
                    width: parent.width

                    Item {
                        Layout.fillWidth: true

                        width: parent.width
                        height: parent.height

                        Image {
                            id: timeIcon

                            anchors.verticalCenter: parent.verticalCenter

                            sourceSize.width: popup.width / 18.235
                            sourceSize.height: popup.width / 17.714

                            source: "qrc:/assets/edit_event_time.png"
                        }

                        Kirigami.Label {
                            anchors {
                                left: timeIcon.right
                                leftMargin: popup.width / 31
                                verticalCenter: parent.verticalCenter
                            }

                            font.pointSize: theme.defaultFont.pointSize + 2
                            text: "Time"
                        }

                        DateSelectorButton {
                            id: eventDate

                            anchors {
                                right: eventTime.left
                                verticalCenter: parent.verticalCenter
                            }

                            implicitWidth: popup.width / 3

                            font.pointSize: theme.defaultFont.pointSize + 2
                            textColor: isTimeDataChanged ? "red" : "black"
                            selectorDate: _eventController.localSystemDateTime()
                            enabled: false
                        }

                        TimeSelectorButton {
                            id: eventTime

                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            implicitWidth: is24HourFormat ? parent.width / 6 : parent.width / 3.5

                            font.pointSize: theme.defaultFont.pointSize + 2
                            textColor: isTimeDataChanged ? "red" : "black"
                            selectorDate: popup.startDt
                            is24HourFormat: popup.is24HourFormat
                            selectorHour: popup.incidenceData ? (is24HourFormat ? popup.incidenceData.dtstart.getHours() : popup.incidenceData.dtstart.getHours() % 12) : (is24HourFormat ? popup.startDt.getHours() : popup.startDt.getHours() % 12)
                            selectorMinutes: popup.incidenceData ? popup.incidenceData.dtstart.getMinutes(
                                                                       ) : popup.startDt.getMinutes(
                                                                       )
                            selectorPm: popup.incidenceData ? (popup.incidenceData.dtstart.getHours(
                                                                   )
                                                               >= 12) : (popup.startDt.getHours(
                                                                             ) >= 12)
                            enabled: false
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            width: parent.width

                            color: "#767680"
                            opacity: 0.12
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                isTimeDataChanged = true
                                if (calendarMonth.visible == true) {
                                    setCollapseHeight()
                                    monthViewVisible = false
                                } else {
                                    setExpandHeight()
                                    monthViewVisible = true
                                }
                                calendarMonth.visible = !calendarMonth.visible
                            }
                        }
                    }
                }

                PickerMonthView {
                    id: calendarMonth

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft

                    visible: false
                    selectedDate: startDt
                    selectorHour: startHour
                    selectorMinutes: startMinute
                }

                RowLayout {
                    anchors.bottom: calendarMonth.visble ? calendarMonth.bottom : parent.bottom

                    height: expandHeight / 100 * 9
                    width: parent.width

                    Item {
                        Layout.fillWidth: true

                        width: parent.width
                        height: parent.height

                        Image {
                            id: alertIcon

                            anchors.verticalCenter: parent.verticalCenter

                            sourceSize.width: popup.width / 19.735
                            sourceSize.height: popup.width / 19.735

                            source: "qrc:/assets/event_alarm.png"
                        }

                        Kirigami.Label {
                            anchors {
                                left: alertIcon.right
                                leftMargin: popup.width / 31
                                verticalCenter: parent.verticalCenter
                            }

                            font.pointSize: theme.defaultFont.pointSize + 2
                            text: "Alert"
                        }

                        Kirigami.Label {
                            id: eventAlert

                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            opacity: 0.6
                            color: "black"
                            font.pointSize: theme.defaultFont.pointSize + 2
                            text: currentAlerTimeName

                            onTextChanged: {
                                isDataChanged = incidenceAlarmsModel
                                        && incidenceAlarmsModel.displayText(
                                            0) !== text
                            }
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            width: parent.width

                            color: "#767680"
                            opacity: 0.12
                        }

                        MouseArea {

                            anchors.fill: parent

                            onClicked: {

                                if (alertSelector.visible == false) {
                                    setExpandHeight()
                                }
                                scroll.visible = false
                                alertSelector.visible = true
                                rowTitle.visible = false
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: blankRect

            anchors.bottom: contentItem.bottom

            width: parent.width
            height: 50

            color: "white"
            radius: 24
        }

        Item {
            id: alertSelector

            anchors.fill: parent

            visible: false

            ColumnLayout {
                anchors.fill: parent

                Item {
                    id: alertTtile

                    anchors.top: parent.top
                    anchors.topMargin: popup.height / 30

                    width: parent.width
                    height: childrenRect.height

                    Kirigami.Icon {
                        id: alertBack

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        width: popup.width / 14.42
                        height: popup.width / 14.42

                        source: "qrc://assets/alert_back.png"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                rowTitle.visible = true
                                scroll.visible = true
                                alertSelector.visible = false
                                if (monthViewVisible) {
                                    setExpandHeight()
                                } else {
                                    setCollapseHeight()
                                }
                            }
                        }
                    }

                    Kirigami.Label {
                        anchors.left: alertBack.right
                        anchors.verticalCenter: parent.verticalCenter

                        font.pointSize: theme.defaultFont.pointSize + 11
                        text: "Alert"
                    }
                }

                ListView {
                    id: alertListView

                    anchors {
                        top: alertTtile.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        topMargin: popup.height / 32.4
                        leftMargin: popup.width / 15.5
                        rightMargin: popup.width / 15.5
                    }
                    Layout.fillWidth: true

                    model: listModel
                    clip: true
                    spacing: 0

                    delegate: Item {
                        width: parent.width
                        height: expandHeight / 100 * 9

                        Kirigami.Label {
                            anchors.verticalCenter: parent.verticalCenter

                            text: model.displayName
                            font.pointSize: theme.defaultFont.pointSize + 2
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            implicitWidth: parent.width
                            implicitHeight: 1

                            visible: index == listModel.count - 1 ? false : true
                            color: "#767680"
                            opacity: 0.12
                        }

                        Image {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            sourceSize.width: popup.width / 14
                            sourceSize.height: popup.width / 14

                            visible: currentAlerTimeName === model.displayName ? true : false
                            source: "qrc:/assets/alert_time_selected.png"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                currentAlerTimeName = model.displayName
                                isDataChanged = true
                                currentIndex = index
                                if (monthViewVisible) {
                                    setExpandHeight()
                                } else {
                                    setCollapseHeight()
                                }

                                rowTitle.visible = true
                                scroll.visible = true
                                alertSelector.visible = false
                                eventAlert.text = listModel.get(
                                            currentIndex).displayName

                                if (listModel.get(currentIndex).value === -1) {
                                    incidenceAlarmsModel.removeAll()
                                } else {
                                    incidenceAlarmsModel.removeAll()
                                    incidenceAlarmsModel.addAlarm(
                                                listModel.get(
                                                    currentIndex).value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel
        ListElement {
            displayName: "None"
            value: -1
        }
        ListElement {
            displayName: "At time of event"
            value: 0
        }
        ListElement {
            displayName: "5 minutes before"
            value: 300
        }
        ListElement {
            displayName: "10 minutes before"
            value: 600
        }
        ListElement {
            displayName: "15 minutes before"
            value: 900
        }
        ListElement {
            displayName: "30 minutes before"
            value: 1800
        }
        ListElement {
            displayName: "1 hour before"
            value: 3600
        }
        ListElement {
            displayName: "2 hours before"
            value: 7200
        }
        ListElement {
            displayName: "1 day before"
            value: 86400
        }
        ListElement {
            displayName: "2 days before"
            value: 172800
        }
    }
}
