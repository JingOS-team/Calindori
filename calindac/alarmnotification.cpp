/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 * 			    2021 Bob <pengbo·wu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <KLocalizedString>
#include <QDebug>
#include "alarmnotification.h"
#include "notificationhandler.h"
#include "alarmplayer.h"

AlarmNotification::AlarmNotification(NotificationHandler *handler, const QString &uid) : m_uid {uid}, m_remind_at {QDateTime()}, m_notification_handler {handler}
{
    m_notification = new KNotification("alarm");
    m_notification->setActions({i18n("Suspend"), i18n("Dismiss")});
    connect(m_notification, &KNotification::action1Activated, this, &AlarmNotification::suspend);
    connect(m_notification, &KNotification::action2Activated, this, &AlarmNotification::dismiss);
    connect(this, &AlarmNotification::suspend, m_notification_handler, [ = ]() {
        m_notification_handler->suspend(this);
        AlarmPlayer::instance().stop();
    });
    connect(this, &AlarmNotification::dismiss, m_notification_handler, [ = ]() {
        m_notification_handler->dismiss(this);
        AlarmPlayer::instance().stop();
    });
}

AlarmNotification::~AlarmNotification()
{
    delete m_notification;
}

void AlarmNotification::send() const
{
    m_notification->sendEvent();
    QUrl audioPath = QUrl::fromLocalFile(QStandardPaths::locate(QStandardPaths::GenericDataLocation, "sounds/jing/alarm-clock.oga"));
    AlarmPlayer::instance().setSource(audioPath);
    AlarmPlayer::instance().play();
}

QString AlarmNotification::uid() const
{
    return m_uid;
}

QString AlarmNotification::text() const
{
    return m_notification->text();
}

QString AlarmNotification::title() const
{
    return m_notification->title();
}

void AlarmNotification::setTitle(const QString &title)
{
    m_notification->setTitle(title);
}

void AlarmNotification::setText(const QString &alarmText)
{
    m_notification->setText(alarmText);
}

QDateTime AlarmNotification::remindAt() const
{
    return m_remind_at;
}

void AlarmNotification::setRemindAt(const QDateTime &remindAtDt)
{
    m_remind_at = remindAtDt;
}
