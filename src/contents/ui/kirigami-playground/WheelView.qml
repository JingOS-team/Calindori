/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Bob <pengbo·wu@jingos.com>
 *
 */

import QtQuick 2.0
import QtQml 2.12

PathView {
    id: root

    property bool starIndexZero: true
    property bool bgShow
    property int value
    property int displayFontSize: 20
    property real displayStep: 0.6

    width: 100
    height: 300
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5

    signal viewMove(var index)

    focus: true
    clip: true
    pathItemCount: 7
    dragMargin: root.width / 2

    Component.onCompleted: findCurrentIndex()

    onMovementEnded: {
        viewMove(model[currentIndex].value)
    }

    onModelChanged: {
        timer.restart()
    }

    Timer {
        id: timer

        interval: 1000
        repeat: false

        onTriggered: {
            findCurrentIndex()
        }
    }

    onValueChanged: {
        findCurrentIndex()
    }

    Keys.onUpPressed: {
        root.decrementCurrentIndex()
        value = (model[currentIndex].value)
    }

    Keys.onDownPressed: {
        root.incrementCurrentIndex()
        value = (model[currentIndex].value)
    }

    delegate: Item {
        id: delegate

        width: root.width
        height: root.height / pathItemCount

        Text {
            anchors.centerIn: parent

            font.pixelSize: displayFontSize
            text: modelData.display
            opacity: currentIndex == index ? 1 : 0.3
            color: majorForeground
        }
    }

    path: Path {
        startX: root.width / 2
        startY: 0

        PathAttribute {
            name: "textFontPercent"
            value: displayStep
        }

        PathLine {
            x: root.width / 2
            y: root.height / 2
        }

        PathAttribute {
            name: "textFontPercent"
            value: 1
        }

        PathLine {
            x: root.width / 2
            y: root.height
        }

        PathAttribute {
            name: "textFontPercent"
            value: displayStep
        }
    }

    function findCurrentIndex() {
        if (starIndexZero) {
            currentIndex = value
        } else {
            for (var i = 0; i < count; i++)
                if (model[i].value === value) {
                    currentIndex = i
                    break
                }
        }
    }

    Rectangle {
        id: backgroud

        anchors.centerIn: parent

        width: parent.width
        height:  root.height / pathItemCount + 6 * appScale

        visible: bgShow
        color: "#1F767680"
        radius: 7 * appScale
    }
}
