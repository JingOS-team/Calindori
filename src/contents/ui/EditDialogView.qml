/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import org.kde.kirigami 2.15 as Kirigami

Menu {
    id: menu

    property int mwidth: mainWindow.height / 3.2
    property int mheight: mainWindow.height / 14
    property var separatorColor: "#80FFFFFF"
    property int separatorWidth: mwidth * 9 / 10
    property bool isDeleteCicked: false
    property int selectIndex
    property int blurX
    property int blurY
    
    signal deleteClicked
    signal menuClosed(bool deleteClick)

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    Overlay.modal:  Rectangle{
        color:"transparent"
    }

    delegate: MenuItem {
        id: menuItem

        width: mwidth
        height: mheight

        indicator: Item {
            width: 0
            height: 0
        }

        contentItem: Item {
            id: munuContentItem

            width: mwidth
            height: mheight

            Text {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                leftPadding: mwidth / 10
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                text: menuItem.text
                font.pixelSize: 14
                
                color: menuItem.highlighted ? majorForeground : majorForeground
                elide: Text.ElideRight
            }

            Kirigami.Icon {
                id: rightImage

                anchors {
                    right: parent.right
                    rightMargin: mwidth / 10
                    verticalCenter: parent.verticalCenter
                }

                width: mheight / 2.8
                height: mheight / 2.8

                source: "qrc:/assets/edit_delete_black.png"
                color: majorForeground
            }
        }

        background: Rectangle {
            id: menu_bg

            implicitWidth: mwidth
            height: mheight

            color: "transparent"
        }
    }

    background: Rectangle {
        width: mwidth

        color: cardBackground
        radius: mheight / 3.75

        VagueBackground {
            anchors.fill: parent

            sourceView: root
            mouseX: blurX
            mouseY: blurY
        }

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            radius: 20
            samples: 25
            color: isDarkTheme ? "#FF26262A" : "#1A000000"
            spread: 0
        }
    }

    onOpened: {
        isDeleteCicked = false
    }

    onClosed: {
        menuClosed(isDeleteCicked)
    }

    Action {
        text: i18n("Delete")
        checkable: true
        checked: false

        onCheckedChanged: {
            isDeleteCicked = true
            deleteClicked()
        }
    }
}
