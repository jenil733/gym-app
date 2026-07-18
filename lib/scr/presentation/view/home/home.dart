import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/main_navigation_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/view/home/widget/header.dart';
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
                const SizedBox(height: 12),
                const CurrentStreakCard(streakDays: 7),
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

void _openBodyHistory(HomeBodyMetric metric) {
  Get.toNamed<void>(AppRoutes.bodyHistory, arguments: metric);
}
