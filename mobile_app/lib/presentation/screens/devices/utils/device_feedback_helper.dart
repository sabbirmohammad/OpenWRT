import 'package:flutter/material.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/clipboard_helper.dart';

/// Legacy adapter delegating to standard [AppFeedback] and [ClipboardHelper] (DRY compliant).
@Deprecated('Use AppFeedback and ClipboardHelper directly.')
class DeviceFeedbackHelper {
  DeviceFeedbackHelper._();

  static void showNotification({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    AppFeedback.showSnackBar(
      context,
      message: message,
      icon: icon,
      customColor: color,
    );
  }

  static void copyToClipboard({
    required BuildContext context,
    required String text,
    required String label,
  }) {
    ClipboardHelper.copy(context, text, label);
  }
}
