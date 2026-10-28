package com.archerguard.openwrt.ui.navigation

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.archerguard.openwrt.ui.components.GlossyBottomBar
import com.archerguard.openwrt.ui.screens.dashboard.DashboardScreen
import com.archerguard.openwrt.ui.screens.devices.DevicesScreen
import com.archerguard.openwrt.ui.screens.firewall.FirewallScreen
import com.archerguard.openwrt.ui.screens.login.LoginScreen
import com.archerguard.openwrt.ui.screens.network.NetworkScreen
import com.archerguard.openwrt.ui.screens.security.SecurityScreen
import com.archerguard.openwrt.ui.screens.settings.SettingsSheet
import com.archerguard.openwrt.ui.screens.tools.ToolsScreen
import com.archerguard.openwrt.ui.screens.wireless.WirelessScreen
import com.archerguard.openwrt.ui.theme.GlossyColors
import com.archerguard.openwrt.ui.viewmodel.RouterViewModel

enum class NavigationSubScreen {
    FIREWALL,
    NETWORK_QOS
}

/**
 * Modern 5-Tab Navigation Host for ArcherGuard.
 * Features:
 * - 5 dedicated core tabs: Dashboard, Devices, Wireless, Security, Tools
 * - Contextual sub-screen navigation (Firewall, Network QoS) with Back-stack support
 * - Automatic hardware back button handling via BackHandler
 * - Direct access to settings and router actions without drawer friction
 */
@Composable
fun ArcherNavHost(
    viewModel: RouterViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()
    var selectedTab by remember { mutableIntStateOf(0) }
    var activeSubScreen by remember { mutableStateOf<NavigationSubScreen?>(null) }
    var showSettingsSheet by remember { mutableStateOf(false) }

    if (!uiState.isLoggedIn) {
        LoginScreen(
            viewModel = viewModel,
            onLoginSuccess = {
                selectedTab = 0
                activeSubScreen = null
            },
            modifier = modifier
        )
    } else {
        // Intercept Android Back gesture/button when in a subscreen
        BackHandler(enabled = activeSubScreen != null) {
            activeSubScreen = null
        }

        Scaffold(
            modifier = modifier.fillMaxSize(),
            bottomBar = {
                GlossyBottomBar(
                    currentIndex = selectedTab,
                    onTabSelected = { tabIndex ->
                        activeSubScreen = null
                        selectedTab = tabIndex
                    },
                    clientCount = uiState.status.clients.size
                )
            }
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(GlossyColors.BackgroundPrimary)
                    .padding(innerPadding)
            ) {
                if (activeSubScreen != null) {
                    when (activeSubScreen) {
                        NavigationSubScreen.FIREWALL -> {
                            FirewallScreen(
                                firewall = uiState.status.firewall,
                                blockedClients = uiState.status.clients.filter { it.blocked },
                                onBackClick = { activeSubScreen = null },
                                onAddPortForward = { rule ->
                                    viewModel.executeRouterAction(
                                        "add_port_forward",
                                        mapOf(
                                            "name" to rule.name,
                                            "proto" to rule.proto,
                                            "ext_port" to rule.extPort,
                                            "int_ip" to rule.intIp,
                                            "int_port" to rule.intPort
                                        )
                                    )
                                },
                                onUnblockClient = { mac ->
                                    viewModel.executeRouterAction("unblock_mac", mapOf("mac" to mac))
                                },
                                onSaveDmz = { ip, enabled ->
                                    viewModel.executeRouterAction(
                                        "set_dmz",
                                        mapOf("ip" to ip, "enabled" to enabled.toString())
                                    )
                                }
                            )
                        }
                        NavigationSubScreen.NETWORK_QOS -> {
                            NetworkScreen(
                                network = uiState.status.network,
                                onBackClick = { activeSubScreen = null },
                                onToggleSqm = { enabled -> viewModel.toggleSqm(enabled) },
                                onToggleHwOffload = { enabled ->
                                    viewModel.executeRouterAction("toggle_hw_offload", mapOf("enabled" to enabled.toString()))
                                },
                                onTuneSqm = { dlKbit, ulKbit ->
                                    viewModel.executeRouterAction(
                                        "tune_sqm",
                                        mapOf("download_kbit" to dlKbit.toString(), "upload_kbit" to ulKbit.toString())
                                    )
                                },
                                onSelectDns = { preset ->
                                    viewModel.executeRouterAction(
                                        "set_dns",
                                        mapOf("primary" to preset.primaryDns, "secondary" to preset.secondaryDns)
                                    )
                                }
                            )
                        }
                        null -> {}
                    }
                } else {
                    when (selectedTab) {
                        0 -> DashboardScreen(
                            uiState = uiState,
                            onRefresh = { viewModel.refresh() },
                            onReboot = { viewModel.rebootRouter() },
                            onDropCaches = { viewModel.dropCaches() },
                            onToggleLeds = { viewModel.toggleStealthLeds() },
                            onOpenMenu = { showSettingsSheet = true },
                            onNavigateToTab = { tab ->
                                activeSubScreen = null
                                selectedTab = tab
                            }
                        )
                        1 -> DevicesScreen(
                            clients = uiState.status.clients,
                            onKickClient = { mac -> viewModel.kickClient(mac) },
                            onBlockClient = { mac ->
                                viewModel.executeRouterAction("block_mac", mapOf("mac" to mac))
                            },
                            onRenameClient = { mac, newName ->
                                viewModel.executeRouterAction("rename_client", mapOf("mac" to mac, "name" to newName))
                            }
                        )
                        2 -> WirelessScreen(
                            wireless = uiState.status.wireless,
                            clients = uiState.status.clients,
                            onSaveSsid = { band, ssid, key, isHidden ->
                                viewModel.executeRouterAction(
                                    "save_ssid",
                                    mapOf("band" to band, "ssid" to ssid, "key" to key, "hidden" to isHidden.toString())
                                )
                            },
                            onToggleMasterWifi = {
                                viewModel.executeRouterAction("wifi_toggle")
                            },
                            onSavePower = { p2g, p5g ->
                                viewModel.executeRouterAction(
                                    "set_tx_power",
                                    mapOf("tx2g" to p2g.toString(), "tx5g" to p5g.toString())
                                )
                            }
                        )
                        3 -> SecurityScreen(
                            status = uiState.status,
                            viewModel = viewModel,
                            onNavigateToFirewall = { activeSubScreen = NavigationSubScreen.FIREWALL }
                        )
                        4 -> ToolsScreen(
                            status = uiState.status,
                            latencyMs = uiState.latencyMs,
                            onFlushRam = { viewModel.dropCaches() },
                            onReboot = { viewModel.rebootRouter() },
                            onFetchLogs = { logType -> viewModel.fetchLogs(logType) },
                            onCreateBackup = { viewModel.createBackup() },
                            onNavigateToNetwork = { activeSubScreen = NavigationSubScreen.NETWORK_QOS },
                            onOpenSettings = { showSettingsSheet = true },
                            onLogout = { viewModel.logout() }
                        )
                    }
                }
            }

            if (showSettingsSheet) {
                SettingsSheet(
                    viewModel = viewModel,
                    onDismiss = { showSettingsSheet = false }
                )
            }
        }
    }
}
