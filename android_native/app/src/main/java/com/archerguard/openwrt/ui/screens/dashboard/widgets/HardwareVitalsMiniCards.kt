package com.archerguard.openwrt.ui.screens.dashboard.widgets

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.core.util.Formatters
import com.archerguard.openwrt.ui.theme.GlossyColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import java.util.Locale

/**
 * 1. System Uptime Mini Card
 * Features:
 * - Real-time 1-second live ticker
 * - Precise time display with seconds (d, h, m, s)
 * - Animated pulsing green beacon indicating live router telemetry
 * - 5-segmented stability bar with dynamic glow shimmer
 */
@Composable
fun UptimeMiniCard(
    uptimeSeconds: Long,
    modifier: Modifier = Modifier
) {
    var currentSeconds by remember(uptimeSeconds) { mutableLongStateOf(uptimeSeconds) }
    LaunchedEffect(uptimeSeconds) {
        currentSeconds = uptimeSeconds
        while (isActive) {
            delay(1000L)
            currentSeconds++
        }
    }

    val uptimeText = remember(currentSeconds) {
        Formatters.formatUptimeWithSeconds(currentSeconds)
    }

    // Stability level calculation based on system uptime
    val activeSegments = remember(currentSeconds) {
        when {
            currentSeconds >= 86400 -> 5
            currentSeconds >= 21600 -> 4
            currentSeconds >= 3600 -> 3
            currentSeconds >= 600 -> 2
            else -> 1
        }
    }

    // Infinite breathing/pulsing animation for the beacon and stability shimmer
    val infiniteTransition = rememberInfiniteTransition(label = "uptimeBeacon")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.35f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseAlpha"
    )
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.85f,
        targetValue = 1.35f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseScale"
    )

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(Color.White.copy(alpha = 0.03f))
            .border(0.5.dp, GlossyColors.GlassBorderLight, RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header Row: Icon + "UPTIME" + Pulsing Green Beacon
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Timer,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(13.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "UPTIME",
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }

                // Pulsing Beacon
                Box(
                    modifier = Modifier.size(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        modifier = Modifier
                            .size(12.dp)
                            .scale(pulseScale)
                            .clip(CircleShape)
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.3f * pulseAlpha))
                    )
                    Box(
                        modifier = Modifier
                            .size(6.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.EmeraldMint)
                    )
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Uptime Value with seconds
            Text(
                text = uptimeText,
                color = GlossyColors.TextPrimary,
                fontSize = 12.5.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = (-0.2).sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(8.dp))

            // 5-Segmented Stability Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(3.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                for (i in 0 until 5) {
                    val isLit = i < activeSegments
                    val color = if (isLit) {
                        GlossyColors.EmeraldMint.copy(alpha = 0.7f + (0.3f * pulseAlpha))
                    } else {
                        GlossyColors.EmeraldMint.copy(alpha = 0.15f)
                    }
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(4.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(color)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Footer Subtitle
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "100% Stability",
                    color = GlossyColors.EmeraldMint,
                    fontSize = 8.5.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = "ONLINE",
                    color = GlossyColors.EmeraldMint.copy(alpha = pulseAlpha),
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
            }
        }
    }
}

/**
 * 2. Load Average Mini Card
 * Features:
 * - 3 Distinct horizontal capacity bars for 1m, 5m, and 15m load
 * - Dynamic color transitions: Emerald (<1.0), Amber (<2.0), Rose (>=2.0)
 * - Clear numeric readout per interval
 */
