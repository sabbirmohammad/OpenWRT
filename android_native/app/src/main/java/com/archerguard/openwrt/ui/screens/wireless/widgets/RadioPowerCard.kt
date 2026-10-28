package com.archerguard.openwrt.ui.screens.wireless.widgets

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CellTower
import androidx.compose.material3.Icon
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors
import java.util.Locale

@Composable
fun RadioPowerCard(
    txPower2g: Int,
    txPower5g: Int,
    onSavePower: (power2g: Int, power5g: Int) -> Unit,
    modifier: Modifier = Modifier
) {
    var power2g by remember(txPower2g) { mutableFloatStateOf(txPower2g.toFloat()) }
    var power5g by remember(txPower5g) { mutableFloatStateOf(txPower5g.toFloat()) }

    GlossyCard(modifier = modifier) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.CellTower,
                    contentDescription = null,
                    tint = GlossyColors.LightBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.size(8.dp))
                Text(
                    text = "Transmit Power (TX dBm)",
                    color = GlossyColors.TextPrimary,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // 2.4 GHz Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("2.4 GHz Power", color = GlossyColors.TextSecondary, fontSize = 13.sp)
                Text(
                    String.format(Locale.US, "%.0f dBm", power2g),
                    color = GlossyColors.EmeraldMint,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Slider(
                value = power2g,
                onValueChange = { power2g = it },
                valueRange = 10f..23f,
                colors = SliderDefaults.colors(
                    thumbColor = GlossyColors.EmeraldMint,
                    activeTrackColor = GlossyColors.EmeraldMint
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            // 5.0 GHz Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("5.0 GHz Power", color = GlossyColors.TextSecondary, fontSize = 13.sp)
                Text(
                    String.format(Locale.US, "%.0f dBm", power5g),
                    color = GlossyColors.LightBlue,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Slider(
                value = power5g,
                onValueChange = { power5g = it },
                valueRange = 10f..23f,
                colors = SliderDefaults.colors(
                    thumbColor = GlossyColors.LightBlue,
                    activeTrackColor = GlossyColors.LightBlue
                )
            )

            Spacer(modifier = Modifier.height(12.dp))

            GlossyButton(
                text = "Apply Transmit Power",
                onClick = { onSavePower(power2g.toInt(), power5g.toInt()) },
                isPrimary = false,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
