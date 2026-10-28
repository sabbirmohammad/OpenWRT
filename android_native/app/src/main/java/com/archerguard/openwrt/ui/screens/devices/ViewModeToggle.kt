package com.archerguard.openwrt.ui.screens.devices

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.FormatListBulleted
import androidx.compose.material.icons.filled.Hub
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.theme.GlossyColors

/**
 * Cyberpunk segmented pill button toggling between traditional [DeviceViewMode.LIST]
 * and interactive [DeviceViewMode.TOPOLOGY] radar view.
 *
 * @param currentMode The currently active display mode.
 * @param onModeSelected Callback triggered when a mode segment is selected.
 * @param modifier Composable layout modifier.
 */
@Composable
fun ViewModeToggle(
    currentMode: DeviceViewMode,
    onModeSelected: (DeviceViewMode) -> Unit,
    modifier: Modifier = Modifier
) {
    val containerShape = RoundedCornerShape(10.dp)

    Row(
        modifier = modifier
            .clip(containerShape)
            .background(GlossyColors.BackgroundSecondary)
            .border(1.dp, GlossyColors.GlassBorderLight, containerShape)
            .padding(2.dp),
        horizontalArrangement = Arrangement.spacedBy(2.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // --- List Mode Segment ---
        val isList = currentMode == DeviceViewMode.LIST
        val listBgColor by animateColorAsState(
            targetValue = if (isList) GlossyColors.PrimaryBlue else Color.Transparent,
            animationSpec = tween(durationMillis = 200),
            label = "listBgAnim"
        )
        val listContentColor by animateColorAsState(
            targetValue = if (isList) GlossyColors.TextPrimary else GlossyColors.TextMuted,
            animationSpec = tween(durationMillis = 200),
            label = "listContentAnim"
        )

        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(listBgColor)
                .clickable { onModeSelected(DeviceViewMode.LIST) }
                .padding(horizontal = 10.dp, vertical = 6.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.FormatListBulleted,
                    contentDescription = "List View",
                    tint = listContentColor,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "List",
                    color = if (isList) GlossyColors.TextPrimary else GlossyColors.TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = if (isList) FontWeight.Bold else FontWeight.Medium
                )
            }
        }

        // --- Radar / Topology Mode Segment ---
        val isTopology = currentMode == DeviceViewMode.TOPOLOGY
        val topologyBgColor by animateColorAsState(
            targetValue = if (isTopology) GlossyColors.PrimaryBlue else Color.Transparent,
            animationSpec = tween(durationMillis = 200),
            label = "topologyBgAnim"
        )
        val topologyContentColor by animateColorAsState(
            targetValue = if (isTopology) GlossyColors.TextPrimary else GlossyColors.TextMuted,
            animationSpec = tween(durationMillis = 200),
            label = "topologyContentAnim"
        )

        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(topologyBgColor)
                .clickable { onModeSelected(DeviceViewMode.TOPOLOGY) }
                .padding(horizontal = 10.dp, vertical = 6.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Hub,
                    contentDescription = "Radar View",
                    tint = topologyContentColor,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "Radar",
                    color = if (isTopology) GlossyColors.TextPrimary else GlossyColors.TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = if (isTopology) FontWeight.Bold else FontWeight.Medium
                )
            }
        }
    }
}
