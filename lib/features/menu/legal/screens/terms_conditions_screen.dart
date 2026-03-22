/// FinBill — Terms & Conditions screen.
///
/// Renders the full terms and conditions as rich scrollable text with an
/// optional "I Agree" acceptance button tracked via SharedPreferences.
///
/// File location: lib/features/menu/legal/screens/terms_conditions_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _accepted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptance();
  }

  Future<void> _loadAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accepted = prefs.getBool('terms_conditions_accepted') ?? false;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_conditions_accepted', true);
    setState(() => _accepted = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terms & Conditions accepted.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.md),
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
                          Text('Terms & Conditions', style: AppTextStyles.h2),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Atulix Finserv  •  Last updated: March 2026',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          ..._buildSections(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Accept button
                if (!_accepted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.cardBorder)),
                    ),
                    child: ElevatedButton(
                      onPressed: _accept,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                      child: const Text('I Agree', style: AppTextStyles.bodyLarge),
                    ),
                  ),
              ],
            ),
    );
  }

  List<Widget> _buildSections() {
    const sections = [
      _Section(
        title: '1. Acceptance of Terms',
        body:
            'By downloading, installing, or using FinBill ("the App"), you agree '
            'to be bound by these Terms & Conditions. If you do not agree with '
            'any part of these terms, you must not use the App. These terms '
            'constitute a legally binding agreement between you and Atulix Finserv.',
      ),
      _Section(
        title: '2. Description of Service',
        body:
            'FinBill is a business management application that provides:\n'
            '• Invoice creation and management\n'
            '• Purchase tracking and recording\n'
            '• Inventory management with stock alerts\n'
            '• Party (customer/supplier) management\n'
            '• Financial reports and analytics\n'
            '• PDF invoice generation and sharing\n\n'
            'Features may vary based on your subscription plan (Lite, Standard, Elite).',
      ),
      _Section(
        title: '3. User Accounts',
        body:
            'You are responsible for maintaining the confidentiality of your '
            'account credentials. You agree to provide accurate, complete, and '
            'current information during registration. You must notify us '
            'immediately of any unauthorised access to your account.',
      ),
      _Section(
        title: '4. Subscription & Pricing',
        body:
            'The App offers free (Lite) and paid (Standard, Elite) plans. '
            'Paid subscriptions are billed annually. Prices are subject to '
            'change with 30 days advance notice. Refunds are handled on a '
            'case-by-case basis within 7 days of purchase.',
      ),
      _Section(
        title: '5. Acceptable Use',
        body:
            'You agree NOT to:\n'
            '• Use the App for any unlawful purpose\n'
            '• Attempt to reverse-engineer, modify, or distribute the App\n'
            '• Upload malicious content or interfere with App operations\n'
            '• Share your account credentials with unauthorised parties\n'
            '• Use the App to store or transmit fraudulent financial data',
      ),
      _Section(
        title: '6. Intellectual Property',
        body:
            'All content, features, and functionality of FinBill — including '
            'but not limited to design, code, graphics, and trademarks — are '
            'owned by Atulix Finserv and are protected by Indian and '
            'international intellectual property laws.',
      ),
      _Section(
        title: '7. Data Ownership',
        body:
            'You retain ownership of all business data you enter into FinBill. '
            'We do not claim any ownership rights over your invoices, purchase '
            'records, party information, or financial data. You may export or '
            'delete your data at any time.',
      ),
      _Section(
        title: '8. Limitation of Liability',
        body:
            'Atulix Finserv shall not be liable for any indirect, incidental, '
            'special, or consequential damages arising from your use of the App. '
            'Our total liability shall not exceed the amount you paid for the '
            'App in the 12 months preceding the claim.',
      ),
      _Section(
        title: '9. Termination',
        body:
            'We reserve the right to suspend or terminate your account if you '
            'violate these terms. Upon termination, your right to use the App '
            'ceases immediately. You may request a data export within 30 days '
            'of termination.',
      ),
      _Section(
        title: '10. Governing Law',
        body:
            'These Terms shall be governed by and construed in accordance with '
            'the laws of India. Any disputes arising from these terms shall be '
            'subject to the exclusive jurisdiction of the courts in Delhi, India.',
      ),
      _Section(
        title: '11. Contact Us',
        body:
            'Atulix Finserv\n'
            'Laxmi Nagar, Delhi, India\n\n'
            'Phone: +91 9279545313\n'
            'Email: contact@atulix.com\n'
            'WhatsApp: +91 8588870031',
      ),
    ];

    final widgets = <Widget>[];
    for (final s in sections) {
      widgets.add(
        Text(s.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
      );
      widgets.add(const SizedBox(height: AppSizes.xs));
      widgets.add(
        Text(s.body, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6)),
      );
      widgets.add(const SizedBox(height: AppSizes.lg));
    }
    return widgets;
  }
}

class _Section {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
}
