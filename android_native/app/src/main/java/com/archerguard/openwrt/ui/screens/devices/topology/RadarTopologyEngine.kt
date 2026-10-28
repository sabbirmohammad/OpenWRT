package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import com.archerguard.openwrt.domain.model.ClientInfo
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Pure mathematical layout engine for ArcherGuard's interactive network topology radar.
 *
 * Computes radial band tiers (5GHz, 2.4GHz, LAN, Guest), RSSI modulation, equidistant angular
 * distributions, dense collision avoidance (interleaved radial staggering), focal coordinate
 * transformations (zoom & pan), bounded clamping, and accessible hit-testing.
 */
class RadarTopologyEngine {

    companion object {
        const val MIN_ZOOM = 0.5f
        const val MAX_ZOOM = 3.0f
        const val DEFAULT_TOUCH_RADIUS_PX = 60f
        const val DEFAULT_VISUAL_RADIUS_PX = 18f
        const val RADIAL_STAGGER_OFFSET_PX = 16f
        const val MIN_NODE_SPACING_PX = 24f

        // Tier relative radii (% of maxRadius)
        const val RATIO_5GHZ = 0.33f
        const val RATIO_2GHZ = 0.62f
        const val RATIO_LAN = 0.18f
        const val RATIO_GUEST = 0.88f
        const val MAX_RADIUS_RATIO = 0.44f

        // Signal RSSI bounds in dBm
        const val RSSI_STRONG_DBM = -30f
        const val RSSI_WEAK_DBM = -90f
    }

    /**
     * Calculates the center origin and radial tier rings for the given canvas dimensions.
     */
    fun calculateGeometry(size: Size): RadarGeometry {
        if (size.width <= 0f || size.height <= 0f) {
            return RadarGeometry(
                center = Offset.Zero,
                maxRadius = 0f,
                tierRadii = mapOf(
                    BandTier.BAND_5GHZ to 0f,
                    BandTier.BAND_2GHZ to 0f,
                    BandTier.WIRED_LAN to 0f,
                    BandTier.GUEST_ISOLATED to 0f
                )
            )
        }

        val center = Offset(size.width / 2f, size.height / 2f)
        val maxRadius = minOf(size.width, size.height) * MAX_RADIUS_RATIO

        val tierRadii = mapOf(
            BandTier.BAND_5GHZ to maxRadius * RATIO_5GHZ,
            BandTier.BAND_2GHZ to maxRadius * RATIO_2GHZ,
            BandTier.WIRED_LAN to maxRadius * RATIO_LAN,
            BandTier.GUEST_ISOLATED to maxRadius * RATIO_GUEST
        )

        return RadarGeometry(
            center = center,
            maxRadius = maxRadius,
            tierRadii = tierRadii
        )
    }

    /**
     * Maps a client to its corresponding network band tier.
     */
    fun mapClientToTier(client: ClientInfo): BandTier {
        return when {
            client.isIsolated ||
                    client.connectionType.equals("Guest", ignoreCase = true) ||
                    client.ssidName.contains("Guest", ignoreCase = true) ->
                BandTier.GUEST_ISOLATED

            client.connectionType.contains("5", ignoreCase = true) ||
                    client.ssidName.contains("5G", ignoreCase = true) ->
                BandTier.BAND_5GHZ

            client.connectionType.contains("2.4", ignoreCase = true) ||
                    client.connectionType.contains("2G", ignoreCase = true) ||
                    client.ssidName.contains("2.4G", ignoreCase = true) ->
                BandTier.BAND_2GHZ

            client.connectionType.equals("LAN", ignoreCase = true) ||
                    client.connectionType.contains("Ethernet", ignoreCase = true) ||
                    client.connectionType.contains("Wired", ignoreCase = true) ->
                BandTier.WIRED_LAN

            client.signalDbm == 0 ->
                BandTier.WIRED_LAN

            else ->
                BandTier.BAND_2GHZ
        }
    }

