package com.archerguard.openwrt.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.Hub
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Nightlight
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.text.style.TextOverflow
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun GlossySidebarDrawer(
    status: RouterStatus,
    routerIp: String,
    onNavigateToSettings: () -> Unit,
    onNavigateToSecurity: () -> Unit,
    onNavigateToFirewall: () -> Unit,
    onNavigateToNetwork: () -> Unit = {},
    onNavigateToTools: () -> Unit,
    onFlushRam: () -> Unit,
    onToggleLeds: () -> Unit,
    onReboot: () -> Unit,
    onLogout: () -> Unit = {},
    modifier: Modifier = Modifier
) {
    val scrollState = rememberScrollState()

    Box(
        modifier = modifier
            .fillMaxHeight()
            .widthIn(max = 320.dp)
            .background(GlossyColors.BackgroundSecondary.copy(alpha = 0.98f))
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .verticalScroll(scrollState)
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            // Router Header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Shield,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(24.dp)
                    )
                }
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "ArcherGuard",
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = "$routerIp • OpenWrt",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
            HorizontalDivider(color = GlossyColors.GlassBorderLight)
            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "MANAGEMENT & SECURITY",
                color = GlossyColors.TextMuted,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(10.dp))

            DrawerTile(
                icon = Icons.Default.Tune,
                title = "Settings",
                subtitle = "Gateway IP, token & polling",
                onClick = onNavigateToSettings
            )
            DrawerTile(
                icon = Icons.Default.Security,
                title = "Security Hub",
                subtitle = "Audit score & threat mitigations",
                onClick = onNavigateToSecurity
            )
            DrawerTile(
                icon = Icons.Default.Shield,
                title = "Firewall & NAT",
                subtitle = "nftables rules & DDoS shield",
                onClick = onNavigateToFirewall
            )
            DrawerTile(
                icon = Icons.Default.Hub,
                title = "Network & QoS",
                subtitle = "SQM CAKE, DNS privacy & HW offload",
                onClick = onNavigateToNetwork
            )
            DrawerTile(
                icon = Icons.Default.Info,
                title = "System Tools",
                subtitle = "Hardware specs & ping test",
                onClick = onNavigateToTools
            )
            DrawerTile(
                icon = Icons.AutoMirrored.Filled.ExitToApp,
                title = "Disconnect / Log Out",
                subtitle = "End session and return to login",
                onClick = onLogout
            )

            Spacer(modifier = Modifier.height(24.dp))

            HorizontalDivider(color = GlossyColors.GlassBorderLight)
            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = "QUICK ACTIONS",
                color = GlossyColors.TextMuted,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                GlossyButton(
                    text = "Flush",
                    onClick = onFlushRam,
                    icon = Icons.Default.CleaningServices,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 4.dp, vertical = 6.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "LEDs",
                    onClick = onToggleLeds,
                    icon = Icons.Default.Nightlight,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 4.dp, vertical = 6.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "Reboot",
                    onClick = onReboot,
                    icon = Icons.Default.RestartAlt,
                    isPrimary = true,
                    contentPadding = PaddingValues(horizontal = 4.dp, vertical = 6.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
            }
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun DrawerTile(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 10.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = GlossyColors.LightBlue,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Column {
            Text(
                text = title,
                color = GlossyColors.TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = subtitle,
                color = GlossyColors.TextSecondary,
                fontSize = 11.sp
            )
        }
    }
}
