package com.archerguard.openwrt.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = GlossyColors.LightBlue,
    onPrimary = GlossyColors.TextPrimary,
    primaryContainer = GlossyColors.PrimaryBlue,
    secondary = GlossyColors.EmeraldMint,
    onSecondary = GlossyColors.BackgroundPrimary,
    background = GlossyColors.BackgroundPrimary,
    onBackground = GlossyColors.TextPrimary,
    surface = GlossyColors.BackgroundSecondary,
    onSurface = GlossyColors.TextPrimary,
    surfaceVariant = GlossyColors.BackgroundElevated,
    onSurfaceVariant = GlossyColors.TextSecondary,
    error = GlossyColors.RoseCoral
)

@Composable
fun ArcherGuardTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content
    )
}
