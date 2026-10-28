package com.archerguard.openwrt.core.network

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.util.concurrent.TimeUnit

@Serializable
data class GithubAsset(
    val name: String = "",
    @SerialName("browser_download_url") val browserDownloadUrl: String = "",
    val size: Long = 0L
)

@Serializable
data class GithubRelease(
    @SerialName("tag_name") val tagName: String = "",
    val name: String = "",
    val body: String = "",
    @SerialName("html_url") val htmlUrl: String = "",
    val assets: List<GithubAsset> = emptyList()
)

data class UpdateInfo(
    val hasUpdate: Boolean,
    val latestVersion: String,
    val releaseNotes: String,
    val downloadUrl: String,
    val apkDownloadUrl: String? = null,
    val apkSize: Long = 0L
)

class GithubUpdateService(
    private val client: OkHttpClient = OkHttpClient.Builder()
        .followRedirects(true)
        .followSslRedirects(true)
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build(),
    private val json: Json = Json { ignoreUnknownKeys = true }
) {
    suspend fun checkForUpdates(
        currentVersion: String = "1.0.0",
        repo: String = "sabbirmohammad/OpenWRT"
    ): UpdateInfo? = withContext(Dispatchers.IO) {
        val url = "https://api.github.com/repos/$repo/releases/latest"
        try {
            val request = Request.Builder()
                .url(url)
                .header("Accept", "application/vnd.github.v3+json")
                .header("User-Agent", "ArcherGuard-Android")
                .build()

            val apiSuccess = try {
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string()
                        if (body != null) {
                            val release = json.decodeFromString<GithubRelease>(body)
                            val remoteVer = release.tagName.removePrefix("v").trim()
                            val hasNewVer = isNewerVersion(remoteVer, currentVersion)

                            // Search for APK asset or construct direct GitHub release asset URL
                            val apkAsset = release.assets.firstOrNull { it.name.endsWith(".apk", ignoreCase = true) }
                            val apkUrl = apkAsset?.browserDownloadUrl
                                ?: "https://github.com/$repo/releases/download/${release.tagName}/ArcherGuard-${release.tagName}.apk"
                            val apkSize = apkAsset?.size ?: 0L

                            return@withContext UpdateInfo(
                                hasUpdate = hasNewVer,
                                latestVersion = release.tagName,
                                releaseNotes = release.body.ifEmpty { "Performance optimizations and bug fixes." },
                                downloadUrl = release.htmlUrl,
                                apkDownloadUrl = apkUrl,
                                apkSize = apkSize
                            )
                        }
                    }
                    false
                }
            } catch (e: Exception) {
                false
            }

            // Fallback: Query web redirect if API was rate-limited
            try {
                val webRequest = Request.Builder()
                    .url("https://github.com/$repo/releases/latest")
                    .header("User-Agent", "ArcherGuard-Android")
                    .build()
                client.newCall(webRequest).execute().use { response ->
                    if (response.isSuccessful) {
                        val finalUrl = response.request.url.toString()
                        val tag = finalUrl.substringAfterLast("/")
                        if (tag.startsWith("v")) {
                            val remoteVer = tag.removePrefix("v").trim()
                            val hasNewVer = isNewerVersion(remoteVer, currentVersion)
                            val apkUrl = "https://github.com/$repo/releases/download/$tag/ArcherGuard-$tag.apk"
                            return@withContext UpdateInfo(
                                hasUpdate = hasNewVer,
                                latestVersion = tag,
                                releaseNotes = "Performance optimizations, bug fixes, and layout improvements.",
                                downloadUrl = finalUrl,
                                apkDownloadUrl = apkUrl,
                                apkSize = 12300000L
                            )
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore fallback error
            }

            null
        } catch (e: Exception) {
            null
        }
    }

    suspend fun downloadApk(
        context: Context,
        downloadUrl: String,
        fileName: String = "ArcherGuard-update.apk",
        onProgress: (downloadedBytes: Long, totalBytes: Long, percent: Float) -> Unit
    ): File? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(downloadUrl)
                .header("User-Agent", "ArcherGuard-Android")
                .build()

            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) return@withContext null
                val body = response.body ?: return@withContext null
                val totalBytes = body.contentLength()

                val updatesDir = File(context.cacheDir, "updates")
                if (!updatesDir.exists()) {
                    updatesDir.mkdirs()
                }

                val destinationFile = File(updatesDir, fileName)
                if (destinationFile.exists()) {
                    destinationFile.delete()
                }

                destinationFile.outputStream().use { output ->
                    body.byteStream().use { input ->
                        val buffer = ByteArray(8 * 1024)
                        var bytesRead: Int
                        var totalRead = 0L

                        while (input.read(buffer).also { bytesRead = it } != -1) {
                            output.write(buffer, 0, bytesRead)
                            totalRead += bytesRead
                            val percent = if (totalBytes > 0) {
                                (totalRead.toFloat() / totalBytes.toFloat()).coerceIn(0f, 1f)
                            } else {
                                0f
                            }
                            onProgress(totalRead, totalBytes, percent)
                        }
                        output.flush()
                    }
                }
                destinationFile
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun canRequestPackageInstalls(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    fun openInstallPermissionSettings(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }

    fun installApk(context: Context, apkFile: File): Boolean {
        try {
            if (!apkFile.exists()) return false

            if (!canRequestPackageInstalls(context)) {
                openInstallPermissionSettings(context)
                return false
            }

            val apkUri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                apkFile
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(apkUri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            context.startActivity(intent)
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
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
