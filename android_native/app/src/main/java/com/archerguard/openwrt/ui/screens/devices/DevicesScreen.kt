package com.archerguard.openwrt.ui.screens.devices

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Devices
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PersonRemove
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.core.util.DeviceFingerprintHelper
import com.archerguard.openwrt.core.util.DeviceType
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors

/**
 * Modern Connected Devices / Clients Management Screen.
 * Features:
 * - Smart Brand/Device Fingerprinting (Apple, Samsung, Android, Windows, Smart TV, Gaming, IoT)
 * - Wi-Fi RSSI Signal Quality Meter (-dBm with color grading)
 * - 1-Tap Parental Internet Pause & Resume
 * - Real-time traffic consumption metrics
 * - Multi-criteria categorization filters
 */
@Composable
fun DevicesScreen(
    clients: List<ClientInfo>,
    onKickClient: (String) -> Unit,
    onBlockClient: (String) -> Unit = {},
    onRenameClient: (mac: String, newName: String) -> Unit = { _, _ -> },
    modifier: Modifier = Modifier
) {
    var selectedClient by remember { mutableStateOf<ClientInfo?>(null) }
    var searchQuery by remember { mutableStateOf("") }
    var selectedFilter by remember { mutableStateOf("All") }

    val filterOptions = listOf("All", "Apple", "Android", "5.0 GHz", "2.4 GHz", "LAN", "Guest", "Paused")

    val filteredClients = clients.filter { client ->
        val matchesSearch = searchQuery.isBlank() ||
                client.displayName.contains(searchQuery, ignoreCase = true) ||
                client.ip.contains(searchQuery, ignoreCase = true) ||
                client.mac.contains(searchQuery, ignoreCase = true)

        val deviceType = DeviceFingerprintHelper.resolveDeviceType(client)

        val matchesFilter = when (selectedFilter) {
            "Apple" -> deviceType == DeviceType.APPLE || deviceType == DeviceType.APPLE_MAC
            "Android" -> deviceType == DeviceType.ANDROID || deviceType == DeviceType.SAMSUNG
            "5.0 GHz" -> client.ssidName.contains("5", ignoreCase = true) || client.connectionType.contains("5", ignoreCase = true)
            "2.4 GHz" -> client.ssidName.contains("2.4", ignoreCase = true) || client.connectionType.contains("2.4", ignoreCase = true)
            "LAN" -> client.connectionType.equals("LAN", ignoreCase = true) || deviceType == DeviceType.WIRED_LAN
            "Guest" -> client.isIsolated
            "Paused" -> client.blocked
            else -> true
        }
        matchesSearch && matchesFilter
    }

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Connected Clients",
                        color = GlossyColors.TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = (-0.4).sp
                    )
                    Text(
                        text = "Real-time discovery & access controls",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f))
                        .border(1.dp, GlossyColors.LightBlue.copy(alpha = 0.35f), RoundedCornerShape(8.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = "${filteredClients.size} / ${clients.size} Online",
                        color = GlossyColors.LightBlue,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(modifier = Modifier.height(10.dp))

            // Search Bar
            GlossyInput(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                label = "",
                placeholder = "Search device name, IP, or MAC..."
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Multi-criteria Filter Chips
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(filterOptions) { filter ->
                    val isSelected = selectedFilter == filter
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(10.dp))
                            .background(
                                if (isSelected) GlossyColors.PrimaryBlue else GlossyColors.GlassSurface
                            )
                            .border(
                                1.dp,
                                if (isSelected) GlossyColors.LightBlue else GlossyColors.GlassBorderLight,
                                RoundedCornerShape(10.dp)
                            )
                            .clickable { selectedFilter = filter }
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = filter,
                            color = if (isSelected) GlossyColors.TextPrimary else GlossyColors.TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                        )
                    }
                }
            }
        }

        if (filteredClients.isEmpty()) {
            item {
                GlossyCard {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            imageVector = Icons.Default.Devices,
                            contentDescription = null,
                            tint = GlossyColors.TextMuted,
                            modifier = Modifier.size(44.dp)
                        )
                        Spacer(modifier = Modifier.height(10.dp))
                        Text(
                            text = if (searchQuery.isNotEmpty()) "No devices matching \"$searchQuery\""
                            else "No devices found in this filter",
                            color = GlossyColors.TextSecondary,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
        } else {
            items(filteredClients, key = { it.mac }) { client ->
                DeviceCard(
                    client = client,
                    onKick = { onKickClient(client.mac) },
                    onToggleBlock = { onBlockClient(client.mac) },
                    onClick = { selectedClient = client }
                )
            }
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    selectedClient?.let { client ->
        DeviceDetailsSheet(
            client = client,
            onKick = { onKickClient(client.mac) },
            onBlock = { onBlockClient(client.mac) },
            onRename = { newName -> onRenameClient(client.mac, newName) },
            onDismiss = { selectedClient = null }
        )
    }
}

@Composable
private fun DeviceCard(
    client: ClientInfo,
    onKick: () -> Unit,
    onToggleBlock: () -> Unit,
    onClick: () -> Unit = {}
) {
    val deviceType = DeviceFingerprintHelper.resolveDeviceType(client)
    val isWifi = !client.connectionType.equals("LAN", ignoreCase = true)
    val signal = if (isWifi) DeviceFingerprintHelper.getSignalQuality(client.signalDbm) else null

    GlossyCard(
        onClick = onClick,
        borderColor = if (client.blocked) GlossyColors.RoseCoral.copy(alpha = 0.6f) else GlossyColors.GlassBorderLight,
        backgroundColor = if (client.blocked) GlossyColors.RoseCoral.copy(alpha = 0.08f) else GlossyColors.CardElevated
    ) {
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    modifier = Modifier.weight(1f),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Fingerprinted Device Icon in Styled Pill
                    Box(
                        modifier = Modifier
                            .size(38.dp)
                            .clip(CircleShape)
                            .background(deviceType.badgeBg)
                            .border(1.dp, deviceType.accentColor.copy(alpha = 0.35f), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = deviceType.icon,
                            contentDescription = deviceType.brand,
                            tint = deviceType.accentColor,
                            modifier = Modifier.size(20.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = client.displayName,
                                color = GlossyColors.TextPrimary,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                                modifier = Modifier.weight(1f, fill = false)
                            )

                            Spacer(modifier = Modifier.width(6.dp))

                            // Brand Badge
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(deviceType.badgeBg)
                                    .padding(horizontal = 6.dp, vertical = 1.5.dp)
                            ) {
                                Text(
                                    text = deviceType.brand,
                                    color = deviceType.accentColor,
                                    fontSize = 9.5.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(2.dp))

                        Text(
                            text = "${client.ip}  •  ${client.mac}",
                            color = GlossyColors.TextSecondary,
                            fontSize = 11.5.sp,
                            style = GlossyColors.TabularCaption,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                // Status Badges (Blocked or Guest)
                if (client.blocked) {
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(GlossyColors.RoseCoral.copy(alpha = 0.2f))
                            .border(0.5.dp, GlossyColors.RoseCoral.copy(alpha = 0.5f), RoundedCornerShape(6.dp))
                            .padding(horizontal = 7.dp, vertical = 2.5.dp)
                    ) {
                        Text(
                            text = "PAUSED",
                            color = GlossyColors.RoseCoral,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                } else if (client.isIsolated) {
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(GlossyColors.IsolatedAccent.copy(alpha = 0.2f))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = "GUEST",
                            color = GlossyColors.IsolatedLight,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Sub-info Bar: Connection type, Signal RSSI & Traffic Bandwidth
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(8.dp))
                    .background(GlossyColors.GlassSurface)
                    .padding(horizontal = 10.dp, vertical = 5.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (isWifi && signal != null) {
                        Box(
                            modifier = Modifier
                                .size(6.dp)
                                .clip(CircleShape)
                                .background(signal.color)
                        )
                        Spacer(modifier = Modifier.width(5.dp))
                        Text(
                            text = "${client.connectionType} (${signal.label} ${client.signalDbm}dBm)",
                            color = signal.color,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                            style = GlossyColors.TabularCaption
                        )
                    } else {
                        Box(
                            modifier = Modifier
                                .size(6.dp)
                                .clip(CircleShape)
                                .background(GlossyColors.LanGigabit)
                        )
                        Spacer(modifier = Modifier.width(5.dp))
                        Text(
                            text = "Gigabit LAN (Wired)",
                            color = GlossyColors.LanGigabit,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }

                Text(
                    text = "↓ ${client.formattedRx}   ↑ ${client.formattedTx}",
                    color = GlossyColors.TextMuted,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    style = GlossyColors.TabularCaption
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Action Strip: 1-Tap Parental Pause + Kick button
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // 1-Tap Parental Internet Control
                GlossyButton(
                    text = if (client.blocked) "Resume Internet" else "Pause Internet",
                    onClick = onToggleBlock,
                    icon = if (client.blocked) Icons.Default.PlayArrow else Icons.Default.Pause,
                    isPrimary = client.blocked,
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 5.dp),
                    fontSize = 11.5.sp
                )

                GlossyButton(
                    text = "Kick Wi-Fi",
                    onClick = onKick,
                    icon = Icons.Default.PersonRemove,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 5.dp),
                    fontSize = 11.5.sp
                )
            }
        }
    }
}
