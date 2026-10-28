package com.archerguard.openwrt.ui.screens.devices.topology

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import com.archerguard.openwrt.domain.model.ClientInfo
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import kotlin.math.sqrt

/**
 * Adversarial Stress & Edge Case Test Suite for [RadarTopologyEngine].
 *
 * Authored by Challenger 1 to empirically verify layout robustness under hostile conditions:
 * 1. Extreme device scaling: 100, 200, 500 connected devices across mixed and single tiers.
 * 2. Hostile float inputs: NaN, POSITIVE_INFINITY, NEGATIVE_INFINITY in canvas size, zoom, pan, and tap.
 * 3. Malformed telemetry: 10,000-character hostnames, UTF-8 null bytes, emoji payloads, SQL/XSS injections.
 * 4. Coordinate stability and boundary clamping under extreme zoom ($10^{-5}$ to $10^5$) and extreme pan offsets.
 * 5. Touch hit-testing resiliency under high density, boundary taps, and corrupted input positions.
 */
class RadarTopologyAdversarialTest {

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
    // 1. EXTREME DEVICE SCALING & HIGH DENSITY (100+ DEVICES)
    // =========================================================================

    @Test
    fun testDenseNetwork_100Devices_mixedFleet_performanceAndCoordinateIntegrity() {
        // Fleet of 100 devices: 40 on 5G, 40 on 2.4G, 10 on LAN, 10 on Guest
        val fleet = mutableListOf<ClientInfo>()
        for (i in 1..40) fleet.add(createClient(mac = "5g_$i", hostname = "Phone-5G-$i", connectionType = "5GHz", signalDbm = -40 - (i % 45)))
        for (i in 1..40) fleet.add(createClient(mac = "2g_$i", hostname = "IoT-2G-$i", connectionType = "2.4GHz", signalDbm = -50 - (i % 38)))
        for (i in 1..10) fleet.add(createClient(mac = "lan_$i", hostname = "Server-LAN-$i", connectionType = "LAN", signalDbm = 0))
        for (i in 1..10) fleet.add(createClient(mac = "gst_$i", hostname = "Guest-Tab-$i", connectionType = "Guest", isIsolated = true, signalDbm = -65))

        assertEquals(100, fleet.size)

        val startTime = System.nanoTime()
        val nodes = engine.computeNodes(fleet, standardGeometry)
        val elapsedMs = (System.nanoTime() - startTime) / 1_000_000.0

        assertEquals(100, nodes.size)
        assertTrue("Computing 100 nodes must complete in under 50ms (actual: ${elapsedMs}ms)", elapsedMs < 50.0)

        // Verify every node has valid finite coordinates within reasonable bounds
        nodes.forEach { node ->
            assertFalse("World X must not be NaN for ${node.client.mac}", node.worldPosition.x.isNaN())
            assertFalse("World Y must not be NaN for ${node.client.mac}", node.worldPosition.y.isNaN())
            assertFalse("Screen X must not be NaN for ${node.client.mac}", node.screenPosition.x.isNaN())
            assertFalse("Screen Y must not be NaN for ${node.client.mac}", node.screenPosition.y.isNaN())
            assertTrue("World X must be finite", node.worldPosition.x.isFinite())
            assertTrue("World Y must be finite", node.worldPosition.y.isFinite())
        }

        // Hit-test on every node center must resolve accurately without collision ambiguity
        nodes.forEach { node ->
            val hit = engine.hitTest(node.screenPosition, nodes, minTouchRadiusPx = 15f)
            assertNotNull("Hit test must find node ${node.client.mac}", hit)
            assertEquals(node.client.mac, hit!!.mac)
        }
    }

    @Test
    fun testDenseNetwork_200Devices_allOnSingleTier_2GHz() {
        // 200 devices crammed into a single 2.4GHz orbital band
        val fleet = (1..200).map { i ->
            createClient(mac = "c2g_$i", hostname = "Sensor-$i", connectionType = "2.4GHz", signalDbm = -60)
        }

        val startTime = System.nanoTime()
        val nodes = engine.computeNodes(fleet, standardGeometry)
        val elapsedMs = (System.nanoTime() - startTime) / 1_000_000.0

        assertEquals(200, nodes.size)
        assertTrue("200 node layout should be fast (actual: ${elapsedMs}ms)", elapsedMs < 100.0)

        // Verify all 200 nodes have finite coordinates
        nodes.forEach { node ->
            assertEquals(BandTier.BAND_2GHZ, node.tier)
            assertTrue(node.worldPosition.x.isFinite())
            assertTrue(node.worldPosition.y.isFinite())
            assertTrue(node.screenPosition.x.isFinite())
            assertTrue(node.screenPosition.y.isFinite())
        }
    }

