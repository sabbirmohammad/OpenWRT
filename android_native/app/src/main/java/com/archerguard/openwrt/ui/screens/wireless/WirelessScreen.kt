package com.archerguard.openwrt.ui.screens.wireless

import androidx.compose.foundation.background
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CellTower
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.RadioInfo
import com.archerguard.openwrt.domain.model.WirelessInfo
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun WirelessScreen(
    wireless: WirelessInfo,
    onSaveSsid: (band: String, ssid: String, key: String, isHidden: Boolean) -> Unit = { _, _, _, _ -> },
    onToggleMasterWifi: (Boolean) -> Unit = {},
    onSavePower: (power2g: Int, power5g: Int) -> Unit = { _, _ -> },
    modifier: Modifier = Modifier
) {
    var editingRadio by remember { mutableStateOf<Pair<String, RadioInfo>?>(null) }
    var sharingSsid by remember { mutableStateOf<Pair<String, String>?>(null) }

    val isMasterWifiOn = wireless.radio2g.enabled || wireless.radio5g.enabled

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Wi-Fi Radios",
                color = GlossyColors.TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            com.archerguard.openwrt.ui.screens.wireless.widgets.MasterWifiCard(
                isWifiOn = isMasterWifiOn,
                onToggle = onToggleMasterWifi
            )
        }

        item {
            RadioCard(
                band = "2.4 GHz High-Range",
                radio = wireless.radio2g,
                accentColor = GlossyColors.EmeraldMint,
                onEdit = { editingRadio = "2.4 GHz" to wireless.radio2g },
                onShare = { sharingSsid = wireless.radio2g.ssid to "" }
            )
        }

        item {
            RadioCard(
                band = "5.0 GHz Ultra-Fast",
                radio = wireless.radio5g,
                accentColor = GlossyColors.LightBlue,
                onEdit = { editingRadio = "5.0 GHz" to wireless.radio5g },
                onShare = { sharingSsid = wireless.radio5g.ssid to "" }
            )
        }

        if (wireless.guest.enabled || wireless.guest.ssid.isNotEmpty()) {
            item {
                RadioCard(
                    band = "Isolated Guest Network",
                    radio = wireless.guest,
                    accentColor = GlossyColors.IsolatedAccent,
                    onEdit = { editingRadio = "Guest Network" to wireless.guest },
                    onShare = { sharingSsid = wireless.guest.ssid to "" }
                )
            }
        }

        item {
            com.archerguard.openwrt.ui.screens.wireless.widgets.RadioPowerCard(
                txPower2g = wireless.radio2g.txPowerDbm,
                txPower5g = wireless.radio5g.txPowerDbm,
                onSavePower = onSavePower
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
}

@Composable
private fun RadioCard(
    band: String,
    radio: RadioInfo,
    accentColor: androidx.compose.ui.graphics.Color,
    onEdit: () -> Unit = {},
    onShare: () -> Unit = {}
) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
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
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = radio.ssid.ifEmpty { "Disabled Radio" },
                            color = GlossyColors.TextPrimary,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = band,
                            color = GlossyColors.TextSecondary,
                            fontSize = 12.sp
                        )
                    }
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    com.archerguard.openwrt.ui.components.GlossyButton(
                        text = "Share",
                        onClick = onShare,
                        isPrimary = false
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    com.archerguard.openwrt.ui.components.GlossyButton(
                        text = "Edit",
                        onClick = onEdit,
                        isPrimary = false
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(if (radio.enabled) GlossyColors.EmeraldMint.copy(alpha = 0.2f) else GlossyColors.GlassSurface)
                            .padding(horizontal = 8.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = if (radio.enabled) "ACTIVE" else "OFF",
                            color = if (radio.enabled) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                MetricPill(label = "Channel", value = radio.channel.toString())
                MetricPill(label = "TX Power", value = "${radio.txPowerDbm} dBm")
                MetricPill(label = "Clients", value = "${radio.connectedClients}")
                MetricPill(label = "Mode", value = radio.htmode)
            }
        }
    }
}

@Composable
private fun MetricPill(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            color = GlossyColors.TextPrimary,
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
