package com.archerguard.openwrt.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Devices
import androidx.compose.material.icons.filled.Hub
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material.icons.outlined.Hub
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material.icons.outlined.Wifi
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.theme.GlossyColors

data class NavigationTabItem(
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val badgeCount: Int? = null
)

@Composable
fun GlossyBottomBar(
    currentIndex: Int,
    onTabSelected: (Int) -> Unit,
    clientCount: Int = 0,
    modifier: Modifier = Modifier
) {
    val haptic = LocalHapticFeedback.current

    val items = listOf(
        NavigationTabItem("Dashboard", Icons.Filled.Dashboard, Icons.Outlined.Dashboard),
        NavigationTabItem("Devices", Icons.Filled.Devices, Icons.Outlined.Devices, if (clientCount > 0) clientCount else null),
        NavigationTabItem("Wireless", Icons.Filled.Wifi, Icons.Outlined.Wifi),
        NavigationTabItem("Network", Icons.Filled.Hub, Icons.Outlined.Hub),
        NavigationTabItem("Menu", Icons.Filled.Menu, Icons.Outlined.Menu)
    )

    // Outer container honoring navigation bars inset with centered responsive width
    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 12.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .widthIn(max = 520.dp),
            shape = RoundedCornerShape(26.dp),
            color = GlossyColors.BackgroundSecondary.copy(alpha = 0.92f),
            border = BorderStroke(
                width = 1.dp,
                brush = Brush.verticalGradient(
                    colors = listOf(
                        GlossyColors.LightBlue.copy(alpha = 0.35f),
                        GlossyColors.GlassBorderLight,
                        GlossyColors.GlassBorderDark
                    )
                )
            ),
            shadowElevation = 14.dp
        ) {
            Box {
                // Top specular gradient hairline reflection
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    GlossyColors.SkyBlue.copy(alpha = 0.40f),
                                    GlossyColors.LightBlue.copy(alpha = 0.65f),
                                    GlossyColors.SkyBlue.copy(alpha = 0.40f),
                                    Color.Transparent
                                )
                            )
                        )
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 6.dp, vertical = 5.dp),
                    horizontalArrangement = Arrangement.SpaceAround,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    items.forEachIndexed { index, item ->
                        val isSelected = currentIndex == index
                        val interactionSource = remember { MutableInteractionSource() }

                        // Animated state variables for ultra-smooth UI transitions
                        val pillBgColor by animateColorAsState(
                            targetValue = if (isSelected) GlossyColors.LightBlue.copy(alpha = 0.16f) else Color.Transparent,
                            animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
                            label = "pillBgColor"
                        )
                        val pillBorderColor by animateColorAsState(
                            targetValue = if (isSelected) GlossyColors.LightBlue.copy(alpha = 0.32f) else Color.Transparent,
                            animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
                            label = "pillBorderColor"
                        )
                        val iconTint by animateColorAsState(
                            targetValue = if (isSelected) GlossyColors.SkyBlue else GlossyColors.TextMuted,
                            animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
                            label = "iconTint"
                        )
                        val labelColor by animateColorAsState(
                            targetValue = if (isSelected) GlossyColors.TextPrimary else GlossyColors.TextMuted,
                            animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
                            label = "labelColor"
                        )
                        val iconScale by animateFloatAsState(
                            targetValue = if (isSelected) 1.12f else 1.0f,
                            animationSpec = spring(dampingRatio = 0.65f, stiffness = Spring.StiffnessMediumLow),
                            label = "iconScale"
                        )
                        val indicatorWidth by animateDpAsState(
                            targetValue = if (isSelected) 14.dp else 0.dp,
                            animationSpec = spring(dampingRatio = 0.7f, stiffness = Spring.StiffnessMediumLow),
                            label = "indicatorWidth"
                        )

                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(18.dp))
                                .background(pillBgColor)
                                .border(width = 1.dp, color = pillBorderColor, shape = RoundedCornerShape(18.dp))
                                .clickable(
                                    interactionSource = interactionSource,
                                    indication = ripple(bounded = true, color = GlossyColors.LightBlue),
                                    onClick = {
                                        if (!isSelected) {
                                            haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                                            onTabSelected(index)
                                        }
                                    }
                                )
                                .padding(vertical = 5.dp, horizontal = 2.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            // Centered icon container with externally offset badge
                            Box(
                                modifier = Modifier.size(28.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = if (isSelected) item.selectedIcon else item.unselectedIcon,
                                    contentDescription = item.label,
                                    tint = iconTint,
                                    modifier = Modifier
                                        .size(22.dp)
                                        .graphicsLayer {
                                            scaleX = iconScale
                                            scaleY = iconScale
                                        }
                                )

                                // Active Client Count Badge - offset outside icon bounding box
                                if (item.badgeCount != null && item.badgeCount > 0) {
                                    val badgeDisplay = if (item.badgeCount > 99) "99+" else item.badgeCount.toString()
                                    Box(
                                        modifier = Modifier
                                            .align(Alignment.TopEnd)
                                            .offset(x = 10.dp, y = (-4).dp)
                                            .clip(CircleShape)
                                            .background(
                                                Brush.horizontalGradient(
                                                    listOf(
                                                        GlossyColors.EmeraldMint,
                                                        GlossyColors.EmeraldSoft
                                                    )
                                                )
                                            )
                                            .border(
                                                width = 1.5.dp,
                                                color = GlossyColors.BackgroundSecondary,
                                                shape = CircleShape
                                            )
                                            .padding(horizontal = 4.5.dp, vertical = 0.5.dp),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = badgeDisplay,
                                            color = Color.White,
                                            fontSize = 9.sp,
                                            fontWeight = FontWeight.ExtraBold,
                                            lineHeight = 10.sp,
                                            textAlign = TextAlign.Center
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(2.dp))

                            Text(
                                text = item.label,
                                color = labelColor,
                                fontSize = 10.5.sp,
                                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )

                            Spacer(modifier = Modifier.height(2.dp))

                            // Glowing cyan micro-indicator line
                            Box(
                                modifier = Modifier
                                    .height(2.5.dp)
                                    .width(indicatorWidth)
                                    .clip(RoundedCornerShape(1.5.dp))
                                    .background(
                                        Brush.horizontalGradient(
                                            listOf(
                                                GlossyColors.LightBlue,
                                                GlossyColors.SkyBlue
                                            )
                                        )
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
}
