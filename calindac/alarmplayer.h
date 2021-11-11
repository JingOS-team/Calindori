/*
 * SPDX-FileCopyrightText: 2021 Meng De Xiang <dexiang.meng@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QMediaPlayer>
#include <QStandardPaths>
#include <QObject>

class AlarmPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
public:
    static AlarmPlayer &instance();
    int volume()
    {
        return m_player->volume();
    };
    Q_INVOKABLE void setVolume(int volume);
    Q_INVOKABLE void setSource(QUrl path);
    Q_INVOKABLE void play();
    Q_INVOKABLE void stop();

signals:
    void volumeChanged();

protected:
    explicit AlarmPlayer(QObject *parent = nullptr);

private:
    QMediaPlayer *m_player;
    quint64 startPlayingTime = 0;

    bool userStop = false; // indicate if user asks to stop
private slots:
    void loopAudio(QMediaPlayer::State state);
};
