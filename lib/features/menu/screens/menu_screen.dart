/// FinBill — Menu screen.
///
/// Scrollable settings/navigation menu organised into 7 sections:
/// Business, Reports, Account, Rewards, Support, Legal, and Logout.
///
/// Each item navigates via GoRouter named routes. The "GST Filing"
/// item shows a "Coming Soon" badge and is non-navigable.
///
/// File location: lib/features/menu/screens/menu_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../widgets/section_header.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.navMenu)),
      body: ListView(
        children: [
          const SizedBox(height: AppSizes.sm),

          // ── BUSINESS ────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionBusiness),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.business_rounded,
              label: AppStrings.businessProfile,
              onTap: () => context.goNamed(RouteNameIds.businessProfile),
            ),
            _MenuItem(
              icon: Icons.print_rounded,
              label: AppStrings.printSettings,
              onTap: () => context.goNamed(RouteNameIds.printSettings),
            ),
            _MenuItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.manageInventory,
              onTap: () => context.goNamed(RouteNameIds.inventory),
            ),
            _MenuItem(
              icon: Icons.queue_rounded,
              label: AppStrings.smartOrderQueue,
              onTap: () => context.goNamed(RouteNameIds.smartOrderQueue),
            ),
            _MenuItem(
              icon: Icons.access_time_rounded,
              label: AppStrings.dueTracker,
              onTap: () => context.goNamed(RouteNameIds.dueTracker),
            ),
            _MenuItem(
              icon: Icons.auto_awesome,
              label: AppStrings.aiQuotation,
              onTap: () => context.goNamed(RouteNameIds.aiQuotation),
            ),
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.gstFiling,
              onTap: () {
                print('GST screen opened');
                context.goNamed(RouteNameIds.gstDashboard);
              },
            ),
          ]),

          // ── REPORTS ─────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionReports),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.bar_chart_rounded,
              label: AppStrings.reports,
              onTap: () => context.goNamed(RouteNameIds.reports),
            ),
          ]),

          // ── ACCOUNT ─────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionAccount),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.settings_outlined,
              label: AppStrings.accountSettings,
              onTap: () => context.goNamed(RouteNameIds.accountSettings),
            ),
            _MenuItem(
              icon: Icons.workspace_premium_outlined,
              label: AppStrings.subscription,
              onTap: () => context.goNamed(RouteNameIds.subscription),
            ),
          ]),

          // ── REWARDS ─────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionRewards),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.card_giftcard_rounded,
              label: AppStrings.referFriend,
              onTap: () {
                // TODO: Navigate to referral screen
              },
            ),
          ]),

          // ── SUPPORT ─────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionSupport),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.support_agent_rounded,
              label: AppStrings.customerSupport,
              onTap: () => context.goNamed(RouteNameIds.customerSupport),
            ),
            _MenuItem(
              icon: Icons.info_outline_rounded,
              label: AppStrings.aboutUs,
              onTap: () => context.goNamed(RouteNameIds.aboutUs),
            ),
          ]),

          // ── LEGAL ───────────────────────────────────────────
          const SectionHeader(title: AppStrings.sectionLegal),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              label: AppStrings.privacyPolicy,
              onTap: () => context.goNamed(RouteNameIds.privacyPolicy),
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              label: AppStrings.termsConditions,
              onTap: () => context.goNamed(RouteNameIds.termsConditions),
            ),
          ]),

          // ── LOGOUT ──────────────────────────────────────────
          const SizedBox(height: AppSizes.md),
          _LogoutTile(onTap: () {
            // TODO: Handle logout via AuthService
          }),

          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  /// "Coming Soon" chip shown next to GST Filing.
  static Widget _comingSoonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Soon',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Private widgets
// ══════════════════════════════════════════════════════════════════

/// A single menu item with icon, label, optional trailing, and tap callback.
class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
}

/// Renders a group of [_MenuItem]s in a styled rounded container
/// with dividers between each item.
class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.iconDefault, size: 22),
                title: Text(item.label, style: AppTextStyles.bodyMedium),
                trailing: item.trailing ??
                    const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }),
      ),
    );
  }
}

/// Standalone red logout tile at the bottom of the menu.
class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: AppColors.error),
        title: Text(
          AppStrings.logout,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
        onTap: onTap,
      ),
    );
  }
}
