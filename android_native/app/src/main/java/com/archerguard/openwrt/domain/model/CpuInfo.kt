package com.archerguard.openwrt.domain.model

import com.archerguard.openwrt.core.util.Formatters
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CpuInfo(
    val cores: Int = 2,
    val threads: Int = 4,
    val model: String = "MediaTek MT7621DAT",
    val architecture: String = "MIPS 1004Kc",
    @SerialName("frequency_mhz") val frequencyMhz: Int = 880,
    @SerialName("usage_percent") val usagePercent: Double = 0.0,
    @SerialName("temperature_c") val temperatureC: Double = 0.0,
    @SerialName("load_avg") val loadAvg: String = "0.00",
    @SerialName("uptime_seconds") val uptimeSeconds: Long = 0L
) {
    val formattedUptime: String
        get() = Formatters.formatUptime(uptimeSeconds)
}
