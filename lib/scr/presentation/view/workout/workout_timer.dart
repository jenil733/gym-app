import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  late final WorkoutController controller;

  @override
  void initState() {
    super.initState();
    controller = WorkoutController.resolve();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Workout Timer', centerTitle: false),
      body: SafeArea(
        child: Obx(() {
          final exercise =
              controller.activeExercise.value ?? controller.allExercises.first;
          final isRunning = controller.isWorkoutTimerRunning.value;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 86,
                                width: 86,
                                decoration: BoxDecoration(
                                  color: exercise.color.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: exercise.color.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  exercise.icon,
                                  color: exercise.color,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                exercise.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextHelper.homeTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.focus,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextHelper.homeSubtitle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 34),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                controller.formattedWorkoutElapsed,
                                style: TextHelper.homeTitle.copyWith(
                                  fontSize: 48,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isRunning
                                    ? 'Workout running'
                                    : 'Workout paused',
                                style: TextHelper.homeSubtitle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _CaloriesBurnCard(
                          controller: controller,
                          isRunning: isRunning,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: isRunning
                              ? controller.pauseWorkoutTimer
                              : controller.resumeWorkoutTimer,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textOnDark,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            isRunning ? 'Pause' : 'Resume',
                            style: TextHelper.button,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonButton(
                        label: controller.isTimingSaving.value
                            ? 'Saving...'
                            : 'Finish',
                        onPressed: controller.isTimingSaving.value
                            ? null
                            : () async {
                                await controller.finishWorkout();
                                Get.back<void>();
                              },
                        icon: Icons.check_rounded,
                        height: 52,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CaloriesBurnCard extends StatelessWidget {
  const _CaloriesBurnCard({required this.controller, required this.isRunning});

  final WorkoutController controller;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final calories = controller.workoutCaloriesBurned;
    final elapsed = controller.workoutElapsedSeconds.value;
    const graphSamples = 16;
    final points = <FlSpot>[];
    final caloriesPerSecond = controller.caloriesBurnedAt(1);
    for (var index = 0; index < graphSamples; index++) {
      final second = elapsed - (graphSamples - 1 - index);
      if (second < 0 || elapsed == 0) {
        points.add(FlSpot(index.toDouble(), 0));
        continue;
      }

      // A deterministic intensity wave gives the live graph the small peaks
      // and dips of the reference while the total remains cumulative.
      final intensity =
          0.72 +
          0.20 * math.sin(second * 1.31) +
          0.12 * math.sin(second * 0.47 + 1.4);
      points.add(
        FlSpot(index.toDouble(), caloriesPerSecond * math.max(0.18, intensity)),
      );
    }

    final highestPoint = points.fold<double>(
      0,
      (highest, point) => math.max(highest, point.y),
    );
    final maxY = math.max(0.1, highestPoint * 1.22);
    const accentColor = AppColors.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isRunning && elapsed.isEven ? 1 : 0.25),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeInOut,
      builder: (context, pulse, _) {
        return Container(
          key: const ValueKey('workout-calories-card'),
          height: 150,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          decoration: BoxDecoration(
            color: const Color(0xFF101820),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1D2A33)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.05 + pulse * 0.06),
                blurRadius: 10 + pulse * 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: accentColor,
                    size: 17,
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(
                          alpha: 0.45 + pulse * 0.3,
                        ),
                        blurRadius: 5 + pulse * 4,
                      ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Calories Burned',
                    style: TextHelper.homeSubtitle.copyWith(
                      color: AppColors.textOnDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: calories),
                duration: const Duration(milliseconds: 450),
                builder: (context, value, _) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      key: const ValueKey('workout-calories-value'),
                      style: TextHelper.homeTitle.copyWith(
                        color: accentColor,
                        fontSize: 29,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: accentColor.withValues(
                              alpha: 0.30 + pulse * 0.22,
                            ),
                            blurRadius: 6 + pulse * 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'kcal',
                        style: TextHelper.homeSubtitle.copyWith(
                          color: const Color(0xFFB6BEC5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (graphSamples - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    clipData: const FlClipData.all(),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: false,
                        color: accentColor,
                        barWidth: 2.2,
                        shadow: Shadow(
                          color: accentColor.withValues(
                            alpha: 0.5 + pulse * 0.3,
                          ),
                          blurRadius: 4 + pulse * 4,
                        ),
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentColor.withValues(
                                alpha: 0.20 + pulse * 0.08,
                              ),
                              accentColor.withValues(alpha: 0.005),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CurrentStreakCard extends StatelessWidget {
  const CurrentStreakCard({super.key, required this.streakDays});

  final int streakDays;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final currentWeekdayIndex = DateTime.now().weekday - 1;

    return Container(
      key: const ValueKey('current-streak-card'),
      height: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12101A), Color(0xFF08090F)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: 2,
            bottom: -28,
            width: 172,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.white],
                stops: [0, 0.28],
              ).createShader(bounds),
              child: Image.asset(
                'assets/images/streak_fire.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: 18,
            child: Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Current Streak',
                      style: TextHelper.homeSubtitle.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$streakDays',
                      key: const ValueKey('current-streak-days'),
                      style: TextHelper.homeTitle.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 40,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, bottom: 4),
                      child: Text(
                        'Days',
                        style: TextHelper.homeSubtitle.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "You're on fire! Keep it up.",
                  style: TextHelper.homeSubtitle.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 216,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_weekdayLabels.length, (index) {
                      final isToday = index == currentWeekdayIndex;
                      return _StreakDay(
                        label: _weekdayLabels[index],
                        isToday: isToday,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF09090D) : AppColors.primary,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isToday ? 0.45 : 0.18,
                ),
                blurRadius: isToday ? 8 : 4,
              ),
            ],
          ),
          child: Icon(
            isToday ? Icons.local_fire_department_rounded : Icons.check_rounded,
            color: AppColors.textOnDark,
            size: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextHelper.homeSubtitle.copyWith(
            color: isToday ? AppColors.primary : AppColors.textMuted,
            fontSize: 9,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
