package com.archerguard.openwrt.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RadioInfo(
    val ssid: String = "",
    val channel: Int = 1,
    @SerialName("tx_power_dbm") val txPowerDbm: Int = 20,
    val enabled: Boolean = true,
    @SerialName("connected_clients") val connectedClients: Int = 0,
    val hwmode: String = "11ax",
    val htmode: String = "HE80"
)

@Serializable
data class SsidInfo(
    val id: String,
    val ssid: String,
    val band: String,
    val radio: String,
    val ifname: String,
    val enabled: Boolean = true,
    val encryption: String = "WPA2-PSK/WPA3-SAE",
    val channel: Int = 1,
    @SerialName("connected_clients") val connectedClients: Int = 0,
    @SerialName("is_guest") val isGuest: Boolean = false,
    @SerialName("tx_power") val txPower: Int = 20
)

@Serializable
data class WirelessInfo(
    @SerialName("radio_2g") val radio2g: RadioInfo = RadioInfo(ssid = "ArcherGuard_2.4G", channel = 6),
    @SerialName("radio_5g") val radio5g: RadioInfo = RadioInfo(ssid = "ArcherGuard_5G", channel = 36),
    val guest: RadioInfo = RadioInfo(ssid = "ArcherGuard_Guest", channel = 6, enabled = false),
    val ssids: List<SsidInfo> = emptyList(),
    @SerialName("fast_roaming") val fastRoaming: Boolean = true,
    @SerialName("pmf_protected") val pmfProtected: Boolean = true,
    @SerialName("wmm_qos") val wmmQos: Boolean = true,
    @SerialName("drop_legacy_rates") val dropLegacyRates: Boolean = true
)
