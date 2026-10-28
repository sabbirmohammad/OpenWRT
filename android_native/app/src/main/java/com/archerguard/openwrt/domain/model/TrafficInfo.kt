package com.archerguard.openwrt.domain.model

import com.archerguard.openwrt.core.util.Formatters
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TrafficInfo(
    @SerialName("interface") val interfaceName: String = "wan",
    @SerialName("rx_bytes") val rxBytes: Long = 0L,
    @SerialName("tx_bytes") val txBytes: Long = 0L,
    @SerialName("wan_ip") val wanIp: String = "0.0.0.0",
    @SerialName("current_download_mbps") val currentDownloadMbps: Double = 0.0,
    @SerialName("current_upload_mbps") val currentUploadMbps: Double = 0.0,
    @SerialName("ping_ms") val pingMs: Int = -1
) {
    val formattedRx: String
        get() = Formatters.formatBytes(rxBytes)

    val formattedTx: String
        get() = Formatters.formatBytes(txBytes)
}
