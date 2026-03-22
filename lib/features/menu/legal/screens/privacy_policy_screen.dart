/// FinBill — Privacy Policy screen.
///
/// Renders the full privacy policy as rich scrollable text with an
/// optional "I Agree" acceptance button tracked via SharedPreferences.
///
/// File location: lib/features/menu/legal/screens/privacy_policy_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
      _accepted = prefs.getBool('privacy_policy_accepted') ?? false;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_policy_accepted', true);
    setState(() => _accepted = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy Policy accepted.'),
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
        title: const Text('Privacy Policy'),
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
                          Text('Privacy Policy', style: AppTextStyles.h2),
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
        title: '1. Information We Collect',
        body:
            'We collect information you provide directly when using FinBill, '
            'including your name, mobile number, email address, business details, '
            'and transaction data (invoices, purchases, party information). '
            'We may also collect device information and usage analytics to '
            'improve our services.',
      ),
      _Section(
        title: '2. How We Use Your Information',
        body:
            'Your information is used to:\n'
            '• Provide, maintain, and improve the FinBill app\n'
            '• Process and store your business transactions\n'
            '• Generate invoices, reports, and analytics\n'
            '• Send critical service notifications (e.g., low stock alerts)\n'
            '• Provide customer support\n'
            '• Ensure data security and fraud prevention',
      ),
      _Section(
        title: '3. Data Storage & Security',
        body:
            'Your data is stored securely on Google Firebase servers with '
            'industry-standard encryption (AES-256 at rest, TLS 1.3 in transit). '
            'We implement access controls, regular security audits, and '
            'automated backups to protect your business information.',
      ),
      _Section(
        title: '4. Data Sharing',
        body:
            'We do NOT sell or rent your personal data to third parties. '
            'Data may be shared only:\n'
            '• With your explicit consent\n'
            '• To comply with legal obligations\n'
            '• With service providers who assist in app operations '
            '(e.g., Firebase, analytics), bound by confidentiality agreements',
      ),
      _Section(
        title: '5. Your Rights',
        body:
            'You have the right to:\n'
            '• Access and download your data at any time\n'
            '• Request correction of inaccurate information\n'
            '• Request deletion of your account and associated data\n'
            '• Opt out of non-essential communications\n\n'
            'To exercise any of these rights, contact us at contact@atulix.com.',
      ),
      _Section(
        title: '6. Cookies & Analytics',
        body:
            'We use minimal analytics to understand app usage patterns and '
            'improve performance. No third-party advertising cookies are used. '
            'You can disable analytics through device settings.',
      ),
      _Section(
        title: '7. Changes to This Policy',
        body:
            'We may update this Privacy Policy from time to time. We will '
            'notify you of significant changes through in-app notifications '
            'or email. Continued use of the app after changes constitutes '
            'acceptance of the updated policy.',
      ),
      _Section(
        title: '8. Contact Us',
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
