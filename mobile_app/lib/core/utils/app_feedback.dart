import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glossy_colors.dart';

class AppFeedback {
  /// Shows a standardized floating glossy SnackBar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    Color? customColor,
  }) {
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final backgroundColor = customColor ??
        (isError ? GlossyColors.roseCoral : GlossyColors.emeraldMint);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
        elevation: 8,
        backgroundColor: GlossyColors.backgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: backgroundColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        duration: duration,
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
                color: backgroundColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convenience helper for success messages
  static void showSuccess(BuildContext context, String message, {IconData? icon}) {
    showSnackBar(context, message: message, isError: false, icon: icon);
  }

  /// Convenience helper for info messages
  static void showInfo(BuildContext context, String message, {IconData? icon}) {
    showSnackBar(context, message: message, isError: false, icon: icon ?? Icons.info_outline, customColor: GlossyColors.lightBlue);
  }

  /// Convenience helper for warning messages
  static void showWarning(BuildContext context, String message, {IconData? icon}) {
    showSnackBar(context, message: message, isError: false, icon: icon ?? Icons.warning_amber_rounded, customColor: GlossyColors.amberWarm);
  }

  /// Convenience helper for error messages
  static void showError(BuildContext context, String message, {IconData? icon}) {
    showSnackBar(context, message: message, isError: true, icon: icon);
  }
}
