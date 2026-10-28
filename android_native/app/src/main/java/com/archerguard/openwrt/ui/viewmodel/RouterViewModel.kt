package com.archerguard.openwrt.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.archerguard.openwrt.core.datastore.PreferencesRepository
import com.archerguard.openwrt.core.network.ApiConstants
import com.archerguard.openwrt.core.network.RouterApiService
import com.archerguard.openwrt.domain.model.ClientInfo
import com.archerguard.openwrt.domain.model.CpuInfo
import com.archerguard.openwrt.domain.model.FirewallInfo
import com.archerguard.openwrt.domain.model.MemoryInfo
import com.archerguard.openwrt.domain.model.NetworkInfo
import com.archerguard.openwrt.domain.model.PortForwardRule
import com.archerguard.openwrt.domain.model.RadioInfo
import com.archerguard.openwrt.domain.model.RouterStatus
import com.archerguard.openwrt.domain.model.SsidInfo
import com.archerguard.openwrt.domain.model.StorageInfo
import com.archerguard.openwrt.domain.model.TrafficInfo
import com.archerguard.openwrt.domain.model.TrafficRule
import com.archerguard.openwrt.domain.model.WirelessInfo
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

enum class ConnectionStatus {
    INITIAL, CONNECTING, CONNECTED, ERROR, OFFLINE
}

data class RouterUiState(
    val connectionStatus: ConnectionStatus = ConnectionStatus.INITIAL,
    val status: RouterStatus = RouterStatus(),
    val latencyMs: Long = -1L,
    val isRefreshing: Boolean = false,
    val errorMessage: String? = null,
    val downloadSpeedHistory: List<Double> = emptyList(),
    val uploadSpeedHistory: List<Double> = emptyList(),
    val liveDownloadSpeed: String = "0 bps",
    val liveUploadSpeed: String = "0 bps",
    val routerIp: String = ApiConstants.DEFAULT_GATEWAY_IP,
    val routerPort: Int = ApiConstants.DEFAULT_PORT,
    val routerUsername: String = ApiConstants.DEFAULT_USERNAME,
    val routerPassword: String = ApiConstants.DEFAULT_PASSWORD,
    val isLoggedIn: Boolean = false,
    val isLoggingIn: Boolean = false,
    val loginError: String? = null
)

