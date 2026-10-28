package com.archerguard.openwrt.ui.screens.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Archive
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.NetworkPing
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Terminal
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.core.util.AppFeedback
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.theme.GlossyColors
import kotlinx.coroutines.launch

@Composable
fun ToolsScreen(
    status: RouterStatus,
    latencyMs: Long,
    onFlushRam: () -> Unit,
    onReboot: () -> Unit,
    onFetchLogs: suspend (logType: String) -> String = { "Kernel buffer log output." },
    onCreateBackup: suspend () -> String = { "Backup archive generated successfully." },
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var selectedLogType by remember { mutableStateOf("dmesg") }
    var logsOutput by remember { mutableStateOf<String?>(null) }
    var isFetchingLogs by remember { mutableStateOf(false) }
    var isBackingUp by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(GlossyColors.BackgroundPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Diagnostics & Tools",
                color = GlossyColors.TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            GlossyCard {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.NetworkPing,
                            contentDescription = null,
                            tint = GlossyColors.LightBlue,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.padding(4.dp))
                        Text(
                            text = "Ping Latency Diagnostics",
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = if (latencyMs >= 0) "Router Response: $latencyMs ms (Healthy Local Link)"
                               else "Router Unreachable",
                        color = if (latencyMs >= 0) GlossyColors.EmeraldMint else GlossyColors.RoseCoral,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }

        item {
            GlossyCard {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = null,
                            tint = GlossyColors.PrimaryBlue,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.padding(4.dp))
                        Text(
                            text = "Hardware Specifications",
                            color = GlossyColors.TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    SpecRow(label = "SoC Model", value = status.cpu.model)
                    SpecRow(label = "Architecture", value = status.cpu.architecture)
                    SpecRow(label = "Clock Speed", value = "${status.cpu.frequencyMhz} MHz (${status.cpu.cores}C / ${status.cpu.threads}T)")
                    SpecRow(label = "Flash Memory", value = status.storage.device)
                    SpecRow(label = "System Uptime", value = status.cpu.formattedUptime)
                }
            }
        }

        item {
            // System Logs Console Card
            GlossyCard {
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
                            Icon(
                                imageVector = Icons.Default.Terminal,
                                contentDescription = null,
                                tint = GlossyColors.EmeraldMint,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "System Logs Console",
                                color = GlossyColors.TextPrimary,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }

                        Spacer(modifier = Modifier.width(6.dp))

                        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            GlossyButton(
                                text = "dmesg",
                                onClick = { selectedLogType = "dmesg" },
                                isPrimary = selectedLogType == "dmesg",
                                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                                fontSize = 11.sp
                            )
                            GlossyButton(
                                text = "logread",
                                onClick = { selectedLogType = "logread" },
                                isPrimary = selectedLogType == "logread",
                                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 5.dp),
                                fontSize = 11.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        GlossyButton(
                            text = "Fetch $selectedLogType",
                            onClick = {
                                scope.launch {
                                    isFetchingLogs = true
                                    logsOutput = onFetchLogs(selectedLogType)
                                    isFetchingLogs = false
                                }
                            },
                            icon = Icons.Default.Refresh,
                            isLoading = isFetchingLogs,
                            isPrimary = false,
                            modifier = Modifier.weight(1f)
                        )
                        if (logsOutput != null) {
                            GlossyButton(
                                text = "Copy",
                                onClick = {
                                    AppFeedback.copyToClipboard(context, "System Logs", logsOutput ?: "", "Logs copied to clipboard!")
                                },
                                icon = Icons.Default.ContentCopy,
                                isPrimary = false
                            )
                        }
                    }

                    if (logsOutput != null) {
                        Spacer(modifier = Modifier.height(10.dp))
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(180.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(GlossyColors.BackgroundPrimary)
                                .padding(10.dp)
                                .verticalScroll(rememberScrollState())
                                .horizontalScroll(rememberScrollState())
                        ) {
                            Text(
                                text = logsOutput ?: "",
                                color = GlossyColors.EmeraldSoft,
                                fontFamily = FontFamily.Monospace,
                                fontSize = 11.sp,
                                lineHeight = 15.sp
                            )
                        }
                    }
                }
            }
        }

        item {
            GlossyCard {
                Column {
                    Text(
                        text = "MAINTENANCE & BACKUP",
                        color = GlossyColors.TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    GlossyButton(
                        text = "Create Router Configuration Backup",
                        onClick = {
                            scope.launch {
                                isBackingUp = true
                                val result = onCreateBackup()
                                isBackingUp = false
                                AppFeedback.showToast(context, result)
                            }
                        },
                        icon = Icons.Default.Archive,
                        isLoading = isBackingUp,
                        isPrimary = false,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    GlossyButton(
                        text = "Flush PageCache & Drop RAM",
                        onClick = onFlushRam,
                        icon = Icons.Default.CleaningServices,
                        isPrimary = false,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    GlossyButton(
                        text = "Soft Reboot Router",
                        onClick = onReboot,
                        icon = Icons.Default.RestartAlt,
                        isPrimary = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun SpecRow(label: String, value: String) {
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
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = value,
            color = GlossyColors.TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(1.4f, fill = false)
        )
    }
}
