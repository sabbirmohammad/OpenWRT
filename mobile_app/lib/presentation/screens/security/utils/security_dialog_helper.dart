import 'package:flutter/material.dart';
import '../../../../models/router_status_model.dart';
import '../sheets/device_picker_sheet.dart';
import '../sheets/security_audit_sheet.dart';
import 'security_score_helper.dart';

class SecurityDialogHelper {
  static void showAuditSheet(
    BuildContext context, {
    required RouterStatusModel? status,
    required bool isAutoHardening,
    required VoidCallback onAutoHarden,
  }) {
    final score = SecurityScoreHelper.calculateScore(status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SecurityAuditSheet(
        score: score,
        scoreRatingText: SecurityScoreHelper.getRatingText(score),
        scoreColor: SecurityScoreHelper.getScoreColor(score),
        isPmf: status?.wireless.pmfProtected ?? true,
        isRebind: status?.network.dnsRebindProtection ?? true,
        isWanLock: status?.network.wanLockdown ?? true,
        isDoh: status?.network.dohEnabled ?? true,
        isWg: status?.network.wireguardEnabled ?? false,
        isAutoHardening: isAutoHardening,
        onAutoHarden: onAutoHarden,
      ),
    );
  }

  static void showDevicePicker(
    BuildContext context, {
    required List<ClientInfo> clients,
    required Function(String mac, String hostname) onKickClient,
    required Function(String mac) onBlockClient,
    required Function(String mac) onUnblockClient,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DevicePickerSheet(
        clients: clients,
        onKickClient: onKickClient,
        onBlockClient: onBlockClient,
        onUnblockClient: onUnblockClient,
      ),
    );
  }
}