class RouterViewModel(
    val preferencesRepository: PreferencesRepository,
    private val apiService: RouterApiService = RouterApiService()
) : ViewModel() {

    private val _uiState = MutableStateFlow(RouterUiState())
    val uiState: StateFlow<RouterUiState> = _uiState.asStateFlow()

    private val speedTracker = SpeedTracker()
    private var pollingJob: Job? = null

    init {
        viewModelScope.launch {
            val ip = preferencesRepository.routerIp.first()
            val port = preferencesRepository.routerPort.first()
            val user = preferencesRepository.routerUsername.first()
            val pass = preferencesRepository.routerPassword.first()
            val hasCredentials = pass.isNotBlank()

            _uiState.value = _uiState.value.copy(
                routerIp = ip,
                routerPort = port,
                routerUsername = user,
                routerPassword = pass,
                isLoggedIn = hasCredentials
            )

            // If user already saved credentials, log in automatically
            if (hasCredentials) {
                ensureSessionToken(ip, port, user, pass)
                startPolling()
            }
        }
    }

    private suspend fun ensureSessionToken(ip: String, port: Int, user: String, pass: String): String {
        var token = preferencesRepository.sessionToken.first()
        if (token.isBlank() && pass.isNotBlank()) {
            val loginResult = apiService.login(ip, port, user, pass)
            if (loginResult.isSuccess && !loginResult.token.isNullOrBlank()) {
                token = loginResult.token
                preferencesRepository.setSessionToken(token)
            }
        }
        return token
    }

    fun startPolling() {
        pollingJob?.cancel()
        pollingJob = viewModelScope.launch {
            while (isActive) {
                fetchTelemetry()
                delay(ApiConstants.DEFAULT_POLL_INTERVAL_SEC * 1000L)
            }
        }
    }

    fun stopPolling() {
        pollingJob?.cancel()
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isRefreshing = true)
            fetchTelemetry()
            _uiState.value = _uiState.value.copy(isRefreshing = false)
        }
    }

    suspend fun testConnectionAndLogin(
        ip: String,
        port: Int,
        username: String,
        password: String
    ): Pair<Boolean, String> {
        val ping = apiService.pingRouter(ip, port)
        if (!ping.isOnline) {
            return Pair(false, ping.error ?: "Router unreachable on $ip:$port")
        }

        if (password.isBlank()) {
            return Pair(true, "Router Online (${ping.latencyMs} ms) • No password provided")
        }

        val loginRes = apiService.login(ip, port, username, password)
        return if (loginRes.isSuccess && !loginRes.token.isNullOrBlank()) {
            preferencesRepository.setSessionToken(loginRes.token)
            Pair(true, "Router Online (${ping.latencyMs} ms) • Authenticated as '$username' successfully")
        } else {
            Pair(false, "Router Online (${ping.latencyMs} ms) • Auth failed: ${loginRes.error ?: "Invalid credentials"}")
        }
    }

    fun login(
        ip: String,
        port: Int,
        username: String,
        password: String,
        remember: Boolean = true,
        onResult: (Boolean, String?) -> Unit = { _, _ -> }
    ) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoggingIn = true, loginError = null)

            // Step 1: Ping router
            val ping = apiService.pingRouter(ip, port)
            if (!ping.isOnline) {
                val err = ping.error ?: "Router unreachable at $ip:$port. Check your Wi-Fi connection."
                _uiState.value = _uiState.value.copy(isLoggingIn = false, loginError = err)
                onResult(false, err)
                return@launch
            }

            // Step 2: Authenticate with OpenWrt ubus / shadow
            val loginResult = apiService.login(ip, port, username, password)
            if (loginResult.isSuccess && !loginResult.token.isNullOrBlank()) {
                val token = loginResult.token
                preferencesRepository.setRouterIp(ip)
                preferencesRepository.setRouterPort(port)
                preferencesRepository.setRouterUsername(username)
                preferencesRepository.setSessionToken(token)

                if (remember) {
                    preferencesRepository.setRouterPassword(password)
                } else {
                    preferencesRepository.setRouterPassword("")
                }

                _uiState.value = _uiState.value.copy(
                    isLoggingIn = false,
                    isLoggedIn = true,
                    loginError = null,
                    routerIp = ip,
                    routerPort = port,
                    routerUsername = username,
                    routerPassword = if (remember) password else "",
                    connectionStatus = ConnectionStatus.CONNECTED
                )

                startPolling()
                refresh()
                onResult(true, null)
            } else {
                val err = loginResult.error ?: "Incorrect router password"
                _uiState.value = _uiState.value.copy(isLoggingIn = false, loginError = err)
                onResult(false, err)
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            stopPolling()
            val ip = preferencesRepository.routerIp.first()
            val port = preferencesRepository.routerPort.first()
            val token = preferencesRepository.sessionToken.first()

            if (token.isNotBlank()) {
                try {
                    apiService.executeAction(ip, port, token, "logout")
                } catch (_: Exception) {}
            }

            preferencesRepository.setSessionToken("")
            preferencesRepository.setRouterPassword("")

            _uiState.value = _uiState.value.copy(
                isLoggedIn = false,
                routerPassword = "",
                connectionStatus = ConnectionStatus.INITIAL
            )
        }
    }

    fun updateSettings(
        ip: String,
        port: Int,
        username: String,
        password: String,
        autoRefresh: Boolean,
        pollInterval: Int = 5
    ) {
        viewModelScope.launch {
            preferencesRepository.setRouterIp(ip)
            preferencesRepository.setRouterPort(port)
            preferencesRepository.setRouterUsername(username)
            preferencesRepository.setRouterPassword(password)
            preferencesRepository.setAutoRefresh(autoRefresh)
            preferencesRepository.setPollInterval(pollInterval)

            _uiState.value = _uiState.value.copy(
                routerIp = ip,
                routerPort = port,
                routerUsername = username,
                routerPassword = password
            )

            // Re-authenticate with new credentials
            preferencesRepository.setSessionToken("")
            ensureSessionToken(ip, port, username, password)
            refresh()
        }
    }

    private suspend fun fetchTelemetry() {
        val ip = preferencesRepository.routerIp.first()
        val port = preferencesRepository.routerPort.first()
        val user = preferencesRepository.routerUsername.first()
        val pass = preferencesRepository.routerPassword.first()
        val token = ensureSessionToken(ip, port, user, pass)

        val ping = apiService.pingRouter(ip, port)
        if (!ping.isOnline) {
            _uiState.value = _uiState.value.copy(
                connectionStatus = ConnectionStatus.OFFLINE,
                latencyMs = -1L,
                errorMessage = ping.error ?: "Router unreachable on $ip:$port"
            )
            return
        }

        val result = apiService.fetchStatus(ip, port, token)
        result.fold(
            onSuccess = { statusData ->
                speedTracker.updateSpeeds(statusData)
                _uiState.value = _uiState.value.copy(
                    connectionStatus = ConnectionStatus.CONNECTED,
                    status = statusData,
                    latencyMs = ping.latencyMs,
                    errorMessage = null,
                    downloadSpeedHistory = speedTracker.downloadSpeedHistory,
                    uploadSpeedHistory = speedTracker.uploadSpeedHistory,
                    liveDownloadSpeed = speedTracker.formattedDownloadSpeed,
                    liveUploadSpeed = speedTracker.formattedUploadSpeed,
                    routerIp = ip,
                    routerPort = port,
                    routerUsername = user,
                    routerPassword = pass
                )
            },
            onFailure = { error ->
                _uiState.value = _uiState.value.copy(
                    connectionStatus = ConnectionStatus.ERROR,
                    latencyMs = ping.latencyMs,
                    errorMessage = error.localizedMessage
                )
            }
        )
    }

    fun executeRouterAction(command: String, params: Map<String, String> = emptyMap(), onComplete: (Boolean) -> Unit = {}) {
        viewModelScope.launch {
            val ip = preferencesRepository.routerIp.first()
            val port = preferencesRepository.routerPort.first()
            val user = preferencesRepository.routerUsername.first()
            val pass = preferencesRepository.routerPassword.first()
            var token = ensureSessionToken(ip, port, user, pass)

            var result = apiService.executeAction(ip, port, token, command, params)

            // Auto-recover if session expired (401 Unauthorized)
            if (result.isFailure && result.exceptionOrNull()?.message?.contains("401", ignoreCase = true) == true) {
                val loginRes = apiService.login(ip, port, user, pass)
                if (loginRes.isSuccess && !loginRes.token.isNullOrBlank()) {
                    token = loginRes.token
                    preferencesRepository.setSessionToken(token)
                    result = apiService.executeAction(ip, port, token, command, params)
                }
            }

            if (result.isSuccess) {
                fetchTelemetry()
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
    }

    fun kickClient(mac: String, onComplete: (Boolean) -> Unit = {}) {
        executeRouterAction("kick_client", mapOf("mac" to mac), onComplete)
    }

    fun rebootRouter(onComplete: (Boolean) -> Unit = {}) {
        executeRouterAction("reboot", emptyMap(), onComplete)
    }

    fun dropCaches(onComplete: (Boolean) -> Unit = {}) {
        executeRouterAction("drop_caches", emptyMap(), onComplete)
    }

    fun toggleStealthLeds(onComplete: (Boolean) -> Unit = {}) {
        executeRouterAction("toggle_leds", emptyMap(), onComplete)
    }

    fun toggleSqm(enabled: Boolean, onComplete: (Boolean) -> Unit = {}) {
        executeRouterAction("sqm_toggle", mapOf("enabled" to enabled.toString()), onComplete)
    }

    suspend fun fetchLogs(logType: String): String {
        val ip = preferencesRepository.routerIp.first()
        val port = preferencesRepository.routerPort.first()
        val user = preferencesRepository.routerUsername.first()
        val pass = preferencesRepository.routerPassword.first()
        val token = ensureSessionToken(ip, port, user, pass)
        val res = apiService.executeAction(ip, port, token, "raw_cmd", mapOf("value" to logType))
        return res.getOrDefault("System logs buffer returned from router.")
    }

    suspend fun createBackup(): String {
        val ip = preferencesRepository.routerIp.first()
        val port = preferencesRepository.routerPort.first()
        val user = preferencesRepository.routerUsername.first()
        val pass = preferencesRepository.routerPassword.first()
        val token = ensureSessionToken(ip, port, user, pass)
        val res = apiService.executeAction(ip, port, token, "backup_config")
        return res.getOrDefault("Backup archive /tmp/backup-OpenWrt-c6.tar.gz created.")
    }

    fun loadDemoMode() {
        stopPolling()
        _uiState.value = _uiState.value.copy(
            isLoggedIn = true,
            connectionStatus = ConnectionStatus.CONNECTED,
            latencyMs = 12L,
            routerIp = "192.168.1.1",
            routerUsername = "root (Demo)",
            liveDownloadSpeed = "48.5 Mbps",
            liveUploadSpeed = "12.3 Mbps",
            downloadSpeedHistory = listOf(14.2, 22.5, 31.0, 42.8, 48.5, 39.4, 45.0, 48.5),
            uploadSpeedHistory = listOf(3.1, 6.4, 9.8, 11.2, 12.3, 10.5, 12.3),
            status = RouterStatus(
                cpu = CpuInfo(
                    cores = 2,
                    threads = 4,
                    model = "MediaTek MT7621DAT",
                    architecture = "MIPS 1004Kc",
                    frequencyMhz = 880,
                    usagePercent = 16.4,
                    temperatureC = 45.8,
                    loadAvg = "0.24, 0.18, 0.15",
                    uptimeSeconds = 345600L
                ),
                memory = MemoryInfo(
                    totalKb = 131072L,
                    usedKb = 61440L,
                    freeKb = 45056L,
                    cachedKb = 24576L,
                    availableKb = 69632L,
                    type = "DDR3",
                    usagePercent = 46.8
                ),
                storage = StorageInfo(
                    totalKb = 16384L,
                    usedKb = 6960L,
                    availableKb = 9424L,
                    device = "16MB SPI NOR Flash",
                    usagePercent = 42.5
                ),
                traffic = TrafficInfo(
                    interfaceName = "pppoe-wan",
                    rxBytes = 14859200000L,
                    txBytes = 4280100000L,
                    wanIp = "103.145.74.88",
                    currentDownloadMbps = 48.5,
                    currentUploadMbps = 12.3,
                    pingMs = 12
                ),
                network = NetworkInfo(
                    hwOffload = true,
                    flowOffloadingHw = true,
                    sqmEnabled = true,
                    sqmQdisc = "cake",
                    sqmDownloadKbit = 95000,
                    sqmUploadKbit = 20000,
                    gateway = "192.168.1.1",
                    dns = "1.1.1.1, 1.0.0.1",
                    protocol = "pppoe",
                    mtu = 1492,
                    latencyMs = 8.5,
                    jitterMs = 0.9,
                    wireguardEnabled = true,
                    wireguardInterface = "wg0",
                    wireguardEndpoint = "vpn.archerguard.cloud:51820",
                    wireguardStatus = "connected",
                    wireguardLatestHandshake = "32 seconds ago",
                    wireguardTransferRx = 104857600L,
                    wireguardTransferTx = 52428800L,
                    dohEnabled = true,
                    dohProvider = "Cloudflare DoH (1.1.1.1)",
                    dnsRebindProtection = true,
                    wanLockdown = true
                ),
                wireless = WirelessInfo(
                    radio2g = RadioInfo(
                        ssid = "ArcherGuard_2.4G",
                        channel = 6,
                        txPowerDbm = 20,
                        enabled = true,
                        connectedClients = 3,
                        hwmode = "11ax",
                        htmode = "HE20",
                        band = "2.4GHz",
                        chipset = "MediaTek MT7603E",
                        encryption = "WPA2-PSK/WPA3-SAE"
                    ),
                    radio5g = RadioInfo(
                        ssid = "ArcherGuard_5G",
                        channel = 44,
                        txPowerDbm = 23,
                        enabled = true,
                        connectedClients = 4,
                        hwmode = "11ax",
                        htmode = "HE80",
                        band = "5GHz",
                        chipset = "MediaTek MT7613BEN",
                        encryption = "WPA3-SAE"
                    ),
                    guest = RadioInfo(
                        ssid = "ArcherGuard_Guest",
                        channel = 6,
                        txPowerDbm = 14,
                        enabled = true,
                        connectedClients = 1,
                        hwmode = "11ax",
                        htmode = "HE20",
                        band = "2.4GHz",
                        chipset = "MediaTek MT7603E",
                        encryption = "WPA2-PSK"
                    ),
                    ssids = listOf(
                        SsidInfo(
                            id = "ssid_2g",
                            ssid = "ArcherGuard_2.4G",
                            band = "2.4GHz",
                            radio = "radio0",
                            ifname = "wlan0",
                            enabled = true,
                            encryption = "WPA2-PSK/WPA3-SAE",
                            channel = 6,
                            connectedClients = 3,
                            txPower = 20
                        ),
                        SsidInfo(
                            id = "ssid_5g",
                            ssid = "ArcherGuard_5G",
                            band = "5GHz",
                            radio = "radio1",
                            ifname = "wlan1",
                            enabled = true,
                            encryption = "WPA3-SAE",
                            channel = 44,
                            connectedClients = 4,
                            txPower = 23
                        ),
                        SsidInfo(
                            id = "ssid_guest",
                            ssid = "ArcherGuard_Guest",
                            band = "2.4GHz",
                            radio = "radio0",
                            ifname = "wlan0-1",
                            enabled = true,
                            encryption = "WPA2-PSK",
                            channel = 6,
                            connectedClients = 1,
                            isGuest = true,
                            isIsolated = true,
                            txPower = 14
                        )
                    ),
                    fastRoaming = true,
                    pmfProtected = true,
                    wmmQos = true,
                    dropLegacyRates = true
                ),
                clients = listOf(
                    ClientInfo(
                        mac = "B4:2E:99:A1:3C:44",
                        ip = "192.168.1.101",
                        hostname = "MacBook-Pro-M3",
                        connectionType = "5GHz",
                        ssidName = "ArcherGuard_5G",
                        signalDbm = -42,
                        rxBytes = 4294967296L,
                        txBytes = 1073741824L,
                        connectedSeconds = 14500L,
                        vendor = "Apple Inc.",
                        customName = "Sabbir's MacBook"
                    ),
                    ClientInfo(
                        mac = "38:F9:D3:8E:12:9A",
                        ip = "192.168.1.102",
                        hostname = "Pixel-8-Pro",
                        connectionType = "5GHz",
                        ssidName = "ArcherGuard_5G",
                        signalDbm = -55,
                        rxBytes = 1572864000L,
                        txBytes = 419430400L,
                        connectedSeconds = 7200L,
                        vendor = "Google Inc.",
                        customName = "Pixel 8 Pro"
                    ),
                    ClientInfo(
                        mac = "70:EE:50:41:2B:11",
                        ip = "192.168.1.105",
                        hostname = "Workstation-Tower",
                        connectionType = "LAN",
                        ssidName = "Ethernet Port 1",
                        signalDbm = -30,
                        rxBytes = 8589934592L,
                        txBytes = 3221225472L,
                        connectedSeconds = 28000L,
                        vendor = "Realtek Semiconductor",
                        isStatic = true,
                        customName = "Main PC"
                    ),
                    ClientInfo(
                        mac = "AC:67:84:89:C2:5E",
                        ip = "192.168.1.110",
                        hostname = "LG-Smart-OLED",
                        connectionType = "5GHz",
                        ssidName = "ArcherGuard_5G",
                        signalDbm = -58,
                        rxBytes = 5368709120L,
                        txBytes = 268435456L,
                        connectedSeconds = 18000L,
                        vendor = "LG Electronics",
                        customName = "Living Room TV"
                    ),
                    ClientInfo(
                        mac = "80:7D:3A:45:11:80",
                        ip = "192.168.1.115",
                        hostname = "ESP32-Smart-Bulb",
                        connectionType = "2.4GHz",
                        ssidName = "ArcherGuard_2.4G",
                        signalDbm = -66,
                        rxBytes = 20971520L,
                        txBytes = 15728640L,
                        connectedSeconds = 86400L,
                        vendor = "Espressif Inc.",
                        customName = "Smart Lighting Hub"
                    )
                ),
                stealthLeds = false,
                firewall = FirewallInfo(
                    engine = "nftables v1.0.8 (fw4)",
                    table = "table inet fw4",
                    status = "enforcing",
                    synFlood = true,
                    dropInvalid = true,
                    wanPing = false,
                    wanLockdown = true,
                    dnsRebind = true,
                    flowOffload = true,
                    flowOffloadHw = true,
                    mssClamping = true,
                    antiSpoofing = true,
                    ipv6Firewall = true,
                    stealthMode = true,
                    guestIsolation = true,
                    dmzEnabled = false,
                    dmzIp = "192.168.1.150",
                    conntrackCount = 342,
                    conntrackMax = 16384,
                    portForwards = listOf(
                        PortForwardRule(
                            id = "pf1",
                            name = "WireGuard Server",
                            proto = "udp",
                            extPort = "51820",
                            intIp = "192.168.1.1",
                            intPort = "51820",
                            enabled = true
                        ),
                        PortForwardRule(
                            id = "pf2",
                            name = "SSH Internal Access",
                            proto = "tcp",
                            extPort = "2222",
                            intIp = "192.168.1.105",
                            intPort = "22",
                            enabled = true
                        ),
                        PortForwardRule(
                            id = "pf3",
                            name = "Plex Media Streaming",
                            proto = "tcp",
                            extPort = "32400",
                            intIp = "192.168.1.105",
                            intPort = "32400",
                            enabled = true
                        )
                    ),
                    trafficRules = listOf(
                        TrafficRule(
                            id = "tr1",
                            name = "Block IoT to Private LAN",
                            proto = "all",
                            src = "guest",
                            dest = "lan",
                            target = "DROP",
                            enabled = true
                        )
                    )
                )
            )
        )
    }
}
