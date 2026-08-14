import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/attendance_controller.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/view/profile/widgets/profile_header.dart';
import 'package:gym/scr/presentation/view/profile/widgets/profile_list.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  ProfileController get controller {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }

    return Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    AttendanceController.resolve();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          init: controller,
          builder: (profileController) {
            if (profileController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  key: ValueKey('profile-loading'),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: TextHelper.homeTitle),
                  const SizedBox(height: 18),
                  ProfileHeader(controller: profileController),
                  const SizedBox(height: 18),
                  Text('Physical Detail', style: TextHelper.homeTitle2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (
                        var index = 0;
                        index < profileController.physicalDetails.length;
                        index += 1
                      ) ...[
                        if (index > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _PhysicalDetailCard(
                            item: profileController.physicalDetails[index],
                            onTap:
                                profileController
                                        .physicalDetails[index]
                                        .route ==
                                    null
                                ? null
                                : () => profileController.openRoute(
                                    profileController
                                        .physicalDetails[index]
                                        .route!,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Account', style: TextHelper.homeTitle2),
                  const SizedBox(height: 12),
                  for (
                    var index = 0;
                    index < profileController.profileItems.length;
                    index += 1
                  ) ...[
                    if (index > 0) const SizedBox(height: 10),
                    ProfileListTile(
                      item: profileController.profileItems[index],
                      onTap: profileController.profileItems[index].route == null
                          ? null
                          : () => profileController.openRoute(
                              profileController.profileItems[index].route!,
                            ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhysicalDetailCard extends StatelessWidget {
  const _PhysicalDetailCard({required this.item, required this.onTap});

  final ProfileItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: AppColors.primary, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: onTap == null
                        ? AppColors.border
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextHelper.homeSubtitle),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextHelper.homeTitle2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextHelper.homeSubtitle),
            Text(value, style: TextHelper.homeTitle4),
          ],
        ),
      ),
    );
  }
}
