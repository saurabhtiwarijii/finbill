/// FinBill — Customer Support screen.
///
/// Displays contact options (Phone, Email, WhatsApp) with tap actions
/// that launch the device's native dialer, email client, or WhatsApp.
///
/// File location: lib/features/menu/support/screens/customer_support_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Support'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.headset_mic_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'We\'re here to help!',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Reach out to us through any of the channels below.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Phone
          _SupportTile(
            icon: Icons.phone_rounded,
            iconColor: AppColors.success,
            title: 'Call Us',
            subtitle: '+91 92795 45313',
            onTap: () => _launch(
              context,
              Uri.parse('tel:+919279545313'),
            ),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          // Email
          _SupportTile(
            icon: Icons.email_rounded,
            iconColor: AppColors.primary,
            title: 'Email Us',
            subtitle: 'contact@atulix.com',
            onTap: () => _launch(
              context,
              Uri.parse('mailto:contact@atulix.com'),
            ),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          // WhatsApp
          _SupportTile(
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF25D366),
            title: 'WhatsApp',
            subtitle: '+91 85888 70031',
            onTap: () => _launch(
              context,
              Uri.parse('https://wa.me/918588870031?text=Hi%20I%20need%20support'),
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // ── FAQ Section ──────────────────────────────────────────
          Text('Frequently Asked Questions', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.sm + 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              children: [
                _FaqTile(
                  question: 'How do I add a new transaction?',
                  answer:
                      'Go to the Sales or Purchases tab and tap the "+" button. '
                      'Fill in the details and hit Save. Your transaction will '
                      'be recorded instantly.',
                ),
                Divider(height: 1, color: AppColors.divider),
                _FaqTile(
                  question: 'Can I export my reports?',
                  answer:
                      'Yes! Navigate to Menu → Reports. You can generate PDF '
                      'reports and share them via WhatsApp, Email, or any '
                      'other sharing app on your device.',
                ),
                Divider(height: 1, color: AppColors.divider),
                _FaqTile(
                  question: 'How to use voice assistant?',
                  answer:
                      'Tap the AI Assistant icon on the Home screen header. '
                      'You can speak naturally to create invoices, check stock, '
                      'or ask questions about your business data.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // ── Support Hours ────────────────────────────────────────
          Text('Support Hours', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.sm + 4),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _HoursRow(
                  icon: Icons.work_outline_rounded,
                  day: 'Monday – Friday',
                  time: '9:00 AM – 6:00 PM',
                ),
                const Divider(height: 24, color: AppColors.divider),
                _HoursRow(
                  icon: Icons.weekend_outlined,
                  day: 'Saturday',
                  time: '10:00 AM – 4:00 PM',
                ),
                const Divider(height: 24, color: AppColors.divider),
                _HoursRow(
                  icon: Icons.event_busy_outlined,
                  day: 'Sunday',
                  time: 'Closed',
                  isClosed: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this link. Please try manually.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ── Support Tile ──────────────────────────────────────────────────

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSizes.md),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ Tile (Collapsible) ──────────────────────────────────────

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSizes.md, 0, AppSizes.md, AppSizes.md,
      ),
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(question, style: AppTextStyles.bodyLarge),
      children: [
        Text(
          answer,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Hours Row ────────────────────────────────────────────────────

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.icon,
    required this.day,
    required this.time,
    this.isClosed = false,
  });

  final IconData icon;
  final String day;
  final String time;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isClosed ? AppColors.error : AppColors.primary),
        const SizedBox(width: AppSizes.sm + 4),
        Expanded(
          child: Text(day, style: AppTextStyles.bodyLarge),
        ),
        Text(
          time,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isClosed ? AppColors.error : AppColors.textSecondary,
            fontWeight: isClosed ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
