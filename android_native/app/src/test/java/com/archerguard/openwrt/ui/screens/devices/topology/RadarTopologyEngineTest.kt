package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import com.archerguard.openwrt.domain.model.ClientInfo
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Comprehensive 4-Tier Test Suite for [RadarTopologyEngine].
 *
 * Verifies mathematical layout, radial tier distribution, RSSI modulation, dense network
 * collision avoidance (minimum 24px spacing), multi-touch zoom and pan constraints,
 * coordinate inversion, touch hit-testing, and real-world OpenWrt fleet telemetry workloads.
 */
class RadarTopologyEngineTest {

    private lateinit var engine: RadarTopologyEngine
    private val standardSize = Size(1000f, 1000f)
    private lateinit var standardGeometry: RadarGeometry

    @Before
    fun setUp() {
        engine = RadarTopologyEngine()
        standardGeometry = engine.calculateGeometry(standardSize)
    }

    private fun createClient(
        mac: String = "aa:bb:cc:dd:ee:01",
        ip: String = "192.168.1.100",
        hostname: String = "Test-Device",
        connectionType: String = "5GHz",
        ssidName: String? = null,
        signalDbm: Int = -55,
        isIsolated: Boolean = false,
        blocked: Boolean = false,
        customName: String? = null
    ): ClientInfo {
        val resolvedSsid = ssidName ?: when {
            isIsolated || connectionType.equals("Guest", ignoreCase = true) -> "ArcherC6_Guest"
            connectionType.contains("5", ignoreCase = true) -> "ArcherC6_5G"
            connectionType.contains("2", ignoreCase = true) -> "ArcherC6_2.4G"
            connectionType.equals("LAN", ignoreCase = true) ||
                    connectionType.contains("Ethernet", ignoreCase = true) ||
                    connectionType.contains("Wired", ignoreCase = true) -> ""
            signalDbm == 0 -> ""
            else -> "ArcherC6_2.4G"
        }

        return ClientInfo(
            mac = mac,
            ip = ip,
            hostname = hostname,
            connectionType = connectionType,
            ssidName = resolvedSsid,
            signalDbm = signalDbm,
            isIsolated = isIsolated,
            blocked = blocked,
            customName = customName
        )
    }

    private fun distance(p1: Offset, p2: Offset): Float {
        val dx = p1.x - p2.x
        val dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }

    // =========================================================================
    // TIER 1: FEATURE COVERAGE
    // =========================================================================

    @Test
    fun testGeometryCalculation_squareAndRectangularCanvas() {
        // 1. Square Canvas
        val squareSize = Size(1000f, 1000f)
        val squareGeom = engine.calculateGeometry(squareSize)

        assertEquals(500f, squareGeom.center.x, 0.001f)
        assertEquals(500f, squareGeom.center.y, 0.001f)
        val expectedMaxRadiusSquare = 1000f * RadarTopologyEngine.MAX_RADIUS_RATIO // 440f
        assertEquals(expectedMaxRadiusSquare, squareGeom.maxRadius, 0.001f)

        assertEquals(expectedMaxRadiusSquare * RadarTopologyEngine.RATIO_5GHZ, squareGeom.tierRadii[BandTier.BAND_5GHZ]!!, 0.001f)
        assertEquals(expectedMaxRadiusSquare * RadarTopologyEngine.RATIO_2GHZ, squareGeom.tierRadii[BandTier.BAND_2GHZ]!!, 0.001f)
        assertEquals(expectedMaxRadiusSquare * RadarTopologyEngine.RATIO_LAN, squareGeom.tierRadii[BandTier.WIRED_LAN]!!, 0.001f)
        assertEquals(expectedMaxRadiusSquare * RadarTopologyEngine.RATIO_GUEST, squareGeom.tierRadii[BandTier.GUEST_ISOLATED]!!, 0.001f)

        // 2. Rectangular Portrait Canvas (Phone aspect ratio)
        val portraitSize = Size(1080f, 2400f)
        val portraitGeom = engine.calculateGeometry(portraitSize)

        assertEquals(540f, portraitGeom.center.x, 0.001f)
        assertEquals(1200f, portraitGeom.center.y, 0.001f)
        val expectedMaxRadiusPortrait = 1080f * RadarTopologyEngine.MAX_RADIUS_RATIO // based on minOf(width, height)
        assertEquals(expectedMaxRadiusPortrait, portraitGeom.maxRadius, 0.001f)

        // 3. Rectangular Landscape Canvas (Tablet aspect ratio)
        val landscapeSize = Size(1920f, 1080f)
        val landscapeGeom = engine.calculateGeometry(landscapeSize)

        assertEquals(960f, landscapeGeom.center.x, 0.001f)
        assertEquals(540f, landscapeGeom.center.y, 0.001f)
        val expectedMaxRadiusLandscape = 1080f * RadarTopologyEngine.MAX_RADIUS_RATIO
        assertEquals(expectedMaxRadiusLandscape, landscapeGeom.maxRadius, 0.001f)
    }

    @Test
    fun testGeometryCalculation_tierRadiiProportions() {
        val geom = standardGeometry
        val lanRadius = geom.tierRadii[BandTier.WIRED_LAN]!!
        val fiveGhzRadius = geom.tierRadii[BandTier.BAND_5GHZ]!!
        val twoGhzRadius = geom.tierRadii[BandTier.BAND_2GHZ]!!
        val guestRadius = geom.tierRadii[BandTier.GUEST_ISOLATED]!!

        // Radial ordering from inner core to outer edge
        assertTrue("LAN must be closest to router core", lanRadius > 0f)
        assertTrue("5GHz must be outside LAN", fiveGhzRadius > lanRadius)
        assertTrue("2.4GHz must be outside 5GHz", twoGhzRadius > fiveGhzRadius)
        assertTrue("Guest must be outermost ring", guestRadius > twoGhzRadius)
        assertTrue("Guest ring must remain inside maxRadius", guestRadius < geom.maxRadius)
    }

