import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/view/home/widget/homebody.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class BodyHistoryScreen extends StatelessWidget {
  const BodyHistoryScreen({super.key, required this.metric});

  final HomeBodyMetric metric;

  @override
  Widget build(BuildContext context) {
    final history = _historyFor(metric);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: '${metric.title} History'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(metric: metric),
              const SizedBox(height: 20),
              Text('Recent History', style: TextHelper.homeTitle2),
              const SizedBox(height: 12),
              if (history.isEmpty)
                Text('No history added yet.', style: TextHelper.homeSubtitle)
              else
                for (var index = 0; index < history.length; index += 1) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _HistoryRow(item: history[index], color: metric.color),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

List<HomeBodyHistoryItem> _historyFor(HomeBodyMetric metric) {
  final history = metric.history;
  return history ?? const <HomeBodyHistoryItem>[];
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metric});

  final HomeBodyMetric metric;

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
              color: metric.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: metric.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.title, style: TextHelper.homeTitle2),
                const SizedBox(height: 6),
                ValueLine(
                  value: metric.value,
                  unit: metric.unit,
                  valueSize: 28,
                ),
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

  final HomeBodyHistoryItem item;
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
