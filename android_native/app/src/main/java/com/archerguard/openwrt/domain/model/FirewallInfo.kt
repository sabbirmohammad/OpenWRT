package com.archerguard.openwrt.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PortForwardRule(
    val id: String,
    val name: String,
    val proto: String = "tcp",
    @SerialName("ext_port") val extPort: String,
    @SerialName("int_ip") val intIp: String,
    @SerialName("int_port") val intPort: String,
    val enabled: Boolean = true
)

@Serializable
data class TrafficRule(
    val id: String,
    val name: String,
    val proto: String = "tcp",
    val src: String = "lan",
    val dest: String = "wan",
    val target: String = "DROP",
    val enabled: Boolean = true
)

@Serializable
data class FirewallInfo(
    val engine: String = "nftables v1.0.8 (fw4)",
    val table: String = "table inet fw4",
    val status: String = "enforcing",
    @SerialName("syn_flood") val synFlood: Boolean = true,
    @SerialName("drop_invalid") val dropInvalid: Boolean = true,
    @SerialName("wan_ping") val wanPing: Boolean = false,
    @SerialName("wan_lockdown") val wanLockdown: Boolean = true,
    @SerialName("dns_rebind") val dnsRebind: Boolean = true,
    @SerialName("flow_offload") val flowOffload: Boolean = true,
    @SerialName("flow_offload_hw") val flowOffloadHw: Boolean = true,
    @SerialName("mss_clamping") val mssClamping: Boolean = true,
    @SerialName("anti_spoofing") val antiSpoofing: Boolean = true,
    @SerialName("ipv6_firewall") val ipv6Firewall: Boolean = true,
    @SerialName("stealth_mode") val stealthMode: Boolean = true,
    @SerialName("guest_isolation") val guestIsolation: Boolean = true,
    @SerialName("dmz_enabled") val dmzEnabled: Boolean = false,
    @SerialName("dmz_ip") val dmzIp: String = "192.168.1.150",
    @SerialName("conntrack_count") val conntrackCount: Int = 342,
    @SerialName("conntrack_max") val conntrackMax: Int = 16384,
    @SerialName("port_forwards") val portForwards: List<PortForwardRule> = emptyList(),
    @SerialName("traffic_rules") val trafficRules: List<TrafficRule> = emptyList()
)
