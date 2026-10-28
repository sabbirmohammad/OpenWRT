package com.archerguard.openwrt.ui.screens.login

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Key
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Router
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.archerguard.openwrt.ui.components.GlossyButton
import com.archerguard.openwrt.ui.components.GlossyCard
import com.archerguard.openwrt.ui.components.GlossyInput
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.RouterViewModel

@Composable
fun LoginScreen(
    viewModel: RouterViewModel,
    onLoginSuccess: () -> Unit,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()

    var ip by remember { mutableStateOf(uiState.routerIp) }
    var port by remember { mutableStateOf(uiState.routerPort.toString()) }
    var username by remember { mutableStateOf(uiState.routerUsername.ifBlank { "root" }) }
    var password by remember { mutableStateOf(uiState.routerPassword) }
    var isPasswordVisible by remember { mutableStateOf(false) }
    var rememberCredentials by remember { mutableStateOf(true) }

    val scrollState = rememberScrollState()

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        GlossyColors.BackgroundSecondary,
                        GlossyColors.BackgroundPrimary,
                        GlossyColors.BackgroundPrimary
                    )
                )
            )
            .padding(horizontal = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.height(48.dp))

            // Glowing App Branding
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                GlossyColors.LightBlue.copy(alpha = 0.35f),
                                GlossyColors.PrimaryBlue.copy(alpha = 0.15f),
                                GlossyColors.BackgroundSecondary
                            )
                        )
                    )
                    .border(1.5.dp, GlossyColors.LightBlue.copy(alpha = 0.5f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Shield,
                    contentDescription = null,
                    tint = GlossyColors.LightBlue,
                    modifier = Modifier.size(42.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "ArcherGuard",
                color = GlossyColors.TextPrimary,
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.5.sp
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = "OpenWrt Hardware Control Center",
                color = GlossyColors.TextSecondary,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Router Model Pill
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(GlossyColors.GlassBorderLight.copy(alpha = 0.2f))
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Router,
                        contentDescription = null,
                        tint = GlossyColors.EmeraldMint,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "TP-Link Archer C6 (OpenWrt 21+)",
                        color = GlossyColors.TextPrimary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Main Login Card
            GlossyCard(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = GlossyColors.BackgroundSecondary.copy(alpha = 0.95f),
                borderColor = GlossyColors.GlassBorderLight
            ) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Lock,
                                contentDescription = null,
                                tint = GlossyColors.LightBlue,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Admin Authentication",
                                color = GlossyColors.TextPrimary,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Sign in with your OpenWrt LuCI admin credentials to control and monitor your router.",
                        color = GlossyColors.TextMuted,
                        fontSize = 12.sp,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    // Gateway IP and Port Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        GlossyInput(
                            value = ip,
                            onValueChange = { ip = it },
                            label = "Router Gateway IP",
                            placeholder = "192.168.1.1",
                            modifier = Modifier.weight(0.7f)
                        )

                        GlossyInput(
                            value = port,
                            onValueChange = { port = it },
                            label = "Port",
                            placeholder = "80",
                            modifier = Modifier.weight(0.3f)
                        )
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // Username Input
                    GlossyInput(
                        value = username,
                        onValueChange = { username = it },
                        label = "Admin Username",
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

                    Spacer(modifier = Modifier.height(14.dp))

                    // Password Input
                    GlossyInput(
                        value = password,
                        onValueChange = { password = it },
                        label = "Admin Password",
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

                    Spacer(modifier = Modifier.height(14.dp))

                    // Remember Credentials Toggle
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Key,
                                contentDescription = null,
                                tint = GlossyColors.TextSecondary,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Save credentials for auto-login",
                                color = GlossyColors.TextSecondary,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                        Switch(
                            checked = rememberCredentials,
                            onCheckedChange = { rememberCredentials = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = GlossyColors.EmeraldMint,
                                checkedTrackColor = GlossyColors.EmeraldMint.copy(alpha = 0.3f)
                            )
                        )
                    }

                    // Error Message Card
                    if (uiState.loginError != null) {
                        Spacer(modifier = Modifier.height(14.dp))
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(10.dp))
                                .background(GlossyColors.RoseCoral.copy(alpha = 0.12f))
                                .border(1.dp, GlossyColors.RoseCoral.copy(alpha = 0.4f), RoundedCornerShape(10.dp))
                                .padding(12.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.Warning,
                                    contentDescription = null,
                                    tint = GlossyColors.RoseCoral,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = uiState.loginError ?: "Authentication failed",
                                    color = GlossyColors.RoseCoral,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    // Connect / Login Button
                    GlossyButton(
                        text = if (uiState.isLoggingIn) "Authenticating..." else "Connect & Login",
                        onClick = {
                            val portInt = port.toIntOrNull() ?: 80
                            viewModel.login(
                                ip = ip.trim(),
                                port = portInt,
                                username = username.trim(),
                                password = password,
                                remember = rememberCredentials,
                                onResult = { success, _ ->
                                    if (success) {
                                        onLoginSuccess()
                                    }
                                }
                            )
                        },
                        icon = Icons.Default.Lock,
                        isPrimary = true,
                        isLoading = uiState.isLoggingIn,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Security note footer
            Text(
                text = "🔒 Local OpenWrt Session • Direct Gateway Connection",
                color = GlossyColors.TextMuted,
                fontSize = 11.sp,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(48.dp))
        }
    }
}
