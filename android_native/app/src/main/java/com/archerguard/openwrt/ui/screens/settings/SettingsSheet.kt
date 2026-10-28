package com.archerguard.openwrt.ui.screens.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
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
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.NetworkPing
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.RouterViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsSheet(
    viewModel: RouterViewModel,
    onDismiss: () -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()
    val uiState = viewModel.uiState.value

    var ip by remember { mutableStateOf(uiState.routerIp) }
    var port by remember { mutableStateOf(uiState.routerPort.toString()) }
    var username by remember { mutableStateOf(uiState.routerUsername.ifBlank { "root" }) }
    var password by remember { mutableStateOf(uiState.routerPassword) }
    var isPasswordVisible by remember { mutableStateOf(false) }
    var autoRefresh by remember { mutableStateOf(true) }

    var isTesting by remember { mutableStateOf(false) }
    var testMessage by remember { mutableStateOf<String?>(null) }
    var testSuccess by remember { mutableStateOf(false) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = GlossyColors.BackgroundSecondary,
        dragHandle = null
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
                        imageVector = Icons.Default.Tune,
                        contentDescription = null,
                        tint = GlossyColors.LightBlue,
                        modifier = Modifier.size(22.dp)
                    )
                    Spacer(modifier = Modifier.padding(4.dp))
                    Text(
                        text = "Router Settings",
                        color = GlossyColors.TextPrimary,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = GlossyColors.TextSecondary
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                GlossyInput(
                    value = ip,
                    onValueChange = { ip = it },
                    label = "Gateway IP Address",
                    placeholder = "192.168.1.1",
                    modifier = Modifier.weight(0.7f)
                )

                GlossyInput(
                    value = port,
                    onValueChange = { port = it },
                    label = "HTTP Port",
                    placeholder = "80",
                    modifier = Modifier.weight(0.3f)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            GlossyInput(
                value = username,
                onValueChange = { username = it },
                label = "Router Admin Username",
                placeholder = "root",
                trailingIcon = {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = GlossyColors.TextSecondary,
                        modifier = Modifier.size(18.dp)
                    )
                }
            )

            Spacer(modifier = Modifier.height(12.dp))

            GlossyInput(
                value = password,
                onValueChange = { password = it },
                label = "Router Admin Password",
                placeholder = "Enter OpenWrt / LuCI password",
                visualTransformation = if (isPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                trailingIcon = {
                    IconButton(
                        onClick = { isPasswordVisible = !isPasswordVisible },
                        modifier = Modifier.size(24.dp)
                    ) {
                        Icon(
                            imageVector = if (isPasswordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                            contentDescription = if (isPasswordVisible) "Hide password" else "Show password",
                            tint = GlossyColors.TextSecondary,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Auto-Refresh Telemetry",
                        color = GlossyColors.TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = "Poll metrics every 5 seconds",
                        color = GlossyColors.TextSecondary,
                        fontSize = 12.sp
                    )
                }
                Switch(
                    checked = autoRefresh,
                    onCheckedChange = { autoRefresh = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = GlossyColors.EmeraldMint,
                        checkedTrackColor = GlossyColors.EmeraldMint.copy(alpha = 0.3f)
                    )
                )
            }

            if (testMessage != null) {
                Spacer(modifier = Modifier.height(12.dp))
                GlossyCard(
                    backgroundColor = if (testSuccess) GlossyColors.EmeraldMint.copy(alpha = 0.15f)
                    else GlossyColors.RoseCoral.copy(alpha = 0.15f),
                    borderColor = if (testSuccess) GlossyColors.EmeraldMint.copy(alpha = 0.4f)
                    else GlossyColors.RoseCoral.copy(alpha = 0.4f)
                ) {
                    Text(
                        text = testMessage ?: "",
                        color = if (testSuccess) GlossyColors.EmeraldMint else GlossyColors.RoseCoral,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                GlossyButton(
                    text = "Test Connection",
                    onClick = {
                        scope.launch {
                            isTesting = true
                            testMessage = null
                            val portInt = port.toIntOrNull() ?: 80
                            val (success, msg) = viewModel.testConnectionAndLogin(
                                ip = ip.trim(),
                                port = portInt,
                                username = username.trim(),
                                password = password
                            )
                            isTesting = false
                            testSuccess = success
                            testMessage = msg
                        }
                    },
                    icon = Icons.Default.NetworkPing,
                    isPrimary = false,
                    isLoading = isTesting,
                    modifier = Modifier.weight(1f)
                )

                GlossyButton(
                    text = "Save & Apply",
                    onClick = {
                        val portInt = port.toIntOrNull() ?: 80
                        viewModel.updateSettings(
                            ip = ip.trim(),
                            port = portInt,
                            username = username.trim(),
                            password = password,
                            autoRefresh = autoRefresh
                        )
                        onDismiss()
                    },
                    icon = Icons.Default.Save,
                    isPrimary = true,
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            var isCheckingUpdate by remember { mutableStateOf(false) }
            val context = androidx.compose.ui.platform.LocalContext.current
            var availableUpdate by remember { mutableStateOf<com.archerguard.openwrt.core.network.UpdateInfo?>(null) }

            GlossyButton(
                text = "Check App Updates (GitHub)",
                onClick = {
                    scope.launch {
                        isCheckingUpdate = true
                        val currentVersion = try {
                            context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "1.2.2"
                        } catch (e: Exception) {
                            "1.2.2"
                        }
                        val updater = com.archerguard.openwrt.core.network.GithubUpdateService()
                        val update = updater.checkForUpdates(currentVersion = currentVersion)
                        isCheckingUpdate = false
                        if (update != null && update.hasUpdate) {
                            availableUpdate = update
                        } else {
                            com.archerguard.openwrt.core.util.AppFeedback.showToast(context, "App is up to date (v$currentVersion)")
                        }
                    }
                },
                icon = androidx.compose.material.icons.Icons.Default.Tune,
                isLoading = isCheckingUpdate,
                isPrimary = false,
                modifier = Modifier.fillMaxWidth()
            )

            availableUpdate?.let { info ->
                com.archerguard.openwrt.ui.components.UpdateDialog(
                    updateInfo = info,
                    onDismiss = { availableUpdate = null }
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}
