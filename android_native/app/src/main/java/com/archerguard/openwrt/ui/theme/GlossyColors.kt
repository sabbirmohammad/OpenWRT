package com.archerguard.openwrt.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Modern Executive Glossy Design Tokens for ArcherGuard.
 * Features optical depth layering (Obsidian Slate), specular rim highlights,
 * semantic radio band colors, and monospace/tabular figures for jitter-free live metrics.
 */
object GlossyColors {
    // Canvas & Layered Depth Backgrounds
    val CanvasBackground = Color(0xFF070A10) // Pure Obsidian base canvas
    val BackgroundPrimary = Color(0xFF0B0F17) // Deep Obsidian Slate
    val BackgroundSecondary = Color(0xFF101726) // Midnight Slate surface
    val BackgroundElevated = Color(0xFF182236) // Elevated card/sheet surface
    val CardElevated = Color(0xFF131D31) // Refined container surface
    val CardElevatedPressed = Color(0xFF1E2D4A) // Tactile pressed state

    // Frosted Glass Surfaces
    val GlassSurface = Color(0x12FFFFFF) // ~7% white opacity
    val GlassSurfaceHover = Color(0x1AFFFFFF) // ~10% white opacity
    val GlassSurfaceActive = Color(0x26FFFFFF) // ~15% white opacity

    // Specular Border & Light Reflection Rims
    val GlassBorderLight = Color(0x33FFFFFF) // Top-left specular rim (~20%)
    val GlassBorderDark = Color(0x0AFFFFFF) // Bottom-right shadow rim (~4%)
    val GlassDivider = Color(0x14FFFFFF)
    val RimHighlight = Color(0x3DFFFFFF) // Specular highlight rim (~24%)

    // Executive Core Accents
    val PrimaryBlue = Color(0xFF2563EB) // Royal Blue
    val LightBlue = Color(0xFF3B82F6) // Azure Light
    val SkyBlue = Color(0xFF60A5FA) // Sky Highlight

    // Semantic Radio & Network Band Accents
    val SpeedCyan = Color(0xFF06B6D4) // 5GHz High-Speed Band & Download Speed
    val Band5GHz = Color(0xFF06B6D4) // 5.0 GHz Radio
    val Band2GHz = Color(0xFF6366F1) // 2.4 GHz Long-Range Radio
    val LanGigabit = Color(0xFF10B981) // Gigabit Ethernet LAN

    // Telemetry & Status Accents
    val EmeraldMint = Color(0xFF10B981) // Positive / Connected / Healthy
    val EmeraldSoft = Color(0xFF34D399) // Soft mint glow
    val AmberWarm = Color(0xFFF59E0B) // Moderate load / Warning / Connecting
    val RoseCoral = Color(0xFFEF4444) // High load / Error / Disconnected / Blocked

    // Isolated SSID & Guest Network Accents
    val IsolatedAccent = Color(0xFFA855F7) // Amethyst Purple
    val IsolatedLight = Color(0xFFC084FC) // Bright Violet
    val IsolatedGlow = Color(0x33A855F7) // 20% specular glow
    val GuestViolet = Color(0xFF8B5CF6) // Guest Portal / Isolation

    // Typography Tokens
    val TextPrimary = Color(0xFFF8FAFC) // Polar White (High contrast)
    val TextSecondary = Color(0xFF94A3B8) // Slate Neutral
    val TextMuted = Color(0xFF64748B) // Dark Slate
    val TextTertiary = Color(0xFF475569) // Subtle hint text

    // Dynamic Gradients
    val GlassBorderGradient = Brush.linearGradient(
        colors = listOf(
            Color(0x45FFFFFF), // Top-left specular rim highlight
            Color(0x15FFFFFF),
            Color(0x06FFFFFF)  // Bottom-right shadow fade
        )
    )

    val CardGlossGradient = Brush.linearGradient(
        colors = listOf(
            Color(0x16FFFFFF),
            Color(0x08FFFFFF)
        )
    )

    val SpecularRimGradient = Brush.verticalGradient(
        colors = listOf(
            Color(0x3538BDF8), // Electric cyan/azure sheen
            Color(0x18FFFFFF),
            Color(0x05FFFFFF)
        )
    )

    val ActiveTabGlowGradient = Brush.horizontalGradient(
        colors = listOf(
            Color(0xFF2563EB),
            Color(0xFF38BDF8)
        )
    )

    // Jitter-free Monospace/Tabular Figure Typography Styles for Live Telemetry
    val TabularDisplay = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 24.sp,
        letterSpacing = (-0.5).sp,
        fontFeatureSettings = "tnum"
    )

    val TabularMetric = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 15.sp,
        fontFeatureSettings = "tnum"
    )

    val TabularCaption = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        fontFeatureSettings = "tnum"
    )
}
