package com.archerguard.openwrt.ui.screens.tools

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.filled.Archive
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.NetworkPing
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Terminal
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.core.util.AppFeedback
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors
import kotlinx.coroutines.launch

@Composable
fun ToolsScreen(
    status: RouterStatus,
    latencyMs: Long,
    onFlushRam: () -> Unit,
    onReboot: () -> Unit,
    onFetchLogs: suspend (logType: String) -> String = { "Kernel buffer log output." },
    onCreateBackup: suspend () -> String = { "Backup archive generated successfully." },
    onNavigateToNetwork: (() -> Unit)? = null,
    onOpenSettings: (() -> Unit)? = null,
    onLogout: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var selectedLogType by remember { mutableStateOf("dmesg") }
    var logsOutput by remember { mutableStateOf<String?>(null) }
    var logSearchQuery by remember { mutableStateOf("") }
    var isFetchingLogs by remember { mutableStateOf(false) }
    var isBackingUp by remember { mutableStateOf(false) }

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
                text = "Diagnostics & Tools",
                color = GlossyColors.TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = (-0.4).sp
            )
            Text(
                text = "System diagnostics, telemetry & firmware utilities",
                color = GlossyColors.TextSecondary,
                fontSize = 12.sp
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            PingRadarDiagnosticCard(latencyMs = latencyMs)
        }

        item {
            GlossyCard {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = null,
                            tint = GlossyColors.PrimaryBlue,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Hardware Specifications",
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    SpecRow(label = "SoC Model", value = status.cpu.model)
                    SpecRow(label = "Architecture", value = status.cpu.architecture)
                    SpecRow(label = "Clock Speed", value = "${status.cpu.frequencyMhz} MHz (${status.cpu.cores}C / ${status.cpu.threads}T)")
                    SpecRow(label = "Flash Storage", value = status.storage.device)
                    SpecRow(label = "System Uptime", value = status.cpu.formattedUptime)
                }
            }
        }

        item {
            // Enhanced System Logs Console Card with Search & Syntax Highlighting
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
                                imageVector = Icons.Default.Terminal,
                                contentDescription = null,
                                tint = GlossyColors.EmeraldMint,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "System Logs Console",
                                color = GlossyColors.TextPrimary,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }

                        Spacer(modifier = Modifier.width(6.dp))

                        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            GlossyButton(
                                text = "dmesg",
                                onClick = { selectedLogType = "dmesg" },
                                isPrimary = selectedLogType == "dmesg",
                                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                                fontSize = 11.sp
                            )
                            GlossyButton(
                                text = "logread",
                                onClick = { selectedLogType = "logread" },
                                isPrimary = selectedLogType == "logread",
                                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                                fontSize = 11.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        GlossyButton(
                            text = "Fetch $selectedLogType",
                            onClick = {
                                scope.launch {
                                    isFetchingLogs = true
                                    logsOutput = onFetchLogs(selectedLogType)
                                    isFetchingLogs = false
                                }
                            },
                            icon = Icons.Default.Refresh,
                            isLoading = isFetchingLogs,
                            isPrimary = false,
                            modifier = Modifier.weight(1f)
                        )
                        if (logsOutput != null) {
                            GlossyButton(
                                text = "Copy",
                                onClick = {
                                    AppFeedback.copyToClipboard(context, "System Logs", logsOutput ?: "", "Logs copied to clipboard!")
                                },
                                icon = Icons.Default.ContentCopy,
                                isPrimary = false
                            )
                        }
                    }

                    if (logsOutput != null) {
                        Spacer(modifier = Modifier.height(10.dp))

                        // In-log filter bar
                        GlossyInput(
                            value = logSearchQuery,
                            onValueChange = { logSearchQuery = it },
                            label = "",
                            placeholder = "Filter logs (e.g. error, hostapd, drop)..."
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        val displayLines = logsOutput!!.lines().filter { line ->
                            logSearchQuery.isBlank() || line.contains(logSearchQuery, ignoreCase = true)
                        }

                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(GlossyColors.CanvasBackground)
                                .border(0.5.dp, GlossyColors.GlassBorderDark, RoundedCornerShape(8.dp))
                                .padding(10.dp)
                                .verticalScroll(rememberScrollState())
                                .horizontalScroll(rememberScrollState())
                        ) {
                            Column {
                                if (displayLines.isEmpty()) {
                                    Text(
                                        text = "No log lines matching \"$logSearchQuery\"",
                                        color = GlossyColors.TextMuted,
                                        fontSize = 11.sp,
                                        fontFamily = FontFamily.Monospace
                                    )
                                } else {
                                    displayLines.forEach { line ->
                                        val lineColor = when {
                                            line.contains("error", ignoreCase = true) || line.contains("failed", ignoreCase = true) -> GlossyColors.RoseCoral
                                            line.contains("warn", ignoreCase = true) -> GlossyColors.AmberWarm
                                            else -> GlossyColors.EmeraldSoft
                                        }
                                        Text(
                                            text = line,
                                            color = lineColor,
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 10.5.sp,
                                            lineHeight = 15.sp
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (onNavigateToNetwork != null || onOpenSettings != null) {
            item {
                GlossyCard {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text(
                            text = "NETWORK & SYSTEM SHORTCUTS",
                            color = GlossyColors.TextSecondary,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.sp
                        )

                        if (onNavigateToNetwork != null) {
                            GlossyButton(
                                text = "Network QoS & Hardware Acceleration",
                                onClick = onNavigateToNetwork,
                                icon = Icons.Default.Speed,
                                isPrimary = false,
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        if (onOpenSettings != null) {
                            GlossyButton(
                                text = "App Preferences & Gateway Settings",
                                onClick = onOpenSettings,
                                icon = Icons.Default.Settings,
                                isPrimary = false,
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }
                }
            }
        }

        item {
            GlossyCard {
                Column {
                    Text(
                        text = "MAINTENANCE & ACTIONS",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    GlossyButton(
                        text = "Create Router Configuration Backup",
                        onClick = {
                            scope.launch {
                                isBackingUp = true
                                val result = onCreateBackup()
                                isBackingUp = false
                                AppFeedback.showToast(context, result)
                            }
                        },
                        icon = Icons.Default.Archive,
                        isLoading = isBackingUp,
                        isPrimary = false,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    GlossyButton(
                        text = "Flush PageCache & Drop RAM",
                        onClick = onFlushRam,
                        icon = Icons.Default.CleaningServices,
                        isPrimary = false,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    GlossyButton(
                        text = "Soft Reboot Router",
                        onClick = onReboot,
                        icon = Icons.Default.RestartAlt,
                        isPrimary = true,
                        modifier = Modifier.fillMaxWidth()
                    )

                    if (onLogout != null) {
                        Spacer(modifier = Modifier.height(8.dp))
                        GlossyButton(
                            text = "Logout From Router",
                            onClick = onLogout,
                            icon = Icons.AutoMirrored.Filled.Logout,
                            isPrimary = false,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun SpecRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 13.sp,
            modifier = Modifier.weight(1f)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = value,
            color = GlossyColors.TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.End,
            style = GlossyColors.TabularCaption,
            modifier = Modifier.weight(1.4f, fill = false)
        )
    }
}

@Composable
private fun PingRadarDiagnosticCard(latencyMs: Long) {
    val infiniteTransition = rememberInfiniteTransition(label = "ping_radar")
    val radarPulse by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "radarPulse"
    )

    val tierLabel = when {
        latencyMs < 0 -> "Router Unreachable"
        latencyMs <= 15 -> "Ultra Low (Optimal for Gaming & VoIP)"
        latencyMs <= 45 -> "Low Latency (Fast Web & Streams)"
        latencyMs <= 90 -> "Moderate Latency (Fair Link)"
        else -> "High Latency (Congested Link)"
    }

    val tierColor = when {
        latencyMs < 0 -> GlossyColors.RoseCoral
        latencyMs <= 15 -> GlossyColors.EmeraldMint
        latencyMs <= 45 -> GlossyColors.LightBlue
        latencyMs <= 90 -> GlossyColors.AmberWarm
        else -> GlossyColors.RoseCoral
    }

    GlossyCard {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.NetworkPing,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "PING & LATENCY RADAR",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(tierColor.copy(alpha = 0.15f))
                        .padding(horizontal = 7.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = if (latencyMs >= 0) "LINK HEALTHY" else "OFFLINE",
                        color = tierColor,
                        fontSize = 9.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = if (latencyMs >= 0) "${latencyMs} ms" else "---",
                        color = GlossyColors.TextPrimary,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = (-0.5).sp,
                        style = GlossyColors.TabularDisplay
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = tierLabel,
                        color = tierColor,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                }

                // Animated Radar Wave Rings
                Box(
                    modifier = Modifier.size(64.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Canvas(modifier = Modifier.size(64.dp)) {
                        val center = Offset(size.width / 2, size.height / 2)
                        val maxRadius = size.minDimension / 2

                        // Base inner circle
                        drawCircle(
                            color = tierColor.copy(alpha = 0.25f),
                            radius = maxRadius * 0.35f,
                            center = center
                        )

                        // Center emitter dot
                        drawCircle(
                            color = tierColor,
                            radius = 4.dp.toPx(),
                            center = center
                        )

                        // Expanding animated radar wave
                        val waveRadius = maxRadius * (0.35f + radarPulse * 0.65f)
                        val waveAlpha = (1f - radarPulse) * 0.5f

                        drawCircle(
                            color = tierColor.copy(alpha = waveAlpha),
                            radius = waveRadius,
                            center = center,
                            style = Stroke(width = 2.dp.toPx())
                        )
                    }
                }
            }
        }
    }
}
