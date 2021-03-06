/*
 * SPDX-FileCopyrightText: 2021 Meng De Xiang <dexiang.meng@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "alarmplayer.h"
#include <QStandardPaths>
#include <QDateTime>

AlarmPlayer &AlarmPlayer::instance()
{
    static AlarmPlayer singleton;
    return singleton;
}
AlarmPlayer::AlarmPlayer(QObject *parent)
    : QObject(parent)
    , m_player(new QMediaPlayer(this, QMediaPlayer::LowLatency))
{
    connect(m_player, &QMediaPlayer::stateChanged, this, &AlarmPlayer::loopAudio);
}

void AlarmPlayer::loopAudio(QMediaPlayer::State state)
{
    if (!userStop && state == QMediaPlayer::StoppedState/* && static_cast<int>(QDateTime::currentSecsSinceEpoch() - startPlayingTime) < settings.alarmSilenceAfter()*/) {
        m_player->play();
    }
}

void AlarmPlayer::play()
{
    if (m_player->state() == QMediaPlayer::PlayingState)
        return;

    startPlayingTime = QDateTime::currentSecsSinceEpoch();
    userStop = false;
    m_player->play();
}

void AlarmPlayer::stop()
{
    userStop = true;
    m_player->stop();
}

void AlarmPlayer::setVolume(int volume)
{
    m_player->setVolume(volume);
    Q_EMIT volumeChanged();
}

void AlarmPlayer::setSource(QUrl path)
{
    // if user set a invalid audio path or doesn't even specified a path, resort to default
    if (!path.isLocalFile())
        m_player->setMedia(QUrl::fromLocalFile(QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("sounds/freedesktop/stereo/alarm-clock-elapsed.oga"))));
    m_player->setMedia(path);
}
