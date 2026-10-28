package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun GlossyCard(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
    backgroundColor: Color = GlossyColors.BackgroundSecondary.copy(alpha = 0.85f),
    borderColor: Color = GlossyColors.GlassBorderLight,
    borderWidth: Dp = 1.dp,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .clip(shape)
            .border(borderWidth, borderColor, shape)
            .background(backgroundColor)
            .padding(16.dp)
    ) {
        content()
    }
}
