package com.archerguard.openwrt.domain.model

import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.intOrNull

private fun JsonElement?.asBoolean(default: Boolean): Boolean =
    (this as? JsonPrimitive)?.booleanOrNull ?: default

private fun JsonElement?.asString(default: String = ""): String =
    (this as? JsonPrimitive)?.content ?: default

private fun JsonElement?.asInt(default: Int = 0): Int =
    (this as? JsonPrimitive)?.intOrNull ?: (this as? JsonPrimitive)?.content?.toIntOrNull() ?: default

@Serializable(with = RadioInfoSerializer::class)
data class RadioInfo(
    val ssid: String = "",
    val channel: Int = 1,
    val txPowerDbm: Int = 20,
    val enabled: Boolean = true,
    val connectedClients: Int = 0,
    val hwmode: String = "11ax",
    val htmode: String = "HE80",
    val band: String = "",
    val chipset: String = "",
    val encryption: String = "WPA2-PSK/WPA3-SAE"
)

object RadioInfoSerializer : KSerializer<RadioInfo> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("RadioInfo")

    override fun serialize(encoder: Encoder, value: RadioInfo) {}

    override fun deserialize(decoder: Decoder): RadioInfo {
        val input = decoder as? JsonDecoder ?: return RadioInfo()
        val root = input.decodeJsonElement() as? JsonObject ?: return RadioInfo()

        val txPower = root["txpower_dbm"].asInt(root["tx_power_dbm"].asInt(20))

        return RadioInfo(
            ssid = root["ssid"].asString(""),
            channel = root["channel"].asInt(1),
            txPowerDbm = txPower,
            enabled = root["enabled"].asBoolean(true),
            connectedClients = root["connected_clients"].asInt(0),
            hwmode = root["hwmode"].asString("11ax"),
            htmode = root["htmode"].asString("HE80"),
            band = root["band"].asString(""),
            chipset = root["chipset"].asString(""),
            encryption = root["encryption"].asString("WPA2-PSK/WPA3-SAE")
        )
    }
}

@Serializable
data class SsidInfo(
    val id: String = "",
    val ssid: String = "",
    val band: String = "2.4GHz",
    val radio: String = "radio0",
    val ifname: String = "",
    val enabled: Boolean = true,
    val encryption: String = "WPA2-PSK/WPA3-SAE",
    val channel: Int = 1,
    @SerialName("connected_clients") val connectedClients: Int = 0,
    @SerialName("is_guest") val isGuest: Boolean = false,
    @SerialName("tx_power") val txPower: Int = 20,
    @SerialName("isolated") val isIsolated: Boolean = false
)

@Serializable(with = WirelessInfoSerializer::class)
data class WirelessInfo(
    val radio2g: RadioInfo = RadioInfo(ssid = "ArcherGuard_2.4G", channel = 6),
    val radio5g: RadioInfo = RadioInfo(ssid = "ArcherGuard_5G", channel = 36),
    val guest: RadioInfo = RadioInfo(ssid = "ArcherGuard_Guest", channel = 6, enabled = false),
    val ssids: List<SsidInfo> = emptyList(),
    val fastRoaming: Boolean = true,
    val pmfProtected: Boolean = true,
    val wmmQos: Boolean = true,
    val dropLegacyRates: Boolean = true
)

object WirelessInfoSerializer : KSerializer<WirelessInfo> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("WirelessInfo")

    override fun serialize(encoder: Encoder, value: WirelessInfo) {}

    override fun deserialize(decoder: Decoder): WirelessInfo {
        val input = decoder as? JsonDecoder ?: return WirelessInfo()
        val root = input.decodeJsonElement() as? JsonObject ?: return WirelessInfo()

        val json = input.json

        val r2g = root["radio_2g"]?.let { json.decodeFromJsonElement(RadioInfoSerializer, it) } ?: RadioInfo(ssid = "ArcherGuard_2.4G", channel = 6)
        val r5g = root["radio_5g"]?.let { json.decodeFromJsonElement(RadioInfoSerializer, it) } ?: RadioInfo(ssid = "ArcherGuard_5G", channel = 36)
        val guest = root["guest"]?.let { json.decodeFromJsonElement(RadioInfoSerializer, it) } ?: RadioInfo(ssid = "ArcherGuard_Guest", channel = 6, enabled = false)

        val ssidsList = root["ssids"]?.let {
            try {
                json.decodeFromJsonElement(ListSerializer(SsidInfo.serializer()), it)
            } catch (_: Exception) {
                emptyList()
            }
        } ?: emptyList()

        val advObj = root["advanced"] as? JsonObject
        val fastRoaming = advObj?.get("fast_roaming").asBoolean(root["fast_roaming"].asBoolean(true))
        val pmf = advObj?.get("pmf_protected").asBoolean(root["pmf_protected"].asBoolean(true))
        val wmm = advObj?.get("wmm_qos").asBoolean(root["wmm_qos"].asBoolean(true))
        val legacy = advObj?.get("drop_legacy_rates").asBoolean(root["drop_legacy_rates"].asBoolean(true))

        return WirelessInfo(
            radio2g = r2g,
            radio5g = r5g,
            guest = guest,
            ssids = ssidsList,
            fastRoaming = fastRoaming,
            pmfProtected = pmf,
            wmmQos = wmm,
            dropLegacyRates = legacy
        )
    }
}
