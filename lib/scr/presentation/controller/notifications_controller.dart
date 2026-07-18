import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';

class NotificationsController extends GetxController {
  final List<NotificationItem> items = const [
    NotificationItem(
      icon: Icons.fitness_center_rounded,
      title: 'Workout Timing',
      message: 'Push Day starts at 6:30 PM today.',
      time: '2 min ago',
      color: AppColors.primary,
    ),
    NotificationItem(
      icon: Icons.water_drop_rounded,
      title: 'Water Reminder',
      message: 'Drink 250 ml water to stay on target.',
      time: '18 min ago',
      color: AppColors.statWater,
    ),
    NotificationItem(
      icon: Icons.restaurant_menu_rounded,
      title: 'Diet Reminder',
      message: 'Lunch plan: grilled chicken rice at 1:00 PM.',
      time: '1 hr ago',
      color: AppColors.secondary,
    ),
    NotificationItem(
      icon: Icons.workspace_premium_rounded,
      title: 'Subscription',
      message: 'Yearly plan offer unlocks with reward tokens.',
      time: 'Yesterday',
      color: AppColors.statWeight,
    ),
  ];
}

class NotificationItem {
  const NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
}
