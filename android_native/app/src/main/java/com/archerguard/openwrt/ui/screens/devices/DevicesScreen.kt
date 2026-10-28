package com.archerguard.openwrt.ui.screens.devices

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.IconButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Devices
import androidx.compose.material.icons.filled.PersonRemove
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors

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

    val filterOptions = listOf("All", "2.4 GHz", "5.0 GHz", "LAN", "Guest")

    val filteredClients = clients.filter { client ->
        val matchesSearch = searchQuery.isBlank() ||
                client.displayName.contains(searchQuery, ignoreCase = true) ||
                client.ip.contains(searchQuery, ignoreCase = true) ||
                client.mac.contains(searchQuery, ignoreCase = true)

        val matchesFilter = when (selectedFilter) {
            "2.4 GHz" -> client.ssidName.contains("2.4", ignoreCase = true) || client.connectionType.contains("2.4", ignoreCase = true)
            "5.0 GHz" -> client.ssidName.contains("5", ignoreCase = true) || client.connectionType.contains("5", ignoreCase = true)
            "LAN" -> client.connectionType.equals("LAN", ignoreCase = true)
            "Guest" -> client.isIsolated
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
                Text(
                    text = "Connected Clients",
                    color = GlossyColors.TextPrimary,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold
                )
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = "${filteredClients.size} / ${clients.size} Online",
                        color = GlossyColors.LightBlue,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
            Spacer(modifier = Modifier.height(8.dp))

            // Search Bar
            com.archerguard.openwrt.ui.components.GlossyInput(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                label = "",
                placeholder = "Search device name, IP, or MAC..."
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Filter Chips
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(filterOptions) { filter ->
                    val isSelected = selectedFilter == filter
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(
                                if (isSelected) GlossyColors.PrimaryBlue else GlossyColors.GlassSurface
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
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = if (searchQuery.isNotEmpty()) "No clients matching \"$searchQuery\"" else "No Clients Detected",
                            color = GlossyColors.TextSecondary,
                            fontSize = 15.sp,
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
    onClick: () -> Unit = {}
) {
    GlossyCard(
        modifier = Modifier.clickable(onClick = onClick)
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
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(
                                if (client.isIsolated) GlossyColors.IsolatedAccent.copy(alpha = 0.2f)
                                else GlossyColors.PrimaryBlue.copy(alpha = 0.2f)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (client.connectionType == "LAN") Icons.Default.Devices else Icons.Default.Wifi,
                            contentDescription = null,
                            tint = if (client.isIsolated) GlossyColors.IsolatedLight else GlossyColors.LightBlue,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = client.displayName,
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "${client.ip} • ${client.mac}",
                            color = GlossyColors.TextSecondary,
                            fontSize = 12.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                if (client.isIsolated) {
                    Spacer(modifier = Modifier.width(8.dp))
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

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Traffic: ↓ ${client.formattedRx}  ↑ ${client.formattedTx}",
                    color = GlossyColors.TextMuted,
                    fontSize = 12.sp
                )
                GlossyButton(
                    text = "Kick",
                    onClick = onKick,
                    icon = Icons.Default.PersonRemove,
                    isPrimary = false,
                    modifier = Modifier.height(34.dp)
                )
            }
        }
    }
}
