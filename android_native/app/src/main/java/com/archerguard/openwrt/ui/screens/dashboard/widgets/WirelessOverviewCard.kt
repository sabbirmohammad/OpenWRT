package com.archerguard.openwrt.ui.screens.dashboard.widgets

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.RadioInfo
import com.archerguard.openwrt.domain.model.WirelessInfo
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors

@Composable
fun WirelessOverviewCard(
    wireless: WirelessInfo,
    onManageWifi: () -> Unit,
    modifier: Modifier = Modifier
) {
    val totalClients = wireless.radio2g.connectedClients + wireless.radio5g.connectedClients + wireless.guest.connectedClients

    GlossyCard(modifier = modifier) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Wifi,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Wireless Radios ($totalClients Clients)",
                        color = GlossyColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .clickable(onClick = onManageWifi)
                        .padding(horizontal = 6.dp, vertical = 2.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Manage",
                        color = GlossyColors.EmeraldMint,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Icon(
                        imageVector = Icons.Default.ChevronRight,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                RadioMiniTile(
                    band = "2.4 GHz",
                    radio = wireless.radio2g,
                    accentColor = GlossyColors.EmeraldMint,
                    modifier = Modifier.weight(1f)
                )
                RadioMiniTile(
                    band = "5.0 GHz",
                    radio = wireless.radio5g,
                    accentColor = GlossyColors.LightBlue,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun RadioMiniTile(
    band: String,
    radio: RadioInfo,
    accentColor: Color,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(GlossyColors.GlassSurface)
            .padding(10.dp)
    ) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = band,
                    color = accentColor,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
                Box(
                    modifier = Modifier
                        .size(7.dp)
                        .clip(CircleShape)
                        .background(if (radio.enabled) GlossyColors.EmeraldMint else GlossyColors.RoseCoral)
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = radio.ssid.ifEmpty { "Disabled" },
                color = GlossyColors.TextPrimary,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "Ch ${radio.channel} • ${radio.txPowerDbm} dBm • ${radio.connectedClients} active",
                color = GlossyColors.TextMuted,
                fontSize = 11.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
