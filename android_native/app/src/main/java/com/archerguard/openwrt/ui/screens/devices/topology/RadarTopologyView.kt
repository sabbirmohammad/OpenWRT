package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animate
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.FilterCenterFocus
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.theme.GlossyColors
import java.util.Locale
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

/**
 * Interactive Radar / Network Topology View for ArcherGuard.
 *
 * Houses the [RadarTopologyCanvas] within dynamic constraints, manages multi-touch
 * focal-point pinch-to-zoom (0.5x to 3.0x) and bounded 2D pan gestures, processes tap
 * hit-testing to select client devices, and provides floating cyberpunk glass controls
 * (re-center/reset button, live zoom badge, online device count pill).
 *
 * @param allClients Complete list of router clients from ViewModel telemetry.
 * @param filteredClients Sublist of clients matching current search query and filter chips.
 * @param onSelectClient Callback invoked when a client node is tapped on the radar.
 * @param selectedClient Currently selected client for detailed inspection and glowing halo.
 * @param modifier Composable layout modifier.
 */
@Composable
fun RadarTopologyView(
    allClients: List<ClientInfo>,
    filteredClients: List<ClientInfo>,
    onSelectClient: (ClientInfo) -> Unit,
    selectedClient: ClientInfo? = null,
    modifier: Modifier = Modifier
) {
    val engine = remember { RadarTopologyEngine() }
    val coroutineScope = rememberCoroutineScope()

    var zoom by remember { mutableFloatStateOf(1.0f) }
    var pan by remember { mutableStateOf(Offset.Zero) }
    var resetJob by remember { mutableStateOf<Job?>(null) }

    BoxWithConstraints(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.CanvasBackground)
    ) {
        val canvasWidthPx = if (constraints.hasBoundedWidth) constraints.maxWidth.toFloat() else 0f
        val canvasHeightPx = if (constraints.hasBoundedHeight) constraints.maxHeight.toFloat() else 0f
        val size = remember(canvasWidthPx, canvasHeightPx) { Size(canvasWidthPx, canvasHeightPx) }

        val geometry = remember(size, engine) { engine.calculateGeometry(size) }

        // Compute visual nodes and highlight state based on filteredClients
        val filteredMacs = remember(filteredClients) {
            filteredClients.map { it.mac.lowercase() }.toSet()
        }

        val nodes = remember(allClients, filteredMacs, geometry, zoom, pan) {
            val rawNodes = engine.computeNodes(allClients, geometry, zoom, pan)
            if (filteredClients.size == allClients.size) {
                rawNodes
            } else {
                rawNodes.map { node ->
                    val isHighlighted = filteredMacs.contains(node.client.mac.lowercase())
                    if (node.isHighlighted != isHighlighted) {
                        node.copy(isHighlighted = isHighlighted)
                    } else {
                        node
                    }
                }
            }
        }

        // Updated state holders to keep gesture handlers fresh without restarting coroutines
        val currentNodes by rememberUpdatedState(nodes)
        val currentZoom by rememberUpdatedState(zoom)
        val currentPan by rememberUpdatedState(pan)
        val currentGeometry by rememberUpdatedState(geometry)
        val currentSize by rememberUpdatedState(size)
        val currentOnSelectClient by rememberUpdatedState(onSelectClient)

        // Smooth animation helper for reset and step zoom buttons
        fun animateToTransform(targetZoom: Float, targetPan: Offset) {
            resetJob?.cancel()
            resetJob = coroutineScope.launch {
                val startZoom = zoom
                val startPan = pan
                animate(
                    initialValue = 0f,
                    targetValue = 1f,
                    animationSpec = tween(durationMillis = 350, easing = FastOutSlowInEasing)
                ) { progress, _ ->
                    val interpolatedZoom = startZoom + (targetZoom - startZoom) * progress
                    val lerpX = startPan.x + (targetPan.x - startPan.x) * progress
                    val lerpY = startPan.y + (targetPan.y - startPan.y) * progress
                    zoom = interpolatedZoom
                    pan = Offset(lerpX, lerpY)
                }
            }
        }

        // Interactive radar viewport with chained tap and transform gesture detection
        Box(
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    detectTapGestures(
                        onTap = { tapOffset ->
                            val hitClient = engine.hitTest(tapOffset, currentNodes)
                            if (hitClient != null) {
                                currentOnSelectClient(hitClient)
                            }
                        }
                    )
                }
                .pointerInput(Unit) {
                    detectTransformGestures { centroid, panChange, zoomChange, _ ->
                        resetJob?.cancel()
                        val oldZoom = currentZoom
                        val newZoom = engine.clampZoom(oldZoom * zoomChange)
                        val zoomFactor = if (oldZoom != 0f) newZoom / oldZoom else 1.0f
                        val centerOffset = centroid - currentGeometry.center
                        val unconstrainedPan = (currentPan - centerOffset) * zoomFactor + centerOffset + panChange
                        pan = engine.clampPan(unconstrainedPan, currentSize, currentGeometry.maxRadius, newZoom)
                        zoom = newZoom
                    }
                }
        ) {
            RadarTopologyCanvas(
                geometry = geometry,
                nodes = nodes,
                selectedClient = selectedClient,
                modifier = Modifier.fillMaxSize()
            )
        }

        // Top Status Overlay: Online Client Count Badge & Live Zoom Level Indicator
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.TopCenter)
                .padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Online Client Count Pill
            TopologyStatusBadge(
                totalCount = allClients.size,
                filteredCount = filteredClients.size
            )

            // Live Zoom Level Indicator Pill
            TopologyZoomBadge(zoom = zoom)
        }

        // Floating Cyberpunk Controls: Re-center / Reset, Zoom In (+), Zoom Out (-)
        FloatingTopologyControls(
            zoom = zoom,
            pan = pan,
            onZoomIn = {
                val targetZoom = engine.clampZoom(zoom + 0.35f)
                val targetPan = engine.clampPan(pan, size, geometry.maxRadius, targetZoom)
                animateToTransform(targetZoom, targetPan)
            },
            onZoomOut = {
                val targetZoom = engine.clampZoom(zoom - 0.35f)
                val targetPan = engine.clampPan(pan, size, geometry.maxRadius, targetZoom)
                animateToTransform(targetZoom, targetPan)
            },
            onReset = {
                animateToTransform(1.0f, Offset.Zero)
            },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp)
        )
    }
}

