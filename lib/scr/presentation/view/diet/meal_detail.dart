import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.meal});

  final DietMeal meal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Food Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.65),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        color: meal.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(meal.icon, color: meal.color, size: 34),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      meal.mealType,
                      style: TextHelper.poppins.copyWith(
                        color: meal.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      meal.title,
                      textAlign: TextAlign.center,
                      style: TextHelper.homeTitle.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _NutritionTile(
                      label: 'Calories',
                      value: meal.calories,
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.statCalories,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NutritionTile(
                      label: 'Protein',
                      value: meal.protein,
                      icon: Icons.fitness_center_rounded,
                      color: meal.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Description', style: TextHelper.homeTitle2),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.65),
                  ),
                ),
                child: Text(
                  meal.description,
                  style: TextHelper.poppins.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextHelper.homeSubtitle),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextHelper.homeTitle2,
          ),
        ],
      ),
    );
  }
}