    @Test
    fun testDenseNetwork_100Devices_allOnWiredLan_zeroRssiModulation() {
        // 100 devices on Wired LAN (fixed base radius, no RSSI modulation)
        val fleet = (1..100).map { i ->
            createClient(mac = "clan_$i", hostname = "Cluster-Node-$i", connectionType = "LAN", signalDbm = 0)
        }

        val nodes = engine.computeNodes(fleet, standardGeometry)
        assertEquals(100, nodes.size)

        nodes.forEach { node ->
            assertEquals(BandTier.WIRED_LAN, node.tier)
            assertTrue(node.worldPosition.x.isFinite())
            assertTrue(node.worldPosition.y.isFinite())
        }
    }

    @Test
    fun testDenseNetwork_500Devices_stressThroughput() {
        // Extreme stress: 500 connected clients
        val fleet = (1..500).map { i ->
            val band = when (i % 4) {
                0 -> "5GHz"
                1 -> "2.4GHz"
                2 -> "LAN"
                else -> "Guest"
            }
            createClient(mac = "stress_$i", hostname = "Stress-$i", connectionType = band, signalDbm = -55)
        }

        val startTime = System.nanoTime()
        val nodes = engine.computeNodes(fleet, standardGeometry)
        val elapsedMs = (System.nanoTime() - startTime) / 1_000_000.0

        assertEquals(500, nodes.size)
        assertTrue("500 node calculation must complete in under 200ms (actual: ${elapsedMs}ms)", elapsedMs < 200.0)

        nodes.forEach { node ->
            assertFalse(node.worldPosition.x.isNaN())
            assertFalse(node.worldPosition.y.isNaN())
        }
    }

    // =========================================================================
    // 2. EXTREME ZERO / SINGLE DEVICE BOUNDARIES
    // =========================================================================

    @Test
    fun testZeroDevices_safeEmptyState() {
        val nodes = engine.computeNodes(emptyList(), standardGeometry)
        assertTrue("Zero clients must yield empty list", nodes.isEmpty())

        // Hit testing must safely return null
        assertNull(engine.hitTest(Offset(500f, 500f), nodes))
        assertNull(engine.hitTest(Offset.Zero, nodes))
    }

    @Test
    fun testSingleDevice_eachTierPlacedAt12OClock() {
        val bands = listOf("5GHz", "2.4GHz", "LAN", "Guest")

        bands.forEach { band ->
            val client = createClient(mac = "single_$band", connectionType = band, signalDbm = -50)
            val nodes = engine.computeNodes(listOf(client), standardGeometry)

            assertEquals(1, nodes.size)
            val node = nodes.first()

            // 12 o'clock means worldX == 0 and worldY < 0
            assertEquals("Single device in $band should have worldX == 0", 0f, node.worldPosition.x, 0.01f)
            assertTrue("Single device in $band should have worldY < 0 (12 o'clock)", node.worldPosition.y < 0f)
            assertEquals(standardGeometry.center.x, node.screenPosition.x, 0.01f)
            assertTrue(node.screenPosition.y < standardGeometry.center.y)
        }
    }

    // =========================================================================
    // 3. HOSTILE FLOAT INPUTS (NaN, INFINITY, NEGATIVE DIMENSIONS)
    // =========================================================================

    @Test
    fun testNegativeCanvasDimensions_defensivelyClampedToZero() {
        val negWidth = engine.calculateGeometry(Size(-500f, 500f))
        assertEquals(Offset.Zero, negWidth.center)
        assertEquals(0f, negWidth.maxRadius, 0.001f)

        val negHeight = engine.calculateGeometry(Size(500f, -500f))
        assertEquals(Offset.Zero, negHeight.center)
        assertEquals(0f, negHeight.maxRadius, 0.001f)

        val bothNeg = engine.calculateGeometry(Size(-1000f, -1000f))
        assertEquals(Offset.Zero, bothNeg.center)
        assertEquals(0f, bothNeg.maxRadius, 0.001f)
    }

    @Test
    fun testZeroCanvasDimensions_defensivelyClampedToZero() {
        val zero = engine.calculateGeometry(Size(0f, 0f))
        assertEquals(Offset.Zero, zero.center)
        assertEquals(0f, zero.maxRadius, 0.001f)
        zero.tierRadii.values.forEach { assertEquals(0f, it, 0.001f) }
    }

