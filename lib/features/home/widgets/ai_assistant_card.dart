/// FinBill — AI Assistant gradient card.
///
/// A premium hero card on the Home dashboard promoting the AI assistant.
/// Uses the brand gradient for a polished, modern fintech look.
///
/// File location: lib/features/home/widgets/ai_assistant_card.dart
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({super.key, this.onTryNow});

  final VoidCallback? onTryNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left content ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI sparkle icon badge
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Title
                Text(
                  AppStrings.aiTitle,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSizes.xs),

                // Subtitle
                Text(
                  AppStrings.aiSubtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // CTA button (inverted: white bg, primary text)
                ElevatedButton(
                  onPressed: onTryNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm + 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    AppStrings.aiButton,
                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // ── Right decorative element ──────────────────────────
          const Opacity(
            opacity: 0.15,
            child: Icon(
              Icons.psychology_rounded,
              size: 100,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
