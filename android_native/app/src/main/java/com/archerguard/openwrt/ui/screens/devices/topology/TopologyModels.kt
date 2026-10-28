package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import com.archerguard.openwrt.domain.model.ClientInfo

/**
 * Network band tier for orbital placement in the radar topology.
 */
enum class BandTier {
    BAND_5GHZ,
    BAND_2GHZ,
    WIRED_LAN,
    GUEST_ISOLATED
}

/**
 * Represents a single visual node positioned in the radar topology.
 *
 * @param client The underlying domain client telemetry data.
 * @param worldPosition Center coordinate relative to router center at (0, 0).
 * @param screenPosition Viewport pixel coordinate mapped with current zoom and pan.
 * @param tier The network frequency band or isolation tier.
 * @param visualRadiusPx Nominal visual node badge radius in pixels.
 * @param isHighlighted Whether this node matches the active search query and filter selection.
 */
data class TopologyNode(
    val client: ClientInfo,
    val worldPosition: Offset,
    val screenPosition: Offset,
    val tier: BandTier,
    val visualRadiusPx: Float = 18f,
    val isHighlighted: Boolean = true
)

/**
 * Geometric bounds and radial orbital ring metrics for the radar topology canvas.
 *
 * @param center The viewport center origin (width / 2, height / 2).
 * @param maxRadius The maximum boundary radius for client placement.
 * @param tierRadii Radial distances mapped to each band tier.
 */
data class RadarGeometry(
    val center: Offset = Offset.Zero,
    val maxRadius: Float = 0f,
    val tierRadii: Map<BandTier, Float> = emptyMap()
)

/**
 * Active interactive transformation state for the radar canvas.
 *
 * @param zoom Scaling factor between [0.5, 3.0].
 * @param pan 2D translation offset in pixels.
 */
data class TransformState(
    val zoom: Float = 1.0f,
    val pan: Offset = Offset.Zero
)
