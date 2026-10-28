package com.archerguard.openwrt.ui.components

import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.InstallMobile
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.SystemUpdate
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.archerguard.openwrt.core.network.GithubUpdateService
import com.archerguard.openwrt.core.network.UpdateInfo
import com.archerguard.openwrt.ui.theme.GlossyColors
import kotlinx.coroutines.launch
import java.io.File
import java.util.Locale

enum class UpdateDialogState {
    IDLE,
    DOWNLOADING,
    NEEDS_PERMISSION,
    READY_TO_INSTALL,
    ERROR
}

@Composable
fun UpdateDialog(
    updateInfo: UpdateInfo,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val updater = remember { GithubUpdateService() }
    val lifecycleOwner = LocalLifecycleOwner.current

    var state by remember { mutableStateOf(UpdateDialogState.IDLE) }
    var progressPercent by remember { mutableFloatStateOf(0f) }
    var downloadedBytes by remember { mutableLongStateOf(0L) }
    var totalBytes by remember { mutableLongStateOf(updateInfo.apkSize) }
    var downloadedFile by remember { mutableStateOf<File?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // When returning from Android Settings after enabling "Install Unknown Apps" permission
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                if (state == UpdateDialogState.NEEDS_PERMISSION) {
                    if (updater.canRequestPackageInstalls(context)) {
                        state = UpdateDialogState.READY_TO_INSTALL
                        downloadedFile?.let { updater.installApk(context, it) }
                    }
                }
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    fun startDownload() {
        val apkUrl = updateInfo.apkDownloadUrl
        if (apkUrl.isNullOrEmpty()) {
            state = UpdateDialogState.ERROR
            errorMessage = "No direct APK link found in this release."
            return
        }

        state = UpdateDialogState.DOWNLOADING
        errorMessage = null
        progressPercent = 0f

        scope.launch {
            val fileName = "ArcherGuard-${updateInfo.latestVersion}.apk"
            val file = updater.downloadApk(
                context = context,
                downloadUrl = apkUrl,
                fileName = fileName
            ) { downloaded, total, percent ->
                downloadedBytes = downloaded
                if (total > 0) totalBytes = total
                progressPercent = percent
            }

            if (file != null && file.exists()) {
                downloadedFile = file
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !updater.canRequestPackageInstalls(context)) {
                    state = UpdateDialogState.NEEDS_PERMISSION
                } else {
                    state = UpdateDialogState.READY_TO_INSTALL
                    updater.installApk(context, file)
                }
            } else {
                state = UpdateDialogState.ERROR
                errorMessage = "Download failed. Please check your internet connection."
            }
        }
    }

    fun triggerInstall() {
        val file = downloadedFile
        if (file != null && file.exists()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !updater.canRequestPackageInstalls(context)) {
                state = UpdateDialogState.NEEDS_PERMISSION
                updater.openInstallPermissionSettings(context)
            } else {
                state = UpdateDialogState.READY_TO_INSTALL
                updater.installApk(context, file)
            }
        } else {
            startDownload()
        }
    }

    Dialog(
        onDismissRequest = {
            if (state != UpdateDialogState.DOWNLOADING) {
                onDismiss()
            }
        },
        properties = DialogProperties(
            dismissOnBackPress = state != UpdateDialogState.DOWNLOADING,
            dismissOnClickOutside = state != UpdateDialogState.DOWNLOADING
        )
    ) {
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
            Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(
                containerColor = GlossyColors.BackgroundSecondary
            ),
            border = androidx.compose.foundation.BorderStroke(1.dp, GlossyColors.GlassBorderLight)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(22.dp)
            ) {
                // Header with Icon and Tag
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(46.dp)
                            .clip(CircleShape)
                            .background(GlossyColors.PrimaryBlue.copy(alpha = 0.2f))
                            .border(1.dp, GlossyColors.PrimaryBlue.copy(alpha = 0.4f), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.SystemUpdate,
                            contentDescription = "Update",
                            tint = GlossyColors.SkyBlue,
                            modifier = Modifier.size(24.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(14.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "New Update Available",
                            color = GlossyColors.TextPrimary,
                            fontSize = 17.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            // Version Tag Badge
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(GlossyColors.EmeraldMint.copy(alpha = 0.15f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = updateInfo.latestVersion,
                                    color = GlossyColors.EmeraldMint,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }

                            if (updateInfo.apkSize > 0) {
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = formatBytes(updateInfo.apkSize),
                                    color = GlossyColors.TextMuted,
                                    fontSize = 12.sp
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Release Notes Box
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(GlossyColors.BackgroundPrimary.copy(alpha = 0.7f))
                        .border(1.dp, GlossyColors.GlassBorderDark, RoundedCornerShape(14.dp))
                        .padding(12.dp)
                ) {
                    Text(
                        text = "What's New:",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(max = 110.dp)
                            .verticalScroll(rememberScrollState())
                    ) {
                        Text(
                            text = updateInfo.releaseNotes.trim(),
                            color = GlossyColors.TextMuted,
                            fontSize = 12.sp,
                            lineHeight = 16.sp
                        )
                    }
                }

                // Downloading Progress UI
                if (state == UpdateDialogState.DOWNLOADING) {
                    Spacer(modifier = Modifier.height(16.dp))
                    Column(modifier = Modifier.fillMaxWidth()) {
                        LinearProgressIndicator(
                            progress = { progressPercent },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(8.dp)
                                .clip(RoundedCornerShape(4.dp)),
                            color = GlossyColors.EmeraldMint,
                            trackColor = GlossyColors.BackgroundElevated
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "Downloading update...",
                                color = GlossyColors.SkyBlue,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium
                            )
                            Text(
                                text = "${(progressPercent * 100).toInt()}% (${formatBytes(downloadedBytes)} / ${if (totalBytes > 0) formatBytes(totalBytes) else "..."})",
                                color = GlossyColors.TextSecondary,
                                fontSize = 12.sp
                            )
                        }
                    }
                }

                // Needs Permission Banner
                if (state == UpdateDialogState.NEEDS_PERMISSION) {
                    Spacer(modifier = Modifier.height(14.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(GlossyColors.AmberWarm.copy(alpha = 0.12f))
                            .border(1.dp, GlossyColors.AmberWarm.copy(alpha = 0.35f), RoundedCornerShape(12.dp))
                            .padding(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Security,
                            contentDescription = null,
                            tint = GlossyColors.AmberWarm,
                            modifier = Modifier.size(22.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = "To install update directly, please allow 'Install unknown apps' permission in Settings.",
                            color = GlossyColors.AmberWarm,
                            fontSize = 12.sp,
                            lineHeight = 16.sp
                        )
                    }
                }

                // Ready to Install Banner
                if (state == UpdateDialogState.READY_TO_INSTALL) {
                    Spacer(modifier = Modifier.height(14.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(GlossyColors.EmeraldMint.copy(alpha = 0.12f))
                            .border(1.dp, GlossyColors.EmeraldMint.copy(alpha = 0.35f), RoundedCornerShape(12.dp))
                            .padding(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = GlossyColors.EmeraldMint,
                            modifier = Modifier.size(22.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = "Download complete! Ready to install.",
                            color = GlossyColors.EmeraldMint,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }

                // Error Banner
                if (state == UpdateDialogState.ERROR) {
                    Spacer(modifier = Modifier.height(14.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(GlossyColors.RoseCoral.copy(alpha = 0.12f))
                            .border(1.dp, GlossyColors.RoseCoral.copy(alpha = 0.35f), RoundedCornerShape(12.dp))
                            .padding(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.ErrorOutline,
                            contentDescription = null,
                            tint = GlossyColors.RoseCoral,
                            modifier = Modifier.size(22.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = errorMessage ?: "Failed to download update.",
                            color = GlossyColors.RoseCoral,
                            fontSize = 12.sp,
                            lineHeight = 16.sp
                        )
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (state != UpdateDialogState.DOWNLOADING) {
                        TextButton(
                            onClick = onDismiss,
                            colors = ButtonDefaults.textButtonColors(contentColor = GlossyColors.TextMuted)
                        ) {
                            Text("Later")
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                    }

                    when (state) {
                        UpdateDialogState.IDLE -> {
                            Button(
                                onClick = { startDownload() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = GlossyColors.EmeraldMint,
                                    contentColor = Color.White
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Download,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text("Download & Install", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }

                        UpdateDialogState.DOWNLOADING -> {
                            Button(
                                onClick = {},
                                enabled = false,
                                colors = ButtonDefaults.buttonColors(
                                    disabledContainerColor = GlossyColors.PrimaryBlue.copy(alpha = 0.4f),
                                    disabledContentColor = GlossyColors.TextMuted
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(16.dp),
                                    color = GlossyColors.TextMuted,
                                    strokeWidth = 2.dp
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Downloading...", fontSize = 13.sp)
                            }
                        }

                        UpdateDialogState.NEEDS_PERMISSION -> {
                            Button(
                                onClick = { updater.openInstallPermissionSettings(context) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = GlossyColors.AmberWarm,
                                    contentColor = Color.Black
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Security,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text("Grant Permission", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }

                        UpdateDialogState.READY_TO_INSTALL -> {
                            Button(
                                onClick = { triggerInstall() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = GlossyColors.EmeraldMint,
                                    contentColor = Color.White
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.InstallMobile,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text("Install Now", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }

                        UpdateDialogState.ERROR -> {
                            Button(
                                onClick = { startDownload() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = GlossyColors.LightBlue,
                                    contentColor = Color.White
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Text("Retry", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}
}

private fun formatBytes(bytes: Long): String {
    if (bytes <= 0) return "0 B"
    val kb = bytes / 1024.0
    val mb = kb / 1024.0
    val gb = mb / 1024.0
    return when {
        gb >= 1.0 -> String.format(Locale.US, "%.1f GB", gb)
        mb >= 1.0 -> String.format(Locale.US, "%.1f MB", mb)
        kb >= 1.0 -> String.format(Locale.US, "%.1f KB", kb)
        else -> "$bytes B"
    }
}
