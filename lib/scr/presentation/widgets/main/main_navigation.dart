import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/main_navigation_controller.dart';
import 'package:gym/scr/presentation/view/attendance/attendance.dart';
import 'package:gym/scr/presentation/view/home/home.dart';
import 'package:gym/scr/presentation/view/profile/profile.dart';
import 'package:gym/scr/presentation/view/workout/workout.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  static const Duration _dockAnimationDuration = Duration(milliseconds: 240);
  static const Curve _dockAnimationCurve = Curves.easeOutCubic;

  static const List<_BottomBarItem> _items = [
    _BottomBarItem(label: 'Home', icon: Icons.home_rounded),
    _BottomBarItem(label: 'Workouts', icon: Icons.fitness_center_rounded),
    _BottomBarItem(label: 'Attendance', icon: Icons.qr_code_scanner_rounded),
    _BottomBarItem(label: 'Profile', icon: Icons.person_rounded),
  ];

  static const List<Widget> _pages = [
    FitnessHomeScreen(),
    WorkoutScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  @override
  MainNavigationController get controller {
    if (Get.isRegistered<MainNavigationController>()) {
      return Get.find<MainNavigationController>();
    }

    return Get.put(MainNavigationController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.48)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];

              return Obx(
                () => Expanded(
                  child: _DockItem(
                    item: item,
                    isSelected: controller.selectedIndex.value == index,
                    duration: _dockAnimationDuration,
                    curve: _dockAnimationCurve,
                    onTap: () => controller.selectTab(index),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.isSelected,
    required this.duration,
    required this.curve,
    required this.onTap,
  });

  final _BottomBarItem item;
  final bool isSelected;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected ? AppColors.white : AppColors.textMuted;
    final backgroundColor = isSelected
        ? AppColors.primary
        : AppColors.transparent;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TweenAnimationBuilder<double>(
          duration: isSelected ? const Duration(milliseconds: 360) : duration,
          curve: isSelected ? Curves.easeOutBack : curve,
          tween: Tween<double>(end: isSelected ? 1 : 0),
          builder: (context, selectedProgress, child) {
            return Transform.translate(
              offset: Offset(0, -4 * selectedProgress),
              child: Transform.scale(
                scale: 1 + (0.06 * selectedProgress),
                child: child,
              ),
            );
          },
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              height: 58,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration: duration,
                        curve: curve,
                        scale: isSelected ? 1.08 : 1,
                        child: Icon(
                          item.icon,
                          color: foregroundColor,
                          size: 21,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: curve,
                        style: TextHelper.navLabel,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 6,
                    child: AnimatedContainer(
                      duration: duration,
                      curve: curve,
                      height: 3,
                      width: isSelected ? 18 : 0,
                      decoration: BoxDecoration(
                        color: foregroundColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem {
  const _BottomBarItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
