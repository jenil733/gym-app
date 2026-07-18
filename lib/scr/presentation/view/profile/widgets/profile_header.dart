import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/view/profile/profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 84,
            width: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: controller.profileImageBytes != null
                ? Image.memory(controller.profileImageBytes!, fit: BoxFit.cover)
                : controller.profileImageUrl != null
                ? Image.network(
                    controller.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      controller.profileImageAsset,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(controller.profileImageAsset, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.userName, style: TextHelper.homeTitle2),
                const SizedBox(height: 4),
                Text(controller.userLevel, style: TextHelper.homeSubtitle),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ProfileStat(label: 'Streak', value: controller.streak),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