@Composable
fun LoadAverageMiniCard(
    loadAvgString: String,
    modifier: Modifier = Modifier
) {
    val loads = remember(loadAvgString) {
        val parts = loadAvgString.replace(",", " ")
            .split("\\s+".toRegex())
            .mapNotNull { it.toDoubleOrNull() }
        listOf(
            parts.getOrElse(0) { 0.0 },
            parts.getOrElse(1) { 0.0 },
            parts.getOrElse(2) { 0.0 }
        )
    }

    fun colorForLoad(load: Double): Color = when {
        load < 1.0 -> GlossyColors.EmeraldMint
        load < 2.0 -> GlossyColors.AmberWarm
        else -> GlossyColors.RoseCoral
    }

    val primaryColor = colorForLoad(loads[0])

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(Color.White.copy(alpha = 0.03f))
            .border(0.5.dp, GlossyColors.GlassBorderLight, RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header Row: Icon + "LOAD AVG" + "MAX 2.0"
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Speed,
                        contentDescription = null,
                        tint = primaryColor,
                        modifier = Modifier.size(13.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "LOAD AVG",
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }

                Text(
                    text = "MAX 2.0",
                    color = GlossyColors.TextMuted,
                    fontSize = 8.5.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // 3 Horizontal Load Bars: 1m, 5m, 15m
            LoadBarRow(label = "1m", load = loads[0], color = colorForLoad(loads[0]))
            Spacer(modifier = Modifier.height(3.dp))
            LoadBarRow(label = "5m", load = loads[1], color = colorForLoad(loads[1]))
            Spacer(modifier = Modifier.height(3.dp))
            LoadBarRow(label = "15m", load = loads[2], color = colorForLoad(loads[2]))
        }
    }
}

@Composable
private fun LoadBarRow(
    label: String,
    load: Double,
    color: Color
) {
    val animatedRatio by animateFloatAsState(
        targetValue = (load / 2.0).coerceIn(0.04, 1.0).toFloat(),
        animationSpec = tween(500),
        label = "loadRatio_$label"
    )

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 9.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.width(22.dp)
        )
        Box(
            modifier = Modifier
                .weight(1f)
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(Color.White.copy(alpha = 0.08f))
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(animatedRatio)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(2.dp))
                    .background(color)
            )
        }
        Spacer(modifier = Modifier.width(6.dp))
        Text(
            text = String.format(Locale.US, "%.2f", load),
            color = color,
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.width(26.dp),
            textAlign = TextAlign.End
        )
    }
}

/**
 * 3. CPU Cores Mini Card
 * Features:
 * - Horizontal utilization bars for Core 1 and Core 2
 * - Thread assignment tags (T1·T2, T3·T4)
 * - Frequency badge
 * - Dynamic color transitions based on core load
 */
@Composable
fun CpuCoresMiniCard(
    cores: Int,
    threads: Int,
    frequencyMhz: Int,
    usagePercent: Double,
    modifier: Modifier = Modifier
) {
    // Distributed load for MediaTek dual core router
    val c1Usage = (usagePercent * 1.15).coerceIn(0.0, 100.0)
    val c2Usage = (usagePercent * 0.85).coerceIn(0.0, 100.0)

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(Color.White.copy(alpha = 0.03f))
            .border(0.5.dp, GlossyColors.GlassBorderLight, RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header Row: Icon + "CPU CORES" + Frequency Badge
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Memory,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(13.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "CPU CORES",
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(GlossyColors.LightBlue.copy(alpha = 0.15f))
                        .padding(horizontal = 4.dp, vertical = 1.dp)
                ) {
                    Text(
                        text = "${frequencyMhz}MHz",
                        color = GlossyColors.SkyBlue,
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Core 1 Bar Row
            CoreBarRow(coreName = "Core 1", threadTag = "T1·T2", usage = c1Usage)
            Spacer(modifier = Modifier.height(4.dp))
            // Core 2 Bar Row
            CoreBarRow(coreName = "Core 2", threadTag = "T3·T4", usage = c2Usage)

            Spacer(modifier = Modifier.height(3.dp))

            // Footer
            Text(
                text = "$cores Cores / $threads Threads",
                color = GlossyColors.TextMuted,
                fontSize = 8.5.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

@Composable
private fun CoreBarRow(
    coreName: String,
    threadTag: String,
    usage: Double
) {
    val barColor = when {
        usage > 80.0 -> GlossyColors.RoseCoral
        usage > 50.0 -> GlossyColors.AmberWarm
        else -> GlossyColors.LightBlue
    }

    val animatedUsage by animateFloatAsState(
        targetValue = (usage / 100.0).coerceIn(0.04, 1.0).toFloat(),
        animationSpec = tween(500),
        label = "coreUsage_$coreName"
    )

    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = coreName,
                    color = GlossyColors.TextPrimary,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.width(3.dp))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(3.dp))
                        .background(GlossyColors.LightBlue.copy(alpha = 0.12f))
                        .padding(horizontal = 3.dp, vertical = 0.5.dp)
                ) {
                    Text(
                        text = threadTag,
                        color = GlossyColors.SkyBlue,
                        fontSize = 7.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Text(
                text = "${usage.toInt()}%",
                color = barColor,
                fontSize = 8.5.sp,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(2.dp))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(Color.White.copy(alpha = 0.08f))
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(animatedUsage)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(2.dp))
                    .background(barColor)
            )
        }
    }
}

