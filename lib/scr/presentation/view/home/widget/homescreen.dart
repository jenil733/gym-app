import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/view/home/home.dart';
import 'package:gym/scr/presentation/view/home/widget/homebody.dart';

class HomeScreen extends FitnessHomeScreen {
  const HomeScreen({super.key});
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.item, this.onTap});

  final HomeStatItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trendColor = item.trendUp ? AppColors.primary : AppColors.warning;
    final displayedUnit = item.title == 'Workout Time'
        ? item.unit.replaceFirst(RegExp(r'\s*00 sec$'), '')
        : item.unit;
    final showTrend =
        item.title != 'Steps' ||
        item.trend.trim().toLowerCase() != 'today' ||
        !item.footer.toLowerCase().contains('today');
    final artwork = switch (item.title) {
      'Workout Time' => 'assets/images/home_workout_time.png',
      'Steps' => 'assets/images/home_steps.png',
      _ => null,
    };

    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap:
            onTap ??
            (item.history.isEmpty ? null : () => _openStatHistory(item)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 116,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              if (artwork != null)
                Positioned(
                  right: 0,
                  bottom: 1,
                  child: Opacity(
                    opacity: 0.88,
                    child: Image.asset(
                      artwork,
                      key: ValueKey(
                        'home-card-artwork-${item.title.toLowerCase().replaceAll(' ', '-')}',
                      ),
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(icon: item.icon, color: item.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextHelper.homeCardTitle,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ValueLine(
                    value: item.value,
                    unit: displayedUnit,
                    valueSize: 22,
                  ),
                  const SizedBox(height: 5),
                  if (showTrend)
                    Row(
                      children: [
                        if (item.showTrendIcon) ...[
                          Icon(
                            item.trendUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: trendColor,
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          item.trend,
                          style: TextHelper.poppins.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  Padding(
                    padding: EdgeInsets.only(right: artwork == null ? 0 : 42),
                    child: Text(
                      item.footer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextHelper.poppins.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openStatHistory(HomeStatItem item) {
  Get.toNamed<void>(AppRoutes.statHistory, arguments: item);
}

class DietPlanCard extends StatelessWidget {
  const DietPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('home-diet-card'),
        onTap: () => Get.toNamed<void>(AppRoutes.dietPlan),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 118,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.surfaceHigh,
                AppColors.primaryDark.withValues(alpha: 0.42),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diet Plan', style: TextHelper.homeTitle2),
                      const SizedBox(height: 4),
                      Text(
                        'Meals tailored to your fitness goal',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.homeSubtitle,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'View meal plan',
                        style: TextHelper.poppins.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
