package com.archerguard.openwrt.core.util

import java.util.Locale

object Formatters {
    fun formatBytes(bytes: Long): String {
        if (bytes <= 0) return "0 B"
        val units = arrayOf("B", "KB", "MB", "GB", "TB")
        var digitGroups = (Math.log10(bytes.toDouble()) / Math.log10(1024.0)).toInt()
        if (digitGroups >= units.size) digitGroups = units.size - 1
        val value = bytes / Math.pow(1024.0, digitGroups.toDouble())
        return String.format(Locale.US, "%.1f %s", value, units[digitGroups])
    }

    fun formatSpeed(bytesPerSec: Double): String {
        val bitsPerSec = bytesPerSec * 8.0
        return when {
            bitsPerSec >= 1_000_000_000 -> String.format(Locale.US, "%.1f Gbps", bitsPerSec / 1_000_000_000)
            bitsPerSec >= 1_000_000 -> String.format(Locale.US, "%.1f Mbps", bitsPerSec / 1_000_000)
            bitsPerSec >= 1_000 -> String.format(Locale.US, "%.1f Kbps", bitsPerSec / 1_000)
            else -> String.format(Locale.US, "%.0f bps", bitsPerSec)
        }
    }

    fun formatUptime(seconds: Long): String {
        val days = seconds / 86400
        val hours = (seconds % 86400) / 3600
        val minutes = (seconds % 3600) / 60
        return when {
            days > 0 -> "${days}d ${hours}h ${minutes}m"
            hours > 0 -> "${hours}h ${minutes}m"
            else -> "${minutes}m"
        }
    }
}
