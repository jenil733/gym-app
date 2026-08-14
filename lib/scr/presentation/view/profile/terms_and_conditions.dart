import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Terms & Conditions'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TermsSection(
                icon: Icons.app_registration_rounded,
                title: 'Using the App',
                body:
                    'Provide accurate account and fitness information and use the app only for lawful personal fitness activities.',
              ),
              _TermsSection(
                icon: Icons.health_and_safety_rounded,
                title: 'Health & Safety',
                body:
                    'Workout guidance is informational. Exercise within your ability and consult a qualified professional when needed.',
              ),
              _TermsSection(
                icon: Icons.manage_accounts_rounded,
                title: 'Your Account',
                body:
                    'You are responsible for activity performed through your account and for keeping your login access secure.',
              ),
              _TermsSection(
                icon: Icons.update_rounded,
                title: 'Changes',
                body:
                    'Features and these terms may change over time. Continuing to use the app means you accept the current terms.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextHelper.homeTitle4),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextHelper.homeSubtitle.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
