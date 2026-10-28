import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_feedback.dart';

class ClipboardHelper {
  /// Copies text to system clipboard and displays a consistent confirmation toast
  static void copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppFeedback.showSuccess(
      context,
      '$label ($text) copied to clipboard.',
      icon: Icons.copy_rounded,
    );
  }
}
