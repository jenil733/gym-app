import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:gym/scr/presentation/view/progress/widgets/weight.dart';

class ProgressScreen extends GetView<ProgressController> {
  const ProgressScreen({super.key});

  @override
  ProgressController get controller => ProgressController.resolve();

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress', style: TextHelper.homeTitle),
              const SizedBox(height: 2),
              Text(
                'Stay focused on your six-month target.',
                style: TextHelper.homeSubtitle,
              ),
              const SizedBox(height: 18),
              WeightSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key, required this.item});

  final ProgressHistoryItem item;

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
                Text(
                  item.label,
                  style: TextHelper.homeTitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  item.note?.trim().isNotEmpty == true
                      ? '${item.weight} • ${item.note}'
                      : item.weight,
                  style: TextHelper.homeSubtitle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            item.change,
            style: TextHelper.poppins.copyWith(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
