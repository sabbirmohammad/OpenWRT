package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.archerguard.openwrt.ui.theme.GlossyColors

/**
 * Enterprise Glossy Card component featuring:
 * - Optical depth layering with frosted background
 * - Top specular hairline reflection highlight
 * - Smooth rounded corners (18dp standard)
 * - Optional ripple-enabled click handling
 */
@Composable
fun GlossyCard(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(18.dp),
    backgroundColor: Color = GlossyColors.CardElevated.copy(alpha = 0.90f),
    borderColor: Color = GlossyColors.GlassBorderLight,
    borderWidth: Dp = 1.dp,
    borderBrush: Brush? = null,
    onClick: (() -> Unit)? = null,
    showSpecularRim: Boolean = true,
    contentPadding: Dp = 16.dp,
    content: @Composable () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }

    val baseModifier = modifier
        .fillMaxWidth()
        .clip(shape)
        .then(
            if (borderBrush != null) {
                Modifier.border(borderWidth, borderBrush, shape)
            } else {
                Modifier.border(borderWidth, borderColor, shape)
            }
        )
        .background(backgroundColor)
        .then(
            if (onClick != null) {
                Modifier.clickable(
                    interactionSource = interactionSource,
                    indication = ripple(bounded = true, color = GlossyColors.LightBlue),
                    onClick = onClick
                )
            } else {
                Modifier
            }
        )

    Box(modifier = baseModifier) {
        if (showSpecularRim) {
            // Subtle top specular hairline reflection
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(
                                Color.Transparent,
                                Color(0x35FFFFFF),
                                Color(0x18FFFFFF),
                                Color.Transparent
                            )
                        )
                    )
            )
        }
        Box(modifier = Modifier.padding(contentPadding)) {
            content()
        }
    }
}