    @Test
    fun testBandTierMapping_5GHz_2GHz_LAN_Guest() {
        // 5GHz band mapping
        val client5G1 = createClient(connectionType = "5GHz", ssidName = "Home_5G")
        val client5G2 = createClient(connectionType = "Wi-Fi 5GHz", ssidName = "")
        val client5G3 = createClient(connectionType = "Unknown", ssidName = "ArcherC6_5G")

        assertEquals(BandTier.BAND_5GHZ, engine.mapClientToTier(client5G1))
        assertEquals(BandTier.BAND_5GHZ, engine.mapClientToTier(client5G2))
        assertEquals(BandTier.BAND_5GHZ, engine.mapClientToTier(client5G3))

        // 2.4GHz band mapping
        val client2G1 = createClient(connectionType = "2.4GHz", ssidName = "Home_2.4G")
        val client2G2 = createClient(connectionType = "2G", ssidName = "")
        val client2G3 = createClient(connectionType = "Unknown", ssidName = "ArcherC6_2.4G")
        val clientFallback = createClient(connectionType = "Wi-Fi", ssidName = "OtherNet", signalDbm = -70)

        assertEquals(BandTier.BAND_2GHZ, engine.mapClientToTier(client2G1))
        assertEquals(BandTier.BAND_2GHZ, engine.mapClientToTier(client2G2))
        assertEquals(BandTier.BAND_2GHZ, engine.mapClientToTier(client2G3))
        assertEquals(BandTier.BAND_2GHZ, engine.mapClientToTier(clientFallback))

        // Wired LAN mapping
        val clientLan1 = createClient(connectionType = "LAN", ssidName = "", signalDbm = 0)
        val clientLan2 = createClient(connectionType = "Ethernet", ssidName = "", signalDbm = 0)
        val clientLan3 = createClient(connectionType = "Wired Gigabit", ssidName = "", signalDbm = 0)
        val clientLan4 = createClient(connectionType = "", ssidName = "", signalDbm = 0) // zero signal indicates wired

        assertEquals(BandTier.WIRED_LAN, engine.mapClientToTier(clientLan1))
        assertEquals(BandTier.WIRED_LAN, engine.mapClientToTier(clientLan2))
        assertEquals(BandTier.WIRED_LAN, engine.mapClientToTier(clientLan3))
        assertEquals(BandTier.WIRED_LAN, engine.mapClientToTier(clientLan4))

        // Guest / Isolated mapping (takes highest precedence)
        val clientGuest1 = createClient(connectionType = "Guest", ssidName = "GuestNet")
        val clientGuest2 = createClient(connectionType = "5GHz", ssidName = "ArcherC6_5G", isIsolated = true)
        val clientGuest3 = createClient(connectionType = "2.4GHz", ssidName = "Archer_Guest_Network")

        assertEquals(BandTier.GUEST_ISOLATED, engine.mapClientToTier(clientGuest1))
        assertEquals(BandTier.GUEST_ISOLATED, engine.mapClientToTier(clientGuest2))
        assertEquals(BandTier.GUEST_ISOLATED, engine.mapClientToTier(clientGuest3))
    }

    @Test
    fun testSignalRssiModulation_radialDistanceIncreasesWithAttenuation() {
        // Signal RSSI ranges from -30 dBm (strongest) to -90 dBm (weakest)
        val strongClient = createClient(mac = "01", connectionType = "5GHz", signalDbm = -30)
        val midClient = createClient(mac = "02", connectionType = "5GHz", signalDbm = -60)
        val weakClient = createClient(mac = "03", connectionType = "5GHz", signalDbm = -90)

        val nodesStrong = engine.computeNodes(listOf(strongClient), standardGeometry)
        val nodesMid = engine.computeNodes(listOf(midClient), standardGeometry)
        val nodesWeak = engine.computeNodes(listOf(weakClient), standardGeometry)

        val distStrong = distance(Offset.Zero, nodesStrong.first().worldPosition)
        val distMid = distance(Offset.Zero, nodesMid.first().worldPosition)
        val distWeak = distance(Offset.Zero, nodesWeak.first().worldPosition)

        assertTrue("Strong signal (-30 dBm) must be closer than mid signal (-60 dBm): $distStrong vs $distMid", distStrong < distMid)
        assertTrue("Mid signal (-60 dBm) must be closer than weak signal (-90 dBm): $distMid vs $distWeak", distMid < distWeak)

        // Repeat for 2.4GHz
        val strong2G = createClient(mac = "11", connectionType = "2.4GHz", signalDbm = -35)
        val weak2G = createClient(mac = "12", connectionType = "2.4GHz", signalDbm = -85)

        val nodesStrong2G = engine.computeNodes(listOf(strong2G), standardGeometry)
        val nodesWeak2G = engine.computeNodes(listOf(weak2G), standardGeometry)

        val distStrong2G = distance(Offset.Zero, nodesStrong2G.first().worldPosition)
        val distWeak2G = distance(Offset.Zero, nodesWeak2G.first().worldPosition)

        assertTrue("Strong 2.4GHz must be closer than weak 2.4GHz", distStrong2G < distWeak2G)
    }

