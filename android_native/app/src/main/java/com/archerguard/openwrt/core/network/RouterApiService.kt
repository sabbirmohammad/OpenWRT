package com.archerguard.openwrt.core.network

import com.archerguard.openwrt.domain.model.RouterStatus
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.concurrent.TimeUnit

data class PingResult(
    val isOnline: Boolean,
    val latencyMs: Long,
    val error: String? = null
)

data class LoginResult(
    val isSuccess: Boolean,
    val token: String? = null,
    val error: String? = null
)

class RouterApiService(
    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(ApiConstants.TIMEOUT_MS, TimeUnit.MILLISECONDS)
        .readTimeout(ApiConstants.TIMEOUT_MS, TimeUnit.MILLISECONDS)
        .writeTimeout(ApiConstants.TIMEOUT_MS, TimeUnit.MILLISECONDS)
        .build(),
    private val json: Json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        isLenient = true
    }
) {
    private fun getBaseUrl(ip: String, port: Int): String {
        return if (port == 80) {
            "http://$ip${ApiConstants.API_PATH}"
        } else {
            "http://$ip:$port${ApiConstants.API_PATH}"
        }
    }

    suspend fun pingRouter(ip: String, port: Int): PingResult = withContext(Dispatchers.IO) {
        val url = "${getBaseUrl(ip, port)}?action=speed"
        val start = System.currentTimeMillis()
        try {
            val request = Request.Builder()
                .url(url)
                .get()
                .build()

            client.newCall(request).execute().use { response ->
                val elapsed = System.currentTimeMillis() - start
                if (response.isSuccessful) {
                    PingResult(isOnline = true, latencyMs = elapsed)
                } else {
                    PingResult(isOnline = false, latencyMs = elapsed, error = "HTTP ${response.code}")
                }
            }
        } catch (e: Exception) {
            PingResult(isOnline = false, latencyMs = -1, error = e.localizedMessage ?: "Unreachable")
        }
    }

    suspend fun login(ip: String, port: Int, username: String, password: String): LoginResult = withContext(Dispatchers.IO) {
        val url = "${getBaseUrl(ip, port)}?action=login"
        try {
            val payload = buildJsonObject {
                put("username", username.ifBlank { "root" })
                put("password", password)
            }
            val mediaType = "application/json; charset=utf-8".toMediaType()
            val requestBody = payload.toString().toRequestBody(mediaType)
            val request = Request.Builder()
                .url(url)
                .post(requestBody)
                .build()

            client.newCall(request).execute().use { response ->
                val body = response.body?.string() ?: ""
                if (response.isSuccessful) {
                    val rootObj = json.parseToJsonElement(body) as? JsonObject
                    val status = rootObj?.get("status")?.toString()?.replace("\"", "")
                    val token = rootObj?.get("token")?.toString()?.replace("\"", "")
                    if (status == "ok" && !token.isNullOrBlank()) {
                        LoginResult(isSuccess = true, token = token)
                    } else {
                        val msg = rootObj?.get("message")?.toString()?.replace("\"", "") ?: "Authentication failed"
                        LoginResult(isSuccess = false, error = msg)
                    }
                } else {
                    LoginResult(isSuccess = false, error = "HTTP ${response.code}: $body")
                }
            }
        } catch (e: Exception) {
            LoginResult(isSuccess = false, error = e.localizedMessage ?: "Login failed")
        }
    }

    suspend fun fetchStatus(ip: String, port: Int, token: String = ""): Result<RouterStatus> = withContext(Dispatchers.IO) {
        val url = "${getBaseUrl(ip, port)}?action=status"
        try {
            val requestBuilder = Request.Builder()
                .url(url)
                .header("Accept", "application/json")
                .header("Cache-Control", "no-cache")

            if (token.isNotBlank()) {
                requestBuilder.header("X-Router-Session", token)
                requestBuilder.header("Authorization", "Bearer $token")
            }

            client.newCall(requestBuilder.build()).execute().use { response ->
                if (!response.isSuccessful) {
                    return@withContext Result.failure(IOException("Router returned HTTP ${response.code}"))
                }
                val body = response.body?.string() ?: return@withContext Result.failure(IOException("Empty response"))
                val parsed = json.decodeFromString<RouterStatus>(body)
                Result.success(parsed)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun executeAction(
        ip: String,
        port: Int,
        token: String,
        command: String,
        extraParams: Map<String, String> = emptyMap()
    ): Result<String> = withContext(Dispatchers.IO) {
        val url = "${getBaseUrl(ip, port)}?action=control"
        try {
            val payload = buildJsonObject {
                put("command", command)
                put("cmd", command)
                if (token.isNotBlank()) {
                    put("token", token)
                }
                extraParams.forEach { (k, v) -> put(k, v) }
            }

            val mediaType = "application/json; charset=utf-8".toMediaType()
            val requestBody = payload.toString().toRequestBody(mediaType)

            val requestBuilder = Request.Builder()
                .url(url)
                .post(requestBody)

            if (token.isNotBlank()) {
                requestBuilder.header("X-Router-Session", token)
                requestBuilder.header("Authorization", "Bearer $token")
            }

            client.newCall(requestBuilder.build()).execute().use { response ->
                val body = response.body?.string() ?: ""
                if (response.isSuccessful) {
                    Result.success(body)
                } else {
                    Result.failure(IOException("HTTP ${response.code}: $body"))
                }
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
