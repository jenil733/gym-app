import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class MyWorkoutScreen extends GetView<WorkoutController> {
  const MyWorkoutScreen({super.key});

  @override
  WorkoutController get controller => WorkoutController.resolve();

  @override
  Widget build(BuildContext context) {
    final workoutController = controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'My Workout'),
      body: SafeArea(
        child: Obx(() {
          final exercises = workoutController.selectedExercises;
          if (exercises.isEmpty) {
            return const _EmptyWorkoutQueue();
          }

          final completed = exercises
              .where(workoutController.isExerciseCompleted)
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$completed of ${exercises.length} exercises completed',
                            style: TextHelper.homeTitle3,
                          ),
                        ),
                        Text(
                          '${exercises.length}/${WorkoutController.maxSelectedExercises}',
                          style: TextHelper.homeSubtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Today total: ${workoutController.formattedTodayWorkoutElapsed}',
                      key: const ValueKey('today-workout-total'),
                      style: TextHelper.homeSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < exercises.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                _QueuedExerciseCard(
                  exercise: exercises[index],
                  isCompleted: workoutController.isExerciseCompleted(
                    exercises[index],
                  ),
                  durationSeconds: workoutController.exerciseDuration(
                    exercises[index],
                  ),
                  onOpen: () => Get.toNamed<void>(
                    AppRoutes.exerciseDetail,
                    arguments: exercises[index],
                  ),
                  onRemove: () =>
                      workoutController.removeExercise(exercises[index]),
                  onStart: () {
                    workoutController.startExercise(exercises[index]);
                    Get.toNamed<void>(AppRoutes.timer);
                  },
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _QueuedExerciseCard extends StatelessWidget {
  const _QueuedExerciseCard({
    required this.exercise,
    required this.isCompleted,
    required this.durationSeconds,
    required this.onOpen,
    required this.onRemove,
    required this.onStart,
  });

  final WorkoutExercise exercise;
  final bool isCompleted;
  final int durationSeconds;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: exercise.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(exercise.icon, color: exercise.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeTitle2,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted
                          ? 'Completed · ${_formatDuration(durationSeconds)}'
                          : '${exercise.sets} sets · ${exercise.reps} reps',
                      style: TextHelper.homeSubtitle.copyWith(
                        color: isCompleted ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('remove-exercise-${exercise.id}'),
                onPressed: onRemove,
                tooltip: 'Remove exercise',
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.textMuted,
              ),
              if (isCompleted)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary)
              else
                IconButton.filled(
                  key: ValueKey('start-exercise-${exercise.id}'),
                  onPressed: onStart,
                  tooltip: 'Start exercise',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

class _EmptyWorkoutQueue extends StatelessWidget {
  const _EmptyWorkoutQueue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text('My Workout is empty', style: TextHelper.homeTitle),
            const SizedBox(height: 6),
            Text(
              'Go back to All Exercises and add up to 10 exercises.',
              textAlign: TextAlign.center,
              style: TextHelper.homeSubtitle,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: Get.back<void>,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Browse Exercises'),
            ),
          ],
        ),
      ),
    );
  }
}
