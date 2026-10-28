package com.archerguard.openwrt.ui.screens.wireless

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CellTower
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Devices
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.domain.model.RadioInfo
import com.archerguard.openwrt.domain.model.WirelessInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WirelessScreen(
    wireless: WirelessInfo,
    clients: List<ClientInfo> = emptyList(),
    onSaveSsid: (band: String, ssid: String, key: String, isHidden: Boolean) -> Unit = { _, _, _, _ -> },
    onToggleMasterWifi: (Boolean) -> Unit = {},
    onSavePower: (power2g: Int, power5g: Int) -> Unit = { _, _ -> },
    modifier: Modifier = Modifier
) {
    var editingRadio by remember { mutableStateOf<Pair<String, RadioInfo>?>(null) }
    var sharingSsid by remember { mutableStateOf<Pair<String, String>?>(null) }
    var viewingClientsForRadio by remember { mutableStateOf<Pair<RadioInfo, String>?>(null) }

    var power2g by remember(wireless.radio2g.txPowerDbm) { mutableFloatStateOf(wireless.radio2g.txPowerDbm.toFloat()) }
    var power5g by remember(wireless.radio5g.txPowerDbm) { mutableFloatStateOf(wireless.radio5g.txPowerDbm.toFloat()) }

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Wireless Networks",
                        color = GlossyColors.TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Dual-Band Wi-Fi & Radio Management",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp
                    )
                }
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = "${wireless.radio2g.connectedClients + wireless.radio5g.connectedClients} Clients",
                        color = GlossyColors.EmeraldMint,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(modifier = Modifier.height(4.dp))
        }

        // ── 2.4 GHz Section ──────────────────────────────────────────
        item {
            BandHeaderRow(
                title = "2.4 GHz Radio & Networks",
                spec = "MediaTek MT7603E • Long-Range Wi-Fi",
                tag = "2.4 GHz",
                clients = wireless.radio2g.connectedClients,
                accentColor = GlossyColors.SkyBlue
            )
        }

        item {
            SingleBandPowerCard(
                bandTitle = "2.4 GHz Radio Transmit Power",
                chipset = "MT7603E (802.11b/g/n)",
                power = power2g,
                onPowerChange = { power2g = it },
                accentColor = GlossyColors.SkyBlue,
                onApply = { onSavePower(power2g.toInt(), power5g.toInt()) }
            )
        }

        item {
            SubSectionHeader(title = "2.4 GHz Broadcasted Networks", count = if (wireless.guest.enabled) 2 else 1)
        }

        item {
            val radioClients = clients.filter {
                it.connectionType.equals("2.4GHz", ignoreCase = true) ||
                        it.ssidName.equals(wireless.radio2g.ssid, ignoreCase = true)
            }
            RadioCard(
                band = "2.4 GHz Primary Access Point",
                radio = wireless.radio2g,
                matchingClients = radioClients,
                accentColor = GlossyColors.SkyBlue,
                onEdit = { editingRadio = "2.4 GHz" to wireless.radio2g },
                onShare = { sharingSsid = wireless.radio2g.ssid to "" },
                onViewClients = { viewingClientsForRadio = wireless.radio2g to "2.4 GHz" }
            )
        }

        if (wireless.guest.enabled || wireless.guest.ssid.isNotEmpty()) {
            item {
                val guestClients = clients.filter {
                    it.connectionType.contains("guest", ignoreCase = true) ||
                            it.ssidName.equals(wireless.guest.ssid, ignoreCase = true)
                }
                RadioCard(
                    band = "Isolated Guest Network (2.4 GHz)",
                    radio = wireless.guest,
                    matchingClients = guestClients,
                    accentColor = GlossyColors.IsolatedAccent,
                    onEdit = { editingRadio = "Guest Network" to wireless.guest },
                    onShare = { sharingSsid = wireless.guest.ssid to "" },
                    onViewClients = { viewingClientsForRadio = wireless.guest to "Guest" }
                )
            }
        }

        item { Spacer(modifier = Modifier.height(8.dp)) }

        // ── 5.0 GHz Section ──────────────────────────────────────────
        item {
            BandHeaderRow(
                title = "5.0 GHz Radio & Networks",
                spec = "MediaTek MT7613BEN • High-Throughput AC Wave 2",
                tag = "5.0 GHz",
                clients = wireless.radio5g.connectedClients,
                accentColor = GlossyColors.LightBlue
            )
        }

        item {
            SingleBandPowerCard(
                bandTitle = "5.0 GHz Radio Transmit Power",
                chipset = "MT7613BEN (802.11ac Wave 2)",
                power = power5g,
                onPowerChange = { power5g = it },
                accentColor = GlossyColors.LightBlue,
                onApply = { onSavePower(power2g.toInt(), power5g.toInt()) }
            )
        }

        item {
            SubSectionHeader(title = "5.0 GHz Broadcasted Networks", count = 1)
        }

        item {
            val radioClients = clients.filter {
                it.connectionType.equals("5GHz", ignoreCase = true) ||
                        it.ssidName.equals(wireless.radio5g.ssid, ignoreCase = true)
            }
            RadioCard(
                band = "5.0 GHz Primary Access Point",
                radio = wireless.radio5g,
                matchingClients = radioClients,
                accentColor = GlossyColors.LightBlue,
                onEdit = { editingRadio = "5.0 GHz" to wireless.radio5g },
                onShare = { sharingSsid = wireless.radio5g.ssid to "" },
                onViewClients = { viewingClientsForRadio = wireless.radio5g to "5.0 GHz" }
            )
        }

        item {
            SecurityFeaturesCard(wireless = wireless)
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    editingRadio?.let { (band, radio) ->
        EditSsidSheet(
            band = band,
            radio = radio,
            onSave = { ssid, key, isHidden ->
                onSaveSsid(band, ssid, key, isHidden)
            },
            onDismiss = { editingRadio = null }
        )
    }

    sharingSsid?.let { (ssid, pass) ->
        ShareSsidSheet(
            ssid = ssid,
            password = pass,
            onDismiss = { sharingSsid = null }
        )
    }

    viewingClientsForRadio?.let { (radio, band) ->
        val matchingClients = clients.filter {
            it.ssidName.equals(radio.ssid, ignoreCase = true) ||
                    (band.contains("5") && it.connectionType.equals("5GHz", ignoreCase = true)) ||
                    (band.contains("2.4") && it.connectionType.equals("2.4GHz", ignoreCase = true)) ||
                    (band.contains("Guest") && it.connectionType.contains("guest", ignoreCase = true))
        }
        ConnectedClientsSheet(
            radio = radio,
            band = band,
            clients = matchingClients,
            onDismiss = { viewingClientsForRadio = null }
        )
    }
}

