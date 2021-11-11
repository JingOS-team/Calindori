/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "wakeupmanager.h"
#include "solidwakeupbackend.h"
#include "powermanagementadaptor.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDebug>

WakeupManager::WakeupManager(QObject *parent) : QObject(parent), m_cookie {-1}, m_active {false}
{
    m_callback_info = QVariantMap({
        {"dbus-service", QString { "org.kde.calindac"} },
        {"dbus-path", QString {"/wakeupmanager"} }
    });

    new PowerManagementAdaptor(this);
    m_wakeup_backend = new SolidWakeupBackend(this);

    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject(m_callback_info["dbus-path"].toString(), this);

    checkBackend();
}

void WakeupManager::scheduleWakeup(const QDateTime wakeupAt)
{
    if (wakeupAt <= QDateTime::currentDateTime()) {
        return;
    }

    auto scheduledCookie = m_wakeup_backend->scheduleWakeup(m_callback_info, wakeupAt.toSecsSinceEpoch()).toInt();

    if (scheduledCookie > 0) {

        if (m_cookie > 0) {
            removeWakeup(m_cookie);
        }

        m_cookie = scheduledCookie;
    }
}

void WakeupManager::wakeupCallback(int cookie)
{

    if (m_cookie == cookie) {
        m_cookie = -1;
        Q_EMIT wakeupAlarmClient();
    }
}

void WakeupManager::removeWakeup(int cookie)
{

    m_wakeup_backend->clearWakeup(cookie);
    m_cookie = -1;
}

void WakeupManager::checkBackend()
{
    auto checkCookie = m_wakeup_backend->scheduleWakeup(m_callback_info, QDateTime::currentDateTime().addDays(1).toSecsSinceEpoch()).toInt();

    if (checkCookie > 0) {
        m_wakeup_backend->clearWakeup(checkCookie);
        setActive(true);
    } else {
        setActive(false);
    }
}

bool WakeupManager::active() const
{
    return m_active;
}

void WakeupManager::setActive(const bool activeBackend)
{
    if (activeBackend != m_active) {
        m_active = activeBackend;
        Q_EMIT activeChanged();
    }
}