    @Test
    fun testSignalRssiModulation_wiredLanUnaffectedByRssi() {
        // Wired LAN should not be displaced by RSSI fluctuations
        val lanClient1 = createClient(mac = "l1", connectionType = "LAN", ssidName = "", signalDbm = 0)
        val lanClient2 = createClient(mac = "l2", connectionType = "LAN", ssidName = "", signalDbm = -80)

        val nodes1 = engine.computeNodes(listOf(lanClient1), standardGeometry)
        val nodes2 = engine.computeNodes(listOf(lanClient2), standardGeometry)

        val dist1 = distance(Offset.Zero, nodes1.first().worldPosition)
        val dist2 = distance(Offset.Zero, nodes2.first().worldPosition)

        assertEquals("Wired LAN radial distance must remain fixed regardless of signalDbm", dist1, dist2, 0.001f)
        assertEquals(standardGeometry.tierRadii[BandTier.WIRED_LAN]!!, dist1, 0.001f)
    }

    @Test
    fun testAngularDistribution_equidistantDistributionInBand() {
        // 4 clients in the same band (5GHz)
        val clients = (1..4).map { i ->
            createClient(mac = "0$i", hostname = "Phone-$i", connectionType = "5GHz", signalDbm = -50)
        }

        val nodes = engine.computeNodes(clients, standardGeometry)
        assertEquals(4, nodes.size)

        // For N=4, angles should be separated by exactly 2*PI / 4 = PI / 2 radians (90 degrees)
        val angles = nodes.map { node ->
            atan2(node.worldPosition.y, node.worldPosition.x)
        }

        for (i in 0 until 3) {
            var diff = angles[i + 1] - angles[i]
            if (diff < 0) diff += (2.0 * PI).toFloat()
            assertEquals("Angular step between node $i and ${i + 1} must be PI/2", (PI / 2.0).toFloat(), diff, 0.01f)
        }

        // Test 3 clients in 5GHz band
        val clients3 = (1..3).map { i ->
            createClient(mac = "3$i", hostname = "Device-$i", connectionType = "5GHz", signalDbm = -50)
        }
        val nodes3 = engine.computeNodes(clients3, standardGeometry)
        val angles3 = nodes3.map { atan2(it.worldPosition.y, it.worldPosition.x) }

        for (i in 0 until 2) {
            var diff = angles3[i + 1] - angles3[i]
            if (diff < 0) diff += (2.0 * PI).toFloat()
            assertEquals("Angular step for 3 nodes must be 2*PI/3", (2.0 * PI / 3.0).toFloat(), diff, 0.01f)
        }
    }

    @Test
    fun testAngularDistribution_tierBaseAnglesStaggered() {
        // Verify that different bands have staggered base angles so devices on different bands
        // do not align along the exact same radial line when multiple devices are present
        val clients5G = (1..2).map { createClient(mac = "5$it", connectionType = "5GHz", signalDbm = -50) }
        val clients2G = (1..2).map { createClient(mac = "2$it", connectionType = "2.4GHz", signalDbm = -50) }

        val nodes5G = engine.computeNodes(clients5G, standardGeometry)
        val nodes2G = engine.computeNodes(clients2G, standardGeometry)

        assertEquals(BandTier.BAND_5GHZ, nodes5G.first().tier)
        assertEquals(BandTier.BAND_2GHZ, nodes2G.first().tier)

        val angle5GNode0 = atan2(nodes5G[0].worldPosition.y, nodes5G[0].worldPosition.x)
        val angle2GNode0 = atan2(nodes2G[0].worldPosition.y, nodes2G[0].worldPosition.x)

        assertNotEquals("5GHz and 2.4GHz base angles must be staggered", angle5GNode0, angle2GNode0, 0.01f)
    }

    @Test
    fun testHitTest_exactNodeCenterSelection() {
        val client1 = createClient(mac = "m1", hostname = "Phone-1", connectionType = "5GHz")
        val client2 = createClient(mac = "m2", hostname = "TV-2", connectionType = "2.4GHz")
        val client3 = createClient(mac = "m3", hostname = "NAS-3", connectionType = "LAN", signalDbm = 0)

        val nodes = engine.computeNodes(listOf(client1, client2, client3), standardGeometry)

        // Exact hit on node 1
        val hit1 = engine.hitTest(nodes[0].screenPosition, nodes)
        assertNotNull(hit1)
        assertEquals("m1", hit1!!.mac)

        // Exact hit on node 2
        val hit2 = engine.hitTest(nodes[1].screenPosition, nodes)
        assertNotNull(hit2)
        assertEquals("m2", hit2!!.mac)

        // Exact hit on node 3
        val hit3 = engine.hitTest(nodes[2].screenPosition, nodes)
        assertNotNull(hit3)
        assertEquals("m3", hit3!!.mac)
    }

    @Test
    fun testHitTest_withinAccessibleTouchRadius() {
        val client = createClient(mac = "touch1", connectionType = "5GHz")
        val nodes = engine.computeNodes(listOf(client), standardGeometry)
        val nodeCenter = nodes.first().screenPosition

        // Tap offset by 20px (well within default 60px touch radius)
        val tapNear = nodeCenter + Offset(15f, 15f) // distance ~21.2px
        val hitNear = engine.hitTest(tapNear, nodes, minTouchRadiusPx = 60f)
        assertNotNull(hitNear)
        assertEquals("touch1", hitNear!!.mac)

        // Tap offset by 55px (near the 60px boundary)
        val tapBoundary = nodeCenter + Offset(0f, 55f)
        val hitBoundary = engine.hitTest(tapBoundary, nodes, minTouchRadiusPx = 60f)
        assertNotNull(hitBoundary)
        assertEquals("touch1", hitBoundary!!.mac)
    }