@Composable
private fun BandHeaderRow(
    title: String,
    spec: String,
    tag: String,
    clients: Int,
    accentColor: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(accentColor.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Wifi,
                    contentDescription = null,
                    tint = accentColor,
                    modifier = Modifier.size(18.dp)
                )
            }
            Spacer(modifier = Modifier.width(10.dp))
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = title,
                        color = GlossyColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(accentColor.copy(alpha = 0.2f))
                            .padding(horizontal = 5.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = tag,
                            color = accentColor,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
                Text(
                    text = spec,
                    color = GlossyColors.TextMuted,
                    fontSize = 11.sp
                )
            }
        }
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(6.dp))
                .background(if (clients > 0) GlossyColors.EmeraldMint.copy(alpha = 0.15f) else GlossyColors.GlassSurface)
                .padding(horizontal = 8.dp, vertical = 4.dp)
        ) {
            Text(
                text = "$clients Connected",
                color = if (clients > 0) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun SubSectionHeader(title: String, count: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            color = GlossyColors.TextSecondary,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold
        )
        Text(
            text = "$count Configured",
            color = GlossyColors.TextMuted,
            fontSize = 11.sp
        )
    }
}

@Composable
private fun SingleBandPowerCard(
    bandTitle: String,
    chipset: String,
    power: Float,
    onPowerChange: (Float) -> Unit,
    accentColor: Color,
    onApply: () -> Unit
) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.CellTower,
                        contentDescription = null,
                        tint = accentColor,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column {
                        Text(
                            text = bandTitle,
                            color = GlossyColors.TextPrimary,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = chipset,
                            color = GlossyColors.TextMuted,
                            fontSize = 10.sp
                        )
                    }
                }
                Text(
                    text = String.format(Locale.US, "%.0f dBm", power),
                    color = accentColor,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Slider(
                value = power,
                onValueChange = onPowerChange,
                valueRange = 10f..23f,
                colors = SliderDefaults.colors(
                    thumbColor = accentColor,
                    activeTrackColor = accentColor
                )
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                GlossyButton(
                    text = "Apply ${power.toInt()} dBm",
                    onClick = onApply,
                    isPrimary = false,
                    fontSize = 11.sp
                )
            }
        }
    }
}

