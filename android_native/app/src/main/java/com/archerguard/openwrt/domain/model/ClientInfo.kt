package com.archerguard.openwrt.domain.model

import com.archerguard.openwrt.core.util.Formatters
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ClientInfo(
    val mac: String = "",
    val ip: String = "",
    val hostname: String = "",
    @SerialName("connection_type") val connectionType: String = "LAN",
    @SerialName("ssid_name") val ssidName: String = "",
    @SerialName("signal_dbm") val signalDbm: Int = -50,
    @SerialName("rx_bytes") val rxBytes: Long = 0L,
    @SerialName("tx_bytes") val txBytes: Long = 0L,
    @SerialName("connected_seconds") val connectedSeconds: Long = 0L,
    val blocked: Boolean = false,
    @SerialName("nds_authenticated") val ndsAuthenticated: Boolean = true,
    @SerialName("custom_name") val customName: String? = null,
    val vendor: String? = null,
    @SerialName("is_static") val isStatic: Boolean = false,
    @SerialName("download_limit_kbps") val downloadLimitKbps: Int = 0,
    @SerialName("upload_limit_kbps") val uploadLimitKbps: Int = 0,
    @SerialName("is_isolated") val isIsolated: Boolean = false
) {
    val displayName: String
        get() = when {
            !customName.isNullOrBlank() -> customName
            hostname.isNotBlank() -> hostname
            else -> "Device (${mac.takeLast(5)})"
        }

    val formattedRx: String
        get() = Formatters.formatBytes(rxBytes)

    val formattedTx: String
        get() = Formatters.formatBytes(txBytes)

    val formattedUptime: String
        get() = Formatters.formatUptime(connectedSeconds)
}
