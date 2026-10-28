package com.archerguard.openwrt.domain.model

import com.archerguard.openwrt.core.util.Formatters
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class NetworkInfo(
    @SerialName("hw_offload") val hwOffload: Boolean = true,
    @SerialName("flow_offloading_hw") val flowOffloadingHw: Boolean = true,
    @SerialName("sqm_enabled") val sqmEnabled: Boolean = false,
    @SerialName("sqm_qdisc") val sqmQdisc: String = "cake",
    @SerialName("sqm_download_kbit") val sqmDownloadKbit: Int = 95000,
    @SerialName("sqm_upload_kbit") val sqmUploadKbit: Int = 20000,
    val gateway: String = "192.168.1.1",
    val dns: String = "1.1.1.1, 1.0.0.1",
    val protocol: String = "dhcp",
    val mtu: Int = 1492,
    @SerialName("latency_ms") val latencyMs: Double = 8.5,
    @SerialName("jitter_ms") val jitterMs: Double = 0.9,
    @SerialName("wireguard_enabled") val wireguardEnabled: Boolean = false,
    @SerialName("wireguard_interface") val wireguardInterface: String = "wg0",
    @SerialName("wireguard_endpoint") val wireguardEndpoint: String = "10.14.0.1:51820",
    @SerialName("wireguard_status") val wireguardStatus: String = "standby",
    @SerialName("wireguard_latest_handshake") val wireguardLatestHandshake: String = "Never",
    @SerialName("wireguard_transfer_rx") val wireguardTransferRx: Long = 0L,
    @SerialName("wireguard_transfer_tx") val wireguardTransferTx: Long = 0L,
    @SerialName("multi_wan_enabled") val multiWanEnabled: Boolean = false,
    @SerialName("multi_wan_mode") val multiWanMode: String = "failover",
    @SerialName("multi_wan_wan1") val multiWanWan1: String = "online",
    @SerialName("multi_wan_wan2") val multiWanWan2: String = "standby",
    @SerialName("doh_enabled") val dohEnabled: Boolean = true,
    @SerialName("doh_provider") val dohProvider: String = "Cloudflare (1.1.1.1)",
    @SerialName("dns_rebind_protection") val dnsRebindProtection: Boolean = true,
    @SerialName("wan_lockdown") val wanLockdown: Boolean = true
) {
    val sqmDownloadMbps: Double
        get() = sqmDownloadKbit / 1000.0

    val sqmUploadMbps: Double
        get() = sqmUploadKbit / 1000.0

    val formattedWireguardRx: String
        get() = Formatters.formatBytes(wireguardTransferRx)

    val formattedWireguardTx: String
        get() = Formatters.formatBytes(wireguardTransferTx)

    val dnsProviderName: String
        get() {
            val clean = dns.replace(" ", "")
            return when {
                clean.contains("1.1.1.1") || clean.contains("1.0.0.1") -> "Cloudflare DNS"
                clean.contains("8.8.8.8") || clean.contains("8.8.4.4") -> "Google DNS"
                clean.contains("9.9.9.9") || clean.contains("149.112.112.112") -> "Quad9 DNS"
                clean.contains("94.140.14.14") -> "AdGuard DNS"
                clean.contains("208.67.222.222") -> "OpenDNS"
                else -> "Custom / ISP DNS"
            }
        }
}
