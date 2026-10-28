package com.archerguard.openwrt.ui.screens.firewall

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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Shield
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.PaddingValues
import com.archerguard.openwrt.domain.model.FirewallInfo
import com.archerguard.openwrt.domain.model.PortForwardRule
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun FirewallScreen(
    firewall: FirewallInfo,
    blockedClients: List<com.archerguard.openwrt.domain.model.ClientInfo> = emptyList(),
    onAddPortForward: (PortForwardRule) -> Unit = {},
    onUnblockClient: (String) -> Unit = {},
    onSaveDmz: (ip: String, enabled: Boolean) -> Unit = { _, _ -> },
    onBackClick: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    var showAddSheet by remember { mutableStateOf(false) }
    var showDmzSheet by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        if (onBackClick != null) {
            item {
                com.archerguard.openwrt.ui.components.ArcherTopAppBar(
                    title = "Firewall & Rules",
                    subtitle = "Port forwarding, DMZ & packet filter",
                    onBackClick = onBackClick,
                    actions = {
                        com.archerguard.openwrt.ui.components.GlossyButton(
                            text = "DMZ",
                            onClick = { showDmzSheet = true },
                            isPrimary = false,
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                            fontSize = 12.sp
                        )
                        com.archerguard.openwrt.ui.components.GlossyButton(
                            text = "+ Rule",
                            onClick = { showAddSheet = true },
                            isPrimary = true,
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                            fontSize = 12.sp
                        )
                    }
                )
            }
        } else {
            item {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Firewall & Security",
                        color = GlossyColors.TextPrimary,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        com.archerguard.openwrt.ui.components.GlossyButton(
                            text = "DMZ",
                            onClick = { showDmzSheet = true },
                            isPrimary = false,
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                            fontSize = 12.sp
                        )
                        com.archerguard.openwrt.ui.components.GlossyButton(
                            text = "+ Add Rule",
                            onClick = { showAddSheet = true },
                            isPrimary = true,
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                            fontSize = 12.sp
                        )
                    }
                }
                Spacer(modifier = Modifier.height(4.dp))
            }
        }

        item {
            FirewallStatusCard(firewall = firewall)
        }

        if (blockedClients.isNotEmpty()) {
            item {
                FirewallBlocklistSection(
                    blockedClients = blockedClients,
                    onUnblock = onUnblockClient
                )
            }
        }

        item {
            Text(
                text = "PORT FORWARDING RULES (${firewall.portForwards.size})",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
        }

        items(firewall.portForwards, key = { it.id }) { rule ->
            PortForwardCard(rule = rule)
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    if (showAddSheet) {
        AddPortForwardSheet(
            onAddRule = onAddPortForward,
            onDismiss = { showAddSheet = false }
        )
    }

    if (showDmzSheet) {
        DmzConfigSheet(
            currentDmzIp = firewall.dmzIp,
            isEnabled = firewall.dmzEnabled,
            onSaveDmz = onSaveDmz,
            onDismiss = { showDmzSheet = false }
        )
    }
}

@Composable
private fun FirewallBlocklistSection(
    blockedClients: List<com.archerguard.openwrt.domain.model.ClientInfo>,
    onUnblock: (String) -> Unit
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
                        imageVector = Icons.Default.Security,
                        contentDescription = null,
                        tint = GlossyColors.RoseCoral,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.size(6.dp))
                    Text(
                        text = "Firewall Blocklist (${blockedClients.size})",
                        color = GlossyColors.TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(modifier = Modifier.height(10.dp))
            blockedClients.forEach { client ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = client.displayName,
                            color = GlossyColors.TextPrimary,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = client.mac,
                            color = GlossyColors.TextSecondary,
                            fontSize = 11.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    com.archerguard.openwrt.ui.components.GlossyButton(
                        text = "Unblock",
                        onClick = { onUnblock(client.mac) },
                        isPrimary = false,
                        contentPadding = PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                        fontSize = 11.sp
                    )
                }
            }
        }
    }
}

@Composable
private fun FirewallStatusCard(firewall: FirewallInfo) {
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
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.2f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Shield,
                            contentDescription = null,
                            tint = GlossyColors.EmeraldMint,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.padding(6.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = firewall.engine,
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "State: ${firewall.status.uppercase()}",
                            color = GlossyColors.EmeraldMint,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                Spacer(modifier = Modifier.width(6.dp))

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f))
                        .padding(horizontal = 8.dp, vertical = 3.dp)
                ) {
                    Text(
                        text = "${firewall.conntrackCount} Conntrack",
                        color = GlossyColors.LightBlue,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    FirewallMetric(label = "SYN Flood", active = firewall.synFlood)
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    FirewallMetric(label = "Drop Invalid", active = firewall.dropInvalid)
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    FirewallMetric(label = "DNS Rebind", active = firewall.dnsRebind)
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    FirewallMetric(label = "Anti-Spoof", active = firewall.antiSpoofing)
                }
            }
        }
    }
}

@Composable
private fun FirewallMetric(label: String, active: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(
            imageVector = if (active) Icons.Default.Check else Icons.Default.Close,
            contentDescription = null,
            tint = if (active) GlossyColors.EmeraldMint else GlossyColors.RoseCoral,
            modifier = Modifier.size(16.dp)
        )
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 11.sp,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun PortForwardCard(rule: PortForwardRule) {
    GlossyCard {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = rule.name,
                    color = GlossyColors.TextPrimary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "WAN :${rule.extPort} → ${rule.intIp}:${rule.intPort} (${rule.proto.uppercase()})",
                    color = GlossyColors.TextSecondary,
                    fontSize = 12.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Spacer(modifier = Modifier.width(8.dp))

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(if (rule.enabled) GlossyColors.EmeraldMint.copy(alpha = 0.2f) else GlossyColors.GlassSurface)
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            ) {
                Text(
                    text = if (rule.enabled) "ON" else "OFF",
                    color = if (rule.enabled) GlossyColors.EmeraldMint else GlossyColors.TextMuted,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
