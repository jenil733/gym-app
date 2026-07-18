import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/view/home/widget/homebody.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class StatHistoryScreen extends StatefulWidget {
  const StatHistoryScreen({super.key, required this.stat});

  final HomeStatItem stat;

  @override
  State<StatHistoryScreen> createState() => _StatHistoryScreenState();
}

class _StatHistoryScreenState extends State<StatHistoryScreen> {
  HomeController? _homeController;

  bool get _isWorkoutHistory => widget.stat.title == 'Workout Time';

  @override
  void initState() {
    super.initState();
    if (_isWorkoutHistory) {
      _homeController = HomeController.resolve();
      Future<void>.microtask(
        () => _homeController?.getWorkoutHistory(force: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_homeController != null) {
      return Obx(() {
        final controller = _homeController!;
        final liveStat = controller.stats.firstWhereOrNull(
          (item) => item.title == 'Workout Time',
        );
        return _HistoryScaffold(
          stat: liveStat ?? widget.stat,
          isLoading: controller.isWorkoutHistoryLoading.value,
          error: controller.workoutHistoryError.value,
          onRetry: () => controller.getWorkoutHistory(force: true),
        );
      });
    }

    return _HistoryScaffold(stat: widget.stat);
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({
    required this.stat,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  final HomeStatItem stat;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: '${stat.title} History'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(stat: stat),
              if (isLoading) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(color: AppColors.primary),
              ],
              if (error != null) ...[
                const SizedBox(height: 14),
                _HistoryError(message: error!, onRetry: onRetry),
              ],
              const SizedBox(height: 20),
              Text('Recent History', style: TextHelper.homeTitle2),
              const SizedBox(height: 12),
              if (stat.history.isEmpty && !isLoading)
                Text(
                  'No workout timing history yet.',
                  style: TextHelper.homeSubtitle,
                )
              else
                for (
                  var index = 0;
                  index < stat.history.length;
                  index += 1
                ) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _HistoryRow(item: stat.history[index], color: stat.color),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextHelper.homeSubtitle)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stat});

  final HomeStatItem stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(stat.icon, color: stat.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.title, style: TextHelper.homeTitle2),
                const SizedBox(height: 6),
                ValueLine(value: stat.value, unit: stat.unit, valueSize: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.color});

  final HomeStatHistoryItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: TextHelper.homeTitle4),
                const SizedBox(height: 4),
                Text(item.note, style: TextHelper.homeSubtitle),
              ],
            ),
          ),
          Text('${item.value} ${item.unit}', style: TextHelper.homeTitle4),
        ],
      ),
    );
  }
}
