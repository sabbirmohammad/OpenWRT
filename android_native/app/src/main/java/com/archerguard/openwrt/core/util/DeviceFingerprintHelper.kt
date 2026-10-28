package com.archerguard.openwrt.core.util

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cable
import androidx.compose.material.icons.filled.Computer
import androidx.compose.material.icons.filled.Devices
import androidx.compose.material.icons.filled.Laptop
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.PhoneIphone
import androidx.compose.material.icons.filled.Router
import androidx.compose.material.icons.filled.Sensors
import androidx.compose.material.icons.filled.SportsEsports
import androidx.compose.material.icons.filled.Terminal
import androidx.compose.material.icons.filled.Tv
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.theme.GlossyColors

enum class DeviceType(
    val brand: String,
    val icon: ImageVector,
    val accentColor: Color,
    val badgeBg: Color
) {
    APPLE(
        brand = "Apple",
        icon = Icons.Default.PhoneIphone,
        accentColor = Color(0xFFE2E8F0),
        badgeBg = Color(0x3394A3B8)
    ),
    APPLE_MAC(
        brand = "Mac",
        icon = Icons.Default.Laptop,
        accentColor = Color(0xFFF1F5F9),
        badgeBg = Color(0x3394A3B8)
    ),
    ANDROID(
        brand = "Android",
        icon = Icons.Default.PhoneAndroid,
        accentColor = GlossyColors.EmeraldMint,
        badgeBg = Color(0x2810B981)
    ),
    SAMSUNG(
        brand = "Samsung",
        icon = Icons.Default.PhoneAndroid,
        accentColor = GlossyColors.LightBlue,
        badgeBg = Color(0x283B82F6)
    ),
    WINDOWS(
        brand = "Windows PC",
        icon = Icons.Default.Computer,
        accentColor = GlossyColors.SkyBlue,
        badgeBg = Color(0x2860A5FA)
    ),
    SMART_TV(
        brand = "Smart TV",
        icon = Icons.Default.Tv,
        accentColor = Color(0xFFF472B6), // Pinkish Magenta
        badgeBg = Color(0x28F472B6)
    ),
    GAMING(
        brand = "Gaming",
        icon = Icons.Default.SportsEsports,
        accentColor = Color(0xFFA78BFA), // Lavender
        badgeBg = Color(0x28A78BFA)
    ),
    IOT_SMART_HOME(
        brand = "IoT / Smart",
        icon = Icons.Default.Sensors,
        accentColor = GlossyColors.AmberWarm,
        badgeBg = Color(0x28F59E0B)
    ),
    LINUX_SERVER(
        brand = "Linux / Server",
        icon = Icons.Default.Terminal,
        accentColor = GlossyColors.EmeraldSoft,
        badgeBg = Color(0x2834D399)
    ),
    WIRED_LAN(
        brand = "Gigabit LAN",
        icon = Icons.Default.Cable,
        accentColor = GlossyColors.LanGigabit,
        badgeBg = Color(0x2810B981)
    ),
    GENERIC_WIFI(
        brand = "Wi-Fi Device",
        icon = Icons.Default.Wifi,
        accentColor = GlossyColors.LightBlue,
        badgeBg = Color(0x283B82F6)
    )
}

enum class SignalQuality(val label: String, val color: Color, val bars: Int) {
    EXCELLENT("Excellent", GlossyColors.EmeraldMint, 4),
    GOOD("Good", GlossyColors.LightBlue, 3),
    FAIR("Fair", GlossyColors.AmberWarm, 2),
    POOR("Weak", GlossyColors.RoseCoral, 1)
}

object DeviceFingerprintHelper {

    fun resolveDeviceType(client: ClientInfo): DeviceType {
        val name = (client.displayName + " " + client.hostname + " " + (client.vendor ?: "")).lowercase()
        val mac = client.mac.uppercase().replace("[:-]".toRegex(), "")

        // 1. Apple ecosystem
        if (name.contains("iphone") || name.contains("ipad") || name.contains("apple-watch") || name.contains("watch")) {
            return DeviceType.APPLE
        }
        if (name.contains("macbook") || name.contains("macmini") || name.contains("imac") || name.contains("darwin")) {
            return DeviceType.APPLE_MAC
        }

        // 2. Samsung devices
        if (name.contains("samsung") || name.contains("galaxy") || name.startsWith("sm-")) {
            return DeviceType.SAMSUNG
        }

        // 3. Android devices
        if (name.contains("android") || name.contains("pixel") || name.contains("xiaomi") ||
            name.contains("redmi") || name.contains("oneplus") || name.contains("oppo") ||
            name.contains("vivo") || name.contains("realme") || name.contains("poco")
        ) {
            return DeviceType.ANDROID
        }

        // 4. Windows PC
        if (name.contains("desktop-") || name.contains("laptop-") || name.contains("windows") || name.contains("win-")) {
            return DeviceType.WINDOWS
        }

        // 5. Smart TV & Media Streamers
        if (name.contains("tv") || name.contains("roku") || name.contains("firetv") ||
            name.contains("chromecast") || name.contains("bravia") || name.contains("webos") ||
            name.contains("tizen") || name.contains("shield")
        ) {
            return DeviceType.SMART_TV
        }

        // 6. Gaming Consoles
        if (name.contains("playstation") || name.contains("ps4") || name.contains("ps5") ||
            name.contains("xbox") || name.contains("nintendo") || name.contains("switch")
        ) {
            return DeviceType.GAMING
        }

        // 7. IoT & Smart Home
        if (name.contains("esp_") || name.contains("tuya") || name.contains("sonoff") ||
            name.contains("shelly") || name.contains("camera") || name.contains("smartplug") ||
            name.contains("tasmota") || name.contains("yeelight") || name.contains("bulb")
        ) {
            return DeviceType.IOT_SMART_HOME
        }

        // 8. Linux & Home Server
        if (name.contains("ubuntu") || name.contains("debian") || name.contains("raspberry") ||
            name.contains("rpi") || name.contains("pi-hole") || name.contains("server")
        ) {
            return DeviceType.LINUX_SERVER
        }

        // 9. Ethernet LAN vs Wi-Fi
        if (client.connectionType.equals("LAN", ignoreCase = true) || client.connectionType.equals("Ethernet", ignoreCase = true)) {
            return DeviceType.WIRED_LAN
        }

        return DeviceType.GENERIC_WIFI
    }

    fun getSignalQuality(signalDbm: Int): SignalQuality = when {
        signalDbm >= -58 -> SignalQuality.EXCELLENT
        signalDbm >= -68 -> SignalQuality.GOOD
        signalDbm >= -78 -> SignalQuality.FAIR
        else -> SignalQuality.POOR
    }
}