    /**
     * Computes the visual nodes and spatial coordinates for connected clients.
     *
     * @param clients List of router clients to position.
     * @param geometry The radar canvas geometry.
     * @param zoom Active viewport zoom factor.
     * @param pan Active viewport 2D pan offset.
     * @param searchQuery Search query to highlight matching devices.
     * @param selectedFilter Category filter chip selection.
     */
    fun computeNodes(
        clients: List<ClientInfo>,
        geometry: RadarGeometry,
        zoom: Float = 1.0f,
        pan: Offset = Offset.Zero,
        searchQuery: String = "",
        selectedFilter: String = "All"
    ): List<TopologyNode> {
        if (clients.isEmpty()) return emptyList()

        val tierGroups = clients.groupBy { mapClientToTier(it) }
        val tierIndices = mutableMapOf<BandTier, Int>()

        return clients.map { client ->
            val tier = mapClientToTier(client)
            val tierClients = tierGroups[tier] ?: emptyList()
            val tierCount = tierClients.size
            val tierIndex = tierIndices.getOrDefault(tier, 0)
            tierIndices[tier] = tierIndex + 1

            val baseRadius = geometry.tierRadii[tier] ?: (geometry.maxRadius * 0.5f)

            // RSSI Modulation: -30 dBm closer to router, -90 dBm towards outer edge
            val rssiModulatedRadius = if (tier == BandTier.WIRED_LAN || geometry.maxRadius <= 0f) {
                baseRadius
            } else {
                val clampedRssi = client.signalDbm.coerceIn(RSSI_WEAK_DBM.toInt(), RSSI_STRONG_DBM.toInt()).toFloat()
                // factor = 0.0 at -30 dBm (strong), 1.0 at -90 dBm (weak)
                val rssiFactor = (-clampedRssi + RSSI_STRONG_DBM) / (-RSSI_WEAK_DBM + RSSI_STRONG_DBM)
                val spread = when (tier) {
                    BandTier.BAND_5GHZ -> geometry.maxRadius * 0.12f
                    BandTier.BAND_2GHZ -> geometry.maxRadius * 0.14f
                    BandTier.GUEST_ISOLATED -> geometry.maxRadius * 0.08f
                    BandTier.WIRED_LAN -> 0f
                }
                baseRadius + (rssiFactor - 0.5f) * spread
            }

            // Dense collision avoidance (30+ devices): interleaved radial staggering
            val isDense = clients.size >= 20 || tierCount >= 6
            val staggerOffset = if (isDense && tierCount > 1) {
                if (tierCount % 2 != 0 && tierIndex == tierCount - 1) {
                    0f
                } else if (tierIndex % 2 == 0) {
                    RADIAL_STAGGER_OFFSET_PX
                } else {
                    -RADIAL_STAGGER_OFFSET_PX
                }
            } else {
                0f
            }

            val finalRadius = if (geometry.maxRadius <= 0f) 0f else maxOf(0f, rssiModulatedRadius + staggerOffset)

            // Equidistant angular distribution within the tier
            val angle = if (tierCount <= 1) {
                -PI.toFloat() / 2f // Position single device at top (12 o'clock)
            } else {
                val tierBaseAngle = when (tier) {
                    BandTier.WIRED_LAN -> -PI.toFloat() / 2f
                    BandTier.BAND_5GHZ -> -PI.toFloat() / 2f
                    BandTier.BAND_2GHZ -> (-PI.toFloat() / 2f) + (PI.toFloat() / tierCount)
                    BandTier.GUEST_ISOLATED -> (-PI.toFloat() / 2f) + (PI.toFloat() / 4f)
                }
                val angleStep = (2.0 * PI / tierCount).toFloat()
                tierBaseAngle + tierIndex * angleStep
            }

            // Coordinate conversion
            val worldX = finalRadius * cos(angle)
            val worldY = finalRadius * sin(angle)
            val worldPosition = Offset(worldX, worldY)
            val screenPosition = worldToScreen(worldPosition, geometry.center, zoom, pan)

            // Filtering and search highlighting
            val matchesSearch = searchQuery.isBlank() ||
                    client.displayName.contains(searchQuery, ignoreCase = true) ||
                    client.ip.contains(searchQuery, ignoreCase = true) ||
                    client.mac.contains(searchQuery, ignoreCase = true) ||
                    client.hostname.contains(searchQuery, ignoreCase = true)

            val matchesFilter = when (selectedFilter) {
                "All", "" -> true
                "2.4 GHz", "2.4GHz" -> client.ssidName.contains("2.4", ignoreCase = true) ||
                        client.connectionType.contains("2.4", ignoreCase = true)
                "5.0 GHz", "5GHz", "5.0GHz" -> client.ssidName.contains("5", ignoreCase = true) ||
                        client.connectionType.contains("5", ignoreCase = true)
                "LAN" -> client.connectionType.equals("LAN", ignoreCase = true)
                "Guest" -> client.isIsolated ||
                        client.connectionType.equals("Guest", ignoreCase = true) ||
                        client.ssidName.contains("Guest", ignoreCase = true)
                else -> true
            }

            TopologyNode(
                client = client,
                worldPosition = worldPosition,
                screenPosition = screenPosition,
                tier = tier,
                visualRadiusPx = DEFAULT_VISUAL_RADIUS_PX,
                isHighlighted = matchesSearch && matchesFilter
            )
        }
    }