    @Test
    fun testHitTest_outsideTouchRadiusReturnsNull() {
        val client = createClient(mac = "touch2", connectionType = "5GHz")
        val nodes = engine.computeNodes(listOf(client), standardGeometry)
        val nodeCenter = nodes.first().screenPosition

        // Tap offset by 75px (strictly outside 60px touch radius)
        val tapFar = nodeCenter + Offset(75f, 0f)
        val hitFar = engine.hitTest(tapFar, nodes, minTouchRadiusPx = 60f)
        assertNull("Hit test outside 60px radius must return null", hitFar)

        // Tap far outside at top-left origin (0, 0)
        val hitOrigin = engine.hitTest(Offset.Zero, nodes, minTouchRadiusPx = 60f)
        assertNull("Hit test at canvas origin must return null", hitOrigin)
    }

    @Test
    fun testHitTest_resolvesToClosestNodeWhenMultipleWithinRadius() {
        // Two nodes placed at known screen positions
        val clientA = createClient(mac = "A", hostname = "Node-A")
        val clientB = createClient(mac = "B", hostname = "Node-B")

        val nodeA = TopologyNode(
            client = clientA,
            worldPosition = Offset(-30f, 0f),
            screenPosition = Offset(470f, 500f),
            tier = BandTier.BAND_5GHZ
        )
        val nodeB = TopologyNode(
            client = clientB,
            worldPosition = Offset(30f, 0f),
            screenPosition = Offset(530f, 500f),
            tier = BandTier.BAND_5GHZ
        )

        val nodeList = listOf(nodeA, nodeB)

        // Tap at (480, 500): distance to A is 10px, distance to B is 50px
        val tap = Offset(480f, 500f)
        val resolved = engine.hitTest(tap, nodeList, minTouchRadiusPx = 60f)
        assertNotNull(resolved)
        assertEquals("Must resolve to closer Node-A", "A", resolved!!.mac)
    }

    // =========================================================================
    // TIER 2: BOUNDARY & CORNER CASES
    // =========================================================================

    @Test
    fun testEmptyClientsList_returnsEmptyNodesWithoutNaNOrCrash() {
        val emptyNodes = engine.computeNodes(emptyList(), standardGeometry)
        assertTrue("Empty clients list must produce empty nodes", emptyNodes.isEmpty())

        val hitOnEmpty = engine.hitTest(Offset(500f, 500f), emptyNodes)
        assertNull("Hit test on empty nodes must return null without crashing", hitOnEmpty)
    }

    @Test
    fun testSingleClientPlacement_validFiniteCoordinates() {
        val singleClient = createClient(mac = "s1", hostname = "Single-Client", connectionType = "5GHz", signalDbm = -50)
        val nodes = engine.computeNodes(listOf(singleClient), standardGeometry)

        assertEquals(1, nodes.size)
        val node = nodes.first()

        assertFalse("X coordinate must not be NaN", node.worldPosition.x.isNaN())
        assertFalse("Y coordinate must not be NaN", node.worldPosition.y.isNaN())
        assertFalse("Screen X must not be NaN", node.screenPosition.x.isNaN())
        assertFalse("Screen Y must not be NaN", node.screenPosition.y.isNaN())

        // Single device must be placed at 12 o'clock (-PI / 2): worldX ~= 0, worldY < 0
        assertEquals(0f, node.worldPosition.x, 0.01f)
        assertTrue("Single device at 12 o'clock must have negative worldY", node.worldPosition.y < 0f)

        // Screen position must map to center.x and center.y + worldY
        assertEquals(standardGeometry.center.x, node.screenPosition.x, 0.01f)
        assertEquals(standardGeometry.center.y + node.worldPosition.y, node.screenPosition.y, 0.01f)
    }

    @Test
    fun testZoomClamping_strictlyEnforcedBounds() {
        // Minimum zoom bound is 0.5f
        assertEquals(0.5f, engine.clampZoom(0.01f), 0.001f)
        assertEquals(0.5f, engine.clampZoom(-5.0f), 0.001f)
        assertEquals(0.5f, engine.clampZoom(0.5f), 0.001f)

        // Maximum zoom bound is 3.0f
        assertEquals(3.0f, engine.clampZoom(100.0f), 0.001f)
        assertEquals(3.0f, engine.clampZoom(3.5f), 0.001f)
        assertEquals(3.0f, engine.clampZoom(3.0f), 0.001f)

        // Intermediate values
        assertEquals(1.0f, engine.clampZoom(1.0f), 0.001f)
        assertEquals(1.75f, engine.clampZoom(1.75f), 0.001f)
    }

    @Test
    fun testZoomClamping_nanAndInfinity() {
        // Defensive handling for NaN and Infinities
        assertEquals("NaN zoom must fallback to 1.0f", 1.0f, engine.clampZoom(Float.NaN), 0.001f)
        assertEquals(0.5f, engine.clampZoom(Float.NEGATIVE_INFINITY), 0.001f)
        assertEquals(3.0f, engine.clampZoom(Float.POSITIVE_INFINITY), 0.001f)
    }

