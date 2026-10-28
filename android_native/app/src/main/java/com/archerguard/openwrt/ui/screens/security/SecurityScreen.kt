package com.archerguard.openwrt.ui.screens.security

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VpnKey
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
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
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.components.CircularGauge
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.RouterViewModel

@Composable
fun SecurityScreen(
    status: RouterStatus,
    viewModel: RouterViewModel,
    modifier: Modifier = Modifier
) {
    var showAuditSheet by remember { mutableStateOf(false) }
    var macToBlock by remember { mutableStateOf("") }

    // Security Score Calculation (out of 100)
    var score = 0
    if (status.wireless.pmfProtected) score += 20
    if (status.network.dnsRebindProtection) score += 20
    if (status.network.dohEnabled) score += 20
    if (status.network.wanLockdown) score += 20
    if (status.firewall.guestIsolation) score += 20

    val scoreColor = when {
        score >= 80 -> GlossyColors.EmeraldMint
        score >= 60 -> GlossyColors.AmberWarm
        else -> GlossyColors.RoseCoral
    }

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
                text = "Security Hub",
                color = GlossyColors.TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            SecurityScoreCard(
                score = score,
                scoreColor = scoreColor,
                onViewAudit = { showAuditSheet = true },
                onAutoHarden = {
                    viewModel.executeRouterAction("auto_harden", emptyMap())
                }
            )
        }

        item {
            SecurityTogglesCard(
                status = status,
                viewModel = viewModel
            )
        }

        item {
            MacBlockCard(
                macInput = macToBlock,
                onMacChange = { macToBlock = it },
                onBlock = {
                    if (macToBlock.isNotBlank()) {
                        viewModel.executeRouterAction("block_mac", mapOf("mac" to macToBlock.trim()))
                        macToBlock = ""
                    }
                }
            )
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    if (showAuditSheet) {
        SecurityAuditBottomSheet(
            status = status,
            score = score,
            onDismiss = { showAuditSheet = false }
        )
    }
}

@Composable
private fun SecurityScoreCard(
    score: Int,
    scoreColor: Color,
    onViewAudit: () -> Unit,
    onAutoHarden: () -> Unit
) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "SECURITY RATING",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = when {
                            score >= 80 -> "Hardened & Protected"
                            score >= 60 -> "Moderate Defense"
                            else -> "Vulnerable to Intrusions"
                        },
                        color = scoreColor,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                CircularGauge(
                    value = score.toDouble(),
                    label = "Defense",
                    size = 72.dp,
                    activeColor = scoreColor
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                GlossyButton(
                    text = "Audit Checklist",
                    onClick = onViewAudit,
                    icon = Icons.Default.Shield,
                    isPrimary = false,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "1-Tap Harden",
                    onClick = onAutoHarden,
                    icon = Icons.Default.Lock,
                    isPrimary = true,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun SecurityTogglesCard(
    status: RouterStatus,
    viewModel: RouterViewModel
) {
    GlossyCard {
        Column {
            Text(
                text = "ACTIVE THREAT MITIGATION",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(12.dp))

            SecurityToggleRow(
                title = "Protected Management Frames (PMF)",
                subtitle = "802.11w deauth & disassociation attack shield",
                checked = status.wireless.pmfProtected,
                onCheckedChange = {
                    viewModel.executeRouterAction("toggle_pmf", mapOf("enabled" to it.toString()))
                }
            )

            SecurityToggleRow(
                title = "DNS Rebind Attack Protection",
                subtitle = "Disallow RFC1918 private IPs from upstream DNS",
                checked = status.network.dnsRebindProtection,
                onCheckedChange = {
                    viewModel.executeRouterAction("toggle_dns_rebind", mapOf("enabled" to it.toString()))
                }
            )

            SecurityToggleRow(
                title = "WAN Port Lockdown",
                subtitle = "Drop unprompted incoming WAN scans and pings",
                checked = status.network.wanLockdown,
                onCheckedChange = {
                    viewModel.executeRouterAction("toggle_wan_lockdown", mapOf("enabled" to it.toString()))
                }
            )

            SecurityToggleRow(
                title = "WireGuard VPN Management",
                subtitle = "Curve25519 encrypted remote router control",
                checked = status.network.wireguardEnabled,
                onCheckedChange = {
                    viewModel.executeRouterAction("toggle_wireguard", mapOf("enabled" to it.toString()))
                }
            )
        }
    }
}

@Composable
private fun SecurityToggleRow(
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = GlossyColors.TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = subtitle,
                color = GlossyColors.TextMuted,
                fontSize = 11.sp
            )
        }
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = GlossyColors.EmeraldMint,
                checkedTrackColor = GlossyColors.EmeraldMint.copy(alpha = 0.3f)
            )
        )
    }
}

@Composable
private fun MacBlockCard(
    macInput: String,
    onMacChange: (String) -> Unit,
    onBlock: () -> Unit
) {
    GlossyCard {
        Column {
            Text(
                text = "BLOCK UNTRUSTED DEVICE",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(10.dp))
            GlossyInput(
                value = macInput,
                onValueChange = onMacChange,
                label = "Target MAC Address",
                placeholder = "AA:BB:CC:DD:EE:FF"
            )
            Spacer(modifier = Modifier.height(10.dp))
            GlossyButton(
                text = "Drop & Block from Wi-Fi",
                onClick = onBlock,
                icon = Icons.Default.Block,
                isPrimary = false,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SecurityAuditBottomSheet(
    status: RouterStatus,
    score: Int,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = GlossyColors.BackgroundSecondary
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            Text(
                text = "Security Audit Breakdown ($score/100)",
                color = GlossyColors.TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(14.dp))

            AuditItem("802.11w PMF Protection", status.wireless.pmfProtected, 20)
            AuditItem("DNS Rebinding Shield", status.network.dnsRebindProtection, 20)
            AuditItem("DNS over HTTPS (DoH)", status.network.dohEnabled, 20)
            AuditItem("WAN Interface Lockdown", status.network.wanLockdown, 20)
            AuditItem("Guest Network Isolation", status.firewall.guestIsolation, 20)

            Spacer(modifier = Modifier.height(16.dp))
            GlossyButton(
                text = "Close Audit",
                onClick = onDismiss,
                isPrimary = false,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
private fun AuditItem(name: String, passed: Boolean, points: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = if (passed) Icons.Default.Check else Icons.Default.Warning,
                contentDescription = null,
                tint = if (passed) GlossyColors.EmeraldMint else GlossyColors.RoseCoral,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.padding(4.dp))
            Text(
                text = name,
                color = GlossyColors.TextPrimary,
                fontSize = 14.sp
            )
        }
        Text(
            text = if (passed) "+$points pts" else "0 pts",
            color = if (passed) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}
