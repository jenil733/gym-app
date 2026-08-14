import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:gym/scr/presentation/view/progress/progress.dart';

const Color _journeyAccent = Color(0xFFFFAA00);

class WeightSection extends StatefulWidget {
  const WeightSection({super.key, required this.controller});

  final ProgressController controller;

  @override
  State<WeightSection> createState() => _WeightSectionState();
}

class _WeightSectionState extends State<WeightSection> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _weeklyWeightController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    _weeklyWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.isWeightHistoryLoading.value &&
              controller.currentWeight.value <= 0)
            const Center(child: CircularProgressIndicator())
          else if (controller.activeGoal.value == null) ...[
            _CurrentWeightCard(
              weight: controller.currentWeight.value,
              change: controller.currentChange.value,
            ),
            const SizedBox(height: 16),
          ],
          if (controller.activeGoal.value == null)
            _GoalSetupCard(
              targetController: _targetController,
              enabled: controller.currentWeight.value > 0,
              onSetGoal: () => _setGoal(controller),
            )
          else
            _WeightJourneyCard(controller: controller),
          const SizedBox(height: 16),
          _WeeklyWeightCheckIn(
            controller: _weeklyWeightController,
            isSaving: controller.isHeightWeightSaving.value,
            onSave: () => _saveWeeklyWeight(controller),
          ),
          const SizedBox(height: 16),
          _AnimatedWeightWaveChart(
            points: controller.graphPoints.toList(growable: false),
            rangeLabel: controller.graphRangeLabel,
          ),
          if (controller.heightWeightError.value != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.heightWeightError.value!,
              style: TextHelper.homeSubtitle.copyWith(color: AppColors.warning),
            ),
          ],
          if (controller.weightHistoryError.value != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.weightHistoryError.value!,
              style: TextHelper.homeSubtitle,
            ),
          ],
          const SizedBox(height: 22),
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

  Future<void> _setGoal(ProgressController controller) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final target = double.tryParse(_targetController.text.trim());
    if (target != null && await controller.setSixMonthGoal(target)) {
      _targetController.clear();
    }
  }

  Future<void> _saveWeeklyWeight(ProgressController controller) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final weight = double.tryParse(
      _weeklyWeightController.text.trim().replaceAll(',', '.'),
    );
    if (weight != null && await controller.logWeeklyWeight(weight)) {
      _weeklyWeightController.clear();
    }
  }
}

