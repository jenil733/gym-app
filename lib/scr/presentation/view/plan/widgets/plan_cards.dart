import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/plan_controller.dart';
import 'package:gym/scr/presentation/view/plan/choose_plan.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final PlanOption plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.14)
          : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(plan.title, style: TextHelper.homeTitle),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(plan.badge, style: TextHelper.poppins),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(plan.price, style: TextHelper.homeTitle),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(plan.period, style: TextHelper.homeSubtitle),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final benefit in plan.benefits) ...[
                BenefitLine(text: benefit),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