    @Test
    fun testPanClamping_restrictsPanWithinCanvasBounds() {
        val canvasSize = Size(1000f, 1000f)
        val maxRadius = 440f
        val zoom = 1.0f

        // maxPan = 1000 * 0.5 + 440 * 1.0 * 0.5 = 500 + 220 = 720f
        val extremePositivePan = Offset(2500f, 3000f)
        val clampedPositive = engine.clampPan(extremePositivePan, canvasSize, maxRadius, zoom)
        assertEquals(720f, clampedPositive.x, 0.001f)
        assertEquals(720f, clampedPositive.y, 0.001f)

        val extremeNegativePan = Offset(-2000f, -1500f)
        val clampedNegative = engine.clampPan(extremeNegativePan, canvasSize, maxRadius, zoom)
        assertEquals(-720f, clampedNegative.x, 0.001f)
        assertEquals(-720f, clampedNegative.y, 0.001f)

        // Valid internal pan remains unconstrained
        val internalPan = Offset(150f, -200f)
        val clampedInternal = engine.clampPan(internalPan, canvasSize, maxRadius, zoom)
        assertEquals(150f, clampedInternal.x, 0.001f)
        assertEquals(-200f, clampedInternal.y, 0.001f)
    }

    @Test
    fun testPanClamping_zeroCanvasAndExtremeValues() {
        val zeroSize = Size(0f, 0f)
        val clampedZero = engine.clampPan(Offset(100f, 100f), zeroSize, 0f, 1.0f)
        assertEquals("Zero canvas size must clamp pan to Offset.Zero", Offset.Zero, clampedZero)

        val negativeSize = Size(-100f, -100f)
        val clampedNegative = engine.clampPan(Offset(50f, 50f), negativeSize, 200f, 1.0f)
        assertEquals("Negative canvas size must clamp pan to Offset.Zero", Offset.Zero, clampedNegative)

        val nanPan = Offset(Float.NaN, Float.NaN)
        val clampedNan = engine.clampPan(nanPan, Size(1000f, 1000f), 400f, 1.0f)
        assertEquals(0f, clampedNan.x, 0.001f)
        assertEquals(0f, clampedNan.y, 0.001f)
    }

    @Test
    fun testExtremeSignalRssi_handlesUnboundedValuesGracefully() {
        // Test absurdly strong, weak, and corrupted integer RSSI values
        val clientPositiveRssi = createClient(mac = "e1", signalDbm = 30) // impossible positive RSSI
        val clientExtremeWeak = createClient(mac = "e2", signalDbm = -150)
        val clientNegativeInfinity = createClient(mac = "e3", signalDbm = Int.MIN_VALUE)
        val clientPositiveInfinity = createClient(mac = "e4", signalDbm = Int.MAX_VALUE)

        val nodes = engine.computeNodes(
            listOf(clientPositiveRssi, clientExtremeWeak, clientNegativeInfinity, clientPositiveInfinity),
            standardGeometry
        )

        assertEquals(4, nodes.size)
        nodes.forEach { node ->
            assertFalse("World X coordinate must not be NaN", node.worldPosition.x.isNaN())
            assertFalse("World Y coordinate must not be NaN", node.worldPosition.y.isNaN())
            assertFalse("Screen X must not be NaN", node.screenPosition.x.isNaN())
            assertFalse("Screen Y must not be NaN", node.screenPosition.y.isNaN())

            val dist = distance(Offset.Zero, node.worldPosition)
            assertTrue("Calculated radius must be finite and positive: $dist", dist > 0f && dist.isFinite())
            assertTrue("Radius must not exceed max boundary + reasonable margin", dist <= standardGeometry.maxRadius * 1.5f)
        }
    }

    @Test
    fun testZeroCanvasDimensions_defensiveHandling() {
        // Zero dimensions canvas
        val zeroGeom = engine.calculateGeometry(Size(0f, 0f))
        assertEquals(Offset.Zero, zeroGeom.center)
        assertEquals(0f, zeroGeom.maxRadius, 0.001f)
        assertEquals(0f, zeroGeom.tierRadii[BandTier.BAND_5GHZ]!!, 0.001f)

        // Negative dimensions canvas
        val negGeom = engine.calculateGeometry(Size(-500f, 500f))
        assertEquals(Offset.Zero, negGeom.center)
        assertEquals(0f, negGeom.maxRadius, 0.001f)

        // Compute nodes with zero geometry must not crash or output NaN
        val client = createClient()
        val nodesZero = engine.computeNodes(listOf(client), zeroGeom)
        assertEquals(1, nodesZero.size)
        assertEquals(0f, nodesZero.first().worldPosition.x, 0.001f)
        assertEquals(0f, nodesZero.first().worldPosition.y, 0.001f)
        assertEquals(0f, nodesZero.first().screenPosition.x, 0.001f)
        assertEquals(0f, nodesZero.first().screenPosition.y, 0.001f)
    }

    // =========================================================================
    // TIER 3: CROSS-FEATURE COMBINATIONS
    // =========================================================================

    @Test
    fun testDenseNetwork_30PlusDevices_collisionAvoidanceMaintainsMinimumDistance() {
        // Requirement R4: Dense network (30+ devices) with collision avoidance maintaining >= 24px spacing
        // Create 36 clients: 16 on 2.4GHz, 12 on 5GHz, 4 on LAN, 4 on Guest
        val clients = mutableListOf<ClientInfo>()

        for (i in 1..16) {
            clients.add(createClient(mac = "2G_$i", hostname = "IoT-Device-$i", connectionType = "2.4GHz", signalDbm = -60))
        }
        for (i in 1..12) {
            clients.add(createClient(mac = "5G_$i", hostname = "Phone-Laptop-$i", connectionType = "5GHz", signalDbm = -55))
        }
        for (i in 1..4) {
            clients.add(createClient(mac = "LAN_$i", hostname = "Workstation-$i", connectionType = "LAN", signalDbm = 0))
        }
        for (i in 1..4) {
            clients.add(createClient(mac = "Guest_$i", hostname = "Guest-Device-$i", connectionType = "Guest", isIsolated = true))
        }

        assertEquals(36, clients.size)

        val nodes = engine.computeNodes(clients, standardGeometry, zoom = 1.0f)
        assertEquals(36, nodes.size)

        // Verify that every single pair (i, j) where i != j maintains >= MIN_NODE_SPACING_PX (24px)
        var minDistanceFound = Float.MAX_VALUE
        var closestPair = Pair("", "")

        for (i in 0 until nodes.size) {
            for (j in i + 1 until nodes.size) {
                val d = distance(nodes[i].screenPosition, nodes[j].screenPosition)
                if (d < minDistanceFound) {
                    minDistanceFound = d
                    closestPair = Pair(nodes[i].client.mac, nodes[j].client.mac)
                }
                assertTrue(
                    "Nodes ${nodes[i].client.mac} and ${nodes[j].client.mac} too close ($d px < 24 px minimum spacing)",
                    d >= RadarTopologyEngine.MIN_NODE_SPACING_PX
                )
            }
        }

        assertTrue("Minimum node distance in dense network must be >= 24px: found $minDistanceFound px between $closestPair", minDistanceFound >= 24f)
    }