/**
 * 4. Free Memory Mini Card
 * Features:
 * - Graphical split dual-tone capacity bar showing Used vs Free RAM headroom
 * - Free percentage chip
 * - Accurate numerical statistics (Free MB of Total MB)
 * - Legend with indicator dots
 */
@Composable
fun FreeMemoryMiniCard(
    totalKb: Long,
    freeKb: Long,
    usedKb: Long,
    modifier: Modifier = Modifier
) {
    val totalMb = if (totalKb > 0) totalKb / 1024 else 128L
    val freeMb = freeKb / 1024
    val usedMb = (usedKb / 1024).coerceAtLeast(0L)
    val freeRatio = if (totalMb > 0) (freeMb.toFloat() / totalMb.toFloat()).coerceIn(0f, 1f) else 0.5f
    val freePercent = (freeRatio * 100).toInt()
    val usedRatio = (1f - freeRatio).coerceIn(0f, 1f)

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(Color.White.copy(alpha = 0.03f))
            .border(0.5.dp, GlossyColors.GlassBorderLight, RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header Row: Icon + "FREE RAM" + Free% Chip
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Storage,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(13.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "FREE RAM",
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                        .padding(horizontal = 4.dp, vertical = 1.dp)
                ) {
                    Text(
                        text = "$freePercent% FREE",
                        color = GlossyColors.EmeraldMint,
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Primary value: "75 MB" + "of 128 MB"
            Row(
                verticalAlignment = Alignment.Bottom,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = "$freeMb MB",
                    color = GlossyColors.TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-0.2).sp
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "of $totalMb MB",
                    color = GlossyColors.TextMuted,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Normal,
                    modifier = Modifier.padding(bottom = 1.dp)
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Dual-tone Capacity Bar (Used Blue | Free Mint)
            val animatedUsed by animateFloatAsState(
                targetValue = usedRatio.coerceIn(0.04f, 0.96f),
                animationSpec = tween(500),
                label = "memUsedRatio"
            )
            val animatedFree = 1f - animatedUsed

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(Color.White.copy(alpha = 0.08f))
            ) {
                Box(
                    modifier = Modifier
                        .weight(animatedUsed)
                        .fillMaxHeight()
                        .background(GlossyColors.LightBlue)
                )
                Spacer(modifier = Modifier.width(1.dp))
                Box(
                    modifier = Modifier
                        .weight(animatedFree)
                        .fillMaxHeight()
                        .background(GlossyColors.EmeraldMint)
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Legend Footer: Used XM • Free YM
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(5.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.LightBlue)
                    )
                    Spacer(modifier = Modifier.width(3.dp))
                    Text(
                        text = "Used ${usedMb}M",
                        color = GlossyColors.TextMuted,
                        fontSize = 8.5.sp,
                        fontWeight = FontWeight.Medium
                    )
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(5.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.EmeraldMint)
                    )
                    Spacer(modifier = Modifier.width(3.dp))
                    Text(
                        text = "Free ${freeMb}M",
                        color = GlossyColors.EmeraldMint,
                        fontSize = 8.5.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}
