import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/notifications_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  NotificationsController get controller {
    if (Get.isRegistered<NotificationsController>()) {
      return Get.find<NotificationsController>();
    }

    return Get.put(NotificationsController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonBackHeader(title: 'Notifications'),
              const SizedBox(height: 20),
              Text('Today', style: TextHelper.homeTitle),
              const SizedBox(height: 4),
              Text(
                'Your workout, water, diet, and subscription alerts.',
                style: TextHelper.homeSubtitle,
              ),
              const SizedBox(height: 18),
              for (
                var index = 0;
                index < controller.items.length;
                index += 1
              ) ...[
                if (index > 0) const SizedBox(height: 12),
                _NotificationCard(item: controller.items[index]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.homeTitle2,
                      ),
                    ),
                    Text(item.time, style: TextHelper.homeSubtitle),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item.message, style: TextHelper.poppins),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
