import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/app_update_info.dart';
import 'preferences_service.dart';

class GithubUpdateService {
  static const MethodChannel _channel = MethodChannel('com.archerguard.mobile_app/updater');
  static const int autoCheckIntervalMs = 24 * 60 * 60 * 1000; // 24 hours cooldown

  final PreferencesService _prefs;

  GithubUpdateService(this._prefs);

  /// Check for latest release from GitHub (with Web fallback and rate-limit handling)
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    try {
      final repo = _prefs.githubRepo.trim();
      if (repo.isEmpty) return null;

      // 24-hour cooldown for automatic checks
      if (!force) {
        final lastCheck = _prefs.lastCheckTimestamp;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastCheck < autoCheckIntervalMs) {
          debugPrint('[GithubUpdateService] Skipping background update check (24h cooldown active)');
          return null;
        }
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;

      // 1. Primary: Official GitHub REST API
      AppUpdateInfo? updateInfo = await _checkViaGitHubApi(
        repo: repo,
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
      );

      // 2. Fallback: If GitHub API is rate-limited (403) or fails, use Web Release 302 Redirect
      if (updateInfo == null) {
        debugPrint('[GithubUpdateService] Falling back to Web Release 302 redirect check...');
        updateInfo = await _checkViaWebFallback(
          repo: repo,
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
        );
      }

      if (updateInfo != null) {
        await _prefs.setLastCheckTimestamp(DateTime.now().millisecondsSinceEpoch);
      }

      return updateInfo;
    } catch (e) {
      debugPrint('[GithubUpdateService] Error checking update: $e');
      return null;
    }
  }

  /// Official GitHub REST API check
  Future<AppUpdateInfo?> _checkViaGitHubApi({
    required String repo,
    required String currentVersion,
    required String currentBuildNumber,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      final request = await client.getUrl(Uri.parse('https://api.github.com/repos/$repo/releases/latest'));
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      request.headers.set('User-Agent', 'ArcherGuard-Android');

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);
        return AppUpdateInfo.fromGitHubRelease(
          json: data,
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
        );
      } else if (response.statusCode == 404) {
        debugPrint('[GithubUpdateService] No releases found on GitHub repo: $repo');
        return AppUpdateInfo(
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
          latestVersion: currentVersion,
          tagName: 'v$currentVersion',
          releaseTitle: 'Current Version',
          releaseNotes: 'কোনো নতুন রিলিজ পাওয়া যায়নি।',
          hasUpdate: false,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[GithubUpdateService] GitHub API check failed: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Web 302 redirect fallback (handles GitHub API rate limiting)
  Future<AppUpdateInfo?> _checkViaWebFallback({
    required String repo,
    required String currentVersion,
    required String currentBuildNumber,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      final request = await client.getUrl(Uri.parse('https://github.com/$repo/releases/latest'));
      request.followRedirects = false;
      request.headers.set('User-Agent', 'ArcherGuard-Android');

      final response = await request.close();
      final location = response.headers.value('location');

      if (location != null && location.isNotEmpty && location.contains('/releases/tag/')) {
        final tagName = location.split('/releases/tag/').last.trim();
        if (tagName.isNotEmpty) {
          // Look up expanded assets or construct default release asset URL
          String apkUrl = 'https://github.com/$repo/releases/download/$tagName/ArcherGuard-$tagName.apk';
          int apkSize = 0;

          try {
            final assetsReq = await client.getUrl(
              Uri.parse('https://github.com/$repo/releases/expanded_assets/$tagName'),
            );
            assetsReq.headers.set('User-Agent', 'ArcherGuard-Android');
            final assetsRes = await assetsReq.close();
            if (assetsRes.statusCode == 200) {
              final html = await assetsRes.transform(utf8.decoder).join();
              final match = RegExp(r'href="([^"]+\.apk)"').firstMatch(html);
              if (match != null) {
                final path = match.group(1)!;
                apkUrl = path.startsWith('http') ? path : 'https://github.com$path';
              }
            }
          } catch (_) {}

          final cleanedLatest = tagName.replaceFirst(RegExp(r'^[vV]'), '');
          final hasUpdate = AppUpdateInfo.isNewerVersion(
            latest: cleanedLatest,
            current: currentVersion,
            currentBuild: currentBuildNumber,
          );

          return AppUpdateInfo(
            currentVersion: currentVersion,
            currentBuildNumber: currentBuildNumber,
            latestVersion: cleanedLatest,
            tagName: tagName,
            releaseTitle: 'ArcherGuard $tagName',
            releaseNotes: 'নতুন ফিচার এবং নিরাপত্তা আপডেট অন্তর্ভুক্ত।',
            apkDownloadUrl: apkUrl,
            apkSize: apkSize,
            htmlUrl: location,
            hasUpdate: hasUpdate,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('[GithubUpdateService] Web fallback failed: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Download the APK file with chunk streaming and 302 redirect support
  Future<File?> downloadApk({
    required String downloadUrl,
    required void Function(int received, int total, double percent) onProgress,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      request.followRedirects = true;
      request.maxRedirects = 8;
      request.headers.set('User-Agent', 'ArcherGuard-Android');

      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final totalBytes = response.contentLength > 0 ? response.contentLength : 0;
      final tempDir = await getTemporaryDirectory();
      final updatesDir = Directory('${tempDir.path}/updates');
      if (!await updatesDir.exists()) {
        await updatesDir.create(recursive: true);
      }

      final apkFile = File('${updatesDir.path}/ArcherGuard-update.apk');
      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      final sink = apkFile.openWrite();
      int receivedBytes = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        final percent = totalBytes > 0 ? (receivedBytes / totalBytes) : 0.0;
        onProgress(receivedBytes, totalBytes, percent);
      }

      await sink.flush();
      await sink.close();

      return apkFile;
    } catch (e) {
      debugPrint('[GithubUpdateService] APK download failed: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Trigger native Android installation via FileProvider
  Future<bool> installApk(String filePath) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('installApk', {
        'filePath': filePath,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('[GithubUpdateService] Platform error installing APK: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[GithubUpdateService] Error installing APK: $e');
      return false;
    }
  }
}
