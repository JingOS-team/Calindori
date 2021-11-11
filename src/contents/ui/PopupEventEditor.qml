/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Bob <pengbo·wu@jingos.com>
 *
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.calindori 0.1 as Calindori
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15

Kirigami.JArrowPopup {
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
    property var currentIndex
    property var screenWidth: mainWindow.width
    property bool is24HourFormat: timezoneProxy.isSystem24HourFormat
    property bool monthViewVisible
    property int commMargin: popup.width / 16
    property bool isDataChanged
    property bool isTimeDataChanged
    property var sourceView
    property var currentAlerTimeName
    property int collapseHeight: mainWindow.height / 1.24
    property int expandHeight: mainWindow.height / 1.11
    property int popupTopMargin : mainWindow.height / 8.8
    property alias rightBarY : rightBar.y
    property bool isCoverArea: false
    property bool isSaveBtClick: false
    property var arrowPosition : Kirigami.JRoundRectangle.ARROW_TOP
    property bool isLoadFirstDate : false

    signal pmSelectorChanged(bool b)
    signal dateValueChanged(var type, int value)

    anchors.centerIn: parent
    topMargin: 71 * appScale
    leftMargin: root.width - width

    width: 310 * appScale
    height: 560 * appScale

    contentHeight: height
    contentWidth: width
    padding: 0
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0
    leftPadding:0
    rightPadding:0
    topPadding:0
    bottomPadding:0

    blurBackground.arrowX: width * 0.85 * appScale + 2 * appScale
    blurBackground.arrowY: 300 * appScale
    blurBackground.arrowWidth: 16 * appScale
    blurBackground.arrowHeight: 11 * appScale

    modal: true
    focus: true
    closePolicy: isDataChanged | isTimeDataChanged ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)

    Overlay.modal: Rectangle {
        color: "transparent"
    }

    onDateValueChanged: {
    }

    onPmSelectorChanged: {
        if(startPm == b)
            return
        startPm = b
        isTimeDataChanged = true
    }

    onClosed: {
        rowMain.setListViewItem(-1)
    }

    onOpened: {
        isSaveBtClick = false
        isDataChanged = false
        isTimeDataChanged = false
        calendarMonth.initWidgetState()
        calendarMonth.updateWheelViewData()
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0;
                duration: 75
            }
        }
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
        isLoadFirstDate = false
        arrowPosition = Kirigami.JRoundRectangle.ARROW_RIGHT
        popupTopMargin = mainWindow.height / 14.8
        scroll.visible = true
        rowTitle.visible = true
        eventSummary.focus = true
        eventSummary.text = incidenceData ? incidenceData.summary : ""
        var newDt

        if (incidenceData) {
            newDt = incidenceData.dtstart
        } else {
            newDt = startDt
            newDt.setMinutes(newDt.getMinutes() + _calindoriConfig.eventsDuration)
            newDt.setSeconds(0)
        }
        popup.startDt = newDt;
        eventDate.selectorDate = newDt
        eventTime.selectorHour = newDt.getHours()
        eventTime.selectorMinutes = newDt.getMinutes()

        eventTime.selectorPm = popup.incidenceData ? (popup.incidenceData.dtstart.getHours()>= 12) : (popup.startDt.getHours() >= 12)

        calendarMonth.selectedDate = newDt
        calendarMonth.selectorHour = newDt.getHours()
        calendarMonth.selectorMinutes = newDt.getMinutes()

        var displayNameTrim =  incidenceAlarmsModel.displayText(0)
        currentAlerTimeName = displayNameTrim
        eventAlert.text = i18n(displayNameTrim)
        rightBar.visible = false
        calendarMonth.pmSelected = startPm

        titleLabel.text = i18n("Edit Event")
        setExpandHeight()
    }

    function initFirstData() {
        isLoadFirstDate = true
        arrowPosition = Kirigami.JRoundRectangle.ARROW_TOP
        popupTopMargin = mainWindow.height / 8.2
        scroll.visible = true
        rowTitle.visible = true
        eventSummary.focus = true
        eventSummary.forceActiveFocus()
        eventSummary.text = ""

        var currentDt = _eventController.localSystemDateTime()
        var startDt = calendarMonthView.selectedDate
        startDt.setHours(currentDt.getHours())
        startDt.setMinutes(currentDt.getMinutes())
        startDt.setSeconds(0)

        startHour = startDt.getHours()
        startMinute = startDt.getMinutes()
        popup.startDt = startDt;

        calendarMonth.selectorHour = is24HourFormat ? startDt.getHours() : (startDt.getHours() % 12 == 0 ? 12 : startDt.getHours() % 12)
        calendarMonth.selectorMinutes = startDt.getMinutes()
        calendarMonth.selectedDate = startDt

        uid = ""
        localAlarmsModel.removeAll()
        incidenceAlarmsModel = localAlarmsModel
        currentAlerTimeName = "None"
        eventAlert.text = i18n("None")
        rightBar.visible = false
        if(!is24HourFormat) {
            startPm = startDt.getHours() >= 12
        }
        calendarMonth.pmSelected = startPm
        incidenceData = null

        titleLabel.text = i18n("New Event")

        setCollapseHeight()
    }

    function setCollapseHeight() {
        popup.contentHeight = collapseHeight
    }

    function setExpandHeight() {
        popup.contentHeight = expandHeight
    }

    Rectangle {
        id: rightBar

        y: rightBarY

        anchors.right: parent.right
        anchors.rightMargin: - 12 * appScale

        width: 32 * appScale
        height: 32 * appScale

        visible: true
        rotation: 45
        color: isDarkTheme ? "#E626262A" : "white"
    }

    contentItem: StackView {
        id: stackItem

        clip: true
        popEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: 75
                }
            }
        }

        popExit: Transition {
            ParallelAnimation {

                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: 75
                }
            }
        }

        pushEnter: Transition {
            ParallelAnimation {

                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: 75
                }
            }
        }

        pushExit: Transition {
            ParallelAnimation {

                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: 75
                }
            }
        }

        initialItem: Item {
            id: eventItem

            anchors {
                top: parent.top
                topMargin: 21 * appScale
                left: parent.left
                right: parent.right
                leftMargin: 20 * appScale
                rightMargin: 20 * appScale
            }

            RowLayout {
                id: rowTitle

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Kirigami.Label {
                    id: titleLabel

                    text: i18n("New Event")
                    font.pixelSize: 20 *appFontSize
                    color: majorForeground
                }

                Kirigami.Separator {
                    Layout.fillWidth: true

                    color: "transparent"
                }

                Kirigami.JIconButton {
                    id: eventCacel

                    anchors.right: eventConfirm.left
                    anchors.rightMargin: 20 * appScale

                    implicitWidth: 32 * appScale
                    implicitHeight: 31 * appScale

                    source: "qrc:/assets/event_cancel.png"

                    onClicked: {
                        rowMain.eventCancelCompleted()
                        popup.close()
                    }
                }

                Kirigami.JIconButton {
                    id: eventConfirm

                    anchors.right: parent.right
                    implicitWidth: 32 * appScale
                    implicitHeight: 31 * appScale
                    source: "qrc:/assets/event_confirm.png"
                    enabled: isDataChanged | isTimeDataChanged
                    opacity: enabled ? 1 : 0.4

                    onClicked: {
                        if (isSaveBtClick) {
                            return;
                        }
                        isSaveBtClick = true
                        var mSummary = popup.summary == "" ? i18n("New Schedule") : popup.summary
                        var mStart = popup.startDt
                        mStart.setHours(popup.startHour)
                        mStart.setMinutes(0)
                        mStart.setSeconds(0)

                        var currentHour =  is24HourFormat ? popup.startHour  : popup.startHour  % 12
                        var vevent = {
                            "uid": popup.uid,
                            "startDate": mStart,
                            "summary": mSummary,
                            "description": popup.description,
                            "startHour": (currentHour + (!is24HourFormat
                                                            && popup.startPm ? 12 : 0)),
                            "startMinute": popup.startMinute,
                            "allDay": popup.allDay,
                            "location": popup.location,
                            "endDate": popup.startDt,
                            "endHour": (currentHour + (!is24HourFormat
                                                        && popup.startPm ? 12 : 0)),
                            "endMinute": popup.startMinute,
                            "alarms": incidenceAlarmsModel.alarms(),
                            "periodType": popup.repeatType,
                            "repeatEvery": popup.repeatEvery,
                            "stopAfter": popup.repeatStopAfter
                        }

                        var validation = _eventController.validate(vevent)
                        if (validation.success) {
                            var currentUid = _eventController.addEdit(localCalendar, vevent)
                            rowMain.eventAddCompleted()
                            calendarMonthView.notifyCalendarChanged(popup.startDt,currentUid)
                        } else {
                            showPassiveNotification(validation.reason)
                        }
                        popup.close()
                    }
                }
            }

            Item {
                id: scroll

                anchors.bottom: blankRect.top
                anchors.bottomMargin: -6 * appScale
                anchors.top: rowTitle.bottom
                anchors.topMargin:22 * appScale
                anchors.left: parent.left
                anchors.right: parent.right

                height: parent.height

                ColumnLayout {
                    id: columnLayout

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    spacing:0

                    Item {
                        Layout.preferredHeight: 45 * appScale
                        Layout.fillWidth: true
                        Image {
                            id: summaryIcon
                            width: 22 * appScale
                            height: 22 * appScale
                            anchors.verticalCenter: parent.verticalCenter
                            source: "qrc:/assets/edit_event_summary.png"
                        }

                        Kirigami.JTextField {
                            id: eventSummary

                            anchors {
                                left: summaryIcon.right
                                leftMargin: popup.width / 31
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            leftPadding:0
                            maximumLength: 50
                            placeholderTextColor: majorForeground
                            text: incidenceData ? incidenceData.summary : ""
                            font.pixelSize: 14 * appFontSize
                            placeholderText: i18n("Title")
                            background: Item {}
                            onTextChanged: {
                                isDataChanged = true
                            }
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom
                            width: parent.width

                            color: dividerForeground
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
                                id: alertIcon

                                anchors.verticalCenter: parent.verticalCenter

                                width: 22 * appScale
                                height: 22 * appScale

                                source: "qrc:/assets/event_alarm.png"
                            }

                            Kirigami.Label {
                                anchors {
                                    left: alertIcon.right
                                    leftMargin: popup.width / 31
                                    verticalCenter: parent.verticalCenter
                                }

                                font.pixelSize: 14 * appFontSize
                                color: majorForeground
                                text: i18n("Alert")
                            }

                            Kirigami.Label {
                                id: eventAlert

                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }

                                opacity: 0.6
                                color: majorForeground
                                font.pixelSize: 14 * appFontSize
                                text: i18n(currentAlerTimeName)

                                onTextChanged: {
                                    isDataChanged = incidenceAlarmsModel
                                            && incidenceAlarmsModel.displayText(0) !== text
                                }
                            }

                            Kirigami.Separator {
                                anchors.bottom: parent.bottom

                                width: parent.width

                                color: dividerForeground
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    popup.isTimeDataChanged = true
                                    stackItem.push(alertItem)
                                }
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

                                width: 22 * appScale
                                height: 22 * appScale

                                source: "qrc:/assets/edit_event_time.png"
                            }

                            Kirigami.Label {
                                anchors {
                                    left: timeIcon.right
                                    leftMargin: popup.width / 31
                                    verticalCenter: parent.verticalCenter
                                }

                                font.pixelSize: 14 * appFontSize
                                text: i18n("Time")
                                color: majorForeground
                            }

                            DateSelectorButton {
                                id: eventDate

                                anchors {
                                    right: eventTime.left
                                    rightMargin: 10 * appScale
                                    verticalCenter: parent.verticalCenter
                                }

                                implicitWidth: popup.width / 3

                                font.pixelSize: 14 *appFontSize
                                textColor: "red"
                                selectorDate: _eventController.localSystemDateTime()
                                enabled: false
                            }

                            TimeSelectorButton {
                                id: eventTime

                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }

                                font.pixelSize: 14 * appFontSize
                                textColor: "red"
                                selectorDate: popup.startDt
                                is24HourFormat: popup.is24HourFormat
                                selectorHour: popup.incidenceData ? (is24HourFormat ? popup.incidenceData.dtstart.getHours() : popup.incidenceData.dtstart.getHours() % 12) : (is24HourFormat ? popup.startDt.getHours() : popup.startDt.getHours() % 12)

                                selectorMinutes: popup.incidenceData ? popup.incidenceData.dtstart.getMinutes() : popup.startDt.getMinutes()
                                selectorPm: popup.incidenceData ? (popup.incidenceData.dtstart.getHours()>= 12) : (popup.startDt.getHours() >= 12)
                                enabled: false
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    isTimeDataChanged = true
                                }
                            }
                        }
                    }

                    PickerMonthView {
                        id: calendarMonth

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft

                        visible: true
                        selectedDate: startDt
                        selectorHour: is24HourFormat ? popup.startHour  : popup.startHour  % 12
                        selectorMinutes: startMinute
                    }
                }
            }

            Item {
                anchors.fill: scroll
                width:scroll.width
                height:scroll.height

                visible: isCoverArea

                MouseArea {
                    width:isCoverArea ? parent.width : 0
                    height:isCoverArea ? parent.width : 0

                    onClicked:{
                        isCoverArea = false
                    }
                }
            }

            Rectangle {
                id: blankRect

                anchors.bottom: stackItem.bottom
                anchors.bottomMargin: 24 * appScale
                width: parent.width
                height: 12 * appScale

                color:"transparent"
            }
        }
    }

    Component {
        id: alertItem
        Item {
            id: alertSelector

            anchors {
                top: parent.top
                topMargin: 21 * appScale
                left: parent.left
                right: parent.right
                leftMargin: 10 * appScale
                rightMargin: 10 * appScale
            }

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    id: alertTtile

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Kirigami.JIconButton {
                        id: alertBack

                        implicitWidth: 32 * appScale
                        implicitHeight: 31 * appScale
                        source: "qrc://assets/alert_back.png"

                        onClicked: {
                            stackItem.pop()
                        }
                    }

                    Kirigami.Label {
                        id: alertName

                        font.pixelSize: 20 *appFontSize
                        text: i18n("Alert")
                        color: majorForeground

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stackItem.pop()
                            }
                        }
                    }
                }

                ListView {
                    id: alertListView

                    anchors {
                        top: alertTtile.bottom
                        left: alertTtile.left
                        leftMargin: 10 * appFontSize
                        rightMargin: 10 * appFontSize
                        right: alertTtile.right
                        bottom: parent.bottom
                        topMargin: 17 * appScale
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

                            text: i18n(model.displayName)
                            font.pixelSize: 14 * appFontSize
                            color: majorForeground
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            implicitWidth: parent.width
                            implicitHeight: 1 * appScale

                            visible: index == listModel.count - 1 ? false : true
                            color: dividerForeground
                        }

                        Image {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: popup.width / 14
                            height: popup.width / 14

                            visible: currentAlerTimeName === model.displayName ? true : false
                            source: "qrc:/assets/alert_time_selected.png"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                stackItem.pop()

                                currentAlerTimeName = model.displayName
                                isDataChanged = true
                                currentIndex = index

                                eventAlert.text = i18n(listModel.get(currentIndex).displayName)

                                if (listModel.get(currentIndex).value === -1) {
                                    incidenceAlarmsModel.removeAll()
                                } else {
                                    incidenceAlarmsModel.removeAll()
                                    incidenceAlarmsModel.addAlarm(listModel.get(currentIndex).value)
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
            displayName: " 5 minutes before"
            value: 300
        }
        ListElement {
            displayName: " 10 minutes before"
            value: 600
        }
        ListElement {
            displayName: " 15 minutes before"
            value: 900
        }
        ListElement {
            displayName: " 30 minutes before"
            value: 1800
        }
        ListElement {
            displayName: " 1 hour before"
            value: 3600
        }
        ListElement {
            displayName: " 2 hours before"
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
