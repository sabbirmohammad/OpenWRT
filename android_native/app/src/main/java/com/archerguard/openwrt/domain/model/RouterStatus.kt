package com.archerguard.openwrt.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RouterStatus(
    val cpu: CpuInfo = CpuInfo(),
    val memory: MemoryInfo = MemoryInfo(),
    val storage: StorageInfo = StorageInfo(),
    val traffic: TrafficInfo = TrafficInfo(),
    val network: NetworkInfo = NetworkInfo(),
    val wireless: WirelessInfo = WirelessInfo(),
    val clients: List<ClientInfo> = emptyList(),
    @SerialName("stealth_leds") val stealthLeds: Boolean = false,
    val timestamp: Long = System.currentTimeMillis() / 1000L,
    val firewall: FirewallInfo = FirewallInfo()
)