class _WeeklyWeightCheckIn extends StatelessWidget {
  const _WeeklyWeightCheckIn({
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weekly-weight-check-in'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_repeat_rounded, color: _journeyAccent),
              const SizedBox(width: 9),
              Text('Weekly Weight Check-in', style: TextHelper.homeTitle),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Log once each week under similar conditions for a clearer trend.',
            style: TextHelper.homeSubtitle,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('weekly-weight-input'),
                  controller: controller,
                  enabled: !isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    hintText: 'Current weight',
                    suffixText: 'kg',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                key: const ValueKey('save-weekly-weight-button'),
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedWeightWaveChart extends StatefulWidget {
  const _AnimatedWeightWaveChart({
    required this.points,
    required this.rangeLabel,
  });

  final List<WeightGraphPoint> points;
  final String rangeLabel;

  @override
  State<_AnimatedWeightWaveChart> createState() =>
      _AnimatedWeightWaveChartState();
}

class _AnimatedWeightWaveChartState extends State<_AnimatedWeightWaveChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final summary = points.isEmpty
        ? 'No weekly weight entries yet'
        : '${points.length} weekly weight points, latest '
              '${points.last.weight.toStringAsFixed(1)} kilograms';
    return Container(
      key: const ValueKey('weekly-weight-wave-chart'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight Trend', style: TextHelper.homeTitle),
          const SizedBox(height: 3),
          Text(
            '${widget.rangeLabel} • weekly average in kg',
            style: TextHelper.homeSubtitle.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: summary,
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        'Add your first weekly weight to start the graph.',
                        textAlign: TextAlign.center,
                        style: TextHelper.homeSubtitle,
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => CustomPaint(
                        painter: _WeightWavePainter(
                          points: points,
                          pulse: _pulse.value,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
            ),
          ),
          if (points.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(points.first.label, style: TextHelper.homeSubtitle),
                if (points.length > 1)
                  Text(points.last.label, style: TextHelper.homeSubtitle),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightWavePainter extends CustomPainter {
  const _WeightWavePainter({required this.points, required this.pulse});

  final List<WeightGraphPoint> points;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(8, 10, size.width - 16, size.height - 20);
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index += 1) {
      final y = chart.top + (chart.height * index / 3);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    final weights = points.map((point) => point.weight).toList(growable: false);
    final minimum = weights.reduce(math.min);
    final maximum = weights.reduce(math.max);
    final spread = math.max(maximum - minimum, 1.0);
    final lower = minimum - spread * 0.18;
    final upper = maximum + spread * 0.18;

    Offset offsetFor(int index) {
      final x = points.length == 1
          ? chart.center.dx
          : chart.left + chart.width * index / (points.length - 1);
      final normalized = (points[index].weight - lower) / (upper - lower);
      return Offset(x, chart.bottom - normalized * chart.height);
    }

    final offsets = List<Offset>.generate(points.length, offsetFor);
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var index = 1; index < offsets.length; index += 1) {
      final previous = offsets[index - 1];
      final current = offsets[index];
      final midpoint = (previous.dx + current.dx) / 2;
      path.cubicTo(
        midpoint,
        previous.dy,
        midpoint,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    if (offsets.length > 1) {
      canvas.drawPath(
        path,
        Paint()
          ..color = _journeyAccent.withValues(alpha: 0.12 + pulse * 0.16)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7 + pulse * 2,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = _journeyAccent
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.5,
      );
    }

    final pointPaint = Paint()..color = const Color(0xFF151515);
    final pointBorder = Paint()
      ..color = _journeyAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final offset in offsets) {
      canvas.drawCircle(offset, 4, pointPaint);
      canvas.drawCircle(offset, 4, pointBorder);
    }
    canvas.drawCircle(
      offsets.last,
      6 + pulse * 3,
      Paint()..color = _journeyAccent.withValues(alpha: 0.16 + pulse * 0.16),
    );
    canvas.drawCircle(offsets.last, 3.5, Paint()..color = _journeyAccent);
  }

  @override
  bool shouldRepaint(covariant _WeightWavePainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.points != points;
  }
}

class _WeightJourneyCard extends StatelessWidget {
  const _WeightJourneyCard({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final goal = controller.activeGoal.value!;
    final progress = controller.goalProgress;
    final percent = (progress * 100).round();
    final completed = controller.isGoalCompleted;

    return Container(
      key: const ValueKey('weight-journey-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF343434)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.outlined_flag_rounded,
                          color: _journeyAccent,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Weight Journey',
                          style: TextHelper.homeTitle.copyWith(fontSize: 17),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Target Weight',
                      style: TextHelper.homeSubtitle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${goal.targetWeight.toStringAsFixed(1)} kg',
                      key: const ValueKey('weight-goal-target'),
                      style: TextHelper.homeTitle.copyWith(fontSize: 25),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 98,
                width: 98,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFF303030),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _journeyAccent,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        key: const ValueKey('weight-goal-percent'),
                        style: TextHelper.homeTitle.copyWith(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: const Color(0xFF303030),
              valueColor: const AlwaysStoppedAnimation<Color>(_journeyAccent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  completed
                      ? 'Goal completed'
                      : '${controller.goalRemaining.toStringAsFixed(1)} kg to go',
                  style: TextHelper.poppins.copyWith(
                    color: completed ? AppColors.success : AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                completed
                    ? 'Congratulations!'
                    : 'Locked until ${controller.goalUnlockDateLabel}',
                style: TextHelper.homeSubtitle.copyWith(fontSize: 10),
              ),
            ],
          ),
          if (controller.canChangeGoal) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.startNewGoal,
                child: const Text('Set a New Goal'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalSetupCard extends StatelessWidget {
  const _GoalSetupCard({
    required this.targetController,
    required this.enabled,
    required this.onSetGoal,
  });

  final TextEditingController targetController;
  final bool enabled;
  final VoidCallback onSetGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weight-goal-setup'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.outlined_flag_rounded, color: _journeyAccent),
              const SizedBox(width: 9),
              Text('Set Goal Weight', style: TextHelper.homeTitle),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Choose carefully. Your target cannot be changed for six months.',
            style: TextHelper.homeSubtitle,
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('weight-goal-input'),
            controller: targetController,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: enabled
                  ? 'Target weight'
                  : 'Log your current weight first',
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('set-weight-goal-button'),
              onPressed: enabled ? onSetGoal : null,
              child: const Text('Set 6-Month Goal'),
            ),
          ),
        ],
      ),
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
          if (weight > 0)
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
