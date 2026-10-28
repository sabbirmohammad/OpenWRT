package com.archerguard.openwrt.ui.screens.devices

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DriveFileRenameOutline
import androidx.compose.material.icons.filled.PersonRemove
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeviceDetailsSheet(
    client: ClientInfo,
    onKick: () -> Unit,
    onBlock: () -> Unit,
    onRename: (newName: String) -> Unit,
    onDismiss: () -> Unit
) {
    var showRenameDialog by remember { mutableStateOf(false) }

    val scrollState = rememberScrollState()

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = GlossyColors.BackgroundSecondary
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(scrollState)
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = client.displayName,
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = client.ip,
                        color = GlossyColors.LightBlue,
                        fontSize = 13.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = GlossyColors.TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            GlossyCard {
                Column {
                    DetailRow("MAC Address", client.mac)
                    DetailRow("Hostname", client.hostname.ifEmpty { "Unknown" })
                    DetailRow("Connection Type", "${client.connectionType} (${client.ssidName})")
                    DetailRow("Signal RSSI", "${client.signalDbm} dBm")
                    DetailRow("Connected Since", client.formattedUptime)
                    DetailRow("Downloaded", client.formattedRx)
                    DetailRow("Uploaded", client.formattedTx)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                GlossyButton(
                    text = "Rename",
                    onClick = { showRenameDialog = true },
                    icon = Icons.Default.DriveFileRenameOutline,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "Kick",
                    onClick = {
                        onKick()
                        onDismiss()
                    },
                    icon = Icons.Default.PersonRemove,
                    isPrimary = false,
                    contentPadding = PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
                GlossyButton(
                    text = "Block",
                    onClick = {
                        onBlock()
                        onDismiss()
                    },
                    icon = Icons.Default.Block,
                    isPrimary = true,
                    contentPadding = PaddingValues(horizontal = 6.dp, vertical = 8.dp),
                    fontSize = 12.sp,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }

    if (showRenameDialog) {
        var aliasInput by remember { mutableStateOf(client.customName ?: client.hostname) }
        AlertDialog(
            onDismissRequest = { showRenameDialog = false },
            containerColor = GlossyColors.BackgroundElevated,
            title = { Text("Rename Device", color = GlossyColors.TextPrimary, fontWeight = FontWeight.Bold) },
            text = {
                GlossyInput(
                    value = aliasInput,
                    onValueChange = { aliasInput = it },
                    label = "Device Nickname",
                    placeholder = "e.g. My Phone"
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        onRename(aliasInput.trim())
                        showRenameDialog = false
                    }
                ) {
                    Text("Save", color = GlossyColors.LightBlue, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showRenameDialog = false }) {
                    Text("Cancel", color = GlossyColors.TextMuted)
                }
            }
        )
    }
}

@Composable
private fun DetailRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            color = GlossyColors.TextSecondary,
            fontSize = 13.sp,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            color = GlossyColors.TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(1.3f, fill = false)
        )
    }
}
