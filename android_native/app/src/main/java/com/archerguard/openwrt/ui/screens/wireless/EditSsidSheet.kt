package com.archerguard.openwrt.ui.screens.wireless

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
import androidx.compose.material.icons.filled.Wifi
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
import com.archerguard.openwrt.domain.model.RadioInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditSsidSheet(
    band: String,
    radio: RadioInfo,
    onSave: (ssid: String, key: String, isHidden: Boolean) -> Unit,
    onDismiss: () -> Unit
) {
    var ssidName by remember { mutableStateOf(radio.ssid) }
    var password by remember { mutableStateOf("") }
    var isHidden by remember { mutableStateOf(false) }

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
                        imageVector = Icons.Default.Wifi,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(22.dp)
                    )
                    Spacer(modifier = Modifier.padding(4.dp))
                    Text(
                        text = "Edit $band Wi-Fi",
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
                value = ssidName,
                onValueChange = { ssidName = it },
                label = "Network Name (SSID)",
                placeholder = "My_WiFi_Network"
            )

            Spacer(modifier = Modifier.height(12.dp))

            GlossyInput(
                value = password,
                onValueChange = { password = it },
                label = "WPA2/WPA3 Password",
                placeholder = "Leave empty to keep unchanged"
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Hide SSID (Stealth Beacon)", color = GlossyColors.TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                    Text("Prevent broadcasting network name", color = GlossyColors.TextSecondary, fontSize = 12.sp)
                }
                Switch(
                    checked = isHidden,
                    onCheckedChange = { isHidden = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = GlossyColors.EmeraldMint,
                        checkedTrackColor = GlossyColors.EmeraldMint.copy(alpha = 0.3f)
                    )
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            GlossyButton(
                text = "Save Wi-Fi Configuration",
                onClick = {
                    onSave(ssidName.trim(), password.trim(), isHidden)
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
