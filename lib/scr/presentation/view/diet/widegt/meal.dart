import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';

class MealRow extends StatelessWidget {
  const MealRow({super.key, required this.meal, this.onTap});

  final DietMeal meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 82,
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
          ),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: meal.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(meal.icon, color: meal.color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.mealType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.poppins.copyWith(
                        color: meal.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      meal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.homeTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.calories,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.poppins.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MealImagePlaceholder(meal: meal),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealImagePlaceholder extends StatelessWidget {
  const _MealImagePlaceholder({required this.meal});

  final DietMeal meal;

  @override
  Widget build(BuildContext context) {
    final imageAsset = meal.imageAsset;
    final imageUrl = meal.imageUrl?.trim();

    return SizedBox(
      height: 54,
      width: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: imageUrl?.isNotEmpty == true
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _MealIcon(meal: meal),
              )
            : imageAsset == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: meal.color.withValues(alpha: 0.14),
                ),
                child: Icon(meal.icon, color: meal.color, size: 30),
              )
            : Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
      ),
    );
  }
}

class _MealIcon extends StatelessWidget {
  const _MealIcon({required this.meal});

  final DietMeal meal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: meal.color.withValues(alpha: 0.14),
      child: Icon(meal.icon, color: meal.color, size: 30),
    );
  }
}