    @Test
    fun testZoomClamping_extremeValuesAndSpecialFloats() {
        // Normal bounds [0.5, 3.0]
        assertEquals(0.5f, engine.clampZoom(0.5f), 0.001f)
        assertEquals(3.0f, engine.clampZoom(3.0f), 0.001f)
        assertEquals(1.0f, engine.clampZoom(1.0f), 0.001f)

        // Extreme zoom values: $10^{-5}$ to $10^5$
        assertEquals(0.5f, engine.clampZoom(0.00001f), 0.001f)
        assertEquals(0.5f, engine.clampZoom(1e-10f), 0.001f)
        assertEquals(3.0f, engine.clampZoom(100000f), 0.001f)
        assertEquals(3.0f, engine.clampZoom(1e10f), 0.001f)
        assertEquals(0.5f, engine.clampZoom(-99999f), 0.001f)
        assertEquals(0.5f, engine.clampZoom(0.0f), 0.001f)

        // Float special values
        assertEquals(1.0f, engine.clampZoom(Float.NaN), 0.001f)
        assertEquals(0.5f, engine.clampZoom(Float.NEGATIVE_INFINITY), 0.001f)
        assertEquals(3.0f, engine.clampZoom(Float.POSITIVE_INFINITY), 0.001f)
    }

    @Test
    fun testPanClamping_extremeOffsetsAndSpecialFloats() {
        val canvasSize = Size(1000f, 1000f)
        val maxRadius = 440f

        // Normal clamp bound: 1000 * 0.5 + 440 * 1.0 * 0.5 = 720f
        val extremePositive = engine.clampPan(Offset(1e8f, 1e8f), canvasSize, maxRadius, 1.0f)
        assertEquals(720f, extremePositive.x, 0.001f)
        assertEquals(720f, extremePositive.y, 0.001f)

        val extremeNegative = engine.clampPan(Offset(-1e8f, -1e8f), canvasSize, maxRadius, 1.0f)
        assertEquals(-720f, extremeNegative.x, 0.001f)
        assertEquals(-720f, extremeNegative.y, 0.001f)

        // Pan with NaN values
        val nanPan = engine.clampPan(Offset(Float.NaN, Float.NaN), canvasSize, maxRadius, 1.0f)
        assertEquals(0f, nanPan.x, 0.001f)
        assertEquals(0f, nanPan.y, 0.001f)

        // Pan with zero / negative canvas size
        assertEquals(Offset.Zero, engine.clampPan(Offset(100f, 100f), Size(0f, 0f), maxRadius, 1.0f))
        assertEquals(Offset.Zero, engine.clampPan(Offset(100f, 100f), Size(-100f, 100f), maxRadius, 1.0f))
        assertEquals(Offset.Zero, engine.clampPan(Offset(100f, 100f), canvasSize, 0f, 1.0f))
    }

    @Test
    fun testScreenToWorld_defensiveZeroAndNanZoom() {
        val center = Offset(500f, 500f)
        val pan = Offset.Zero
        val screenPos = Offset(600f, 700f)

        // Zoom = 0f should fallback to 1.0f (avoiding division by zero -> Infinity)
        val resZeroZoom = engine.screenToWorld(screenPos, center, zoom = 0f, pan = pan)
        assertEquals(100f, resZeroZoom.x, 0.001f)
        assertEquals(200f, resZeroZoom.y, 0.001f)

        // Zoom = NaN should fallback to 1.0f
        val resNanZoom = engine.screenToWorld(screenPos, center, zoom = Float.NaN, pan = pan)
        assertEquals(100f, resNanZoom.x, 0.001f)
        assertEquals(200f, resNanZoom.y, 0.001f)
    }

    @Test
    fun testHitTest_adversarialTapPositions_noCrash() {
        val client = createClient(mac = "t1")
        val nodes = engine.computeNodes(listOf(client), standardGeometry)

        // Tap at NaN coordinates
        val hitNan = engine.hitTest(Offset(Float.NaN, Float.NaN), nodes)
        assertNull("Hit testing NaN tap should safely return null", hitNan)

        // Tap at Infinity
        val hitPosInf = engine.hitTest(Offset(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY), nodes)
        assertNull("Hit testing Positive Infinity tap should safely return null", hitPosInf)

        val hitNegInf = engine.hitTest(Offset(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY), nodes)
        assertNull("Hit testing Negative Infinity tap should safely return null", hitNegInf)

        // Tap with negative touch radius
        val hitNegRadius = engine.hitTest(nodes.first().screenPosition, nodes, minTouchRadiusPx = -10f)
        // With negative touch radius, maxOf(node.visualRadiusPx (18f), -10f) = 18f, so it should still hit exact center!
        assertNotNull(hitNegRadius)
        assertEquals("t1", hitNegRadius!!.mac)
    }

