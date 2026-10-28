package com.archerguard.openwrt.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

object GlossyColors {
    // Canvas & Backgrounds
    val BackgroundPrimary = Color(0xFF0B0F17) // Deep Obsidian Slate
    val BackgroundSecondary = Color(0xFF111726) // Midnight Slate
    val BackgroundElevated = Color(0xFF182032) // Elevated sheet

    // Frosted Glass Surfaces
    val GlassSurface = Color(0x12FFFFFF) // ~7% white opacity
    val GlassSurfaceHover = Color(0x1AFFFFFF) // ~10% white opacity
    val GlassSurfaceActive = Color(0x24FFFFFF) // ~14% white opacity

    // Specular Border & Light Reflection Rims
    val GlassBorderLight = Color(0x33FFFFFF) // Top-left specular rim (~20%)
    val GlassBorderDark = Color(0x0AFFFFFF) // Bottom-right shadow rim (~4%)
    val GlassDivider = Color(0x14FFFFFF)

    // Accents
    val PrimaryBlue = Color(0xFF2563EB) // Royal Blue
    val LightBlue = Color(0xFF3B82F6) // Azure Light
    val SkyBlue = Color(0xFF60A5FA) // Sky Highlight

    val EmeraldMint = Color(0xFF10B981) // Positive / Connected
    val EmeraldSoft = Color(0xFF34D399)

    val AmberWarm = Color(0xFFF59E0B) // Moderate load / Warning
    val RoseCoral = Color(0xFFEF4444) // High load / Error / Disconnected

    val IsolatedAccent = Color(0xFFA855F7) // Amethyst Purple
    val IsolatedLight = Color(0xFFC084FC) // Bright Violet
    val IsolatedGlow = Color(0x33A855F7) // 20% specular glow

    // Typography
    val TextPrimary = Color(0xFFF8FAFC) // Polar White
    val TextSecondary = Color(0xFF94A3B8) // Slate Neutral
    val TextMuted = Color(0xFF64748B) // Dark Slate

    // Gradients
    val GlassBorderGradient = Brush.linearGradient(
        colors = listOf(
            Color(0x40FFFFFF),
            Color(0x12FFFFFF),
            Color(0x05FFFFFF)
        )
    )

    val CardGlossGradient = Brush.linearGradient(
        colors = listOf(
            Color(0x14FFFFFF),
            Color(0x08FFFFFF)
        )
    )
}
