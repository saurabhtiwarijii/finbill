/// FinBill — Home Dashboard screen.
///
/// The first tab visible to the user. Composed of four sections built
/// from dedicated widgets. Uses [HomeController] for state — currently
/// populated with placeholder data; will connect to Firestore later.
///
/// Sections:
///   1. Header — app branding, notification and AI icons
///   2. Today's Insights — Sales & Purchases metric cards
///   3. Pending Actions — status card with "View More"
///   4. AI Assistant — gradient hero card with "Try Now" CTA
///
/// File location: lib/features/home/screens/home_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import '../widgets/insights_card.dart';
import '../widgets/pending_actions_card.dart';
import '../widgets/ai_assistant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),

                  // ── 1. Header ─────────────────────────────────
                  _buildHeader(),
                  const SizedBox(height: AppSizes.lg),

                  // ── 2. Today's Insights ───────────────────────
                  const Text(AppStrings.todaysInsights, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSizes.sm + 4),
                  _buildInsightsRow(),
                  const SizedBox(height: AppSizes.lg),

                  // ── 3. Pending Actions ────────────────────────
                  PendingActionsCard(
                    subtitle: _controller.pendingSubtitle,
                    count: _controller.pendingActionCount,
                    onViewMore: () {
                      context.goNamed(RouteNameIds.smartOrderQueue);
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // ── 4. AI Assistant ───────────────────────────
                  AiAssistantCard(
                    onTryNow: () {
                      // TODO: Open AI assistant screen
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header row ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        // App logo badge & Name
        InkWell(
          onTap: () => context.goNamed(RouteNameIds.businessProfile),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.xs,
              horizontal: AppSizes.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm + 4,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    'F',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSizes.sm + 4),
                const Text(AppStrings.appName, style: AppTextStyles.h2),
              ],
            ),
          ),
        ),
        const Spacer(),

        // AI Assistant icon
        _headerIcon(Icons.auto_awesome, () {
          // TODO: Open AI assistant
        }),
        const SizedBox(width: AppSizes.sm),

        // Notifications icon
        _headerIcon(Icons.notifications_outlined, () {
          // TODO: Open notifications
        }),
      ],
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, size: 22, color: AppColors.iconDefault),
      ),
    );
  }

  // ── Insights row ────────────────────────────────────────────────

  Widget _buildInsightsRow() {
    return Row(
      children: [
        InsightsCard(
          title: AppStrings.sales,
          amount: _controller.todaySales,
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
        ),
        const SizedBox(width: AppSizes.sm + 4),
        InsightsCard(
          title: AppStrings.purchases,
          amount: _controller.todayPurchases,
          icon: Icons.trending_down_rounded,
          iconColor: AppColors.error,
        ),
      ],
    );
  }
}