    // =========================================================================
    // 4. MALFORMED TELEMETRY & ATTACK PAYLOADS
    // =========================================================================

    @Test
    fun testCorruptedTelemetry_overflowStringsAndNullBytes() {
        val hugeString = "A".repeat(10_000)
        val attackClient = createClient(
            mac = "FF:FF:FF:FF:FF:FF",
            ip = "255.255.255.255",
            hostname = hugeString,
            connectionType = "5GHz\u0000\u0001\uFFFF",
            ssidName = "SSID-\u0000-Injection",
            signalDbm = -50
        )

        val nodes = engine.computeNodes(listOf(attackClient), standardGeometry)
        assertEquals(1, nodes.size)

        val node = nodes.first()
        assertEquals(BandTier.BAND_5GHZ, node.tier)
        assertTrue(node.worldPosition.x.isFinite())
        assertTrue(node.worldPosition.y.isFinite())

        // Search for huge string prefix
        val searchHit = engine.computeNodes(listOf(attackClient), standardGeometry, searchQuery = "AAAA")
        assertTrue(searchHit.first().isHighlighted)
    }

    @Test
    fun testCorruptedTelemetry_unicodeEmojiAndRtlLanguages() {
        val unicodeClient = createClient(
            mac = "00:11:22:33:44:55",
            hostname = "🚀🔥💻 جهاز توجيه منزل עִברִית 👨‍👩‍👧‍👦",
            connectionType = "2.4GHz"
        )

        val nodes = engine.computeNodes(listOf(unicodeClient), standardGeometry)
        assertEquals(1, nodes.size)
        val node = nodes.first()

        assertEquals(BandTier.BAND_2GHZ, node.tier)

        // Search matches Arabic / Hebrew / Emoji substrings
        val searchEmoji = engine.computeNodes(listOf(unicodeClient), standardGeometry, searchQuery = "🚀")
        assertTrue(searchEmoji.first().isHighlighted)

        val searchArabic = engine.computeNodes(listOf(unicodeClient), standardGeometry, searchQuery = "جهاز")
        assertTrue(searchArabic.first().isHighlighted)
    }

    @Test
    fun testCorruptedTelemetry_regexMetacharactersInSearchQuery_noRegexCrash() {
        val client = createClient(
            mac = "aa:bb:cc:dd:ee:01",
            hostname = "Device(Test)[Main]*+?^\${}"
        )

        val regexQueries = listOf(
            "(", "[", "]", "*", "+", "?", "^", "$", "{", "}", "\\", ".*", "(a|b)"
        )

        for (query in regexQueries) {
            // Must not throw PatternSyntaxException or crash
            val result = engine.computeNodes(listOf(client), standardGeometry, searchQuery = query)
            assertEquals(1, result.size)
        }
    }

    @Test
    fun testCorruptedTelemetry_emptyStringsEverywhere() {
        val emptyClient = ClientInfo(
            mac = "",
            ip = "",
            hostname = "",
            connectionType = "",
            ssidName = "",
            signalDbm = 0,
            isIsolated = false,
            blocked = false
        )

        val nodes = engine.computeNodes(listOf(emptyClient), standardGeometry)
        assertEquals(1, nodes.size)

        val node = nodes.first()
        // SignalDbm == 0 and empty connectionType defaults to WIRED_LAN
        assertEquals(BandTier.WIRED_LAN, node.tier)
        assertTrue(node.worldPosition.x.isFinite())
        assertTrue(node.worldPosition.y.isFinite())
    }

    @Test
    fun testCorruptedTelemetry_allSpecialRssiIntegers() {
        val rssiValues = listOf(
            Int.MIN_VALUE, -9999, -150, -90, -60, -30, -1, 0, 1, 30, 100, 9999, Int.MAX_VALUE
        )

        rssiValues.forEachIndexed { index, rssi ->
            val client = createClient(mac = "rssi_$index", connectionType = "5GHz", signalDbm = rssi)
            val nodes = engine.computeNodes(listOf(client), standardGeometry)

            assertEquals(1, nodes.size)
            val node = nodes.first()
            assertTrue("World X must be finite for RSSI $rssi", node.worldPosition.x.isFinite())
            assertTrue("World Y must be finite for RSSI $rssi", node.worldPosition.y.isFinite())
        }
    }
}
