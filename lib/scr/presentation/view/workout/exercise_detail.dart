import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class ExerciseDetailScreen extends GetView<WorkoutController> {
  const ExerciseDetailScreen({super.key});

  @override
  WorkoutController get controller => WorkoutController.resolve();

  @override
  Widget build(BuildContext context) {
    final exercise = Get.arguments is WorkoutExercise
        ? Get.arguments as WorkoutExercise
        : controller.allExercises.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: exercise.title),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (exercise.hasNetworkImage)
                        Image.network(
                          exercise.image,
                          fit: BoxFit.cover,
                          alignment: exercise.imageAlignment,
                          errorBuilder: (_, _, _) => const _ImageFallback(),
                        )
                      else
                        Image.asset(
                          exercise.image,
                          fit: BoxFit.cover,
                          alignment: exercise.imageAlignment,
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.transparent,
                              AppColors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.category, style: TextHelper.poppins),
                            Text(exercise.focus, style: TextHelper.homeTitle2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Metric(
                    icon: Icons.sync_alt_rounded,
                    value: exercise.sets,
                    label: 'Sets',
                  ),
                  _Metric(
                    icon: Icons.repeat_rounded,
                    value: exercise.reps,
                    label: 'Reps',
                  ),
                  _Metric(
                    icon: Icons.timer_outlined,
                    value: exercise.rest,
                    label: 'Rest',
                  ),
                  _Metric(
                    icon: Icons.local_fire_department_outlined,
                    value: exercise.calories,
                    label: 'Burn',
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text('How to do', style: TextHelper.homeTitle),
              const SizedBox(height: 13),
              for (
                var index = 0;
                index < exercise.instructions.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 12),
                _InstructionStep(
                  step: index + 1,
                  text: exercise.instructions[index],
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Obx(() {
          final isAdded = controller.isExerciseSelected(exercise);
          return CommonButton(
            label: isAdded ? 'Added to My Workout' : 'Add to Workout',
            onPressed: isAdded || !controller.canAddExercise
                ? null
                : () => controller.addExercise(exercise),
            icon: isAdded ? Icons.check_rounded : Icons.add_rounded,
          );
        }),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.field,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary,
          size: 42,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextHelper.homeTitle3,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextHelper.homeSubtitle),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 26,
          width: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Text('$step', style: TextHelper.poppins),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(text, style: TextHelper.poppins.copyWith(height: 1.45)),
        ),
      ],
    );
  }
}
