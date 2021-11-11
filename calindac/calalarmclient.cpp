/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calalarmclient.h"
#include "alarmnotification.h"
#include "alarmsmodel.h"
#include "notificationhandler.h"
#include "calindacadaptor.h"
#include "solidwakeupbackend.h"
#include "wakeupmanager.h"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QVariantMap>
#include <QDateTime>
#include <KLocalizedString>
#include <QDBusServiceWatcher>

using namespace KCalendarCore;

CalAlarmClient::CalAlarmClient(QObject *parent)
    : QObject(parent), m_alarms_model {new AlarmsModel(this)}, m_notification_handler {new NotificationHandler(this)}, m_wakeup_manager {new WakeupManager(this)}
{
    new CalindacAdaptor(this);

    QDBusConnection::sessionBus().registerObject("/calindac", this);

    QDBusServiceWatcher *serviceWatcher = new QDBusServiceWatcher("org.kde.Solid.PowerManagement",QDBusConnection::sessionBus(),QDBusServiceWatcher::WatchModeFlag::WatchForRegistration);
    connect(serviceWatcher,&QDBusServiceWatcher::serviceRegistered,this,&CalAlarmClient::serviceWatcherFinished);
    QDBusConnection::sessionBus().connect(QString(), QString("/org/kde/kcmshell_clock"), "org.kde.kcmshell_clock",
                                                        "clockUpdated", this, SLOT(clockUpdated()));

    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    m_check_interval = generalGroup.readEntry("CheckInterval", 45);
    m_suspend_seconds = generalGroup.readEntry("SuspendSeconds", 540);
    m_last_check = generalGroup.readEntry("CalendarsLastChecked", QDateTime());

    restoreSuspendedFromConfig();
    saveCheckInterval();
    saveSuspendSeconds();
    checkAlarms();

    if ((m_wakeup_manager != nullptr) && (m_wakeup_manager->active())) {
        connect(m_wakeup_manager, &WakeupManager::wakeupAlarmClient, this, &CalAlarmClient::wakeupCallback);
        connect(m_notification_handler, &NotificationHandler::scheduleAlarmCheck, this, &CalAlarmClient::scheduleAlarmCheck);
        scheduleAlarmCheck();
    } else {
        connect(&m_check_timer, &QTimer::timeout, this, &CalAlarmClient::checkAlarms);
        //m_check_timer.start(1000 * m_check_interval);
        m_check_timer.start(1000);
    }
}

void CalAlarmClient::clockUpdated()
{
    m_notification_handler = new NotificationHandler(this);
    checkAlarms();
}

void CalAlarmClient::serviceWatcherFinished(const QString &serviceName)
{
    m_wakeup_manager->setActive(true);
    if (m_check_timer.isActive()) {
        m_check_timer.stop();
    }

    connect(m_wakeup_manager, &WakeupManager::wakeupAlarmClient, this, &CalAlarmClient::wakeupCallback);
    connect(m_notification_handler, &NotificationHandler::scheduleAlarmCheck, this, &CalAlarmClient::scheduleAlarmCheck);
    
    scheduleAlarmCheck();
}

CalAlarmClient::~CalAlarmClient() = default;

QStringList CalAlarmClient::calendarFileList() const
{
    auto filesList { QStringList() };
    KConfigGroup calindoriCfgGeneral(KSharedConfig::openConfig("calindorirc"), "general");
    auto iCalendars = calindoriCfgGeneral.readEntry("calendars", QString());
    auto eCalendars = calindoriCfgGeneral.readEntry("externalCalendars", QString());

    auto calendarsList = iCalendars.isEmpty() ? QStringList() : iCalendars.split(";");
    if (!(eCalendars.isEmpty())) {
        calendarsList.append(eCalendars.split(";"));
    }

    for (const auto &c : qAsConst(calendarsList)) {
        QString fileName = KSharedConfig::openConfig("calindorirc")->group(c).readEntry("file");

        if (!(fileName.isNull())) {
            filesList.append(fileName);
        }
    }

    return filesList;
}

