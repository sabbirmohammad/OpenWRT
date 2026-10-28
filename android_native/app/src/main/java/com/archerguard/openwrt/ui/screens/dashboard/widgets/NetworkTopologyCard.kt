package com.archerguard.openwrt.ui.screens.dashboard.widgets

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cable
import androidx.compose.material.icons.filled.Public
import androidx.compose.material.icons.filled.Router
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.ConnectionStatus

/**
 * Interactive Network Topology Card.
 * Visualizes the hierarchical network tree:
 * [Internet / WAN]
 *        │
 * [Router Gateway]
 *   ┌────┼────┐
 * [2.4G] [5G] [LAN]
 */
@Composable
fun NetworkTopologyCard(
    status: RouterStatus,
    connectionStatus: ConnectionStatus,
    latencyMs: Long,
    routerIp: String,
    onNavigateToDevices: () -> Unit = {},
    onNavigateToWifi: () -> Unit = {},
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "pulse_animation")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.4f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1400, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseAlpha"
    )

    val clients = status.clients
    val clients2g = clients.count {
        it.ssidName.contains("2.4", ignoreCase = true) || it.connectionType.contains("2.4", ignoreCase = true)
    }
    val clients5g = clients.count {
        it.ssidName.contains("5", ignoreCase = true) || it.connectionType.contains("5", ignoreCase = true)
    }
    val clientsLan = clients.count {
        it.connectionType.equals("LAN", ignoreCase = true) || it.connectionType.equals("Ethernet", ignoreCase = true)
    }

    GlossyCard(modifier = modifier) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            // Header Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(7.dp)
                            .clip(CircleShape)
                            .background(
                                if (connectionStatus == ConnectionStatus.CONNECTED) GlossyColors.EmeraldMint
                                else GlossyColors.RoseCoral
                            )
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "NETWORK TOPOLOGY",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(GlossyColors.GlassSurface)
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = "${clients.size} Total Clients",
                        color = GlossyColors.SkyBlue,
                        fontSize = 10.5.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // 1. WAN Uplink Node
            Row(
                modifier = Modifier
                    .fillMaxWidth(0.92f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(GlossyColors.GlassSurface)
                    .border(0.5.dp, GlossyColors.GlassBorderLight, RoundedCornerShape(12.dp))
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Public,
                            contentDescription = "WAN",
                            tint = GlossyColors.LightBlue,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Column {
                        Text(
                            text = "Internet Uplink",
                            color = GlossyColors.TextPrimary,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = if (status.traffic.wanIp.isNotBlank()) status.traffic.wanIp else "Connected",
                            color = GlossyColors.TextMuted,
                            fontSize = 11.sp,
                            style = GlossyColors.TabularCaption
                        )
                    }
                }

                if (latencyMs >= 0) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text(
                            text = "${latencyMs}ms",
                            color = GlossyColors.EmeraldMint,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            style = GlossyColors.TabularCaption
                        )
                    }
                }
            }

            // Connector 1: WAN to Router
            Box(
                modifier = Modifier
                    .width(2.dp)
                    .height(16.dp)
                    .background(
                        Brush.verticalGradient(
                            listOf(GlossyColors.LightBlue, GlossyColors.EmeraldMint)
                        )
                    )
            )

            // 2. Gateway Router Node
            Row(
                modifier = Modifier
                    .fillMaxWidth(0.92f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(GlossyColors.BackgroundElevated)
                    .border(1.dp, GlossyColors.EmeraldMint.copy(alpha = pulseAlpha * 0.5f), RoundedCornerShape(12.dp))
                    .padding(horizontal = 12.dp, vertical = 9.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(34.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.2f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Router,
                            contentDescription = "Router",
                            tint = GlossyColors.EmeraldMint,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Column {
                        Text(
                            text = status.cpu.model.split("@").first().ifBlank { "OpenWrt Gateway" }.trim(),
                            color = GlossyColors.TextPrimary,
                            fontSize = 13.5.sp,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "Gateway: $routerIp • Uptime: ${status.cpu.formattedUptime}",
                            color = GlossyColors.TextSecondary,
                            fontSize = 11.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }

            // Connector 2: Branching Stem Line
            Box(
                modifier = Modifier
                    .width(2.dp)
                    .height(12.dp)
                    .background(GlossyColors.GlassBorderLight)
            )

            // 3. Distribution Nodes (2.4 GHz, 5.0 GHz, LAN)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                TopologyBranchNode(
                    title = "2.4 GHz",
                    subtitle = "${status.wireless.radio2g.channel} Ch",
                    clientCount = clients2g,
                    icon = Icons.Default.Wifi,
                    accentColor = GlossyColors.Band2GHz,
                    onClick = onNavigateToWifi,
                    modifier = Modifier.weight(1f)
                )

                TopologyBranchNode(
                    title = "5.0 GHz",
                    subtitle = "${status.wireless.radio5g.channel} Ch",
                    clientCount = clients5g,
                    icon = Icons.Default.Wifi,
                    accentColor = GlossyColors.Band5GHz,
                    onClick = onNavigateToWifi,
                    modifier = Modifier.weight(1f)
                )

                TopologyBranchNode(
                    title = "LAN Ports",
                    subtitle = "1 Gbps",
                    clientCount = clientsLan,
                    icon = Icons.Default.Cable,
                    accentColor = GlossyColors.LanGigabit,
                    onClick = onNavigateToDevices,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun TopologyBranchNode(
    title: String,
    subtitle: String,
    clientCount: Int,
    icon: ImageVector,
    accentColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(GlossyColors.GlassSurface)
            .border(1.dp, accentColor.copy(alpha = 0.35f), RoundedCornerShape(12.dp))
            .clickable(
                indication = ripple(bounded = true, color = accentColor),
                interactionSource = androidx.compose.foundation.interaction.MutableInteractionSource(),
                onClick = onClick
            )
            .padding(vertical = 10.dp, horizontal = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(accentColor.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = title,
                    tint = accentColor,
                    modifier = Modifier.size(16.dp)
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = title,
                color = GlossyColors.TextPrimary,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Text(
                text = subtitle,
                color = GlossyColors.TextMuted,
                fontSize = 10.sp
            )

            Spacer(modifier = Modifier.height(6.dp))

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(accentColor.copy(alpha = 0.18f))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            ) {
                Text(
                    text = "$clientCount ${if (clientCount == 1) "device" else "devices"}",
                    color = accentColor,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}
