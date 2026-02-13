import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

ColumnLayout {
    id: usageBar

    property string label: ""
    property real percentage: 0
    property color barColor: Kirigami.Theme.positiveTextColor
    property string resetTime: ""

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true
        QQC2.Label {
            text: usageBar.label
            font: Kirigami.Theme.smallFont
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: Math.round(usageBar.percentage) + "%"
            font.bold: true
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: usageBar.barColor
        }
    }

    // Progress bar
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.smallSpacing * 3
        radius: height / 2
        color: Kirigami.Theme.backgroundColor
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(usageBar.percentage / 100, 1.0)
            radius: parent.radius
            color: usageBar.barColor

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }

    QQC2.Label {
        text: usageBar.resetTime ? "Resets in " + usageBar.resetTime : ""
        visible: text !== ""
        font: Kirigami.Theme.smallFont
        color: Kirigami.Theme.disabledTextColor
    }
}
