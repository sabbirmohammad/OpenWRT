package com.archerguard.openwrt.core.datastore

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.archerguard.openwrt.core.network.ApiConstants
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "archerguard_settings")

class PreferencesRepository(private val context: Context) {

    companion object {
        private val KEY_ROUTER_IP = stringPreferencesKey("pref_router_ip")
        private val KEY_ROUTER_PORT = intPreferencesKey("pref_router_port")
        private val KEY_ROUTER_USERNAME = stringPreferencesKey("pref_router_username")
        private val KEY_ROUTER_PASSWORD = stringPreferencesKey("pref_router_password")
        private val KEY_SESSION_TOKEN = stringPreferencesKey("pref_session_token")
        private val KEY_AUTO_REFRESH = booleanPreferencesKey("pref_auto_refresh")
        private val KEY_POLL_INTERVAL = intPreferencesKey("pref_poll_interval")
    }

    val routerIp: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[KEY_ROUTER_IP] ?: ApiConstants.DEFAULT_GATEWAY_IP
    }

    val routerPort: Flow<Int> = context.dataStore.data.map { prefs ->
        prefs[KEY_ROUTER_PORT] ?: ApiConstants.DEFAULT_PORT
    }

    val routerUsername: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[KEY_ROUTER_USERNAME] ?: ApiConstants.DEFAULT_USERNAME
    }

    val routerPassword: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[KEY_ROUTER_PASSWORD] ?: ApiConstants.DEFAULT_PASSWORD
    }

    val sessionToken: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[KEY_SESSION_TOKEN] ?: ""
    }

    val autoRefresh: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[KEY_AUTO_REFRESH] ?: true
    }

    val pollInterval: Flow<Int> = context.dataStore.data.map { prefs ->
        prefs[KEY_POLL_INTERVAL] ?: ApiConstants.DEFAULT_POLL_INTERVAL_SEC
    }

    suspend fun setRouterIp(ip: String) {
        context.dataStore.edit { prefs ->
            prefs[KEY_ROUTER_IP] = ip.trim()
        }
    }

    suspend fun setRouterPort(port: Int) {
        context.dataStore.edit { prefs ->
            prefs[KEY_ROUTER_PORT] = port
        }
    }

    suspend fun setRouterUsername(username: String) {
        context.dataStore.edit { prefs ->
            prefs[KEY_ROUTER_USERNAME] = username.trim()
        }
    }

    suspend fun setRouterPassword(password: String) {
        context.dataStore.edit { prefs ->
            prefs[KEY_ROUTER_PASSWORD] = password
        }
    }

    suspend fun setSessionToken(token: String) {
        context.dataStore.edit { prefs ->
            prefs[KEY_SESSION_TOKEN] = token.trim()
        }
    }

    suspend fun setAutoRefresh(enabled: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[KEY_AUTO_REFRESH] = enabled
        }
    }

    suspend fun setPollInterval(intervalSec: Int) {
        context.dataStore.edit { prefs ->
            prefs[KEY_POLL_INTERVAL] = intervalSec
        }
    }
}
