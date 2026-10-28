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
import androidx.compose.material.icons.filled.Security
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
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
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DmzConfigSheet(
    currentDmzIp: String,
    isEnabled: Boolean,
    onSaveDmz: (ip: String, enabled: Boolean) -> Unit,
    onDismiss: () -> Unit
) {
    var dmzIp by remember { mutableStateOf(currentDmzIp) }
    var enabled by remember { mutableStateOf(isEnabled) }

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
                        imageVector = Icons.Default.Security,
                        contentDescription = null,
                        tint = GlossyColors.AmberWarm,
                        modifier = Modifier.size(22.dp)
                    )
                    Spacer(modifier = Modifier.size(6.dp))
                    Text(
                        text = "DMZ (Demilitarized Zone)",
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = GlossyColors.TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Enable Exposed DMZ Host", color = GlossyColors.TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                    Text("Forwards all unassigned incoming WAN ports", color = GlossyColors.TextMuted, fontSize = 11.sp)
                }
                Switch(
                    checked = enabled,
                    onCheckedChange = { enabled = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = GlossyColors.AmberWarm,
                        checkedTrackColor = GlossyColors.AmberWarm.copy(alpha = 0.3f)
                    )
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            GlossyInput(
                value = dmzIp,
                onValueChange = { dmzIp = it },
                label = "Target DMZ Host IP",
                placeholder = "192.168.1.150"
            )

            Spacer(modifier = Modifier.height(20.dp))

            GlossyButton(
                text = "Save DMZ Configuration",
                onClick = {
                    onSaveDmz(dmzIp.trim(), enabled)
                    onDismiss()
                },
                icon = Icons.Default.Save,
                isPrimary = true,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}
