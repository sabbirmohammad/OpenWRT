import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';

class SecurityScoreCard extends StatelessWidget {
  final int score;
  final String scoreRatingText;
  final Color scoreColor;
  final bool isPmfActive;
  final bool isRebindActive;
  final bool isDohActive;
  final VoidCallback onOpenAudit;

  const SecurityScoreCard({
    super.key,
    required this.score,
    required this.scoreRatingText,
    required this.scoreColor,
    required this.isPmfActive,
    required this.isRebindActive,
    required this.isDohActive,
    required this.onOpenAudit,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'SCORE',
                        style: TextStyle(
                          color: scoreColor.withValues(alpha: 0.8),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scoreRatingText,
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GlossyBadge(
                          label: score >= 90 ? 'Hardened' : 'Checkup',
                          dotColor: scoreColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'PMF ${isPmfActive ? "Active" : "Off"} • Rebind ${isRebindActive ? "Guarded" : "Off"} • DoH ${isDohActive ? "Encrypted" : "Off"}',
                      style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GlossyButton(
              label: 'Security Audit & Posture Checklist',
              icon: Icons.checklist_rounded,
              style: GlossyButtonStyle.secondary,
              onPressed: onOpenAudit,
            ),
          ),
        ],
      ),
    );
  }
}
