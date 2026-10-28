package com.archerguard.openwrt.ui.screens.network

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.domain.model.NetworkInfo
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.theme.GlossyColors
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SqmTuneSheet(
    network: NetworkInfo,
    onApply: (downloadKbit: Int, uploadKbit: Int) -> Unit,
    onDismiss: () -> Unit
) {
    var downloadMbps by remember { mutableFloatStateOf(network.sqmDownloadMbps.toFloat()) }
    var uploadMbps by remember { mutableFloatStateOf(network.sqmUploadMbps.toFloat()) }

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
                        imageVector = Icons.Default.Speed,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(22.dp)
                    )
                    Spacer(modifier = Modifier.padding(4.dp))
                    Text(
                        text = "Tune CAKE SQM Bandwidth",
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

            // Download Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Download Cap", color = GlossyColors.TextSecondary, fontSize = 13.sp)
                Text(
                    String.format(Locale.US, "%.0f Mbps", downloadMbps),
                    color = GlossyColors.EmeraldMint,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Slider(
                value = downloadMbps,
                onValueChange = { downloadMbps = it },
                valueRange = 5f..500f,
                colors = SliderDefaults.colors(
                    thumbColor = GlossyColors.EmeraldMint,
                    activeTrackColor = GlossyColors.EmeraldMint
                )
            )

            Spacer(modifier = Modifier.height(14.dp))

            // Upload Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Upload Cap", color = GlossyColors.TextSecondary, fontSize = 13.sp)
                Text(
                    String.format(Locale.US, "%.0f Mbps", uploadMbps),
                    color = GlossyColors.SkyBlue,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Slider(
                value = uploadMbps,
                onValueChange = { uploadMbps = it },
                valueRange = 2f..200f,
                colors = SliderDefaults.colors(
                    thumbColor = GlossyColors.SkyBlue,
                    activeTrackColor = GlossyColors.SkyBlue
                )
            )

            Spacer(modifier = Modifier.height(20.dp))

            GlossyButton(
                text = "Apply Bandwidth Limits",
                onClick = {
                    val dlKbit = (downloadMbps * 1000).toInt()
                    val ulKbit = (uploadMbps * 1000).toInt()
                    onApply(dlKbit, ulKbit)
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
