import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/data/model/diet_model.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';
import 'package:gym/scr/presentation/view/diet/widegt/meal.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class DietPlanScreen extends GetView<DietPlanController> {
  const DietPlanScreen({super.key});

  @override
  DietPlanController get controller => DietPlanController.resolve();

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Diet Plan'),
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your goal', style: TextHelper.homeTitle),
                const SizedBox(height: 4),
                Text(
                  'Select a plan to see its suggested meals.',
                  style: TextHelper.homeSubtitle,
                ),
                const SizedBox(height: 16),
                if (controller.isDietPlanLoading.value)
                  const _DietPlanLoading()
                else if (controller.dietPlanError.value != null)
                  _DietPlanState(
                    key: const ValueKey('diet-plan-error'),
                    icon: Icons.cloud_off_rounded,
                    title: 'Diet plans could not load',
                    message: controller.dietPlanError.value!,
                    actionLabel: 'Try again',
                    onAction: controller.getDietPlans,
                  )
                else if (controller.apiDietPlans.isEmpty)
                  _DietPlanState(
                    key: const ValueKey('diet-plan-empty'),
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No diet plans yet',
                    message: 'New nutrition plans will appear here.',
                    actionLabel: 'Refresh',
                    onAction: controller.getDietPlans,
                  )
                else ...[
                  SizedBox(
                    height: 164,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.apiDietPlans.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final plan = controller.apiDietPlans[index];
                        return _ApiDietPlanCard(
                          plan: plan,
                          isSelected:
                              controller.selectedApiDietIndex.value == index,
                          onTap: () => controller.selectApiDietPlan(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Suggested meals',
                          style: TextHelper.homeTitle2,
                        ),
                      ),
                      Text(
                        controller.selectedPlanData.value?.planName ??
                            controller.selectedApiDietPlan?.planName ??
                            '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.homeSubtitle.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (controller.isMealLoading.value)
                    const _MealLoading()
                  else if (controller.mealError.value != null)
                    _DietPlanState(
                      key: const ValueKey('diet-meal-error'),
                      icon: Icons.no_meals_rounded,
                      title: 'Meals could not load',
                      message: controller.mealError.value!,
                      actionLabel: 'Try again',
                      onAction: controller.retryMeals,
                    )
                  else if (controller.selectedMeals.isEmpty)
                    _DietPlanState(
                      key: const ValueKey('diet-meal-empty'),
                      icon: Icons.no_food_rounded,
                      title: 'No meals in this plan',
                      message: 'Meals will appear here when they are added.',
                      actionLabel: 'Refresh',
                      onAction: controller.retryMeals,
                    )
                  else
                    for (
                      var index = 0;
                      index < controller.selectedMeals.length;
                      index += 1
                    ) ...[
                      if (index > 0) const SizedBox(height: 8),
                      MealRow(
                        meal: controller.selectedMeals[index],
                        onTap: () async {
                          final meal = controller.selectedMeals[index];
                          final mealId = meal.id;
                          final detailedMeal = mealId == null
                              ? null
                              : await controller.getMealDetail(mealId);

                          await Get.toNamed<void>(
                            AppRoutes.mealDetail,
                            arguments: detailedMeal ?? meal,
                          );
                        },
                      ),
                    ],
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ApiDietPlanCard extends StatelessWidget {
  const _ApiDietPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final DietPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('diet-plan-${plan.id}'),
        onTap: onTap,
        child: Container(
          width: 248,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _DietPlanImage(plan: plan),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.black.withValues(alpha: 0.4),
                      AppColors.black.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.overlayMedium,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.add_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleCase(plan.planName ?? 'Diet Plan'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeTitle2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description?.trim().isNotEmpty == true
                          ? plan.description!.trim()
                          : 'A personalised nutrition plan for your goal.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeSubtitle.copyWith(height: 1.35),
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

  String _titleCase(String value) {
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _DietPlanImage extends StatelessWidget {
  const _DietPlanImage({required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context) {
    final image = plan.image?.trim();
    final fallback = _fallbackImage(plan.planName);

    if (image == null || image.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : Image.asset(fallback, fit: BoxFit.cover);
      },
      errorBuilder: (_, _, _) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }

  String _fallbackImage(String? name) {
    final normalized = name?.toLowerCase() ?? '';
    return normalized.contains('gain') ? banner : workoutImage;
  }
}

class _DietPlanLoading extends StatelessWidget {
  const _DietPlanLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('diet-plan-loading'),
      height: 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, _) => Container(
          width: 248,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

class _MealLoading extends StatelessWidget {
  const _MealLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('diet-meal-loading'),
      children: List.generate(
        2,
        (index) => Container(
          height: 82,
          margin: EdgeInsets.only(bottom: index == 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

class _DietPlanState extends StatelessWidget {
  const _DietPlanState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextHelper.homeTitle2,
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextHelper.homeSubtitle,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAction,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
