import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

class BodyCard extends StatelessWidget {
  const BodyCard({super.key, required this.metric, this.onTap});

  final HomeBodyMetric metric;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 118,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 2,
                child: Opacity(
                  opacity: 0.88,
                  child: Image.asset(
                    'assets/images/home_body_overview.png',
                    key: const ValueKey('home-card-artwork-body-overview'),
                    height: 52,
                    width: 52,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(icon: metric.icon, color: metric.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          metric.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextHelper.homeCardTitle,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ValueLine(
                    value: metric.value,
                    unit: metric.unit,
                    valueSize: 21,
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: metric.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metric.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextHelper.poppins.copyWith(fontSize: 10),
                      ),
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

class ValueLine extends StatelessWidget {
  const ValueLine({
    super.key,
    required this.value,
    required this.unit,
    required this.valueSize,
  });

  final String value;
  final String unit;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: value,
        style: TextHelper.homeValue.copyWith(fontSize: valueSize),
        children: [
          TextSpan(
            text: unit.isEmpty ? '' : ' $unit',
            style: TextHelper.homeUnit,
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}

class MountainMark extends StatelessWidget {
  const MountainMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 54,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 3,
            child: Icon(
              Icons.flag_rounded,
              color: AppColors.primary.withValues(alpha: 0.92),
              size: 28,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.terrain_rounded,
              color: AppColors.primary.withValues(alpha: 0.9),
              size: 74,
            ),
          ),
          Positioned(
            right: 1,
            bottom: 6,
            child: Icon(
              Icons.cloud_rounded,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceHigh,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.border),
  );
}
