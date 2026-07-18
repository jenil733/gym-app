import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/data/model/category_model.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

class WorkoutScreen extends GetView<WorkoutController> {
  const WorkoutScreen({super.key});

  @override
  WorkoutController get controller => WorkoutController.resolve();

  @override
  Widget build(BuildContext context) {
    final workoutController = controller;

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
          child: Obx(() {
            final selectedCategory = workoutController.selectedCategory.value;

            return ListView(
              key: ValueKey(
                selectedCategory == null
                    ? 'category-stage'
                    : 'exercise-stage-${selectedCategory.id}',
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 104),
              children: [
                _ScreenHeader(
                  selectedCategory: selectedCategory,
                  onBack: workoutController.showCategories,
                ),
                if (selectedCategory == null) ...[
                  const SizedBox(height: 16),
                  _MyWorkoutSummary(
                    count: workoutController.selectedExercises.length,
                    completed: workoutController.selectedExercises
                        .where(workoutController.isExerciseCompleted)
                        .length,
                  ),
                  const SizedBox(height: 20),
                ] else
                  const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: selectedCategory == null
                      ? _CategoryStage(controller: workoutController)
                      : _ExerciseStage(
                          key: ValueKey('exercises-${selectedCategory.id}'),
                          controller: workoutController,
                          category: selectedCategory,
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.selectedCategory, required this.onBack});

  final CategoryData? selectedCategory;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (selectedCategory != null) ...[
          IconButton.filled(
            key: const ValueKey('back-to-categories'),
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              foregroundColor: AppColors.textOnDark,
              side: const BorderSide(color: AppColors.border),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedCategory == null
                    ? 'Choose your workout'
                    : selectedCategory!.categoryName ?? 'Exercises',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextHelper.homeTitle,
              ),
              const SizedBox(height: 3),
              Text(
                selectedCategory == null
                    ? 'Pick a category to explore its exercises'
                    : 'Build a session that works for you',
                style: TextHelper.homeSubtitle,
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _CategoryStage extends StatelessWidget {
  const _CategoryStage({required this.controller});

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCategoryLoading.value) {
        return const _CategoryLoading();
      }

      final error = controller.categoryError.value;
      if (error != null) {
        return _StatePanel(
          key: const ValueKey('category-error'),
          icon: Icons.cloud_off_rounded,
          title: 'Categories could not load',
          message: error,
          actionLabel: 'Try again',
          onAction: controller.getCategories,
        );
      }

      if (controller.categories.isEmpty) {
        return _StatePanel(
          key: const ValueKey('category-empty'),
          icon: Icons.grid_view_rounded,
          title: 'No categories yet',
          message: 'New workout categories will appear here.',
          actionLabel: 'Refresh',
          onAction: controller.getCategories,
        );
      }

      final categories = controller.categories.toList(growable: false)
        ..sort(
          (first, second) =>
              (second.exerciseCount ?? 0).compareTo(first.exerciseCount ?? 0),
        );

      return Column(
        key: const ValueKey('category-content'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Workout categories',
            trailing: '${controller.categories.length} available',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.79,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isAvailable = (category.exerciseCount ?? 0) > 0;
              return _CategoryCard(
                category: category,
                isAvailable: isAvailable,
                onTap: isAvailable
                    ? () => controller.selectCategory(category)
                    : null,
              );
            },
          ),
        ],
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isAvailable,
    required this.onTap,
  });

  final CategoryData category;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('category-${category.id}'),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CategoryImage(category: category),
            if (!isAvailable)
              ColoredBox(color: AppColors.black.withValues(alpha: 0.32)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.black.withValues(alpha: 0.28),
                    AppColors.black.withValues(alpha: 0.96),
                  ],
                  stops: const [0.2, 0.5, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  isAvailable
                      ? '${category.exerciseCount ?? 0} exercises'
                      : 'Coming soon',
                  style: TextHelper.homeSubtitle.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 13,
              right: 10,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.categoryName ?? 'Workout',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextHelper.homeTitle2.copyWith(height: 1.15),
                        ),
                        if (category.description?.trim().isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            category.description!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextHelper.homeSubtitle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.primary : AppColors.field,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAvailable
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_clock_rounded,
                      color: AppColors.white,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseStage extends StatelessWidget {
  const _ExerciseStage({
    super.key,
    required this.controller,
    required this.category,
  });

  final WorkoutController controller;
  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryBanner(
            category: category,
            exerciseCount:
                controller.exerciseData.value?.count ?? category.exerciseCount,
          ),
          const SizedBox(height: 14),
          if (controller.isExerciseLoading.value)
            const _ExerciseLoading()
          else if (controller.exerciseError.value != null)
            _StatePanel(
              key: const ValueKey('exercise-error'),
              icon: Icons.sync_problem_rounded,
              title: 'Exercises could not load',
              message: controller.exerciseError.value!,
              actionLabel: 'Try again',
              onAction: controller.retryExercises,
            )
          else if (controller.categoryExercises.isEmpty)
            _StatePanel(
              key: const ValueKey('exercise-empty'),
              icon: Icons.sports_gymnastics_rounded,
              title: 'No exercises here yet',
              message:
                  'Try another category while this workout is being prepared.',
              actionLabel: 'Choose category',
              onAction: controller.showCategories,
            )
          else ...[
            _WorkoutSearchField(
              controller: controller,
              categoryId: category.id,
            ),
            const SizedBox(height: 18),
            _SectionHeading(
              title: 'Exercises',
              trailing: '${controller.visibleCategoryExercises.length} found',
            ),
            const SizedBox(height: 12),
            if (controller.visibleCategoryExercises.isEmpty)
              const _StatePanel(
                icon: Icons.search_off_rounded,
                title: 'No matching exercises',
                message: 'Try a different search term.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.visibleCategoryExercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exercise = controller.visibleCategoryExercises[index];
                  return _ExerciseCard(
                    exercise: exercise,
                    isAdded: controller.isExerciseSelected(exercise),
                    canAdd: controller.canAddExercise,
                    onTap: () => Get.toNamed<void>(
                      AppRoutes.exerciseDetail,
                      arguments: exercise,
                    ),
                    onAdd: () => controller.addExercise(exercise),
                  );
                },
              ),
          ],
        ],
      );
    });
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({required this.category, required this.exerciseCount});

