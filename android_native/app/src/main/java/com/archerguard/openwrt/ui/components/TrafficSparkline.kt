package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Enterprise Live Telemetry Sparkline.
 * Features:
 * - Smooth cubic Bézier wave interpolation
 * - Gradient area fill below the curve
 * - Specular leading-edge dot indicator
 */
@Composable
fun TrafficSparkline(
    data: List<Double>,
    color: Color,
    modifier: Modifier = Modifier,
    height: Dp = 32.dp
) {
    Canvas(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
    ) {
        if (size.width <= 0f || size.height <= 0f) return@Canvas

        if (data.isEmpty() || data.size == 1) {
            drawLine(
                color = color.copy(alpha = 0.25f),
                start = Offset(0f, size.height * 0.85f),
                end = Offset(size.width, size.height * 0.85f),
                strokeWidth = 2.dp.toPx()
            )
            return@Canvas
        }

        val maxVal = (data.maxOrNull() ?: 1.0).coerceAtLeast(1.0)
        val stepX = size.width / (data.size - 1).coerceAtLeast(1)

        val linePath = Path()
        val fillPath = Path()

        var prevX = 0f
        var prevY = 0f
        var lastX = 0f
        var lastY = 0f

        data.forEachIndexed { index, value ->
            val x = index * stepX
            val normalizedY = (1.0 - (value / maxVal)).toFloat().coerceIn(0.08f, 0.90f)
            val y = normalizedY * size.height

            if (index == 0) {
                linePath.moveTo(x, y)
                fillPath.moveTo(x, size.height)
                fillPath.lineTo(x, y)
            } else {
                // Cubic Bézier smoothing
                val cx1 = prevX + (x - prevX) * 0.45f
                val cy1 = prevY
                val cx2 = prevX + (x - prevX) * 0.55f
                val cy2 = y
                linePath.cubicTo(cx1, cy1, cx2, cy2, x, y)
                fillPath.cubicTo(cx1, cy1, cx2, cy2, x, y)
            }
            prevX = x
            prevY = y
            lastX = x
            lastY = y
        }

        fillPath.lineTo(size.width, size.height)
        fillPath.close()

        // Gradient area fill
        drawPath(
            path = fillPath,
            brush = Brush.verticalGradient(
                colors = listOf(
                    color.copy(alpha = 0.32f),
                    color.copy(alpha = 0.08f),
                    Color.Transparent
                )
            )
        )

        // Smooth contour line
        drawPath(
            path = linePath,
            color = color,
            style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round)
        )

        // Leading edge glowing dot
        drawCircle(
            color = color.copy(alpha = 0.35f),
            radius = 4.dp.toPx(),
            center = Offset(lastX, lastY)
        )
        drawCircle(
            color = Color.White,
            radius = 2.dp.toPx(),
            center = Offset(lastX, lastY)
        )
    }
}
