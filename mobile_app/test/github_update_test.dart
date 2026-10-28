import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/app_update_info.dart';

void main() {
  group('AppUpdateInfo & Semver Comparison Tests', () {
    test('Detects newer semver release', () {
      final json = {
        'tag_name': 'v1.1.0',
        'name': 'ArcherGuard v1.1.0',
        'body': 'New dashboard features and bug fixes',
        'html_url': 'https://github.com/sabbirmohammad/OpenWRT/releases/tag/v1.1.0',
        'published_at': '2026-10-28T03:00:00Z',
        'assets': [
          {
            'name': 'app-release.apk',
            'browser_download_url': 'https://github.com/sabbirmohammad/OpenWRT/releases/download/v1.1.0/app-release.apk',
            'size': 25165824, // 24 MB
          }
        ],
      };

      final info = AppUpdateInfo.fromGitHubRelease(
        json: json,
        currentVersion: '1.0.0',
        currentBuildNumber: '1',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '1.1.0');
      expect(info.apkDownloadUrl, 'https://github.com/sabbirmohammad/OpenWRT/releases/download/v1.1.0/app-release.apk');
      expect(info.formattedSize, '24.0 MB');
    });

    test('Recognizes current or older version as no update', () {
      final json = {
        'tag_name': 'v1.0.0',
        'name': 'ArcherGuard v1.0.0',
        'body': 'Initial release',
        'assets': [],
      };

      final info = AppUpdateInfo.fromGitHubRelease(
        json: json,
        currentVersion: '1.0.0',
        currentBuildNumber: '1',
      );

      expect(info.hasUpdate, isFalse);
    });

    test('Detects update based on build number when semver matches', () {
      final json = {
        'tag_name': 'v1.0.0+5',
        'name': 'ArcherGuard Patch',
        'body': 'Hotfix release',
        'assets': [
          {
            'name': 'archerguard.apk',
            'browser_download_url': 'https://github.com/download/app.apk',
            'size': 10485760,
          }
        ],
      };

      final info = AppUpdateInfo.fromGitHubRelease(
        json: json,
        currentVersion: '1.0.0',
        currentBuildNumber: '2',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '1.0.0+5');
      expect(info.apkDownloadUrl, 'https://github.com/download/app.apk');
    });
  });
}
