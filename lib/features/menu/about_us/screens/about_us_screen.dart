/// FinBill — About Us screen.
///
/// A premium, fintech-driven "About Us" page detailing the company's
/// mission, vision, offerings, and contact information.
///
/// File location: lib/features/menu/about_us/screens/about_us_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        children: [
          // ── SECTION 1: HERO ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Reimagining Business\nAccounting for India',
                    style: AppTextStyles.h2.copyWith(color: Colors.white, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Atulix Finserv is building smart, AI-powered tools that simplify billing, accounting, and compliance for modern businesses.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // ── SECTION 2 & 3: WHO WE ARE & MISSION ─────────────────
          _buildInfoCard(
            title: 'Who We Are',
            icon: Icons.business_rounded,
            content: 'Atulix Finserv is a technology-driven fintech company focused on simplifying business operations for Indian entrepreneurs. We combine automation, artificial intelligence, and practical financial expertise to create tools that reduce manual effort and improve accuracy.',
          ),
          _buildInfoCard(
            title: 'Our Mission',
            icon: Icons.flag_rounded,
            content: 'Our mission is to make business management effortless for every small and medium business in India by replacing traditional, complex accounting processes with simple, intelligent, and fast digital solutions.',
          ),
          _buildInfoCard(
            title: 'Our Vision',
            icon: Icons.visibility_rounded,
            content: 'To become the most trusted business management platform for millions of small businesses by leveraging technology and innovation.',
          ),

          // ── SECTION 4: WHAT WE OFFER ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Text('What We Offer', style: AppTextStyles.h3),
          ),
          _buildFeatureGrid([
            _FeatureItem('Smart Billing & Invoicing', Icons.receipt_long_rounded),
            _FeatureItem('AI-powered Voice Entry', Icons.mic_rounded),
            _FeatureItem('Inventory Management', Icons.inventory_2_rounded),
            _FeatureItem('Due Tracking & Payment Insights', Icons.account_balance_wallet_rounded),
            _FeatureItem('GST-ready Business Tools', Icons.gavel_rounded),
            _FeatureItem('Business Analytics & Reports', Icons.bar_chart_rounded),
          ]),
          const SizedBox(height: AppSizes.lg),

          // ── SECTION 5: WHY CHOOSE US ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Text('Why Choose Atulix', style: AppTextStyles.h3),
          ),
          _buildBulletList([
            'Built for Indian Businesses',
            'Easy to Use, No Accounting Knowledge Required',
            'AI-driven Automation',
            'Secure & Reliable Data Handling',
            'Continuous Innovation & Updates',
          ]),
          const SizedBox(height: AppSizes.xl),

          // ── SECTION 7: COMPANY DETAILS ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.domain_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Text('Company Details', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _buildContactRow(Icons.apartment_rounded, 'Atulix Finserv\nLaxmi Nagar, Delhi, India'),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildContactRow(
                    Icons.phone_rounded,
                    '+91 9279545313',
                    isLink: true,
                    onTap: () => launchUrl(Uri.parse('tel:+919279545313')),
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildContactRow(
                    Icons.email_rounded,
                    'contact@atulix.com',
                    isLink: true,
                    onTap: () => launchUrl(Uri.parse('mailto:contact@atulix.com')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xxl),

          // ── SECTION 8: FOOTER ───────────────────────────────────
          Center(
            child: Column(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.error, size: 24),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Built with innovation for India\'s\ngrowing businesses',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER WIDGETS ─────────────────────────────────────────────

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.md, right: AppSizes.md, bottom: AppSizes.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(List<_FeatureItem> features) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSizes.sm,
          crossAxisSpacing: AppSizes.sm,
          childAspectRatio: 2.5,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(feature.icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    feature.label,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(item, style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, {bool isLink = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLink ? AppColors.primary : AppColors.textPrimary,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String label;
  final IconData icon;

  _FeatureItem(this.label, this.icon);
}