  final CategoryData category;
  final int? exerciseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CategoryImage(category: category),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.black.withValues(alpha: 0.94),
                  AppColors.black.withValues(alpha: 0.58),
                  AppColors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.55,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${exerciseCount ?? 0} exercises',
                        style: TextHelper.homeSubtitle.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.categoryName ?? 'Workout',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeTitle,
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
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isAdded,
    required this.canAdd,
    required this.onTap,
    required this.onAdd,
  });

  final WorkoutExercise exercise;
  final bool isAdded;
  final bool canAdd;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('exercise-card-${exercise.id}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 94,
                  width: 88,
                  child: _ExerciseImage(exercise: exercise),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeTitle4.copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetricPill(label: '${exercise.sets} sets'),
                        _MetricPill(label: '${exercise.reps} reps'),
                        _MetricPill(label: exercise.rest),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.calories,
                            style: TextHelper.homeSubtitle,
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: FilledButton(
                            key: ValueKey('add-exercise-${exercise.id}'),
                            onPressed: isAdded || !canAdd ? null : onAdd,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.field,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(isAdded ? 'Added' : 'Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.exercise});

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    if (exercise.hasNetworkImage) {
      return Image.network(
        exercise.image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }
    return Image.asset(
      exercise.image,
      fit: BoxFit.cover,
      alignment: exercise.imageAlignment,
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.category});

  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.image?.trim();
    final fallback = _fallbackAsset(category.id);

    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(fallback, fit: BoxFit.cover),
            ColoredBox(color: AppColors.black.withValues(alpha: 0.22)),
            const Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (_, _, _) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }

  String _fallbackAsset(int? categoryId) {
    return switch (categoryId) {
      1 => onboardingImageTwo,
      2 => workoutImage,
      3 => login,
      _ => banner,
    };
  }
}

class _WorkoutSearchField extends StatelessWidget {
  const _WorkoutSearchField({
    required this.controller,
    required this.categoryId,
  });

  final WorkoutController controller;
  final int? categoryId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        key: ValueKey('exercise-search-$categoryId'),
        onChanged: controller.updateWorkoutSearch,
        cursorColor: AppColors.primary,
        textInputAction: TextInputAction.search,
        style: TextHelper.fieldText,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceHigh,
          hintText: 'Search in this category',
          hintStyle: TextHelper.fieldHint.copyWith(fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
          ),
          contentPadding: const EdgeInsets.only(right: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _MyWorkoutSummary extends StatelessWidget {
  const _MyWorkoutSummary({required this.count, required this.completed});

  final int count;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('my-workout-summary'),
        onTap: () => Get.toNamed<void>(AppRoutes.myWorkout),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.playlist_add_check_circle_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Workout', style: TextHelper.homeTitle2),
                    const SizedBox(height: 3),
                    Text(
                      count == 0
                          ? 'Add exercises to build your workout'
                          : '$completed completed • $count/${WorkoutController.maxSelectedExercises} added',
                      style: TextHelper.homeSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: TextHelper.homeTitle2)),
        Text(trailing, style: TextHelper.homeSubtitle),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextHelper.homeSubtitle),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextHelper.homeTitle2,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextHelper.homeSubtitle.copyWith(height: 1.45),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('category-loading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LoadingBar(width: 170, height: 20),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.79,
          ),
          itemBuilder: (_, _) => const _LoadingBox(radius: 20),
        ),
      ],
    );
  }
}

class _ExerciseLoading extends StatelessWidget {
  const _ExerciseLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('exercise-loading'),
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          child: const SizedBox(
            height: 116,
            width: double.infinity,
            child: _LoadingBox(radius: 18),
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const _LoadingBox(radius: 8),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.field,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary.withValues(alpha: 0.75),
          size: 34,
        ),
      ),
    );
  }
}
