package com.archerguard.openwrt.ui.screens.firewall

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
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
import com.archerguard.openwrt.domain.model.PortForwardRule
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddPortForwardSheet(
    onAddRule: (PortForwardRule) -> Unit,
    onDismiss: () -> Unit
) {
    var name by remember { mutableStateOf("") }
    var extPort by remember { mutableStateOf("") }
    var intIp by remember { mutableStateOf("192.168.1.") }
    var intPort by remember { mutableStateOf("") }
    var proto by remember { mutableStateOf("tcp") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = GlossyColors.BackgroundSecondary
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Shield,
                        contentDescription = null,
                        tint = GlossyColors.AmberWarm,
                        modifier = Modifier.size(22.dp)
                    )
                    Spacer(modifier = Modifier.padding(4.dp))
                    Text(
                        text = "Add Port Forwarding Rule",
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = GlossyColors.TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            GlossyInput(
                value = name,
                onValueChange = { name = it },
                label = "Rule Description",
                placeholder = "e.g. Web Server"
            )

            Spacer(modifier = Modifier.height(10.dp))

            GlossyInput(
                value = extPort,
                onValueChange = { extPort = it },
                label = "External WAN Port",
                placeholder = "e.g. 8080"
            )

            Spacer(modifier = Modifier.height(10.dp))

            GlossyInput(
                value = intIp,
                onValueChange = { intIp = it },
                label = "Destination LAN IP",
                placeholder = "192.168.1.100"
            )

            Spacer(modifier = Modifier.height(10.dp))

            GlossyInput(
                value = intPort,
                onValueChange = { intPort = it },
                label = "Internal LAN Port",
                placeholder = "e.g. 80"
            )

            Spacer(modifier = Modifier.height(20.dp))

            GlossyButton(
                text = "Create Rule in nftables",
                onClick = {
                    if (name.isNotBlank() && extPort.isNotBlank() && intIp.isNotBlank() && intPort.isNotBlank()) {
                        val rule = PortForwardRule(
                            id = "pf_${System.currentTimeMillis()}",
                            name = name.trim(),
                            proto = proto,
                            extPort = extPort.trim(),
                            intIp = intIp.trim(),
                            intPort = intPort.trim(),
                            enabled = true
                        )
                        onAddRule(rule)
                        onDismiss()
                    }
                },
                icon = Icons.Default.Save,
                isPrimary = true,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}
