import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/services/github_update_service.dart';
import '../../core/theme/glossy_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_update_info.dart';
import '../widgets/glossy_button.dart';

class UpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final GithubUpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required GithubUpdateService updateService,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDialog(
        updateInfo: updateInfo,
        updateService: updateService,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadPercent = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  File? _downloadedFile;
  String? _errorMessage;
  bool _isInstalling = false;

  Future<void> _startDownload() async {
    final apkUrl = widget.updateInfo.apkDownloadUrl;
    if (apkUrl == null || apkUrl.isEmpty) {
      setState(() {
        _errorMessage = 'No APK download asset found in this GitHub release.';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _downloadPercent = 0.0;
    });

    try {
      final file = await widget.updateService.downloadApk(
        downloadUrl: apkUrl,
        onProgress: (received, total, percent) {
          if (mounted) {
            setState(() {
              _receivedBytes = received;
              _totalBytes = total;
              _downloadPercent = percent.clamp(0.0, 1.0);
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedFile = file;
        });

        // Trigger installation immediately after download
        _installApk();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Download failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _installApk() async {
    final file = _downloadedFile;
    if (file == null) return;

    setState(() {
      _isInstalling = true;
      _errorMessage = null;
    });

    final success = await widget.updateService.installApk(file.path);
    if (!success && mounted) {
      setState(() {
        _isInstalling = false;
        _errorMessage = 'Could not start Android installer. Check app permissions.';
      });
    } else if (mounted) {
      setState(() {
        _isInstalling = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    return Formatters.formatBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: GlossyColors.backgroundSecondary.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GlossyColors.glassBorderLight, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon & badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GlossyColors.primaryBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: GlossyColors.primaryBlue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        color: GlossyColors.skyBlue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'নতুন আপডেট উপলব্ধ',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GitHub Release: ${info.tagName}',
                            style: const TextStyle(
                              color: GlossyColors.emeraldMint,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Version comparison pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: GlossyColors.glassSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GlossyColors.glassBorderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'বর্তমান: ',
                            style: TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                          ),
                          Text(
                            'v${info.currentVersion}',
                            style: const TextStyle(
                              color: GlossyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: GlossyColors.skyBlue),
                      Row(
                        children: [
                          const Text(
                            'নতুন: ',
                            style: TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                          ),
                          Text(
                            'v${info.latestVersion}',
                            style: const TextStyle(
                              color: GlossyColors.emeraldMint,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (info.apkSize > 0)
                        Text(
                          info.formattedSize,
                          style: const TextStyle(
                            color: GlossyColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Release notes / changelog
                const Text(
                  'কী কী পরিবর্তন এসেছে:',
                  style: TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GlossyColors.backgroundPrimary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GlossyColors.glassBorderDark),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      info.releaseNotes,
                      style: const TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Progress indicator or error
                if (_isDownloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadPercent > 0 ? _downloadPercent : null,
                      backgroundColor: GlossyColors.glassSurfaceActive,
                      valueColor: const AlwaysStoppedAnimation<Color>(GlossyColors.primaryBlue),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'আপডেট ডাউনলোড হচ্ছে (${(_downloadPercent * 100).toInt()}%)...',
                        style: const TextStyle(color: GlossyColors.skyBlue, fontSize: 12),
                      ),
                      Text(
                        '${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}',
                        style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                if (_downloadedFile != null && !_isDownloading) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: GlossyColors.emeraldMint, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'ডাউনলোড সম্পন্ন হয়েছে! ইনস্টল করতে নিচের বাটনে ট্যাপ করুন।',
                          style: TextStyle(color: GlossyColors.emeraldMint, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                if (_errorMessage != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: GlossyColors.roseCoral, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: GlossyColors.roseCoral, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Action buttons
                Row(
                  children: [
                    if (!_isDownloading)
                      Expanded(
                        child: GlossyButton(
                          label: 'পরে',
                          style: GlossyButtonStyle.secondary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    if (!_isDownloading) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GlossyButton(
                        label: _downloadedFile != null
                            ? (_isInstalling ? 'ইনস্টল হচ্ছে...' : 'ইনস্টল করুন')
                            : (_isDownloading ? 'ডাউনলোড হচ্ছে...' : 'আপডেট করুন'),
                        icon: _downloadedFile != null
                            ? Icons.install_mobile_rounded
                            : Icons.download_rounded,
                        style: GlossyButtonStyle.primary,
                        isLoading: _isDownloading || _isInstalling,
                        onPressed: _isDownloading
                            ? null
                            : (_downloadedFile != null ? _installApk : _startDownload),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