@Composable
private fun RadioCard(
    band: String,
    radio: RadioInfo,
    matchingClients: List<ClientInfo> = emptyList(),
    accentColor: Color,
    onEdit: () -> Unit = {},
    onShare: () -> Unit = {},
    onViewClients: () -> Unit = {}
) {
    GlossyCard(
        modifier = Modifier.clickable { onViewClients() }
    ) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    modifier = Modifier.weight(1f),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(accentColor.copy(alpha = 0.2f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Wifi,
                            contentDescription = null,
                            tint = accentColor,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = radio.ssid.ifEmpty { "Disabled Radio" },
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1,
                            overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
                        )
                        Text(
                            text = band,
                            color = GlossyColors.TextSecondary,
                            fontSize = 11.sp,
                            maxLines = 1,
                            overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
                        )
                    }
                }

                Spacer(modifier = Modifier.width(6.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    GlossyButton(
                        text = "Share",
                        onClick = onShare,
                        isPrimary = false,
                        contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                        fontSize = 11.sp
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    GlossyButton(
                        text = "Edit",
                        onClick = onEdit,
                        isPrimary = false,
                        contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                        fontSize = 11.sp
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(if (radio.enabled) GlossyColors.EmeraldMint.copy(alpha = 0.2f) else GlossyColors.GlassSurface)
                            .padding(horizontal = 6.dp, vertical = 5.dp)
                    ) {
                        Text(
                            text = if (radio.enabled) "ACTIVE" else "OFF",
                            color = if (radio.enabled) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    MetricPill(label = "Channel", value = radio.channel.toString())
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    MetricPill(label = "TX Power", value = "${radio.txPowerDbm} dBm")
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clickable { onViewClients() },
                    contentAlignment = Alignment.Center
                ) {
                    MetricPill(label = "Clients", value = "${radio.connectedClients}", isClickable = true)
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    MetricPill(label = "Mode", value = radio.htmode)
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Interactive Connected Clients Preview Strip
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .background(
                        if (matchingClients.isNotEmpty()) GlossyColors.PrimaryBlue.copy(alpha = 0.08f)
                        else GlossyColors.GlassSurface.copy(alpha = 0.2f)
                    )
                    .clickable { onViewClients() }
                    .padding(horizontal = 10.dp, vertical = 8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        modifier = Modifier.weight(1f),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Devices,
                            contentDescription = null,
                            tint = if (matchingClients.isNotEmpty()) GlossyColors.LightBlue else GlossyColors.TextMuted,
                            modifier = Modifier.size(15.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = if (matchingClients.isNotEmpty())
                                "Connected: " + matchingClients.take(2).joinToString(", ") { it.displayName } +
                                        if (matchingClients.size > 2) " +${matchingClients.size - 2} more" else ""
                            else
                                "0 devices connected • Tap to monitor",
                            color = if (matchingClients.isNotEmpty()) GlossyColors.TextPrimary else GlossyColors.TextMuted,
                            fontSize = 11.sp,
                            fontWeight = if (matchingClients.isNotEmpty()) FontWeight.SemiBold else FontWeight.Normal,
                            maxLines = 1,
                            overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
                        )
                    }
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = "${matchingClients.size} online",
                            color = if (matchingClients.isNotEmpty()) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Icon(
                            imageVector = Icons.Default.ChevronRight,
                            contentDescription = null,
                            tint = GlossyColors.TextMuted,
                            modifier = Modifier.size(14.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun MetricPill(label: String, value: String, isClickable: Boolean = false) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            color = if (isClickable) GlossyColors.LightBlue else GlossyColors.TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold
        )
        Text(
            text = label,
            color = GlossyColors.TextMuted,
            fontSize = 11.sp
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ConnectedClientsSheet(
    radio: RadioInfo,
    band: String,
    clients: List<ClientInfo>,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = GlossyColors.BackgroundElevated
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "${radio.ssid} Clients",
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "$band Band • ${clients.size} device(s) connected",
                        color = GlossyColors.TextMuted,
                        fontSize = 12.sp
                    )
                }
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(if (clients.isNotEmpty()) GlossyColors.EmeraldMint.copy(alpha = 0.15f) else GlossyColors.GlassSurface)
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = "${clients.size} Online",
                        color = if (clients.isNotEmpty()) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (clients.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Default.Devices,
                            contentDescription = null,
                            tint = GlossyColors.TextMuted,
                            modifier = Modifier.size(36.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "No devices connected to \"${radio.ssid}\"",
                            color = GlossyColors.TextSecondary,
                            fontSize = 13.sp
                        )
                        Text(
                            text = "Connected devices will appear here automatically.",
                            color = GlossyColors.TextMuted,
                            fontSize = 11.sp
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(clients) { client ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(10.dp))
                                .background(GlossyColors.GlassSurface.copy(alpha = 0.3f))
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                modifier = Modifier.weight(1f),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.15f)),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.PhoneAndroid,
                                        contentDescription = null,
                                        tint = GlossyColors.LightBlue,
                                        modifier = Modifier.size(18.dp)
                                    )
                                }
                                Spacer(modifier = Modifier.width(10.dp))
                                Column {
                                    Text(
                                        text = client.displayName,
                                        color = GlossyColors.TextPrimary,
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                    Text(
                                        text = "${client.ip} • ${client.mac}",
                                        color = GlossyColors.TextMuted,
                                        fontSize = 11.sp
                                    )
                                    if (client.rxBytes > 0 || client.txBytes > 0) {
                                        Text(
                                            text = "↓ ${client.formattedRx} • ↑ ${client.formattedTx}",
                                            color = GlossyColors.TextSecondary,
                                            fontSize = 10.sp
                                        )
                                    }
                                }
                            }

                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                                    .padding(horizontal = 6.dp, vertical = 3.dp)
                            ) {
                                Text(
                                    text = "${client.signalDbm} dBm",
                                    color = GlossyColors.EmeraldMint,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun SecurityFeaturesCard(wireless: WirelessInfo) {
    GlossyCard {
        Column {
            Text(
                text = "WI-FI SECURITY & PROTOCOLS",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(12.dp))
            FeatureRow(name = "802.11r Fast BSS Transition (Roaming)", enabled = wireless.fastRoaming)
            FeatureRow(name = "802.11w Protected Management Frames (PMF)", enabled = wireless.pmfProtected)
            FeatureRow(name = "WMM Wi-Fi Multimedia QoS Prioritization", enabled = wireless.wmmQos)
            FeatureRow(name = "Drop Legacy 802.11b Rates", enabled = wireless.dropLegacyRates)
        }
    }
}

@Composable
private fun FeatureRow(name: String, enabled: Boolean) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = name,
            color = GlossyColors.TextPrimary,
            fontSize = 13.sp,
            modifier = Modifier.weight(1f)
        )
        Icon(
            imageVector = if (enabled) Icons.Default.CheckCircle else Icons.Default.Security,
            contentDescription = null,
            tint = if (enabled) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
            modifier = Modifier.size(16.dp)
        )
    }
}
