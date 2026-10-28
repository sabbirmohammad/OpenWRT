package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
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
    size: Dp = 82.dp,
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
                val strokeWidth = 7.dp.toPx()

                // Background track arc (270 degrees sweep starting from 135 degrees)
                drawArc(
                    color = GlossyColors.GlassBorderDark.copy(alpha = 0.35f),
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

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.widthIn(max = size - 16.dp)
            ) {
                Text(
                    text = String.format(Locale.US, "%.0f%%", clampedVal),
                    color = GlossyColors.TextPrimary,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
                if (!subtitle.isNullOrBlank()) {
                    Text(
                        text = subtitle,
                        color = GlossyColors.TextMuted,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center
        )
    }
}
