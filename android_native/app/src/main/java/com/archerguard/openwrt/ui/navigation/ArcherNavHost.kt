package com.archerguard.openwrt.ui.navigation

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.Scaffold
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.archerguard.openwrt.ui.components.GlossyBottomBar
import com.archerguard.openwrt.ui.components.GlossySidebarDrawer
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
import kotlinx.coroutines.launch

/**
 * Intuitive, Streamlined Navigation Host for ArcherGuard.
 * Features:
 * - Persistent right-side Quick Action & Management Drawer (Menu Bar)
 * - 5 core bottom tabs: Dashboard, Devices, Wireless, Network, and Menu (opens Drawer)
 * - Direct, un-nested screen navigation (Security Hub, Firewall & NAT, System Tools)
 * - Automatic hardware and gesture back navigation via BackHandler
 * - 1-tap quick actions: RAM Flush, Stealth LEDs, Reboot, Logs, and Backup
 */
@Composable
fun ArcherNavHost(
    viewModel: RouterViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()
    var selectedScreen by remember { mutableIntStateOf(0) }
    var showSettingsSheet by remember { mutableStateOf(false) }

    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    if (!uiState.isLoggedIn) {
        LoginScreen(
            viewModel = viewModel,
            onLoginSuccess = {
                selectedScreen = 0
            },
            modifier = modifier
        )
    } else {
        // Intercept Android Back gesture/button when not on dashboard or when drawer is open
        BackHandler(enabled = selectedScreen != 0 || drawerState.isOpen) {
            if (drawerState.isOpen) {
                scope.launch { drawerState.close() }
            } else {
                selectedScreen = 0
            }
        }

        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Rtl) {
            ModalNavigationDrawer(
                drawerState = drawerState,
                drawerContent = {
                    ModalDrawerSheet(
                        drawerContainerColor = GlossyColors.BackgroundSecondary,
                        drawerShape = RoundedCornerShape(topStart = 20.dp, bottomStart = 20.dp)
                    ) {
                        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
                            GlossySidebarDrawer(
                                status = uiState.status,
                                routerIp = uiState.routerIp,
                                onNavigateToSettings = {
                                    scope.launch { drawerState.close() }
                                    showSettingsSheet = true
                                },
                                onNavigateToSecurity = {
                                    scope.launch { drawerState.close() }
                                    selectedScreen = 4 // Security Hub
                                },
                                onNavigateToFirewall = {
                                    scope.launch { drawerState.close() }
                                    selectedScreen = 5 // Firewall & NAT
                                },
                                onNavigateToNetwork = {
                                    scope.launch { drawerState.close() }
                                    selectedScreen = 3 // Network & QoS
                                },
                                onNavigateToTools = {
                                    scope.launch { drawerState.close() }
                                    selectedScreen = 6 // System Tools
                                },
                                onFlushRam = {
                                    scope.launch { drawerState.close() }
                                    viewModel.dropCaches()
                                },
                                onToggleLeds = {
                                    scope.launch { drawerState.close() }
                                    viewModel.toggleStealthLeds()
                                },
                                onReboot = {
                                    scope.launch { drawerState.close() }
                                    viewModel.rebootRouter()
                                },
                                onLogout = {
                                    scope.launch { drawerState.close() }
                                    viewModel.logout()
                                }
                            )
                        }
                    }
                }
            ) {
                CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
                    Scaffold(
                        modifier = modifier.fillMaxSize(),
                        bottomBar = {
                            GlossyBottomBar(
                                currentIndex = if (selectedScreen in 0..3) selectedScreen else -1,
                                onTabSelected = { tabIndex ->
                                    if (tabIndex == 4) {
                                        scope.launch {
                                            if (drawerState.isOpen) drawerState.close() else drawerState.open()
                                        }
                                    } else {
                                        selectedScreen = tabIndex
                                    }
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
                            when (selectedScreen) {
                                0 -> DashboardScreen(
                                    uiState = uiState,
                                    onRefresh = { viewModel.refresh() },
                                    onReboot = { viewModel.rebootRouter() },
                                    onDropCaches = { viewModel.dropCaches() },
                                    onToggleLeds = { viewModel.toggleStealthLeds() },
                                    onOpenMenu = {
                                        scope.launch {
                                            if (drawerState.isOpen) drawerState.close() else drawerState.open()
                                        }
                                    },
                                    onNavigateToTab = { tab ->
                                        selectedScreen = tab
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
                                3 -> NetworkScreen(
                                    network = uiState.status.network,
                                    onBackClick = { selectedScreen = 0 },
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
                                4 -> SecurityScreen(
                                    status = uiState.status,
                                    viewModel = viewModel,
                                    onNavigateToFirewall = { selectedScreen = 5 },
                                    onBackClick = { selectedScreen = 0 }
                                )
                                5 -> FirewallScreen(
                                    firewall = uiState.status.firewall,
                                    blockedClients = uiState.status.clients.filter { it.blocked },
                                    onBackClick = { selectedScreen = 0 },
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
                                6 -> ToolsScreen(
                                    status = uiState.status,
                                    latencyMs = uiState.latencyMs,
                                    onFlushRam = { viewModel.dropCaches() },
                                    onReboot = { viewModel.rebootRouter() },
                                    onFetchLogs = { logType -> viewModel.fetchLogs(logType) },
                                    onCreateBackup = { viewModel.createBackup() },
                                    onNavigateToNetwork = { selectedScreen = 3 },
                                    onOpenSettings = { showSettingsSheet = true },
                                    onLogout = { viewModel.logout() },
                                    onBackClick = { selectedScreen = 0 }
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
    }
}
