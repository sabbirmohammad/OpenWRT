import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/glossy_colors.dart';

class DeviceFeedbackHelper {
  DeviceFeedbackHelper._();

  static void showNotification({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
        elevation: 8,
        backgroundColor: GlossyColors.backgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void copyToClipboard({
    required BuildContext context,
    required String text,
    required String label,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    showNotification(
      context: context,
      message: '$label copied to clipboard ($text)',
      icon: Icons.copy_rounded,
      color: GlossyColors.primaryBlue,
    );
  }
}
