package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

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

        if (data.isEmpty()) {
            drawLine(
                color = color.copy(alpha = 0.2f),
                start = androidx.compose.ui.geometry.Offset(0f, size.height * 0.8f),
                end = androidx.compose.ui.geometry.Offset(size.width, size.height * 0.8f),
                strokeWidth = 2.dp.toPx()
            )
            return@Canvas
        }

        val maxVal = (data.maxOrNull() ?: 1.0).coerceAtLeast(1.0)
        val stepX = size.width / (data.size - 1).coerceAtLeast(1)

        val linePath = Path()
        val fillPath = Path()

        data.forEachIndexed { index, value ->
            val x = index * stepX
            val normalizedY = (1.0 - (value / maxVal)).toFloat().coerceIn(0.05f, 0.95f)
            val y = normalizedY * size.height

            if (index == 0) {
                linePath.moveTo(x, y)
                fillPath.moveTo(x, size.height)
                fillPath.lineTo(x, y)
            } else {
                linePath.lineTo(x, y)
                fillPath.lineTo(x, y)
            }
        }

        fillPath.lineTo(size.width, size.height)
        fillPath.close()

        // Draw smooth gradient fill below line
        drawPath(
            path = fillPath,
            brush = Brush.verticalGradient(
                colors = listOf(
                    color.copy(alpha = 0.35f),
                    color.copy(alpha = 0.0f)
                )
            )
        )

        // Draw line on top
        drawPath(
            path = linePath,
            color = color,
            style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round)
        )
    }
}