/**
 * Top floating pill badge indicating online clients count and active filter status.
 */
@Composable
private fun TopologyStatusBadge(
    totalCount: Int,
    filteredCount: Int,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "statusDotPulse")
    val dotAlpha by infiniteTransition.animateFloat(
        initialValue = 0.4f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "dotAlpha"
    )

    val badgeShape = RoundedCornerShape(20.dp)
    val text = when {
        totalCount == 0 -> "Radar Active • 0 Devices"
        filteredCount < totalCount -> "$filteredCount / $totalCount Active"
        else -> "$totalCount Devices Online"
    }

    Row(
        modifier = modifier
            .clip(badgeShape)
            .border(
                width = 1.dp,
                brush = Brush.horizontalGradient(
                    listOf(
                        GlossyColors.GlassBorderLight.copy(alpha = 0.40f),
                        GlossyColors.GlassBorderLight.copy(alpha = 0.15f)
                    )
                ),
                shape = badgeShape
            )
            .background(GlossyColors.BackgroundElevated.copy(alpha = 0.85f))
            .padding(horizontal = 12.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Pulsing status dot
        Box(
            modifier = Modifier
                .size(7.dp)
                .background(
                    color = GlossyColors.LanGigabit.copy(alpha = dotAlpha),
                    shape = CircleShape
                )
        )
        Spacer(modifier = Modifier.width(7.dp))
        Text(
            text = text,
            color = GlossyColors.TextPrimary,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}

/**
 * Top floating pill badge displaying the live zoom magnification scale.
 */
@Composable
private fun TopologyZoomBadge(
    zoom: Float,
    modifier: Modifier = Modifier
) {
    val badgeShape = RoundedCornerShape(20.dp)
    val formattedZoom = String.format(Locale.US, "%.1fx", zoom)

    Row(
        modifier = modifier
            .clip(badgeShape)
            .border(
                width = 1.dp,
                color = GlossyColors.GlassBorderLight.copy(alpha = 0.30f),
                shape = badgeShape
            )
            .background(GlossyColors.BackgroundElevated.copy(alpha = 0.85f))
            .padding(horizontal = 10.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = formattedZoom,
            color = GlossyColors.SpeedCyan,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

/**
 * Floating cyberpunk glass controls providing Re-center / Reset and stepped zoom controls.
 */
@Composable
private fun FloatingTopologyControls(
    zoom: Float,
    pan: Offset,
    onZoomIn: () -> Unit,
    onZoomOut: () -> Unit,
    onReset: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isTransformed = zoom != 1.0f || pan.x != 0f || pan.y != 0f
    val resetInteractionSource = remember { MutableInteractionSource() }
    val zoomInInteractionSource = remember { MutableInteractionSource() }
    val zoomOutInteractionSource = remember { MutableInteractionSource() }
    val resetRipple = ripple(bounded = true, color = GlossyColors.SpeedCyan)
    val buttonRipple = ripple(bounded = true, color = GlossyColors.LightBlue)

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(8.dp),
        horizontalAlignment = Alignment.End
    ) {
        // Re-center / Reset Button
        val resetBorderColor = if (isTransformed) {
            GlossyColors.SpeedCyan.copy(alpha = 0.65f)
        } else {
            GlossyColors.GlassBorderLight.copy(alpha = 0.35f)
        }

        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .border(width = 1.dp, color = resetBorderColor, shape = CircleShape)
                .background(GlossyColors.CardElevated.copy(alpha = 0.90f))
                .clickable(
                    interactionSource = resetInteractionSource,
                    indication = resetRipple,
                    onClick = onReset
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.FilterCenterFocus,
                contentDescription = "Re-center radar view",
                tint = if (isTransformed) GlossyColors.SpeedCyan else GlossyColors.TextSecondary,
                modifier = Modifier.size(22.dp)
            )
        }

        // Stepped Zoom Controls (+ and -)
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(22.dp))
                .border(
                    width = 1.dp,
                    color = GlossyColors.GlassBorderLight.copy(alpha = 0.30f),
                    shape = RoundedCornerShape(22.dp)
                )
                .background(GlossyColors.CardElevated.copy(alpha = 0.85f)),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Zoom In (+)
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clickable(
                        enabled = zoom < RadarTopologyEngine.MAX_ZOOM,
                        interactionSource = zoomInInteractionSource,
                        indication = buttonRipple,
                        onClick = onZoomIn
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "Zoom In",
                    tint = if (zoom < RadarTopologyEngine.MAX_ZOOM) GlossyColors.TextPrimary else GlossyColors.TextSecondary.copy(alpha = 0.3f),
                    modifier = Modifier.size(18.dp)
                )
            }

            // Divider hairline
            Box(
                modifier = Modifier
                    .size(width = 24.dp, height = 1.dp)
                    .background(GlossyColors.GlassBorderLight.copy(alpha = 0.20f))
            )

            // Zoom Out (-)
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clickable(
                        enabled = zoom > RadarTopologyEngine.MIN_ZOOM,
                        interactionSource = zoomOutInteractionSource,
                        indication = buttonRipple,
                        onClick = onZoomOut
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Remove,
                    contentDescription = "Zoom Out",
                    tint = if (zoom > RadarTopologyEngine.MIN_ZOOM) GlossyColors.TextPrimary else GlossyColors.TextSecondary.copy(alpha = 0.3f),
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}
