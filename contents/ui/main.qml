import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // --- Usage data properties ---
    property real fiveHourUtil: 0
    property string fiveHourResets: ""
    property real sevenDayUtil: 0
    property string sevenDayResets: ""
    property real sevenDaySonnetUtil: 0
    property string sevenDaySonnetResets: ""
    property bool hasError: false
    property string errorMessage: ""
    property bool loading: true
    property date lastUpdated: new Date()

    // --- Extra usage ---
    property bool hasExtraUsage: false
    property bool extraUsageEnabled: false
    property real extraUsageUtil: 0
    property string extraUsageLimit: ""
    property string extraUsageUsed: ""

    // --- Activity monitor state ---
    property real lastActivityMtime: 0

    // --- Config ---
    readonly property int pollInterval: plasmoid.configuration.pollInterval * 1000
    readonly property int activityCheckInterval: plasmoid.configuration.activityCheckInterval * 1000
    readonly property int warningThreshold: plasmoid.configuration.warningThreshold
    readonly property int criticalThreshold: plasmoid.configuration.criticalThreshold

    // --- Compact gauge computed properties ---
    readonly property string compactMetric: plasmoid.configuration.compactMetric
    readonly property real compactUtil: compactMetric === "seven_day" ? sevenDayUtil
        : compactMetric === "seven_day_sonnet" ? sevenDaySonnetUtil
        : fiveHourUtil
    readonly property string compactResets: compactMetric === "seven_day" ? sevenDayResets
        : compactMetric === "seven_day_sonnet" ? sevenDaySonnetResets
        : fiveHourResets
    readonly property color compactColor: usageColor(compactUtil)

    // --- Executable DataSource ---
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]
            root.parseUsageData(stdout)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            if (cmd) connectSource(cmd)
        }
    }

    function fetchUsage() {
        root.loading = true
        var scriptPath = decodeURIComponent(Qt.resolvedUrl("../scripts/fetch_usage.sh").toString().replace(/^file:\/\//, ""))
        executable.exec("bash " + scriptPath)
    }

    function parseUsageData(stdout) {
        root.loading = false
        try {
            var data = JSON.parse(stdout)
            if (data.error) {
                root.hasError = true
                root.errorMessage = data.message || data.error
                return
            }
            root.hasError = false
            root.errorMessage = ""

            if (data.five_hour) {
                root.fiveHourUtil = data.five_hour.utilization || 0
                root.fiveHourResets = data.five_hour.resets_at || ""
            }
            if (data.seven_day) {
                root.sevenDayUtil = data.seven_day.utilization || 0
                root.sevenDayResets = data.seven_day.resets_at || ""
            }
            if (data.seven_day_sonnet) {
                root.sevenDaySonnetUtil = data.seven_day_sonnet.utilization || 0
                root.sevenDaySonnetResets = data.seven_day_sonnet.resets_at || ""
            }

            if (data.extra_usage) {
                root.hasExtraUsage = true
                root.extraUsageEnabled = data.extra_usage.is_enabled || false
                root.extraUsageUtil = data.extra_usage.utilization || 0
                root.extraUsageLimit = data.extra_usage.monthly_limit != null ? plasmoid.configuration.currencySymbol + (data.extra_usage.monthly_limit / 100).toFixed(2) : ""
                root.extraUsageUsed = plasmoid.configuration.currencySymbol + ((data.extra_usage.used_credits || 0) / 100).toFixed(2)
            } else {
                root.hasExtraUsage = false
                root.extraUsageEnabled = false
            }

            root.lastUpdated = new Date()
        } catch (e) {
            root.hasError = true
            root.errorMessage = "Failed to parse response"
        }
    }

    // --- Helper functions ---
    function usageColor(percent) {
        if (percent >= root.criticalThreshold) {
            return Kirigami.Theme.negativeTextColor
        } else if (percent >= root.warningThreshold) {
            return plasmoid.configuration.warningColor || "#E5C07B"
        } else {
            return plasmoid.configuration.normalColor || "#D77757"
        }
    }

    function formatResetTime(isoString) {
        if (!isoString) return ""
        var d = new Date(isoString)
        var now = new Date()
        var diffMs = d.getTime() - now.getTime()
        if (diffMs <= 0) return "expired"
        var diffMin = Math.floor(diffMs / 60000)
        var diffHrs = Math.floor(diffMin / 60)
        var remainMin = diffMin % 60
        if (diffHrs >= 24) {
            var days = Math.floor(diffHrs / 24)
            var hrs = diffHrs % 24
            return days + "d " + hrs + "h"
        }
        if (diffHrs > 0) return diffHrs + "h " + remainMin + "m"
        return diffMin + "m"
    }

    // --- Activity monitor DataSource ---
    Plasma5Support.DataSource {
        id: activityChecker
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"].trim()
            var mtime = parseInt(stdout)
            if (!isNaN(mtime)) {
                if (root.lastActivityMtime > 0 && mtime > root.lastActivityMtime) {
                    fetchDelayTimer.restart()
                }
                root.lastActivityMtime = mtime
            }
            disconnectSource(sourceName)
        }
        function check() {
            // GNU stat format — Linux-only, which is fine since this is a KDE Plasma widget
            connectSource("stat --format=%Y $HOME/.claude/history.jsonl 2>/dev/null || echo 0")
        }
    }

    // --- Activity check timer ---
    Timer {
        id: activityTimer
        interval: root.activityCheckInterval
        running: true
        repeat: true
        onTriggered: activityChecker.check()
        Component.onCompleted: activityChecker.check()
    }

    // --- Delay before fetching after activity ---
    Timer {
        id: fetchDelayTimer
        interval: 15000
        running: false
        repeat: false
        onTriggered: root.fetchUsage()
    }

    // --- Polling timer ---
    Timer {
        id: pollTimer
        interval: root.pollInterval
        running: true
        repeat: true
        onTriggered: root.fetchUsage()
        Component.onCompleted: root.fetchUsage()
    }

    // --- Widget setup ---
    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 8

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
