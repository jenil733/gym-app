import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/view/home/widget/header.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

Widget workoutCard(
  WorkoutController controller, {
  required VoidCallback onBrowseExercises,
  required VoidCallback onOpenWorkout,
}) {
  return Obx(() {
    final exercise = controller.nextExercise;
    final isEmpty = controller.selectedExercises.isEmpty;
    final isComplete = controller.hasCompletedWorkoutToday;
    final displayExercise =
        exercise ??
        (controller.selectedExercises.isNotEmpty
            ? controller.selectedExercises.last
            : null);
    final image = displayExercise?.image ?? banner;
    final imageAlignment =
        displayExercise?.imageAlignment ?? Alignment.centerRight;
    final title = isComplete
        ? 'Workout Complete'
        : isEmpty
        ? 'No exercises added'
        : exercise!.title;
    final subtitle = isComplete
        ? controller.selectedExercises.isEmpty
              ? "Today's workout has been completed"
              : 'All ${controller.selectedExercises.length} exercises completed'
        : isEmpty
        ? 'Build your workout from the exercise catalog'
        : '${exercise!.category} · ${exercise.focus}';
    final buttonLabel = isEmpty ? 'Browse Exercises' : 'Start Workout';

    return Container(
      key: const ValueKey('home-workout-image'),
      height: 178,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: displayExercise?.hasNetworkImage == true
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        alignment: imageAlignment,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.surfaceHigh),
                      )
                    : Image.asset(
                        image,
                        fit: BoxFit.cover,
                        alignment: imageAlignment,
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.background.withValues(alpha: 0.94),
                        AppColors.background.withValues(alpha: 0.62),
                        AppColors.background.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pill("Today's Workout"),
                      const Spacer(),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.homeTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.homeSubtitle,
                      ),
                      const SizedBox(height: 12),
                      if (isComplete)
                        Container(
                          key: const ValueKey('home-workout-completed-banner'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.55),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Completed Today',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        CommonButton(
                          label: buttonLabel,
                          onPressed: isEmpty
                              ? onBrowseExercises
                              : onOpenWorkout,
                          height: 42,
                          borderRadius: 12,
                          fontSize: 12,
                          trailingIcon: Icons.chevron_right_rounded,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  });
}
