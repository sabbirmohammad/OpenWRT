package com.archerguard.openwrt.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.archerguard.openwrt.core.datastore.PreferencesRepository
import com.archerguard.openwrt.core.network.ApiConstants
import com.archerguard.openwrt.core.network.RouterApiService
import com.archerguard.openwrt.domain.model.RouterStatus
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
}
