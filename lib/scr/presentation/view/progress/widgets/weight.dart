import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:gym/scr/presentation/view/progress/progress.dart';

class WeightSection extends StatelessWidget {
  const WeightSection({super.key, required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.isWeightHistoryLoading.value &&
              controller.currentWeight.value <= 0)
            const Center(child: CircularProgressIndicator())
          else
            _CurrentWeightCard(
              weight: controller.currentWeight.value,
              change: controller.currentChange.value,
            ),
          const SizedBox(height: 16),
          _GraphRangeSelector(controller: controller),
          const SizedBox(height: 10),
          ChartCard(
            points: controller.graphPoints,
            rangeLabel: controller.graphRangeLabel,
          ),
          if (controller.weightHistoryError.value != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.weightHistoryError.value!,
              style: TextHelper.homeSubtitle,
            ),
          ],
          const SizedBox(height: 20),
          Text('Past Weight', style: TextHelper.homeTitle),
          const SizedBox(height: 12),
          if (controller.history.isEmpty)
            Text('No weight history yet.', style: TextHelper.homeSubtitle)
          else
            for (
              var index = 0;
              index < controller.history.length;
              index += 1
            ) ...[
              if (index > 0) const SizedBox(height: 10),
              HistoryRow(item: controller.history[index]),
            ],
        ],
      ),
    );
  }
}

class _GraphRangeSelector extends StatelessWidget {
  const _GraphRangeSelector({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    const labels = <WeightGraphRange, String>{
      WeightGraphRange.days: 'Days',
      WeightGraphRange.weeks: 'Weeks',
      WeightGraphRange.months: 'Months',
      WeightGraphRange.annually: 'Annual',
    };
    return Row(
      children: [
        for (final range in WeightGraphRange.values) ...[
          if (range != WeightGraphRange.days) const SizedBox(width: 6),
          Expanded(
            child: ChoiceChip(
              label: Text(labels[range]!),
              selected: controller.selectedGraphRange.value == range,
              onSelected: (_) => controller.selectGraphRange(range),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceHigh,
              side: BorderSide(color: AppColors.border),
              labelStyle: TextHelper.poppins.copyWith(
                color: controller.selectedGraphRange.value == range
                    ? AppColors.white
                    : AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
            ),
          ),
        ],
      ],
    );
  }
}

class _CurrentWeightCard extends StatelessWidget {
  const _CurrentWeightCard({required this.weight, required this.change});

  final double weight;
  final double change;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.statWeight.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.monitor_weight_rounded,
              color: AppColors.statWeight,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weight',
                  style: TextHelper.homeSubtitle.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  weight > 0 ? '${weight.toStringAsFixed(1)} kg' : '—',
                  style: TextHelper.homeTitle.copyWith(fontSize: 26),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: (change <= 0 ? AppColors.success : AppColors.secondary)
                  .withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
              style: TextHelper.poppins.copyWith(
                color: change <= 0 ? AppColors.success : AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  const WeightChartPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i += 1) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minWeight = points.reduce(math.min);
    final maxWeight = points.reduce(math.max);
    final range = math.max(0.1, maxWeight - minWeight);
    final stepX = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    Offset pointAt(int index) {
      final value = points[index];
      final normalized = (value - minWeight) / range;
      return Offset(
        points.length == 1 ? size.width / 2 : stepX * index,
        size.height - (normalized * size.height),
      );
    }

    final fillPath = Path()..moveTo(0, size.height);
    final linePath = Path();

    for (var index = 0; index < points.length; index += 1) {
      final point = pointAt(index);
      if (index == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.28),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = AppColors.secondary;
    for (var index = 0; index < points.length; index += 1) {
      canvas.drawCircle(pointAt(index), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
