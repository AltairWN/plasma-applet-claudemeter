import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.quickcharts as Charts

Item {
    id: gaugeRep

    readonly property real utilization: root.compactUtil
    readonly property string resetsAt: root.compactResets
    readonly property color arcColor: root.compactColor
    readonly property bool isDark: Kirigami.Theme.backgroundColor.hslLightness < 0.5
    readonly property color trackColor: isDark ? "#33373B" : "#E5E7E8"

    Layout.minimumWidth: Kirigami.Units.gridUnit
    Layout.minimumHeight: Kirigami.Units.gridUnit
    Layout.preferredWidth: height
    Layout.preferredHeight: height

    // Background track — always visible
    Charts.PieChart {
        anchors.fill: parent
        fromAngle: -180
        toAngle: 180
        smoothEnds: true
        thickness: Kirigami.Units.smallSpacing * 1.1
        range { from: 0; to: 100; automatic: false }
        valueSources: Charts.SingleValueSource { value: 100 }
        colorSource: Charts.SingleValueSource { value: gaugeRep.trackColor }
    }

    // Foreground usage arc
    Charts.PieChart {
        id: pie
        anchors.fill: parent

        fromAngle: -180
        toAngle: 180
        smoothEnds: true
        thickness: Kirigami.Units.smallSpacing * 1.1

        range {
            from: 0
            to: 100
            automatic: false
        }

        valueSources: Charts.SingleValueSource {
            value: gaugeRep.utilization
        }
        colorSource: Charts.SingleValueSource {
            value: gaugeRep.arcColor
        }
    }

    Text {
        anchors.centerIn: parent
        visible: plasmoid.configuration.gaugeLabel !== "none"
        text: {
            var mode = plasmoid.configuration.gaugeLabel
            if (mode === "percent") return Math.round(gaugeRep.utilization) + "%"
            return root.formatResetTime(gaugeRep.resetsAt)
        }
        color: Kirigami.Theme.textColor
        font.pixelSize: Math.max(7, Math.min(parent.width, parent.height) * 0.22)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
