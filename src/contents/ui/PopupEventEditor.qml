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
    property int collapseHeight: mainWindow.height / 1.24
    property int expandHeight: mainWindow.height / 1.11
    property int popupTopMargin : mainWindow.height / 8.8
    property alias rightBarY : rightBar.y
    property bool isCoverArea: false

    signal pmSelectorChanged(bool b)
    signal dateValueChanged(var type, int value)

    anchors.centerIn: parent
    topMargin: popupTopMargin
    leftMargin: mainWindow.width / 2.6

    width: mainWindow.width / 1920 * 620

    contentHeight: expandHeight
    contentWidth: mainWindow.width / 1920 * 620
    padding: 0
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
        eventSummary.cursorPosition = 0
        isDataChanged = false
        isTimeDataChanged = false
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
        popupTopMargin = mainWindow.height / 14.8
        scroll.visible = true
        alertSelector.visible = false
        rowTitle.visible = true
        eventSummary.focus = false
        eventSummary.text = incidenceData ? incidenceData.summary : ""
        var newDt

        if (incidenceData) {
            newDt = incidenceData.dtstart
        } else {
            newDt = startDt
            newDt.setMinutes(newDt.getMinutes(
                                 ) + _calindoriConfig.eventsDuration)
            newDt.setSeconds(0)
        }
        popup.startDt = newDt;
        eventDate.selectorDate = newDt
        eventTime.selectorHour = newDt.getHours()
        eventTime.selectorMinutes = newDt.getMinutes()

        calendarMonth.selectedDate = newDt
        calendarMonth.selectorHour = newDt.getHours()
        calendarMonth.selectorMinutes = newDt.getMinutes()

        var displayNameTrim =  incidenceAlarmsModel.displayText(0)
        currentAlerTimeName = displayNameTrim
        eventAlert.text = i18n(displayNameTrim)
        popup.upBarVisible = false
        rightBar.visible = true
        calendarMonth.pmSelected = startPm

        titleLabel.text = i18n("Edit Event")
        setExpandHeight()
    }

    function initFirstData() {
        popupTopMargin = mainWindow.height / 8.2
        scroll.visible = true
        alertSelector.visible = false
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

        calendarMonth.selectorHour = startDt.getHours()
        calendarMonth.selectorMinutes = startDt.getMinutes()
        calendarMonth.selectedDate = startDt

        uid = ""
        localAlarmsModel.removeAll()
        incidenceAlarmsModel = localAlarmsModel
        currentAlerTimeName = "None"
        eventAlert.text = i18n("None")
        popup.upBarVisible = true
        rightBar.visible = false
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

        y:rightBarY
        
        anchors.right: parent.right
        anchors.rightMargin: -12 * appScale

        width: 32 * appScale
        height: 32 * appScale

        visible: false
        rotation: 45
    }

    background: Rectangle {
        id: background

        anchors.fill:parent

        color:"transparent"

        Rectangle{
            anchors.top:parent.top

            width:parent.width
            height: 32 * appScale

            radius: 12
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 40
                samples: 25
                color: "#1A000000"
                verticalOffset: 0
                horizontalOffset: 0
                spread: 0
            }
        }

        Rectangle {
            id: upBar

            anchors.top: parent.top
            anchors.topMargin: -12 * appScale
            anchors.right: parent.right
            anchors.rightMargin: 42

            width: 32 * appScale
            height: 32 * appScale

            color:"white"
            visible: true
            rotation: 45

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 40
                samples: 25
                color: "#1A000000"
                verticalOffset: 0
                horizontalOffset: 0
                spread: 0
            }
        }
    }

    contentItem: Rectangle {
        id: contentItem

        anchors.centerIn: parent
        implicitWidth: parent.width

        radius: 12

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: -10
            radius: 40
            samples: 25
            color: "#1A000000"
            verticalOffset: 20
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

                text: i18n("New Event")
                font.pixelSize: 20
                
            }

            Kirigami.Separator {
                Layout.fillWidth: true

                color: "transparent"
            }

            Kirigami.JIconButton {
                id: eventCacel

                anchors.right: eventConfirm.left
                anchors.rightMargin: popup.width / 9.25 - 15

                width: 32
                height: 32

                source: "qrc:/assets/event_cancel.png"

                onClicked: {
                    rowMain.eventCancelCompleted()
                    popup.close()
                }
            }

            Kirigami.JIconButton {
                id: eventConfirm

                anchors.right: parent.right

                width: popup.width / 14 + 10
                height: popup.width / 14.74 + 10

                source: "qrc:/assets/event_confirm.png"
                enabled: isDataChanged | isTimeDataChanged

                opacity: enabled ? 1 : 0.4

                onClicked: {
                    var mSummary = popup.summary == "" ? "New schedule" : popup.summary
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

        ScrollView {
            id: scroll

            anchors.bottom: blankRect.top
            anchors.bottomMargin: -6 * appScale
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

                            sourceSize.width: 22
                            sourceSize.height: 22

                            source: "qrc:/assets/edit_event_summary.png"
                        }

                        TextField {
                            id: eventSummary

                            anchors {
                                left: summaryIcon.right
                                leftMargin: popup.width / 31
                                right: clearIcon.left
                                verticalCenter: parent.verticalCenter
                            }

                            maximumLength: 50
                            text: incidenceData ? incidenceData.summary : ""
                            font.pixelSize: 14
                            placeholderText: i18n("Title")

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

                        Kirigami.JIconButton {
                            id:clearIcon

                            anchors{
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            width: popup.width / 19.375 + 10
                            height: popup.width / 18.235 + 10

                            visible: eventSummary.text.length > 0
                            source: "qrc:/assets/icon_clear.png"
                            
                            onClicked: {
                                isDataChanged = true
                                eventSummary.text = ""
                            }
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            width: parent.width

                            color: "#FFE5E5EA"
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
                            id: alertIcon

                            anchors.verticalCenter: parent.verticalCenter

                            sourceSize.width: 22
                            sourceSize.height: 22

                            source: "qrc:/assets/event_alarm.png"
                        }

                        Kirigami.Label {
                            anchors {
                                left: alertIcon.right
                                leftMargin: popup.width / 31
                                verticalCenter: parent.verticalCenter
                            }

                            font.pixelSize: 14
                            
                            text: i18n("Alert")
                        }

                        Kirigami.Label {
                            id: eventAlert

                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            opacity: 0.6
                            color: "black"
                            font.pixelSize: 14
                            text: i18n(currentAlerTimeName)

                            onTextChanged: {
                                isDataChanged = incidenceAlarmsModel
                                        && incidenceAlarmsModel.displayText(
                                            0) !== text
                            }
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            width: parent.width

                            color: "#FFE5E5EA"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                popup.isTimeDataChanged = true
                                if (alertSelector.visible == false) {
                                }
                                scroll.visible = false
                                alertSelector.visible = true
                                rowTitle.visible = false
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

                            sourceSize.width: 22
                            sourceSize.height: 22

                            source: "qrc:/assets/edit_event_time.png"
                        }

                        Kirigami.Label {
                            anchors {
                                left: timeIcon.right
                                leftMargin: popup.width / 31
                                verticalCenter: parent.verticalCenter
                            }

                            font.pixelSize: 14
                            text: i18n("Time")
                        }

                        DateSelectorButton {
                            id: eventDate

                            anchors {
                                right: eventTime.left
                                verticalCenter: parent.verticalCenter
                            }

                            implicitWidth: popup.width / 3

                            font.pixelSize: 14
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

                            font.pixelSize: 14
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
                    selectorHour: startHour
                    selectorMinutes: startMinute
                }


            }
        }

        Item {
            anchors.fill: scroll
            
            width:scroll.width
            height:scroll.height

            visible: isCoverArea

            MouseArea{
                width:isCoverArea ? parent.width : 0
                height:isCoverArea ? parent.width : 0
                onClicked:{
                    isCoverArea = false
                }
            }
        }

        Rectangle {
            id: blankRect

            anchors.bottom: contentItem.bottom
            anchors.bottomMargin: 24 * appScale

            width: parent.width
            height: 12 * appScale

            color: "white"
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
                            }
                        }
                    }

                    Kirigami.Label {
                        anchors.left: alertBack.right
                        anchors.verticalCenter: parent.verticalCenter

                        font.pixelSize: 20
                        text: i18n("Alert")
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

                            text: i18n(model.displayName)
                            font.pixelSize: 14
                        }

                        Kirigami.Separator {
                            anchors.bottom: parent.bottom

                            implicitWidth: parent.width
                            implicitHeight: 1

                            visible: index == listModel.count - 1 ? false : true
                            color: "#FFE5E5EA"
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

                                rowTitle.visible = true
                                scroll.visible = true
                                alertSelector.visible = false
                                eventAlert.text = i18n(listModel.get(
                                            currentIndex).displayName)

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
