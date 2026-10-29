package com.archerguard.openwrt.ui.screens.dashboard

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Nightlight
import androidx.compose.material.icons.filled.Public
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.components.CircularGauge
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.TrafficSparkline
import com.archerguard.openwrt.ui.screens.dashboard.widgets.CpuCoresMiniCard
import com.archerguard.openwrt.ui.screens.dashboard.widgets.FreeMemoryMiniCard
import com.archerguard.openwrt.ui.screens.dashboard.widgets.LoadAverageMiniCard
import com.archerguard.openwrt.ui.screens.dashboard.widgets.UptimeMiniCard
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.ConnectionStatus
import com.archerguard.openwrt.ui.viewmodel.RouterUiState

@Composable
fun DashboardScreen(
    uiState: RouterUiState,
    onRefresh: () -> Unit,
    onReboot: () -> Unit,
    onDropCaches: () -> Unit,
    onToggleLeds: () -> Unit,
    onOpenMenu: () -> Unit = {},
    onNavigateToTab: (Int) -> Unit = {},
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(8.dp))
            HeaderSection(
                uiState = uiState,
                onRefresh = onRefresh,
                onOpenMenu = onOpenMenu
            )
        }

        if (uiState.connectionStatus == ConnectionStatus.OFFLINE || uiState.connectionStatus == ConnectionStatus.ERROR) {
            item {
                OfflineBanner(
                    message = uiState.errorMessage ?: if (uiState.connectionStatus == ConnectionStatus.OFFLINE) "Router is unreachable" else "Connection error",
                    onRetry = onRefresh
                )
            }
        }

        item {
            HardwareVitalsCard(status = uiState.status)
        }

        item {
            InternetTrafficCard(uiState = uiState)
        }

        item {
            com.archerguard.openwrt.ui.screens.dashboard.widgets.NetworkTopologyCard(
                status = uiState.status,
                connectionStatus = uiState.connectionStatus,
                latencyMs = uiState.latencyMs,
                routerIp = uiState.routerIp,
                onNavigateToDevices = { onNavigateToTab(1) },
                onNavigateToWifi = { onNavigateToTab(2) }
            )
        }

        item {
            com.archerguard.openwrt.ui.screens.dashboard.widgets.WirelessOverviewCard(
                wireless = uiState.status.wireless,
                onManageWifi = { onNavigateToTab(2) }
            )
        }

        item {
            com.archerguard.openwrt.ui.screens.dashboard.widgets.ConnectedDevicesSummaryCard(
                clients = uiState.status.clients,
                onViewAll = { onNavigateToTab(1) }
            )
        }

        item {
            QuickActionsCard(
                onReboot = onReboot,
                onDropCaches = onDropCaches,
                onToggleLeds = onToggleLeds
            )
        }

        item {
            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

@Composable
private fun HeaderSection(
    uiState: RouterUiState,
    onRefresh: () -> Unit,
    onOpenMenu: () -> Unit = {}
) {
    val infiniteTransition = rememberInfiniteTransition(label = "refresh_rotate")
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = LinearEasing)
        ),
        label = "rotation"
    )

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "ArcherGuard",
                color = GlossyColors.TextPrimary,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = (-0.5).sp
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(
                            when (uiState.connectionStatus) {
                                ConnectionStatus.CONNECTED -> GlossyColors.EmeraldMint
                                ConnectionStatus.CONNECTING -> GlossyColors.AmberWarm
                                else -> GlossyColors.RoseCoral
                            }
                        )
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "${uiState.routerIp}:${uiState.routerPort}",
                    color = GlossyColors.TextSecondary,
                    fontSize = 13.sp
                )
                if (uiState.latencyMs >= 0) {
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "•  ${uiState.latencyMs}ms",
                        color = GlossyColors.LightBlue,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }

        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(
                onClick = onRefresh,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(GlossyColors.GlassSurface)
            ) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = "Refresh",
                    tint = GlossyColors.TextPrimary,
                    modifier = if (uiState.isRefreshing) Modifier.rotate(rotation) else Modifier
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            IconButton(
                onClick = onOpenMenu,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(GlossyColors.GlassSurface)
            ) {
                Icon(
                    imageVector = Icons.Default.Menu,
                    contentDescription = "Menu",
                    tint = GlossyColors.TextPrimary
                )
            }
        }
    }
}

