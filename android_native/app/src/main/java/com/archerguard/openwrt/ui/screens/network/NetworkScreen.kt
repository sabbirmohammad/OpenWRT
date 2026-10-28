package com.archerguard.openwrt.ui.screens.network

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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Router
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.VpnKey
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.PaddingValues
import com.archerguard.openwrt.domain.model.NetworkInfo
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun NetworkScreen(
    network: NetworkInfo,
    onToggleSqm: (Boolean) -> Unit,
    onToggleHwOffload: (Boolean) -> Unit = {},
    onTuneSqm: (downloadKbit: Int, uploadKbit: Int) -> Unit = { _, _ -> },
    onSelectDns: (DnsPreset) -> Unit = {},
    modifier: Modifier = Modifier
) {
    var showSqmTune by remember { mutableStateOf(false) }
    var showDnsConfig by remember { mutableStateOf(false) }

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
                text = "Network & Routing",
                color = GlossyColors.TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            WanGatewayCard(network = network)
        }

        item {
            com.archerguard.openwrt.ui.screens.network.widgets.HwOffloadCard(
                network = network,
                onToggle = onToggleHwOffload
            )
        }

        item {
            SqmQosCard(
                network = network,
                onToggleSqm = onToggleSqm,
                onTune = { showSqmTune = true }
            )
        }

        item {
            DnsPrivacyCard(
                network = network,
                onChangeDns = { showDnsConfig = true }
            )
        }

        item {
            com.archerguard.openwrt.ui.screens.network.widgets.MultiWanCard(
                network = network
            )
        }

        item {
            WireguardTunnelCard(network = network)
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    if (showSqmTune) {
        SqmTuneSheet(
            network = network,
            onApply = onTuneSqm,
            onDismiss = { showSqmTune = false }
        )
    }

    if (showDnsConfig) {
        DnsConfigSheet(
            currentDns = network.dns,
            onSelectDns = onSelectDns,
            onDismiss = { showDnsConfig = false }
        )
    }
}

@Composable
private fun WanGatewayCard(network: NetworkInfo) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "WAN GATEWAY & PROTOCOL",
                    color = GlossyColors.TextSecondary,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = network.protocol.uppercase(),
                        color = GlossyColors.LightBlue,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1.2f)) {
                    Text("Gateway IP", color = GlossyColors.TextMuted, fontSize = 11.sp)
                    Text(
                        text = network.gateway.ifBlank { "0.0.0.0" },
                        color = GlossyColors.TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Column(modifier = Modifier.weight(0.8f)) {
                    Text("MTU", color = GlossyColors.TextMuted, fontSize = 11.sp)
                    Text("${network.mtu}", color = GlossyColors.TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text("Latency", color = GlossyColors.TextMuted, fontSize = 11.sp)
                    Text("${network.latencyMs} ms", color = GlossyColors.EmeraldMint, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

@Composable
private fun SqmQosCard(
    network: NetworkInfo,
    onToggleSqm: (Boolean) -> Unit,
    onTune: () -> Unit = {}
) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "CAKE SQM Bufferbloat Shield",
                        color = GlossyColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Zero-lag smart queue management",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Switch(
                    checked = network.sqmEnabled,
                    onCheckedChange = onToggleSqm,
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = GlossyColors.EmeraldMint,
                        checkedTrackColor = GlossyColors.EmeraldMint.copy(alpha = 0.3f)
                    )
                )
            }

            if (network.sqmEnabled) {
                Spacer(modifier = Modifier.height(10.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "↓ ${network.sqmDownloadMbps} Mbps  ↑ ${network.sqmUploadMbps} Mbps",
                            color = GlossyColors.LightBlue,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "Queue Discipline: ${network.sqmQdisc.uppercase()}",
                            color = GlossyColors.TextMuted,
                            fontSize = 11.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    com.archerguard.openwrt.ui.components.GlossyButton(
                        text = "Tune",
                        onClick = onTune,
                        isPrimary = false,
                        contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                        fontSize = 12.sp
                    )
                }
            }
        }
    }
}

@Composable
private fun DnsPrivacyCard(
    network: NetworkInfo,
    onChangeDns: () -> Unit = {}
) {
    GlossyCard {
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
                    Icon(
                        imageVector = Icons.Default.Dns,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "DNS over HTTPS (DoH)",
                        color = GlossyColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                com.archerguard.openwrt.ui.components.GlossyButton(
                    text = "Change",
                    onClick = onChangeDns,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                    fontSize = 12.sp
                )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Provider: ${network.dohProvider}",
                color = GlossyColors.TextSecondary,
                fontSize = 13.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = "Upstream: ${network.dns}",
                color = GlossyColors.TextMuted,
                fontSize = 12.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun WireguardTunnelCard(network: NetworkInfo) {
    GlossyCard {
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
                    Icon(
                        imageVector = Icons.Default.VpnKey,
                        contentDescription = null,
                        tint = GlossyColors.IsolatedLight,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "WireGuard Tunnel",
                        color = GlossyColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.width(6.dp))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(
                            if (network.wireguardEnabled) GlossyColors.EmeraldMint.copy(alpha = 0.2f)
                            else GlossyColors.GlassSurface
                        )
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = if (network.wireguardEnabled) "ONLINE" else "STANDBY",
                        color = if (network.wireguardEnabled) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Interface: ${network.wireguardInterface} (${network.wireguardEndpoint})",
                color = GlossyColors.TextSecondary,
                fontSize = 12.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
