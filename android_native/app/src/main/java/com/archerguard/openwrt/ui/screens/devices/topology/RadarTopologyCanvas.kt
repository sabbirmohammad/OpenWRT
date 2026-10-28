package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.theme.GlossyColors

/**
 * Interactive Jetpack Compose Canvas rendering the cyberpunk radar network topology.
 *
 * Implements 6 visual layers:
 * - Layer 0: Obsidian canvas background with subtle edge vignette.
 * - Layer 1: Concentric orbital rings for network tiers (5GHz, 2.4GHz, Perimeter) with dashed strokes and crosshairs.
 * - Layer 2: Infinite rotating radar sweep with trailing gradient sector cone and crisp leading scanline.
 * - Layer 3: Central router core with expanding pulse beacon and live status indicator.
 * - Layer 4: Client connection lines linking router center to connected nodes with band-colored accents.
 * - Layer 5: Client nodes with band badges, selection halos, and text-measured hostname pills.
 * - Layer 6: Graceful empty state scanner when no devices are connected.
 *
 * @param geometry Calculated center and tier radii.
 * @param nodes List of client visual nodes with screen coordinates.
 * @param selectedClient Currently selected client for detailed inspection.
 * @param modifier Composable layout modifier.
 */
@Composable
fun RadarTopologyCanvas(
    geometry: RadarGeometry,
    nodes: List<TopologyNode>,
    selectedClient: ClientInfo?,
    modifier: Modifier = Modifier
) {
    val textMeasurer = rememberTextMeasurer()
    val dashEffect = remember { PathEffect.dashPathEffect(floatArrayOf(6f, 10f), 0f) }

    // Layer 2 & 3: Infinite transitions for radar sweep, router beacon pulse, and selection halo
    val infiniteTransition = rememberInfiniteTransition(label = "radarSweep")

    val sweepAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 4000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "sweepAngle"
    )

    val beaconWaveProgress by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "beaconWave"
    )

    val selectionPulse by infiniteTransition.animateFloat(
        initialValue = 0.4f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "selectionPulse"
    )

    Canvas(modifier = modifier) {
        if (size.width <= 0f || size.height <= 0f) return@Canvas

        val effectiveCenter = if (geometry.center != Offset.Zero) {
            geometry.center
        } else {
            Offset(size.width / 2f, size.height / 2f)
        }

        val effectiveMaxRadius = if (geometry.maxRadius > 0f) {
            geometry.maxRadius
        } else {
            minOf(size.width, size.height) * 0.44f
        }

        // -------------------------------------------------------------------------
        // Layer 0: Background Fill & Optical Depth
        // -------------------------------------------------------------------------
        drawRect(
            color = GlossyColors.CanvasBackground,
            topLeft = Offset.Zero,
            size = size
        )

        // Subtle radial vignette at canvas boundary
        val vignetteRadius = minOf(size.width, size.height) * 0.75f
        if (vignetteRadius > 0f) {
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.Transparent,
                        Color(0x33000000),
                        Color(0x8804060A)
                    ),
                    center = effectiveCenter,
                    radius = vignetteRadius
                ),
                radius = vignetteRadius,
                center = effectiveCenter
            )
        }

        // -------------------------------------------------------------------------
        // Layer 1: Concentric Orbital Rings & Cardinal Crosshairs
        // -------------------------------------------------------------------------
        if (effectiveMaxRadius > 0f) {
            // Cardinal Crosshairs (0, 90, 180, 270 degrees)
            val crosshairExtent = effectiveMaxRadius * 1.08f
            val crosshairColor = GlossyColors.GlassBorderLight.copy(alpha = 0.12f)
            val crosshairStroke = Stroke(width = 1.dp.toPx(), pathEffect = dashEffect)

            // Horizontal crosshair
            drawLine(
                color = crosshairColor,
                start = Offset(effectiveCenter.x - crosshairExtent, effectiveCenter.y),
                end = Offset(effectiveCenter.x + crosshairExtent, effectiveCenter.y),
                strokeWidth = 1.dp.toPx(),
                pathEffect = dashEffect
            )

            // Vertical crosshair
            drawLine(
                color = crosshairColor,
                start = Offset(effectiveCenter.x, effectiveCenter.y - crosshairExtent),
                end = Offset(effectiveCenter.x, effectiveCenter.y + crosshairExtent),
                strokeWidth = 1.dp.toPx(),
                pathEffect = dashEffect
            )

            // Orbital Ring 1: 5GHz High-Speed Band
            val radius5G = geometry.tierRadii[BandTier.BAND_5GHZ] ?: (effectiveMaxRadius * 0.33f)
            if (radius5G > 0f) {
                drawCircle(
                    color = GlossyColors.GlassBorderLight.copy(alpha = 0.22f),
                    radius = radius5G,
                    center = effectiveCenter,
                    style = crosshairStroke
                )
                // Subtle 5GHz tint ring
                drawCircle(
                    color = GlossyColors.Band5GHz.copy(alpha = 0.05f),
                    radius = radius5G,
                    center = effectiveCenter,
                    style = Stroke(width = 1.dp.toPx())
                )
            }

            // Orbital Ring 2: 2.4GHz Long-Range Band
            val radius2G = geometry.tierRadii[BandTier.BAND_2GHZ] ?: (effectiveMaxRadius * 0.62f)
            if (radius2G > 0f) {
                drawCircle(
                    color = GlossyColors.GlassBorderLight.copy(alpha = 0.22f),
                    radius = radius2G,
                    center = effectiveCenter,
                    style = crosshairStroke
                )
                drawCircle(
                    color = GlossyColors.Band2GHz.copy(alpha = 0.04f),
                    radius = radius2G,
                    center = effectiveCenter,
                    style = Stroke(width = 1.dp.toPx())
                )
            }

            // Orbital Ring 3: Outer Perimeter / Range Edge
            drawCircle(
                color = GlossyColors.GlassBorderLight.copy(alpha = 0.22f),
                radius = effectiveMaxRadius,
                center = effectiveCenter,
                style = crosshairStroke
            )
        }

        // -------------------------------------------------------------------------
        // Layer 2: Infinite Rotating Radar Sweep
        // -------------------------------------------------------------------------
        if (effectiveMaxRadius > 0f) {
            rotate(degrees = sweepAngle, pivot = effectiveCenter) {
                // Trailing Sector Cone (60 degrees trailing behind the leading scanline)
                // In Compose sweepGradient, angles span 0 to 360 clockwise.
                // 300 degrees to 360 degrees covers the 60 degree trailing sector.
                val sweepBrush = Brush.sweepGradient(
                    0.0f to Color.Transparent,
                    0.8333f to Color.Transparent,
                    1.0f to GlossyColors.SpeedCyan.copy(alpha = 0.22f),
                    center = effectiveCenter
                )

                drawArc(
                    brush = sweepBrush,
                    startAngle = 300f,
                    sweepAngle = 60f,
                    useCenter = true,
                    topLeft = Offset(effectiveCenter.x - effectiveMaxRadius, effectiveCenter.y - effectiveMaxRadius),
                    size = Size(effectiveMaxRadius * 2f, effectiveMaxRadius * 2f)
                )

                // Outer boundary arc highlight for the sweep cone
                drawArc(
                    color = GlossyColors.SpeedCyan.copy(alpha = 0.40f),
                    startAngle = 300f,
                    sweepAngle = 60f,
                    useCenter = false,
                    topLeft = Offset(effectiveCenter.x - effectiveMaxRadius, effectiveCenter.y - effectiveMaxRadius),
                    size = Size(effectiveMaxRadius * 2f, effectiveMaxRadius * 2f),
                    style = Stroke(width = 1.5.dp.toPx())
                )

                // Crisp Leading Scanline from center to perimeter
                val scanlineEnd = effectiveCenter + Offset(effectiveMaxRadius, 0f)

                // Soft glow behind scanline
                drawLine(
                    color = GlossyColors.SpeedCyan.copy(alpha = 0.30f),
                    start = effectiveCenter,
                    end = scanlineEnd,
                    strokeWidth = 4.dp.toPx(),
                    cap = StrokeCap.Round
                )

                // Sharp core scanline
                drawLine(
                    color = GlossyColors.SpeedCyan.copy(alpha = 0.85f),
                    start = effectiveCenter,
                    end = scanlineEnd,
                    strokeWidth = 2.dp.toPx(),
                    cap = StrokeCap.Round
                )

                // Leading edge specular tip
                drawCircle(
                    color = GlossyColors.SpeedCyan,
                    radius = 3.dp.toPx(),
                    center = scanlineEnd
                )
                drawCircle(
                    color = Color.White,
                    radius = 1.5.dp.toPx(),
                    center = scanlineEnd
                )
            }
        }

        // -------------------------------------------------------------------------
        // Layer 3: Central Router Node & Pulse Beacon
        // -------------------------------------------------------------------------
        val routerRadius = 22.dp.toPx()

        // Expanding Beacon Wave Animation (fades alpha as it expands)
        val maxBeaconExpand = 26.dp.toPx()
        val beaconRadius = routerRadius + beaconWaveProgress * maxBeaconExpand
        val beaconAlpha = ((1f - beaconWaveProgress).coerceIn(0f, 1f) * 0.45f)

        if (beaconAlpha > 0f) {
            drawCircle(
                color = GlossyColors.LightBlue.copy(alpha = beaconAlpha * 0.35f),
                radius = beaconRadius,
                center = effectiveCenter,
                style = Fill
            )
            drawCircle(
                color = GlossyColors.LightBlue.copy(alpha = beaconAlpha),
                radius = beaconRadius,
                center = effectiveCenter,
                style = Stroke(width = 1.5.dp.toPx())
            )
        }

        // Router Core Circle Base
        drawCircle(
            color = GlossyColors.CardElevated,
            radius = routerRadius,
            center = effectiveCenter,
            style = Fill
        )

        // Specular inner rim
        drawCircle(
            color = GlossyColors.GlassBorderLight.copy(alpha = 0.35f),
            radius = routerRadius - 3.dp.toPx(),
            center = effectiveCenter,
            style = Stroke(width = 1.dp.toPx())
        )

        // Outer Accent Border
        drawCircle(
            color = GlossyColors.LightBlue,
            radius = routerRadius,
            center = effectiveCenter,
            style = Stroke(width = 2.dp.toPx())
        )

        // Central Router Gateway Emblem
        val routerEmblemPath = Path().apply {
            val rw = 14.dp.toPx()
            val rh = 7.dp.toPx()
            val rx = effectiveCenter.x - rw / 2f
            val ry = effectiveCenter.y + 2.dp.toPx()
            moveTo(rx, ry)
            lineTo(rx + rw, ry)
            lineTo(rx + rw, ry + rh)
            lineTo(rx, ry + rh)
            close()
        }
        drawPath(
            path = routerEmblemPath,
            color = GlossyColors.LightBlue.copy(alpha = 0.85f),
            style = Stroke(width = 1.5.dp.toPx(), cap = StrokeCap.Round)
        )

        // Wi-Fi signal arcs above router body
        drawArc(
            color = GlossyColors.LightBlue.copy(alpha = 0.85f),
            startAngle = 210f,
            sweepAngle = 120f,
            useCenter = false,
            topLeft = Offset(effectiveCenter.x - 7.dp.toPx(), effectiveCenter.y - 8.dp.toPx()),
            size = Size(14.dp.toPx(), 14.dp.toPx()),
            style = Stroke(width = 1.5.dp.toPx(), cap = StrokeCap.Round)
        )
        drawArc(
            color = GlossyColors.SpeedCyan.copy(alpha = 0.95f),
            startAngle = 220f,
            sweepAngle = 100f,
            useCenter = false,
            topLeft = Offset(effectiveCenter.x - 4.dp.toPx(), effectiveCenter.y - 4.dp.toPx()),
            size = Size(8.dp.toPx(), 8.dp.toPx()),
            style = Stroke(width = 1.5.dp.toPx(), cap = StrokeCap.Round)
        )

        // Live Router Status Beacon Dot
        val statusDotCenter = Offset(
            effectiveCenter.x + routerRadius * 0.58f,
            effectiveCenter.y - routerRadius * 0.58f
        )
        drawCircle(
            color = GlossyColors.LanGigabit.copy(alpha = 0.35f),
            radius = 5.dp.toPx(),
            center = statusDotCenter
        )
        drawCircle(
            color = GlossyColors.LanGigabit,
            radius = 3.dp.toPx(),
            center = statusDotCenter
        )
        drawCircle(
            color = Color.White.copy(alpha = 0.8f),
            radius = 1.dp.toPx(),
            center = statusDotCenter - Offset(0.8.dp.toPx(), 0.8.dp.toPx())
        )

        // -------------------------------------------------------------------------
        // Layer 4: Connection Lines to Connected Nodes
        // -------------------------------------------------------------------------
        nodes.forEach { node ->
            val isSelected = selectedClient != null && node.client.mac.equals(selectedClient.mac, ignoreCase = true)
            val bandColor = when {
                node.client.blocked -> GlossyColors.RoseCoral
                node.tier == BandTier.BAND_5GHZ -> GlossyColors.Band5GHz
                node.tier == BandTier.BAND_2GHZ -> GlossyColors.Band2GHz
                node.tier == BandTier.WIRED_LAN -> GlossyColors.LanGigabit
                node.tier == BandTier.GUEST_ISOLATED -> GlossyColors.GuestViolet
                else -> GlossyColors.Band2GHz
            }

            val lineAlpha = if (!node.isHighlighted) {
                0.08f
            } else if (isSelected) {
                0.65f
            } else {
                0.22f
            }

            val lineWidth = if (isSelected) 2.dp.toPx() else 1.2.dp.toPx()

            drawLine(
                brush = Brush.linearGradient(
                    colors = listOf(
                        GlossyColors.LightBlue.copy(alpha = lineAlpha * 1.2f),
                        bandColor.copy(alpha = lineAlpha)
                    ),
                    start = effectiveCenter,
                    end = node.screenPosition
                ),
                start = effectiveCenter,
                end = node.screenPosition,
                strokeWidth = lineWidth,
                cap = StrokeCap.Round
            )
        }

        // -------------------------------------------------------------------------
        // Layer 5: Client Nodes, Band Badges, Selection Halos & Labels
        // -------------------------------------------------------------------------
        val nodeRadius = 18.dp.toPx()

        nodes.forEach { node ->
            val isSelected = selectedClient != null && node.client.mac.equals(selectedClient.mac, ignoreCase = true)
            val nodeAlpha = if (node.isHighlighted) 1.0f else 0.25f

            val bandColor = when {
                node.client.blocked -> GlossyColors.RoseCoral
                node.tier == BandTier.BAND_5GHZ -> GlossyColors.Band5GHz
                node.tier == BandTier.BAND_2GHZ -> GlossyColors.Band2GHz
                node.tier == BandTier.WIRED_LAN -> GlossyColors.LanGigabit
                node.tier == BandTier.GUEST_ISOLATED -> GlossyColors.GuestViolet
                else -> GlossyColors.Band2GHz
            }

            // Pulsating Selection Halo for active device
            if (isSelected) {
                val haloOuterRadius = nodeRadius + 6.dp.toPx() + (selectionPulse * 4.dp.toPx())
                drawCircle(
                    color = GlossyColors.SpeedCyan.copy(alpha = 0.20f * selectionPulse),
                    radius = haloOuterRadius,
                    center = node.screenPosition
                )
                drawCircle(
                    color = GlossyColors.LightBlue.copy(alpha = 0.55f * selectionPulse),
                    radius = nodeRadius + 3.dp.toPx(),
                    center = node.screenPosition,
                    style = Stroke(width = 2.dp.toPx())
                )
            }

            // Node Circle Container Fill
            drawCircle(
                color = GlossyColors.CardElevated.copy(alpha = nodeAlpha),
                radius = nodeRadius,
                center = node.screenPosition,
                style = Fill
            )

            // Specular inner rim
            drawCircle(
                color = GlossyColors.GlassBorderLight.copy(alpha = 0.30f * nodeAlpha),
                radius = nodeRadius - 3.dp.toPx(),
                center = node.screenPosition,
                style = Stroke(width = 1.dp.toPx())
            )

            // Band Border Stroke
            drawCircle(
                color = bandColor.copy(alpha = nodeAlpha),
                radius = nodeRadius,
                center = node.screenPosition,
                style = Stroke(width = 2.dp.toPx())
            )

            // Band Badge Text inside node circle
            val badgeText = when {
                node.client.blocked -> "BLK"
                node.tier == BandTier.BAND_5GHZ -> "5G"
                node.tier == BandTier.BAND_2GHZ -> "2.4"
                node.tier == BandTier.WIRED_LAN -> "LAN"
                node.tier == BandTier.GUEST_ISOLATED -> "GST"
                else -> "2.4"
            }
            val badgeLayout = textMeasurer.measure(
                text = badgeText,
                style = TextStyle(
                    color = bandColor.copy(alpha = nodeAlpha),
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Default
                )
            )
            drawText(
                textLayoutResult = badgeLayout,
                topLeft = Offset(
                    node.screenPosition.x - badgeLayout.size.width / 2f,
                    node.screenPosition.y - badgeLayout.size.height / 2f
                )
            )

            // Device Hostname / DisplayName Label Pill below node
            val rawName = node.client.displayName
            val truncatedName = if (rawName.length > 12) rawName.take(12) + "…" else rawName
            val labelLayout = textMeasurer.measure(
                text = truncatedName,
                style = TextStyle(
                    color = GlossyColors.TextPrimary.copy(alpha = nodeAlpha),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Medium,
                    fontFamily = FontFamily.Default
                )
            )

            val pillPaddingH = 6.dp.toPx()
            val pillPaddingV = 3.dp.toPx()
            val pillWidth = labelLayout.size.width + pillPaddingH * 2
            val pillHeight = labelLayout.size.height + pillPaddingV * 2
            val pillTop = node.screenPosition.y + nodeRadius + 4.dp.toPx()
            val pillLeft = node.screenPosition.x - pillWidth / 2f

            // Pill glass background
            drawRoundRect(
                color = GlossyColors.BackgroundSecondary.copy(alpha = 0.85f * nodeAlpha),
                topLeft = Offset(pillLeft, pillTop),
                size = Size(pillWidth, pillHeight),
                cornerRadius = CornerRadius(4.dp.toPx(), 4.dp.toPx()),
                style = Fill
            )
            // Pill specular border
            drawRoundRect(
                color = GlossyColors.GlassBorderLight.copy(alpha = 0.25f * nodeAlpha),
                topLeft = Offset(pillLeft, pillTop),
                size = Size(pillWidth, pillHeight),
                cornerRadius = CornerRadius(4.dp.toPx(), 4.dp.toPx()),
                style = Stroke(width = 1.dp.toPx())
            )
            // Render text
            drawText(
                textLayoutResult = labelLayout,
                topLeft = Offset(pillLeft + pillPaddingH, pillTop + pillPaddingV)
            )
        }

        // -------------------------------------------------------------------------
        // Layer 6: Graceful Empty State Scanner
        // -------------------------------------------------------------------------
        if (nodes.isEmpty()) {
            val titleLayout = textMeasurer.measure(
                text = "Scanning Network...",
                style = TextStyle(
                    color = GlossyColors.TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    fontFamily = FontFamily.Default
                )
            )
            val subtitleLayout = textMeasurer.measure(
                text = "0 Connected Clients",
                style = TextStyle(
                    color = GlossyColors.TextSecondary,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Normal,
                    fontFamily = FontFamily.Default
                )
            )

            val maxTextWidth = maxOf(titleLayout.size.width, subtitleLayout.size.width)
            val badgePaddingH = 16.dp.toPx()
            val badgePaddingV = 10.dp.toPx()
            val indicatorGap = 16.dp.toPx()
            val badgeWidth = maxTextWidth + badgePaddingH * 2 + indicatorGap
            val badgeHeight = titleLayout.size.height + subtitleLayout.size.height + badgePaddingV * 2 + 4.dp.toPx()
            val badgeTop = effectiveCenter.y + routerRadius + 24.dp.toPx()
            val badgeLeft = effectiveCenter.x - badgeWidth / 2f

            // Glass status card background
            drawRoundRect(
                color = GlossyColors.BackgroundElevated.copy(alpha = 0.90f),
                topLeft = Offset(badgeLeft, badgeTop),
                size = Size(badgeWidth, badgeHeight),
                cornerRadius = CornerRadius(10.dp.toPx(), 10.dp.toPx()),
                style = Fill
            )
            // Specular border
            drawRoundRect(
                color = GlossyColors.GlassBorderLight.copy(alpha = 0.35f),
                topLeft = Offset(badgeLeft, badgeTop),
                size = Size(badgeWidth, badgeHeight),
                cornerRadius = CornerRadius(10.dp.toPx(), 10.dp.toPx()),
                style = Stroke(width = 1.dp.toPx())
            )

            // Pulsing scanner beacon dot
            val dotCenter = Offset(
                badgeLeft + badgePaddingH + 4.dp.toPx(),
                badgeTop + badgePaddingV + titleLayout.size.height / 2f
            )
            drawCircle(
                color = GlossyColors.SpeedCyan.copy(alpha = 0.35f * selectionPulse),
                radius = 6.dp.toPx(),
                center = dotCenter
            )
            drawCircle(
                color = GlossyColors.SpeedCyan,
                radius = 3.dp.toPx(),
                center = dotCenter
            )

            // Title text
            drawText(
                textLayoutResult = titleLayout,
                topLeft = Offset(
                    badgeLeft + badgePaddingH + indicatorGap,
                    badgeTop + badgePaddingV
                )
            )
            // Subtitle text
            drawText(
                textLayoutResult = subtitleLayout,
                topLeft = Offset(
                    badgeLeft + badgePaddingH + indicatorGap,
                    badgeTop + badgePaddingV + titleLayout.size.height + 4.dp.toPx()
                )
            )
        }
    }
}
