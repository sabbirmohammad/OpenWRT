package com.archerguard.openwrt.ui.viewmodel

import com.archerguard.openwrt.core.util.Formatters
import com.archerguard.openwrt.domain.model.RouterStatus

data class ClientSpeedSnapshot(
    val lastRx: Long,
    val lastTx: Long,
    val downloadBps: Double,
    val uploadBps: Double
)

class SpeedTracker {
    private var prevRxBytes: Long? = null
    private var prevTxBytes: Long? = null
    private var prevTrafficTime: Long? = null

    var liveDownloadSpeedBps: Double = 0.0
        private set
    var liveUploadSpeedBps: Double = 0.0
        private set

    private val _downloadSpeedHistory = mutableListOf<Double>()
    val downloadSpeedHistory: List<Double> get() = _downloadSpeedHistory.toList()

    private val _uploadSpeedHistory = mutableListOf<Double>()
    val uploadSpeedHistory: List<Double> get() = _uploadSpeedHistory.toList()

    private val clientSpeeds = mutableMapOf<String, ClientSpeedSnapshot>()

    val formattedDownloadSpeed: String
        get() = Formatters.formatSpeed(liveDownloadSpeedBps)

    val formattedUploadSpeed: String
        get() = Formatters.formatSpeed(liveUploadSpeedBps)

    fun getClientDownloadSpeed(mac: String): String =
        Formatters.formatSpeed(clientSpeeds[mac.lowercase()]?.downloadBps ?: 0.0)

    fun getClientUploadSpeed(mac: String): String =
        Formatters.formatSpeed(clientSpeeds[mac.lowercase()]?.uploadBps ?: 0.0)

    fun updateSpeeds(status: RouterStatus) {
        val now = System.currentTimeMillis()
        val prevTime = prevTrafficTime
        val prevRx = prevRxBytes
        val prevTx = prevTxBytes

        if (prevTime != null && prevRx != null && prevTx != null) {
            val deltaSeconds = (now - prevTime) / 1000.0
            if (deltaSeconds >= 0.5) {
                if (status.traffic.currentDownloadMbps > 0) {
                    liveDownloadSpeedBps = (status.traffic.currentDownloadMbps * 1_000_000.0) / 8.0
                } else {
                    val rxDiff = status.traffic.rxBytes - prevRx
                    liveDownloadSpeedBps = if (rxDiff >= 0) rxDiff / deltaSeconds else 0.0
                }

                if (status.traffic.currentUploadMbps > 0) {
                    liveUploadSpeedBps = (status.traffic.currentUploadMbps * 1_000_000.0) / 8.0
                } else {
                    val txDiff = status.traffic.txBytes - prevTx
                    liveUploadSpeedBps = if (txDiff >= 0) txDiff / deltaSeconds else 0.0
                }

                _downloadSpeedHistory.add(liveDownloadSpeedBps)
                if (_downloadSpeedHistory.size > 25) _downloadSpeedHistory.removeAt(0)

                _uploadSpeedHistory.add(liveUploadSpeedBps)
                if (_uploadSpeedHistory.size > 25) _uploadSpeedHistory.removeAt(0)

                // Update per-client speeds
                status.clients.forEach { client ->
                    val macKey = client.mac.lowercase()
                    val existing = clientSpeeds[macKey]
                    if (existing != null) {
                        val cRxDiff = client.rxBytes - existing.lastRx
                        val cTxDiff = client.txBytes - existing.lastTx
                        val cDown = if (cRxDiff >= 0) cRxDiff / deltaSeconds else 0.0
                        val cUp = if (cTxDiff >= 0) cTxDiff / deltaSeconds else 0.0
                        clientSpeeds[macKey] = ClientSpeedSnapshot(client.rxBytes, client.txBytes, cDown, cUp)
                    } else {
                        clientSpeeds[macKey] = ClientSpeedSnapshot(client.rxBytes, client.txBytes, 0.0, 0.0)
                    }
                }
            }
        }

        prevTrafficTime = now
        prevRxBytes = status.traffic.rxBytes
        prevTxBytes = status.traffic.txBytes
    }
}
