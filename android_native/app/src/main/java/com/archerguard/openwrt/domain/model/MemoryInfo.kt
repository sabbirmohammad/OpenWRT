package com.archerguard.openwrt.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.util.Locale

@Serializable
data class MemoryInfo(
    @SerialName("total_kb") val totalKb: Long = 1L,
    @SerialName("used_kb") val usedKb: Long = 0L,
    @SerialName("free_kb") val freeKb: Long = 0L,
    @SerialName("cached_kb") val cachedKb: Long = 0L,
    @SerialName("available_kb") val availableKb: Long = 0L,
    val type: String = "DDR3",
    @SerialName("usage_percent") val usagePercent: Double = 0.0
) {
    val formattedUsedMb: String
        get() = String.format(Locale.US, "%.1f MB", usedKb / 1024.0)

    val formattedTotalMb: String
        get() = String.format(Locale.US, "%.0f MB", totalKb / 1024.0)
}
