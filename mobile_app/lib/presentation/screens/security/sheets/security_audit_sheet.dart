import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';

class SecurityAuditSheet extends StatelessWidget {
  final int score;
  final String scoreRatingText;
  final Color scoreColor;
  final bool isPmf;
  final bool isRebind;
  final bool isWanLock;
  final bool isDoh;
  final bool isWg;
  final bool isAutoHardening;
  final VoidCallback onAutoHarden;

  const SecurityAuditSheet({
    super.key,
    required this.score,
    required this.scoreRatingText,
    required this.scoreColor,
    required this.isPmf,
    required this.isRebind,
    required this.isWanLock,
    required this.isDoh,
    required this.isWg,
    required this.isAutoHardening,
    required this.onAutoHarden,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: GlossyColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.security_rounded, color: scoreColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Audit & Posture',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Current Armor Rating: $score / 100 • $scoreRatingText',
                      style: TextStyle(color: scoreColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildAuditItem('802.11w Protected Management Frames (PMF)', 'Deauth attack & spoof protection', isPmf),
          _buildAuditItem('DNS Rebinding Attack Protection', 'RFC 1918 private IP resolution defense', isRebind),
          _buildAuditItem('Remote WAN Management Lockdown', 'Port 80/443/22 drop on public WAN', isWanLock),
          _buildAuditItem('DNS-over-HTTPS (DoH) TLS 1.3', 'ISP snooping & DNS hijacking defense', isDoh),
          _buildAuditItem('WireGuard VPN Tunnel', 'Peer-to-peer encrypted communications', isWg),
          const SizedBox(height: 22),
          if (score < 100)
            SizedBox(
              width: double.infinity,
              child: GlossyButton(
                label: 'One-Tap Auto-Harden Router Now',
                icon: Icons.shield_rounded,
                style: GlossyButtonStyle.primary,
                isLoading: isAutoHardening,
                onPressed: onAutoHarden,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: GlossyColors.emeraldMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GlossyColors.emeraldMint.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: GlossyColors.emeraldMint, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'All Essential Router Protections Active!',
                      style: TextStyle(color: GlossyColors.emeraldMint, fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuditItem(String title, String desc, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: passed ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(desc, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          GlossyBadge(
            label: passed ? 'Active' : 'Missing',
            dotColor: passed ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
          ),
        ],
      ),
    );
  }
}