@Composable
private fun OfflineBanner(message: String, onRetry: () -> Unit) {
    GlossyCard(
        backgroundColor = GlossyColors.RoseCoral.copy(alpha = 0.12f),
        borderColor = GlossyColors.RoseCoral.copy(alpha = 0.35f)
    ) {
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
                        .size(10.dp)
                        .clip(CircleShape)
                        .background(GlossyColors.RoseCoral)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(
                        text = "Router Communication Issue",
                        color = GlossyColors.RoseCoral,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = message,
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
            IconButton(
                onClick = onRetry,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(GlossyColors.RoseCoral.copy(alpha = 0.2f))
                    .size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = "Retry",
                    tint = GlossyColors.RoseCoral,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

@Composable
private fun HardwareVitalsCard(status: RouterStatus) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "HARDWARE VITALS",
                    color = GlossyColors.TextSecondary,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(GlossyColors.GlassSurface)
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = status.cpu.model.split("@").first().trim(),
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Three circular gauges with equal flexible weights
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    CircularGauge(
                        value = status.cpu.usagePercent,
                        label = "CPU Load",
                        subtitle = if (status.cpu.temperatureC > 0) "${status.cpu.temperatureC.toInt()}°C" else "Normal",
                        size = 80.dp
                    )
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    CircularGauge(
                        value = status.memory.usagePercent,
                        label = "RAM Used",
                        subtitle = status.memory.formattedUsedMb,
                        size = 80.dp
                    )
                }
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    CircularGauge(
                        value = status.storage.usagePercent,
                        label = "Flash",
                        subtitle = status.storage.formattedUsedMb,
                        size = 80.dp
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))
            HorizontalDivider(color = GlossyColors.GlassBorderDark, thickness = 0.5.dp)
            Spacer(modifier = Modifier.height(12.dp))

            // Vital Details Grid (2x2) with graphical interactive mini cards
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(IntrinsicSize.Max),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                UptimeMiniCard(
                    uptimeSeconds = status.cpu.uptimeSeconds,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                )
                LoadAverageMiniCard(
                    loadAvgString = status.cpu.loadAvg,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                )
            }
            Spacer(modifier = Modifier.height(10.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(IntrinsicSize.Max),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                CpuCoresMiniCard(
                    cores = status.cpu.cores,
                    threads = status.cpu.threads,
                    frequencyMhz = status.cpu.frequencyMhz,
                    usagePercent = status.cpu.usagePercent,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                )
                FreeMemoryMiniCard(
                    totalKb = status.memory.totalKb,
                    freeKb = status.memory.freeKb,
                    usedKb = status.memory.usedKb,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                )
            }
        }
    }
}

@Composable
private fun InternetTrafficCard(uiState: RouterUiState) {
    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Public,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "LIVE WAN TRAFFIC",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(10.dp))
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                            .border(0.5.dp, GlossyColors.EmeraldMint.copy(alpha = 0.4f), RoundedCornerShape(10.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(5.dp)
                                    .clip(CircleShape)
                                    .background(GlossyColors.EmeraldMint)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "LIVE",
                                color = GlossyColors.EmeraldMint,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(GlossyColors.GlassSurface)
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = uiState.status.traffic.wanIp.ifBlank { "0.0.0.0" },
                        color = GlossyColors.EmeraldMint,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Two-column side-by-side Live Speed meters
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                SpeedMeterTile(
                    label = "Live Download",
                    speed = uiState.liveDownloadSpeed,
                    icon = Icons.Default.ArrowDownward,
                    color = GlossyColors.SpeedCyan,
                    history = uiState.downloadSpeedHistory,
                    modifier = Modifier.weight(1f)
                )
                SpeedMeterTile(
                    label = "Live Upload",
                    speed = uiState.liveUploadSpeed,
                    icon = Icons.Default.ArrowUpward,
                    color = GlossyColors.EmeraldMint,
                    history = uiState.uploadSpeedHistory,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Data transferred strip (Total Rx & Total Tx)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .background(GlossyColors.GlassSurface)
                    .padding(horizontal = 12.dp, vertical = 7.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = "Total Rx: ",
                            color = GlossyColors.TextMuted,
                            fontSize = 11.sp
                        )
                        Text(
                            text = uiState.status.traffic.formattedRx,
                            color = GlossyColors.TextPrimary,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    Box(
                        modifier = Modifier
                            .width(1.dp)
                            .height(12.dp)
                            .background(GlossyColors.GlassBorderDark)
                    )
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = "Total Tx: ",
                            color = GlossyColors.TextMuted,
                            fontSize = 11.sp
                        )
                        Text(
                            text = uiState.status.traffic.formattedTx,
                            color = GlossyColors.TextPrimary,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }

            // Gateway & Protocol info row
            if (uiState.status.network.gateway.isNotBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Gateway: ${uiState.status.network.gateway}",
                        color = GlossyColors.TextMuted,
                        fontSize = 11.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Text(
                        text = "DNS: ${uiState.status.network.dnsProviderName}",
                        color = GlossyColors.TextMuted,
                        fontSize = 11.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

@Composable
private fun SpeedMeterTile(
    label: String,
    speed: String,
    icon: ImageVector,
    color: Color,
    history: List<Double>,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(GlossyColors.GlassSurface)
            .border(0.5.dp, GlossyColors.GlassBorderDark, RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Column {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(20.dp)
                        .clip(CircleShape)
                        .background(color.copy(alpha = 0.2f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = color,
                        modifier = Modifier.size(12.dp)
                    )
                }
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = label,
                    color = GlossyColors.TextMuted,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = speed,
                color = GlossyColors.TextPrimary,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                style = GlossyColors.TabularMetric,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(6.dp))
            TrafficSparkline(
                data = history,
                color = color,
                height = 28.dp
            )
        }
    }
}

@Composable
private fun QuickActionsCard(
    onReboot: () -> Unit,
    onDropCaches: () -> Unit,
    onToggleLeds: () -> Unit
) {
    GlossyCard {
        Column {
            Text(
                text = "SYSTEM CONTROLS",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                GlossyButton(
                    text = "Flush RAM",
                    onClick = onDropCaches,
                    icon = Icons.Default.CleaningServices,
                    isPrimary = false,
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "LED Stealth",
                    onClick = onToggleLeds,
                    icon = Icons.Default.Nightlight,
                    isPrimary = false,
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "Reboot",
                    onClick = onReboot,
                    icon = Icons.Default.RestartAlt,
                    isPrimary = true,
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}
