/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {

    property int mouseX
    property int mouseY
    property var sourceView
    property var fastBlurRadius: 144
    property var rectRadius: 0
    property var maskOpacity: 0.8

    ShaderEffectSource {
        id: eff

        anchors.centerIn: fastBlur

        width: fastBlur.width
        height: fastBlur.height

        visible: false
        sourceItem: sourceView
        sourceRect: Qt.rect(mouseX, mouseY, width, height)

        function getItemX(width, height) {
            var mapItem = eff.mapToItem(sourceView, mouseX, mouseY,
                                        width, height)
            return mapItem.x
        }

        function getItemY(width, height) {
            var mapItem = eff.mapToItem(sourceView, mouseX, mouseY,
                                        width, height)
            return mapItem.y
        }
    }

    FastBlur {
        id: fastBlur

        anchors.fill: parent

        source: eff
        radius: fastBlurRadius
        cached: true
        visible: false
    }

    Rectangle {
        id: maskRect

        anchors.fill: fastBlur

        visible: false
        clip: true
        radius: rectRadius
    }

    OpacityMask {
        id: mask

        anchors.fill: maskRect

        visible: true
        source: fastBlur
        maskSource: maskRect
        opacity: maskOpacity
    }
}
