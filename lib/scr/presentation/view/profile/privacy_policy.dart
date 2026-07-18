import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Privacy Policy'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _PolicySection(
                icon: Icons.verified_user_rounded,
                title: 'Your Data',
                body:
                    'We use profile, fitness, and progress details only to personalize your gym experience inside the app.',
              ),
              _PolicySection(
                icon: Icons.lock_rounded,
                title: 'Privacy',
                body:
                    'Personal details stay protected and are not shared with outside services without your permission.',
              ),
              _PolicySection(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                body:
                    'Workout, hydration, and progress reminders can be controlled from your device notification settings.',
              ),
              _PolicySection(
                icon: Icons.edit_note_rounded,
                title: 'Updates',
                body:
                    'This policy may be updated as new app features are added. Continued use means you accept the latest version.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
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
