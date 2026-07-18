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
                  ValueLine(value: item.value, unit: item.unit, valueSize: 22),
                  const SizedBox(height: 5),
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
