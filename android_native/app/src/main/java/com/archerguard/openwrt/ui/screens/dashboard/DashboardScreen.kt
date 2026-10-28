package com.archerguard.openwrt.ui.screens.dashboard

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
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Nightlight
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
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
import com.archerguard.openwrt.ui.components.TrafficSparkline
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

        if (uiState.connectionStatus == ConnectionStatus.OFFLINE) {
            item {
                OfflineBanner(uiState.errorMessage ?: "Router is unreachable")
            }
        }

        item {
            HardwareVitalsCard(status = uiState.status)
        }

        item {
            InternetTrafficCard(
                uiState = uiState
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
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun HeaderSection(
    uiState: RouterUiState,
    onRefresh: () -> Unit,
    onOpenMenu: () -> Unit = {}
) {
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
                            if (uiState.connectionStatus == ConnectionStatus.CONNECTED)
                                GlossyColors.EmeraldMint else GlossyColors.RoseCoral
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
                    tint = GlossyColors.TextPrimary
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
                    imageVector = androidx.compose.material.icons.Icons.Default.Menu,
                    contentDescription = "Menu",
                    tint = GlossyColors.TextPrimary
                )
            }
        }
    }
}

@Composable
private fun OfflineBanner(message: String) {
    GlossyCard(
        backgroundColor = GlossyColors.RoseCoral.copy(alpha = 0.15f),
        borderColor = GlossyColors.RoseCoral.copy(alpha = 0.4f)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(10.dp)
                    .clip(CircleShape)
                    .background(GlossyColors.RoseCoral)
            )
            Spacer(modifier = Modifier.width(12.dp))
            Column {
                Text(
                    text = "Router Disconnected",
                    color = GlossyColors.RoseCoral,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = message,
                    color = GlossyColors.TextSecondary,
                    fontSize = 12.sp
                )
            }
        }
    }
}

@Composable
private fun HardwareVitalsCard(status: RouterStatus) {
    GlossyCard {
        Column {
            Text(
                text = "HARDWARE VITALS",
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(14.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                CircularGauge(
                    value = status.cpu.usagePercent,
                    label = "CPU Load",
                    subtitle = status.cpu.loadAvg
                )
                CircularGauge(
                    value = status.memory.usagePercent,
                    label = "RAM Used",
                    subtitle = status.memory.formattedUsedMb
                )
                CircularGauge(
                    value = status.storage.usagePercent,
                    label = "Flash",
                    subtitle = status.storage.formattedUsedMb
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
                Text(
                    text = "LIVE WAN TRAFFIC",
                    color = GlossyColors.TextSecondary,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Text(
                    text = uiState.status.traffic.wanIp,
                    color = GlossyColors.LightBlue,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Download Row & Sparkline
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.ArrowDownward,
                    contentDescription = null,
                    tint = GlossyColors.EmeraldMint,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "Download: ${uiState.liveDownloadSpeed}",
                    color = GlossyColors.TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            TrafficSparkline(
                data = uiState.downloadSpeedHistory,
                color = GlossyColors.EmeraldMint,
                height = 28.dp
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Upload Row & Sparkline
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.ArrowUpward,
                    contentDescription = null,
                    tint = GlossyColors.SkyBlue,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "Upload: ${uiState.liveUploadSpeed}",
                    color = GlossyColors.TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            TrafficSparkline(
                data = uiState.uploadSpeedHistory,
                color = GlossyColors.SkyBlue,
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
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "LED Stealth",
                    onClick = onToggleLeds,
                    icon = Icons.Default.Nightlight,
                    isPrimary = false,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "Reboot",
                    onClick = onReboot,
                    icon = Icons.Default.RestartAlt,
                    isPrimary = true,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}
