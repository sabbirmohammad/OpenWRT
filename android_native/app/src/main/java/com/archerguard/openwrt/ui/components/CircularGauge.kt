package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.theme.GlossyColors
import java.util.Locale

@Composable
fun CircularGauge(
    value: Double,
    label: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    size: Dp = 96.dp,
    activeColor: Color? = null
) {
    val clampedVal = value.coerceIn(0.0, 100.0)
    val color = activeColor ?: when {
        clampedVal < 60.0 -> GlossyColors.EmeraldMint
        clampedVal < 85.0 -> GlossyColors.AmberWarm
        else -> GlossyColors.RoseCoral
    }

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier.size(size),
            contentAlignment = Alignment.Center
        ) {
            Canvas(modifier = Modifier.size(size)) {
                val strokeWidth = 8.dp.toPx()
                val radius = (this.size.minDimension - strokeWidth) / 2f
                val centerOffset = center

                // Background track arc (270 degrees sweep starting from 135 degrees)
                drawArc(
                    color = GlossyColors.GlassBorderDark.copy(alpha = 0.25f),
                    startAngle = 135f,
                    sweepAngle = 270f,
                    useCenter = false,
                    style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
                )

                // Active progress arc
                val sweep = (clampedVal / 100.0 * 270f).toFloat()
                if (sweep > 0f) {
                    drawArc(
                        color = color,
                        startAngle = 135f,
                        sweepAngle = sweep,
                        useCenter = false,
                        style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
                    )
                }
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = String.format(Locale.US, "%.0f%%", clampedVal),
                    color = GlossyColors.TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold
                )
                if (subtitle != null) {
                    Text(
                        text = subtitle,
                        color = GlossyColors.TextMuted,
                        fontSize = 10.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium
        )
    }
}
