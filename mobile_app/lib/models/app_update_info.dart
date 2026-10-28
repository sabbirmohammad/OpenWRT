import '../core/utils/formatters.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String currentBuildNumber;
  final String latestVersion;
  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final String? apkDownloadUrl;
  final int apkSize;
  final String? htmlUrl;
  final DateTime? publishedAt;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    required this.tagName,
    required this.releaseTitle,
    required this.releaseNotes,
    this.apkDownloadUrl,
    this.apkSize = 0,
    this.htmlUrl,
    this.publishedAt,
    required this.hasUpdate,
  });

  String get formattedSize {
    if (apkSize <= 0) return '';
    return Formatters.formatBytes(apkSize);
  }

  factory AppUpdateInfo.fromGitHubRelease({
    required Map<String, dynamic> json,
    required String currentVersion,
    required String currentBuildNumber,
  }) {
    final tagName = json['tag_name'] as String? ?? '';
    final releaseTitle = json['name'] as String? ?? tagName;
    final releaseNotes = json['body'] as String? ?? 'No release notes provided.';
    final htmlUrl = json['html_url'] as String?;
    final publishedAtStr = json['published_at'] as String?;
    final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

    // Search for .apk asset in release assets
    String? apkUrl;
    int apkSize = 0;
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          apkSize = (asset['size'] as num?)?.toInt() ?? 0;
          break;
        }
      }
    }

    // Version comparison
    final cleanedLatest = _cleanVersion(tagName);
    final hasUpdate = isNewerVersion(
      latest: cleanedLatest,
      current: currentVersion,
      currentBuild: currentBuildNumber,
    );

    return AppUpdateInfo(
      currentVersion: currentVersion,
      currentBuildNumber: currentBuildNumber,
      latestVersion: cleanedLatest,
      tagName: tagName,
      releaseTitle: releaseTitle,
      releaseNotes: releaseNotes,
      apkDownloadUrl: apkUrl,
      apkSize: apkSize,
      htmlUrl: htmlUrl,
      publishedAt: publishedAt,
      hasUpdate: hasUpdate,
    );
  }

  static String _cleanVersion(String tag) {
    var v = tag.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    return v;
  }

  static bool isNewerVersion({
    required String latest,
    required String current,
    required String currentBuild,
  }) {
    if (latest.isEmpty) return false;

    // Split version and build number if present
    final latestParts = latest.split('+');
    final latestSemver = latestParts[0];
    final latestBuildNum = latestParts.length > 1 ? int.tryParse(latestParts[1]) ?? 0 : 0;

    final currentParts = current.split('+');
    final currentSemver = currentParts[0];
    final currentBuildNum = currentParts.length > 1
        ? int.tryParse(currentParts[1]) ?? 0
        : int.tryParse(currentBuild) ?? 0;

    final latestNumbers = latestSemver.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final currentNumbers = currentSemver.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    final maxLen = latestNumbers.length > currentNumbers.length ? latestNumbers.length : currentNumbers.length;
    for (int i = 0; i < maxLen; i++) {
      final l = i < latestNumbers.length ? latestNumbers[i] : 0;
      final c = i < currentNumbers.length ? currentNumbers[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }

    // If semver is identical, compare build number
    if (latestBuildNum > currentBuildNum) {
      return true;
    }

    return false;
  }
}
