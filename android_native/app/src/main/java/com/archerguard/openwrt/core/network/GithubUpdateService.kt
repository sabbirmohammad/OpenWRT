package com.archerguard.openwrt.core.network

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

@Serializable
data class GithubRelease(
    @SerialName("tag_name") val tagName: String = "",
    val name: String = "",
    val body: String = "",
    @SerialName("html_url") val htmlUrl: String = ""
)

data class UpdateInfo(
    val hasUpdate: Boolean,
    val latestVersion: String,
    val releaseNotes: String,
    val downloadUrl: String
)

class GithubUpdateService(
    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.SECONDS)
        .readTimeout(5, TimeUnit.SECONDS)
        .build(),
    private val json: Json = Json { ignoreUnknownKeys = true }
) {
    suspend fun checkForUpdates(currentVersion: String = "1.0.0", repo: String = "sabbirmohammad/OpenWRT"): UpdateInfo? =
        withContext(Dispatchers.IO) {
            val url = "https://api.github.com/repos/$repo/releases/latest"
            try {
                val request = Request.Builder()
                    .url(url)
                    .header("Accept", "application/vnd.github.v3+json")
                    .header("User-Agent", "ArcherGuard-Android")
                    .build()

                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) return@withContext null
                    val body = response.body?.string() ?: return@withContext null
                    val release = json.decodeFromString<GithubRelease>(body)
                    val remoteVer = release.tagName.removePrefix("v").trim()
                    val hasNewVer = isNewerVersion(remoteVer, currentVersion)
                    UpdateInfo(
                        hasUpdate = hasNewVer,
                        latestVersion = release.tagName,
                        releaseNotes = release.body.ifEmpty { "Performance optimizations and bug fixes." },
                        downloadUrl = release.htmlUrl
                    )
                }
            } catch (e: Exception) {
                null
            }
        }

    private fun isNewerVersion(remote: String, current: String): Boolean {
        val rParts = remote.split(".").mapNotNull { it.toIntOrNull() }
        val cParts = current.split(".").mapNotNull { it.toIntOrNull() }
        val maxLen = maxOf(rParts.size, cParts.size)
        for (i in 0 until maxLen) {
            val r = rParts.getOrElse(i) { 0 }
            val c = cParts.getOrElse(i) { 0 }
            if (r > c) return true
            if (r < c) return false
        }
        return false
    }
}