    /**
     * Resolves the closest client node to the user's touch point within an accessible radius.
     */
    fun hitTest(
        tapScreenPos: Offset,
        nodes: List<TopologyNode>,
        minTouchRadiusPx: Float = DEFAULT_TOUCH_RADIUS_PX
    ): ClientInfo? {
        if (nodes.isEmpty()) return null

        var closestClient: ClientInfo? = null
        var minDistance = Float.MAX_VALUE

        for (node in nodes) {
            val touchTargetRadius = maxOf(node.visualRadiusPx, minTouchRadiusPx)
            val dx = tapScreenPos.x - node.screenPosition.x
            val dy = tapScreenPos.y - node.screenPosition.y
            val distance = sqrt(dx * dx + dy * dy)

            if (distance <= touchTargetRadius && distance < minDistance) {
                minDistance = distance
                closestClient = node.client
            }
        }

        return closestClient
    }

    /**
     * Clamps the zoom level within supported range [0.5, 3.0].
     */
    fun clampZoom(zoom: Float): Float {
        if (zoom.isNaN()) return 1.0f
        return zoom.coerceIn(MIN_ZOOM, MAX_ZOOM)
    }

    /**
     * Bounds the 2D pan offset so the radar canvas remains visible within the viewport.
     */
    fun clampPan(pan: Offset, canvasSize: Size, maxRadius: Float, zoom: Float): Offset {
        if (canvasSize.width <= 0f || canvasSize.height <= 0f || maxRadius <= 0f) {
            return Offset.Zero
        }
        val safeZoom = clampZoom(zoom)
        val maxPanX = canvasSize.width * 0.5f + maxRadius * safeZoom * 0.5f
        val maxPanY = canvasSize.height * 0.5f + maxRadius * safeZoom * 0.5f

        val clampedX = if (pan.x.isNaN()) 0f else pan.x.coerceIn(-maxPanX, maxPanX)
        val clampedY = if (pan.y.isNaN()) 0f else pan.y.coerceIn(-maxPanY, maxPanY)

        return Offset(clampedX, clampedY)
    }

    /**
     * Transforms a point from world coordinates relative to router center (0, 0) to screen coordinates.
     */
    fun worldToScreen(worldPos: Offset, center: Offset, zoom: Float, pan: Offset): Offset {
        return center + pan + worldPos * zoom
    }

    /**
     * Inverts a screen coordinate back to world coordinates relative to router center (0, 0).
     */
    fun screenToWorld(screenPos: Offset, center: Offset, zoom: Float, pan: Offset): Offset {
        val z = if (zoom == 0f || zoom.isNaN()) 1.0f else zoom
        return (screenPos - center - pan) / z
    }
}
