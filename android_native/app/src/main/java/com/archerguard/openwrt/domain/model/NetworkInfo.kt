package com.archerguard.openwrt.domain.model

import com.archerguard.openwrt.core.util.Formatters
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.longOrNull

@Serializable(with = NetworkInfoSerializer::class)
data class NetworkInfo(
    val hwOffload: Boolean = true,
    val flowOffloadingHw: Boolean = true,
    val sqmEnabled: Boolean = false,
    val sqmQdisc: String = "cake",
    val sqmDownloadKbit: Int = 95000,
    val sqmUploadKbit: Int = 20000,
    val gateway: String = "192.168.1.1",
    val dns: String = "1.1.1.1, 1.0.0.1",
    val protocol: String = "dhcp",
    val mtu: Int = 1492,
    val latencyMs: Double = 8.5,
    val jitterMs: Double = 0.9,
    val wireguardEnabled: Boolean = false,
    val wireguardInterface: String = "wg0",
    val wireguardEndpoint: String = "10.14.0.1:51820",
    val wireguardStatus: String = "standby",
    val wireguardLatestHandshake: String = "Never",
    val wireguardTransferRx: Long = 0L,
    val wireguardTransferTx: Long = 0L,
    val multiWanEnabled: Boolean = false,
    val multiWanMode: String = "failover",
    val multiWanWan1: String = "online",
    val multiWanWan2: String = "standby",
    val dohEnabled: Boolean = true,
    val dohProvider: String = "Cloudflare (1.1.1.1)",
    val dnsRebindProtection: Boolean = true,
    val wanLockdown: Boolean = true
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

private fun JsonElement?.asBoolean(default: Boolean): Boolean =
    (this as? JsonPrimitive)?.booleanOrNull ?: default

private fun JsonElement?.asString(default: String = ""): String =
    (this as? JsonPrimitive)?.content ?: default

private fun JsonElement?.asInt(default: Int = 0): Int =
    (this as? JsonPrimitive)?.intOrNull ?: (this as? JsonPrimitive)?.content?.toIntOrNull() ?: default

private fun JsonElement?.asLong(default: Long = 0L): Long =
    (this as? JsonPrimitive)?.longOrNull ?: (this as? JsonPrimitive)?.content?.toLongOrNull() ?: default

private fun JsonElement?.asDouble(default: Double = 0.0): Double =
    (this as? JsonPrimitive)?.doubleOrNull ?: (this as? JsonPrimitive)?.content?.toDoubleOrNull() ?: default

object NetworkInfoSerializer : KSerializer<NetworkInfo> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("NetworkInfo")

    override fun serialize(encoder: Encoder, value: NetworkInfo) {
        // Serialization not needed for read-only router status
    }

    override fun deserialize(decoder: Decoder): NetworkInfo {
        val input = decoder as? JsonDecoder ?: return NetworkInfo()
        val element = input.decodeJsonElement()
        val root = element as? JsonObject ?: return NetworkInfo()

        val hwObj = root["hw_offload"] as? JsonObject
        val hwOffload = hwObj?.get("enabled").asBoolean(root["hw_offload"].asBoolean(true))
        val flowHw = hwObj?.get("flow_offloading_hw").asBoolean(root["flow_offloading_hw"].asBoolean(true))

        val sqmObj = root["sqm"] as? JsonObject
        val sqmEnabled = sqmObj?.get("enabled").asBoolean(root["sqm_enabled"].asBoolean(false))
        val sqmQdisc = sqmObj?.get("qdisc").asString(root["sqm_qdisc"].asString("cake"))
        val sqmDownload = sqmObj?.get("download_kbit").asInt(root["sqm_download_kbit"].asInt(95000))
        val sqmUpload = sqmObj?.get("upload_kbit").asInt(root["sqm_upload_kbit"].asInt(20000))

        val wanObj = root["wan_details"] as? JsonObject
        val gateway = wanObj?.get("gateway").asString(root["gateway"].asString("192.168.1.1"))
        val dns = wanObj?.get("dns").asString(root["dns"].asString("1.1.1.1, 1.0.0.1"))
        val protocol = wanObj?.get("protocol").asString(root["protocol"].asString("dhcp"))
        val mtu = wanObj?.get("mtu").asInt(root["mtu"].asInt(1492))
        val latencyMs = wanObj?.get("latency_ms").asDouble(root["latency_ms"].asDouble(8.5))
        val jitterMs = wanObj?.get("jitter_ms").asDouble(root["jitter_ms"].asDouble(0.9))

        val wgObj = root["wireguard"] as? JsonObject
        val wgEnabled = wgObj?.get("enabled").asBoolean(root["wireguard_enabled"].asBoolean(false))
        val wgIf = wgObj?.get("interface").asString(root["wireguard_interface"].asString("wg0"))
        val wgEndpoint = wgObj?.get("endpoint").asString(root["wireguard_endpoint"].asString("10.14.0.1:51820"))
        val wgStatus = wgObj?.get("status").asString(root["wireguard_status"].asString("standby"))
        val wgHandshake = wgObj?.get("latest_handshake").asString(root["wireguard_latest_handshake"].asString("Never"))
        val wgRx = wgObj?.get("transfer_rx").asLong(root["wireguard_transfer_rx"].asLong(0L))
        val wgTx = wgObj?.get("transfer_tx").asLong(root["wireguard_transfer_tx"].asLong(0L))

        val mwanObj = root["multi_wan"] as? JsonObject
        val mwanEnabled = mwanObj?.get("enabled").asBoolean(root["multi_wan_enabled"].asBoolean(false))
        val mwanMode = mwanObj?.get("mode").asString(root["multi_wan_mode"].asString("failover"))
        val mwanWan1 = mwanObj?.get("wan1").asString(root["multi_wan_wan1"].asString("online"))
        val mwanWan2 = mwanObj?.get("wan2").asString(root["multi_wan_wan2"].asString("standby"))

        val dohObj = root["doh"] as? JsonObject
        val dohEnabled = dohObj?.get("enabled").asBoolean(root["doh_enabled"].asBoolean(true))
        val dohProvider = dohObj?.get("provider").asString(root["doh_provider"].asString("Cloudflare (1.1.1.1)"))

        val dnsRebind = root["dns_rebind_protection"].asBoolean(root["rebind_protection"].asBoolean(true))
        val wanLock = root["wan_lockdown"].asBoolean(root["wan_block"].asBoolean(true))

        return NetworkInfo(
            hwOffload = hwOffload,
            flowOffloadingHw = flowHw,
            sqmEnabled = sqmEnabled,
            sqmQdisc = sqmQdisc,
            sqmDownloadKbit = sqmDownload,
            sqmUploadKbit = sqmUpload,
            gateway = gateway,
            dns = dns,
            protocol = protocol,
            mtu = mtu,
            latencyMs = latencyMs,
            jitterMs = jitterMs,
            wireguardEnabled = wgEnabled,
            wireguardInterface = wgIf,
            wireguardEndpoint = wgEndpoint,
            wireguardStatus = wgStatus,
            wireguardLatestHandshake = wgHandshake,
            wireguardTransferRx = wgRx,
            wireguardTransferTx = wgTx,
            multiWanEnabled = mwanEnabled,
            multiWanMode = mwanMode,
            multiWanWan1 = mwanWan1,
            multiWanWan2 = mwanWan2,
            dohEnabled = dohEnabled,
            dohProvider = dohProvider,
            dnsRebindProtection = dnsRebind,
            wanLockdown = wanLock
        )
    }
}
