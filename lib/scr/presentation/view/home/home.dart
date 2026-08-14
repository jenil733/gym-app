import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/attendance_controller.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/main_navigation_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/view/home/widget/header.dart';
import 'package:gym/scr/presentation/view/home/widget/bmi_calculator.dart';
import 'package:gym/scr/presentation/view/home/widget/homebody.dart';
import 'package:gym/scr/presentation/view/home/widget/homescreen.dart';
import 'package:gym/scr/presentation/view/home/widget/workout.dart';
import 'package:gym/scr/presentation/view/workout/workout_timer.dart';

class FitnessHomeScreen extends GetView<HomeController> {
  const FitnessHomeScreen({super.key});

  @override
  HomeController get controller => HomeController.resolve();

  WorkoutController get workoutController {
    return WorkoutController.resolve();
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final workoutController = this.workoutController;
    final attendanceController = AttendanceController.resolve();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(controller),
                const SizedBox(height: 35),
                workoutCard(
                  workoutController,
                  onBrowseExercises: _openWorkoutsTab,
                  onOpenWorkout: _openMyWorkout,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => controller.isWorkoutHistoryLoading.value
                      ? const SizedBox(
                          key: ValueKey('home-stats-loading'),
                          height: 116,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                for (
                                  var index = 0;
                                  index < controller.stats.length.clamp(0, 2);
                                  index += 1
                                ) ...[
                                  if (index > 0) const SizedBox(width: 8),
                                  Expanded(
                                    child: StatCard(
                                      item: controller.stats[index],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (controller.stats.length > 2) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: StatCard(
                                  item: controller.stats[2],
                                  onTap: controller.canRetryStepTracking
                                      ? controller.retryStepTracking
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Text('Nutrition', style: TextHelper.homeTitle2),
                const SizedBox(height: 10),
                const DietPlanCard(),
                const SizedBox(height: 16),
                Text('Body Overview', style: TextHelper.homeTitle2),
                const SizedBox(height: 10),
                Obx(
                  () => controller.isWeightHistoryLoading.value
                      ? const SizedBox(
                          key: ValueKey('home-weight-loading'),
                          height: 110,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Row(
                          children: [
                            for (
                              var index = 0;
                              index < controller.bodyMetrics.length;
                              index += 1
                            ) ...[
                              if (index > 0) const SizedBox(width: 8),
                              Expanded(
                                child: BodyCard(
                                  metric: controller.bodyMetrics[index],
                                  onTap:
                                      controller
                                              .bodyMetrics[index]
                                              .history
                                              ?.isEmpty ??
                                          true
                                      ? null
                                      : () => _openBodyHistory(
                                          controller.bodyMetrics[index],
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Column(
                    children: [
                      if (controller.hasLoadedProfileMeasurements.value &&
                          (controller.profileHeight.value <= 0 ||
                              controller.profileWeight.value <= 0)) ...[
                        _ProfileMeasurementPrompt(
                          onTap: () => _openProfileTab(),
                        ),
                        const SizedBox(height: 10),
                      ],
                      BmiCalculatorCard(
                        initialHeight: controller.profileHeight.value,
                        initialWeight: controller.profileWeight.value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => CurrentStreakCard(
                    streakDays: attendanceController.currentStreak(),
                    days: attendanceController.currentWeek(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openMyWorkout() {
  Get.toNamed<void>(AppRoutes.myWorkout);
}

void _openWorkoutsTab() {
  final navigationController = Get.isRegistered<MainNavigationController>()
      ? Get.find<MainNavigationController>()
      : Get.put(MainNavigationController());
  navigationController.selectTab(1);
}

void _openProfileTab() {
  final navigationController = Get.isRegistered<MainNavigationController>()
      ? Get.find<MainNavigationController>()
      : Get.put(MainNavigationController());
  navigationController.selectTab(3);
}

void _openBodyHistory(HomeBodyMetric metric) {
  Get.toNamed<void>(AppRoutes.bodyHistory, arguments: metric);
}

class _ProfileMeasurementPrompt extends StatelessWidget {
  const _ProfileMeasurementPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('set-up-profile-measurements-prompt'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Set up your profile to calculate BMI and track weight.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