    @Test
    fun testDenseNetwork_interleavedRadialStaggering() {
        // In a dense tier (>= 6 clients), adjacent nodes alternate radial staggering (+16px and -16px)
        val clients = (1..8).map {
            createClient(mac = "stagger_$it", connectionType = "2.4GHz", signalDbm = -60)
        }

        val nodes = engine.computeNodes(clients, standardGeometry)
        assertEquals(8, nodes.size)

        val radii = nodes.map { distance(Offset.Zero, it.worldPosition) }

        // Adjacent nodes must have alternating radii due to RADIAL_STAGGER_OFFSET_PX
        for (i in 0 until radii.size - 1) {
            val radialDiff = kotlin.math.abs(radii[i] - radii[i + 1])
            assertEquals(
                "Adjacent nodes in dense tier must have 32px radial difference (+16 vs -16)",
                RadarTopologyEngine.RADIAL_STAGGER_OFFSET_PX * 2f,
                radialDiff,
                0.01f
            )
        }
    }

    @Test
    fun testSimultaneousZoomAndPanTransform_invertsAccurately() {
        val center = standardGeometry.center
        val testPoints = listOf(
            Offset.Zero,
            Offset(100f, -150f),
            Offset(-240f, 320f),
            Offset(450f, 450f),
            Offset(-500f, -500f)
        )

        val transformStates = listOf(
            TransformState(zoom = 1.0f, pan = Offset.Zero),
            TransformState(zoom = 1.8f, pan = Offset(120f, -85f)),
            TransformState(zoom = 0.5f, pan = Offset(-200f, 150f)),
            TransformState(zoom = 3.0f, pan = Offset(400f, 300f)),
            TransformState(zoom = 2.45f, pan = Offset(-180f, -220f))
        )

        for (state in transformStates) {
            for (worldPoint in testPoints) {
                val screenPoint = engine.worldToScreen(worldPoint, center, state.zoom, state.pan)
                val invertedWorld = engine.screenToWorld(screenPoint, center, state.zoom, state.pan)

                assertEquals(
                    "Inverted world X must match original for zoom=${state.zoom}, pan=${state.pan}",
                    worldPoint.x,
                    invertedWorld.x,
                    0.001f
                )
                assertEquals(
                    "Inverted world Y must match original for zoom=${state.zoom}, pan=${state.pan}",
                    worldPoint.y,
                    invertedWorld.y,
                    0.001f
                )
            }
        }
    }

    @Test
    fun testSimultaneousZoomAndPanTransform_hitTestingWithActiveTransform() {
        val client = createClient(mac = "h1", connectionType = "5GHz", signalDbm = -50)
        val zoom = 2.0f
        val pan = Offset(100f, -60f)

        val nodes = engine.computeNodes(listOf(client), standardGeometry, zoom = zoom, pan = pan)
        val node = nodes.first()

        // Tap directly on the transformed node
        val hit = engine.hitTest(node.screenPosition, nodes)
        assertNotNull(hit)
        assertEquals("h1", hit!!.mac)

        // Invert screen tap back to world coordinate and verify it matches node's worldPosition
        val reconstructedWorld = engine.screenToWorld(node.screenPosition, standardGeometry.center, zoom, pan)
        assertEquals(node.worldPosition.x, reconstructedWorld.x, 0.001f)
        assertEquals(node.worldPosition.y, reconstructedWorld.y, 0.001f)
    }

