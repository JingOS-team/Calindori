/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *                         2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef DAYSOFMONTHMODEL_H
#define DAYSOFMONTHMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QDate>
#include <QLocale>

struct DayData {
    bool isCurrent;
    int dayNumber;
    int monthNumber;
    int yearNumber;
    bool isToday = false;
};

class DaysOfMonthModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int year READ year WRITE setYear NOTIFY yearChanged)
    Q_PROPERTY(int month READ month WRITE setMonth NOTIFY monthChanged)
    Q_PROPERTY(int daysPerWeek READ daysPerWeek WRITE setDaysPerWeek NOTIFY daysPerWeekChanged)
    Q_PROPERTY(int weeks READ weeks WRITE setWeeks NOTIFY weeksChanged)
    
public:
    enum Roles {
        CurrentMonthRole = Qt::UserRole + 1,
        DayNumberRole,
        MonthNumberRole,
        YearNumberRole,
        TodayRole
    };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;

    int year() const;

    int month() const;

    int daysPerWeek() const;
    void setDaysPerWeek(int daysPerWeek);

    int weeks() const;
    void setWeeks(int weeks);

    Q_INVOKABLE void setYear(int year);
    Q_INVOKABLE void setMonth(int month);
    Q_INVOKABLE void goNextMonth();
    Q_INVOKABLE void goPreviousMonth();
    Q_INVOKABLE void goCurrentMonth();
    Q_INVOKABLE void update();
    Q_INVOKABLE bool is24HourFormat();

Q_SIGNALS:
    void yearChanged();
    void monthChanged();
    void daysPerWeekChanged();
    void weeksChanged();

private:
    QVector<DayData> m_dayList;
    int m_firstDayOfWeek = QLocale::system().firstDayOfWeek();
    int m_year;
    int m_month;
    int m_daysPerWeek = 7;
    int m_weeks = 6;

    QDateTime lastChangedTime =  QDateTime::currentDateTime();;
};

#endif // DAYSOFMONTHMODEL_H
