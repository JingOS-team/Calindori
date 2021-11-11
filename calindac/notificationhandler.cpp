/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Wang Rui <wangrui@jingos.com>
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "notificationhandler.h"
#include "alarmnotification.h"
#include <KLocalizedString>
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QDBusConnection>

NotificationHandler::NotificationHandler(QObject *parent) : QObject(parent), m_active_notifications {QHash<QString, AlarmNotification*>()}, m_suspended_notifications {QHash<QString, AlarmNotification*>()}
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    m_suspend_seconds = generalGroup.readEntry("SuspendSeconds", 540);
    QDBusConnection::sessionBus().connect(QString(), QString("/org/kde/jingos/calendar"), "org.kde.jingos.calendar",
                                                        "eventRemove", this, SLOT(eventRemove(QString)));
}

NotificationHandler::~NotificationHandler() = default;

void NotificationHandler::eventRemove(const QString &uid)
{
    Q_EMIT scheduleAlarmCheck();
    //m_active_notifications.remove(uid);
    m_suspended_notifications.remove(uid);
}

void NotificationHandler::addActiveNotification(const QString &uid, const QString &title, const QString &text)
{
    AlarmNotification *notification = new AlarmNotification(this, uid);
    notification->setTitle(title);
    notification->setText(text);
    m_active_notifications[notification->uid()] = notification;
}

void NotificationHandler::addSuspendedNotification(const QString &uid, const QString &txt, const QDateTime &remindTime)
{
    AlarmNotification *notification = new AlarmNotification(this, uid);
    notification->setText(txt);
    notification->setRemindAt(remindTime);
    m_suspended_notifications[notification->uid()] = notification;
}

void NotificationHandler::sendSuspendedNotifications()
{
    auto suspItr = m_suspended_notifications.begin();
    while (suspItr != m_suspended_notifications.end()) {
        if (suspItr.value()->remindAt() < m_period.to) {
            suspItr.value()->send();
            suspItr = m_suspended_notifications.erase(suspItr);
        } else {
            suspItr++;
        }
    }
}

void NotificationHandler::sendActiveNotifications()
{
    for (const auto &n : qAsConst(m_active_notifications)) {
        n->send();
    }
}

void NotificationHandler::sendNotifications()
{
    sendSuspendedNotifications();
    sendActiveNotifications();
}
void NotificationHandler::sendNotificationsForUid(const QString &uid)
{
    if (m_active_notifications.contains(uid))
    {
        m_active_notifications[uid]->send();
    }

    // if(m_suspended_notifications.contains(uid))
    // {
    //     m_suspended_notifications[uid]->send();
    //     m_suspended_notifications.remove(uid);
    // }

}

void NotificationHandler::dismiss(AlarmNotification *const notification)
{
    m_active_notifications.remove(notification->uid());

    Q_EMIT scheduleAlarmCheck();
}

void NotificationHandler::suspend(AlarmNotification *const notification)
{

    AlarmNotification *suspendedNotification = new AlarmNotification(this, notification->uid());
    suspendedNotification->setText(notification->text());
    suspendedNotification->setTitle(notification->title());
    suspendedNotification->setRemindAt(QDateTime(QDateTime::currentDateTime()).addSecs(m_suspend_seconds));

    m_suspended_notifications[notification->uid()] = suspendedNotification;
    m_active_notifications.remove(notification->uid());

    Q_EMIT scheduleAlarmCheck();
}

FilterPeriod NotificationHandler::period() const
{
    return m_period;
}

void NotificationHandler::setPeriod(const FilterPeriod &checkPeriod)
{
    m_period = checkPeriod;
}

QHash<QString, AlarmNotification *> NotificationHandler::activeNotifications() const
{
    return m_active_notifications;
}

QHash<QString, AlarmNotification *> NotificationHandler::suspendedNotifications() const
{
    return m_suspended_notifications;
}

QDateTime NotificationHandler::firstSuspendedBefore(const QDateTime &before) const
{
    auto firstAlarmTime = QDateTime(before);

    for (const auto &s : qAsConst(m_suspended_notifications)) {
        auto alarmTime = s->remindAt();
        if (alarmTime < before) {
            firstAlarmTime = alarmTime;
        }
    }

    return firstAlarmTime;
}