    @Test
    fun testSearchAndFilterHighlights_matchesPreservePositionsWhileDimmingNonMatches() {
        val clients = listOf(
            createClient(mac = "c1", hostname = "MacBook-Pro", ip = "192.168.1.101", connectionType = "5GHz"),
            createClient(mac = "c2", hostname = "iPhone-15", ip = "192.168.1.102", connectionType = "5GHz"),
            createClient(mac = "c3", hostname = "Smart-TV", ip = "192.168.1.103", connectionType = "2.4GHz"),
            createClient(mac = "c4", hostname = "NAS-Server", ip = "192.168.1.104", connectionType = "LAN", signalDbm = 0),
            createClient(mac = "c5", hostname = "Guest-Tablet", ip = "192.168.1.105", connectionType = "Guest", isIsolated = true)
        )

        // Baseline: all highlighted
        val baseNodes = engine.computeNodes(clients, standardGeometry, searchQuery = "", selectedFilter = "All")
        baseNodes.forEach { assertTrue(it.isHighlighted) }

        // Filter by "2.4 GHz": only Smart-TV should be highlighted
        val filter2GNodes = engine.computeNodes(clients, standardGeometry, searchQuery = "", selectedFilter = "2.4 GHz")
        for (i in clients.indices) {
            val baseNode = baseNodes[i]
            val filterNode = filter2GNodes[i]

            // Spatial coordinates must be identical regardless of filtering!
            assertEquals("World coordinate must not move when filtering", baseNode.worldPosition, filterNode.worldPosition)
            assertEquals("Screen coordinate must not move when filtering", baseNode.screenPosition, filterNode.screenPosition)

            if (filterNode.client.hostname == "Smart-TV") {
                assertTrue("Smart-TV matches 2.4 GHz filter", filterNode.isHighlighted)
            } else {
                assertFalse("${filterNode.client.hostname} must be dimmed", filterNode.isHighlighted)
            }
        }

        // Search query "MacBook": only MacBook-Pro should be highlighted
        val searchNodes = engine.computeNodes(clients, standardGeometry, searchQuery = "MacBook", selectedFilter = "All")
        for (i in clients.indices) {
            val node = searchNodes[i]
            if (node.client.hostname == "MacBook-Pro") {
                assertTrue("MacBook-Pro must be highlighted", node.isHighlighted)
            } else {
                assertFalse("${node.client.hostname} must be dimmed", node.isHighlighted)
            }
        }
    }

    @Test
    fun testSearchAndFilterHighlights_searchByMacIpAndHostname() {
        val clients = listOf(
            createClient(mac = "aa:bb:cc:dd:ee:11", hostname = "Pixel-Phone", ip = "192.168.1.110"),
            createClient(mac = "aa:bb:cc:dd:ee:22", hostname = "Home-Desktop", ip = "192.168.1.120")
        )

        // Search by IP substring
        val nodesIp = engine.computeNodes(clients, standardGeometry, searchQuery = "110")
        assertTrue(nodesIp[0].isHighlighted)
        assertFalse(nodesIp[1].isHighlighted)

        // Search by MAC substring
        val nodesMac = engine.computeNodes(clients, standardGeometry, searchQuery = "ee:22")
        assertFalse(nodesMac[0].isHighlighted)
        assertTrue(nodesMac[1].isHighlighted)

        // Case-insensitive search
        val nodesCase = engine.computeNodes(clients, standardGeometry, searchQuery = "pixel")
        assertTrue(nodesCase[0].isHighlighted)
        assertFalse(nodesCase[1].isHighlighted)
    }

    // =========================================================================
    // TIER 4: REAL-WORLD OPENWRT TELEMETRY SCENARIOS
    // =========================================================================

    @Test
    fun testRealisticOpenWrtFleet_homeNetwork() {
        // Typical home network scenario:
        // - 2 phones (5GHz)
        // - 2 laptops (5GHz)
        // - 1 Smart TV (2.4GHz)
        // - 6 IoT devices (2.4GHz)
        // - 1 desktop gaming PC (LAN)
        // - 1 guest tablet (Guest isolated)
        val fleet = listOf(
            createClient(mac = "50:01", hostname = "Dad-iPhone", connectionType = "5GHz", signalDbm = -45),
            createClient(mac = "50:02", hostname = "Mom-Galaxy", connectionType = "5GHz", signalDbm = -52),
            createClient(mac = "50:03", hostname = "Work-MacBook", connectionType = "5GHz", signalDbm = -38),
            createClient(mac = "50:04", hostname = "Kid-Chromebook", connectionType = "5GHz", signalDbm = -65),
            createClient(mac = "20:01", hostname = "LivingRoom-TV", connectionType = "2.4GHz", signalDbm = -62),
            createClient(mac = "20:02", hostname = "Hue-Bridge", connectionType = "2.4GHz", signalDbm = -50),
            createClient(mac = "20:03", hostname = "Kitchen-Plug", connectionType = "2.4GHz", signalDbm = -75),
            createClient(mac = "20:04", hostname = "Thermostat", connectionType = "2.4GHz", signalDbm = -68),
            createClient(mac = "20:05", hostname = "Roborock-Vacuum", connectionType = "2.4GHz", signalDbm = -72),
            createClient(mac = "20:06", hostname = "Security-Camera", connectionType = "2.4GHz", signalDbm = -58),
            createClient(mac = "20:07", hostname = "Smart-Speaker", connectionType = "2.4GHz", signalDbm = -60),
            createClient(mac = "10:01", hostname = "Gaming-Rig", connectionType = "LAN", signalDbm = 0),
            createClient(mac = "90:01", hostname = "Guest-iPad", connectionType = "Guest", isIsolated = true, signalDbm = -55)
        )

        assertEquals(13, fleet.size)

        val nodes = engine.computeNodes(fleet, standardGeometry)
        assertEquals(13, nodes.size)

        // Tier counts
        val tierCounts = nodes.groupBy { it.tier }.mapValues { it.value.size }
        assertEquals(4, tierCounts[BandTier.BAND_5GHZ])
        assertEquals(7, tierCounts[BandTier.BAND_2GHZ])
        assertEquals(1, tierCounts[BandTier.WIRED_LAN])
        assertEquals(1, tierCounts[BandTier.GUEST_ISOLATED])

        // Verify all coordinates are finite, valid, and within canvas bounds
        nodes.forEach { node ->
            assertFalse(node.worldPosition.x.isNaN())
            assertFalse(node.worldPosition.y.isNaN())
            assertTrue(node.screenPosition.x in 0f..standardSize.width)
            assertTrue(node.screenPosition.y in 0f..standardSize.height)
        }
    }