void CalAlarmClient::checkAlarms()
{
    KConfigGroup cfg(KSharedConfig::openConfig(), "General");

    if (!cfg.readEntry("Enabled", true)) {
        return;
    }

    auto checkFrom = m_last_check.addSecs(1);
    m_last_check = QDateTime::currentDateTime();

    FilterPeriod fPeriod { .from =  checkFrom, .to = m_last_check };
    m_alarms_model->setCalendarFiles(calendarFileList());
    m_alarms_model->setPeriod(fPeriod);
    m_notification_handler->setPeriod(fPeriod);

    auto alarms = m_alarms_model->alarms();

    for (const auto &alarm : qAsConst(alarms)) {

        auto notifityList = m_notification_handler->activeNotifications();
        if(!notifityList.contains(alarm->parentUid()))
        {
            m_notification_handler->addActiveNotification(alarm->parentUid(), alarm->text(),alarm->time().toString("hh:mm"));
            m_notification_handler->sendNotificationsForUid(alarm->parentUid());
        }
    }
    m_notification_handler->sendSuspendedNotifications();
    //m_notification_handler->sendNotifications();
    saveLastCheckTime();
    flushSuspendedToConfig();
}

void CalAlarmClient::saveLastCheckTime()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("CalendarsLastChecked", m_last_check);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveCheckInterval()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("CheckInterval", m_check_interval);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveSuspendSeconds()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("SuspendSeconds", m_suspend_seconds);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::quit()
{
    flushSuspendedToConfig();
    saveLastCheckTime();
    qApp->quit();
}

void CalAlarmClient::forceAlarmCheck()
{
    checkAlarms();
    saveLastCheckTime();
}

QString CalAlarmClient::dumpLastCheck() const
{
    KConfigGroup cfg(KSharedConfig::openConfig(), "General");
    const QDateTime lastChecked = cfg.readEntry("CalendarsLastChecked", QDateTime());

    return QStringLiteral("Last Check: %1").arg(lastChecked.toString());
}

QStringList CalAlarmClient::dumpAlarms() const
{
    const auto start = QDateTime(QDate::currentDate(), QTime(0, 0), Qt::LocalTime);
    const auto end = start.addDays(1).addSecs(-1);

    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({ .from =  start, .to = end});

    auto lst = QStringList();
    const auto alarms = model.alarms();

    for (const auto &alarm : qAsConst(alarms)) {
        lst << QStringLiteral("%1: \"%2\"").arg(alarm->time().toString("hh:mm"), alarm->parentUid());
    }

    return lst;
}

void CalAlarmClient::restoreSuspendedFromConfig()
{
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), "Suspended");
    const auto suspendedAlarms = suspendedGroup.groupList();

    for (const auto &s : suspendedAlarms) {
        KConfigGroup suspendedAlarm(&suspendedGroup, s);
        QString uid = suspendedAlarm.readEntry("UID");
        QString txt = alarmText(uid);
        QDateTime remindAt = QDateTime::fromString(suspendedAlarm.readEntry("RemindAt"), "yyyy,M,d,HH,m,s");

        if (!(uid.isEmpty() && remindAt.isValid() && !(txt.isEmpty()))) {
            m_notification_handler->addSuspendedNotification(uid, txt, remindAt);
        }
    }
}

QString CalAlarmClient::alarmText(const QString &uid) const
{
    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({.from = QDateTime(), .to = QDateTime::currentDateTime()});
    const auto alarms = model.alarms();

    for (const auto &alarm : qAsConst(alarms)) {
        if (alarm->parentUid() == uid) {
            return alarm->text();
        }
    }

    return QString();
}

void CalAlarmClient::flushSuspendedToConfig()
{
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), "Suspended");
    suspendedGroup.deleteGroup();

    const auto suspendedNotifications = m_notification_handler->suspendedNotifications();

    if (suspendedNotifications.isEmpty()) {
        KSharedConfig::openConfig()->sync();

        return;
    }

    for (const auto &s : suspendedNotifications) {
        KConfigGroup notificationGroup(&suspendedGroup, s->uid());
        notificationGroup.writeEntry("UID", s->uid());
        notificationGroup.writeEntry("RemindAt", s->remindAt());
    }
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::scheduleAlarmCheck()
{
    if ((m_wakeup_manager == nullptr) || !(m_wakeup_manager->active())) {
        return;
    }


    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({ .from =  m_last_check.addSecs(1), .to = m_last_check.addDays(1) });

    auto wakeupAt = model.firstAlarmTime();
    auto suspendedWakeupAt = m_notification_handler->firstSuspendedBefore(wakeupAt);

    if (suspendedWakeupAt.isValid() && suspendedWakeupAt < wakeupAt) {
        wakeupAt = suspendedWakeupAt;
    }

    m_wakeup_manager->scheduleWakeup(wakeupAt.addSecs(1));
}

void CalAlarmClient::wakeupCallback()
{

    checkAlarms();
    scheduleAlarmCheck();
}
