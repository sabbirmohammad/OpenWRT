import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';

class SecurityScoreHelper {
  static int calculateScore(RouterStatusModel? status) {
    if (status == null) return 80;

    int score = 20;
    if (status.network.wireguardEnabled) score += 20;
    if (status.network.dohEnabled) score += 20;
    if (status.wireless.pmfProtected) score += 15;
    if (status.network.dnsRebindProtection) score += 15;
    if (status.network.wanLockdown) score += 10;

    return score.clamp(0, 100);
  }

  static Color getScoreColor(int score) {
    if (score >= 90) return GlossyColors.emeraldMint;
    if (score >= 70) return GlossyColors.lightBlue;
    if (score >= 50) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  static String getRatingText(int score) {
    if (score >= 90) return 'Security Level: A+ Optimal';
    if (score >= 75) return 'Security Level: A Hardened';
    if (score >= 50) return 'Security Level: B Moderate';
    return 'Security Level: C Action Required';
  }
}