    @Test
    fun testRealisticOpenWrtFleet_officeDenseNetwork() {
        // High density enterprise/office scenario: 38 connected devices
        val fleet = mutableListOf<ClientInfo>()

        for (i in 1..18) {
            fleet.add(createClient(mac = "corp_5g_$i", hostname = "Laptop-$i", connectionType = "5GHz", signalDbm = -40 - (i % 40)))
        }
        for (i in 1..14) {
            fleet.add(createClient(mac = "corp_2g_$i", hostname = "Phone-IoT-$i", connectionType = "2.4GHz", signalDbm = -50 - (i % 35)))
        }
        for (i in 1..4) {
            fleet.add(createClient(mac = "corp_lan_$i", hostname = "Server-$i", connectionType = "LAN", signalDbm = 0))
        }
        for (i in 1..2) {
            fleet.add(createClient(mac = "corp_guest_$i", hostname = "Visitor-$i", connectionType = "Guest", isIsolated = true, signalDbm = -60))
        }

        assertEquals(38, fleet.size)

        val nodes = engine.computeNodes(fleet, standardGeometry)
        assertEquals(38, nodes.size)

        // Hit-test every single node at its exact screen location resolves to that specific client
        nodes.forEach { node ->
            val hit = engine.hitTest(node.screenPosition, nodes)
            assertNotNull(hit)
            assertEquals(node.client.mac, hit!!.mac)
        }
    }

    @Test
    fun testQuarantinedAndBlockedClients_securityStylingFlag() {
        val normalClient = createClient(mac = "norm1", hostname = "Trusted-PC", blocked = false, isIsolated = false)
        val blockedClient = createClient(mac = "block1", hostname = "Malicious-Bot", blocked = true, isIsolated = false)
        val isolatedGuest = createClient(mac = "iso1", hostname = "Untrusted-Guest", blocked = false, isIsolated = true)
        val blockedIsolated = createClient(mac = "both1", hostname = "Quarantined", blocked = true, isIsolated = true)

        val nodes = engine.computeNodes(listOf(normalClient, blockedClient, isolatedGuest, blockedIsolated), standardGeometry)
        assertEquals(4, nodes.size)

        // Blocked flags are strictly retained on the underlying client
        assertFalse(nodes[0].client.blocked)
        assertTrue(nodes[1].client.blocked)
        assertFalse(nodes[2].client.blocked)
        assertTrue(nodes[3].client.blocked)

        // Isolation correctly maps to GUEST_ISOLATED tier
        assertEquals(BandTier.BAND_5GHZ, nodes[0].tier)
        assertEquals(BandTier.BAND_5GHZ, nodes[1].tier)
        assertEquals(BandTier.GUEST_ISOLATED, nodes[2].tier)
        assertEquals(BandTier.GUEST_ISOLATED, nodes[3].tier)
    }

    @Test
    fun testDynamicBandSwitching_stableCoordinates() {
        // Simulates a client roaming from 5GHz to 2.4GHz
        val clientInitial5G = createClient(
            mac = "roam_phone",
            hostname = "Roaming-Phone",
            connectionType = "5GHz",
            ssidName = "ArcherC6_5G",
            signalDbm = -45
        )

        val nodesInitial = engine.computeNodes(listOf(clientInitial5G), standardGeometry)
        assertEquals(BandTier.BAND_5GHZ, nodesInitial.first().tier)
        val distInitial = distance(Offset.Zero, nodesInitial.first().worldPosition)

        // Client moves away and falls back to 2.4GHz band and 2.4GHz SSID
        val clientRoamed2G = clientInitial5G.copy(
            connectionType = "2.4GHz",
            ssidName = "ArcherC6_2.4G",
            signalDbm = -75
        )

        val nodesRoamed = engine.computeNodes(listOf(clientRoamed2G), standardGeometry)
        assertEquals(BandTier.BAND_2GHZ, nodesRoamed.first().tier)
        val distRoamed = distance(Offset.Zero, nodesRoamed.first().worldPosition)

        // Roaming to 2.4GHz moves the client outwards to the 2.4GHz orbital ring
        assertTrue(
            "Roamed client distance ($distRoamed) must be greater than 5GHz distance ($distInitial)",
            distRoamed > distInitial
        )
        assertFalse(nodesRoamed.first().worldPosition.x.isNaN())
        assertFalse(nodesRoamed.first().worldPosition.y.isNaN())
    }

    @Test
    fun testAdversarialInputs_corruptedStringsAndSpecialCharacters() {
        val corruptedClient = createClient(
            mac = "CORRUPTED_MAC_FORMAT",
            ip = "999.999.999.999",
            hostname = "<script>alert('xss')</script>",
            connectionType = "5GHz-Special-\u0000\uFFFF-🚀",
            ssidName = "WiFi-5G-\"injection\"; DROP TABLE devices;--",
            signalDbm = -55
        )

        val nodes = engine.computeNodes(listOf(corruptedClient), standardGeometry)
        assertEquals(1, nodes.size)

        val node = nodes.first()
        assertEquals(BandTier.BAND_5GHZ, node.tier)
        assertFalse(node.worldPosition.x.isNaN())
        assertFalse(node.worldPosition.y.isNaN())
        assertFalse(node.screenPosition.x.isNaN())
        assertFalse(node.screenPosition.y.isNaN())

        // Search matching works safely with special characters
        val nodesFound = engine.computeNodes(listOf(corruptedClient), standardGeometry, searchQuery = "<script>")
        assertTrue(nodesFound.first().isHighlighted)

        val nodesNotFound = engine.computeNodes(listOf(corruptedClient), standardGeometry, searchQuery = "normal")
        assertFalse(nodesNotFound.first().isHighlighted)
    }
}
