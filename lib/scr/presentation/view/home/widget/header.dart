import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

Widget header(HomeController controller) {
  return Obx(
    () => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  if (controller.isProfileNameLoading.value)
                    Container(
                      key: const ValueKey('home-name-loading'),
                      height: 22,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  else
                    Text(
                      controller.userName.value.isEmpty
                          ? 'Hello!'
                          : 'Hello, ${controller.userName.value}',
                      style: TextHelper.homeTitle,
                    ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.orangeAccent,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "Let's smash your goals today!",
                style: TextHelper.homeSubtitle,
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.notifications),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                  Positioned(
                    top: 12,
                    right: 13,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceHigh,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget pill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text, style: TextHelper.poppins),
  );
}
