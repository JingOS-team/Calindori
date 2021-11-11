/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *                         2021 Bob <pengbo·wu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QObject>

#ifndef EVENTCONTROLLER_H
#define EVENTCONTROLLER_H

#include <QObject>
#include <QVariantMap>
#include <QDBusMessage>

class LocalCalendar;

class EventController : public QObject
{
    Q_OBJECT

public:
    explicit EventController(QObject *parent = nullptr);
    ~EventController() override;

    Q_INVOKABLE void remove(LocalCalendar *calendar, const QVariantMap &event);
    Q_INVOKABLE QString addEdit(LocalCalendar *calendar, const QVariantMap &event);
    /**
     * @brief Returns the current datetime in the local time zone
     *
     * @return QDateTime
     */
    Q_INVOKABLE QDateTime localSystemDateTime() const;

    Q_INVOKABLE bool getRegionTimeFormat()const;
    /**
     * @brief Validate an event before saving
     *
     * @return A QVariantMap response to be handled by the caller
     */
    Q_INVOKABLE QVariantMap validate(const QVariantMap &eventMap) const;
private:
    QDBusMessage m_dbusMessage;

};
#endif
