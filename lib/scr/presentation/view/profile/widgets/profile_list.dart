import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({super.key, required this.item, this.onTap});

  final ProfileItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = onTap == null ? AppColors.textMuted : AppColors.primary;

    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: TextHelper.homeTitle4),
                    const SizedBox(height: 2),
                    Text(item.value, style: TextHelper.homeSubtitle),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null ? AppColors.border : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
