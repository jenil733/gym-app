import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/plan_controller.dart';
import 'package:gym/scr/presentation/view/plan/widgets/plan_cards.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class ChoosePlanScreen extends GetView<PlanController> {
  const ChoosePlanScreen({super.key});

  @override
  PlanController get controller => PlanController.resolve();

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonBackHeader(title: 'Choose Plan'),
                const SizedBox(height: 20),
                Text('Membership', style: TextHelper.homeTitle),
                const SizedBox(height: 4),
                Text(
                  'Choose a monthly or yearly plan.',
                  style: TextHelper.homeSubtitle,
                ),
                const SizedBox(height: 18),
                if (controller.isPackagesLoading.value) ...[
                  const LinearProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 12),
                ],
                if (controller.packagesError.value != null) ...[
                  _PackagesNotice(
                    message: controller.packagesError.value!,
                    onRetry: controller.getPackages,
                  ),
                  const SizedBox(height: 12),
                ],
                for (
                  var index = 0;
                  index < controller.plans.length;
                  index += 1
                ) ...[
                  if (index > 0) const SizedBox(height: 12),
                  PlanCard(
                    plan: controller.plans[index],
                    isSelected: controller.selectedPlanIndex.value == index,
                    onTap: () => controller.selectPlan(index),
                  ),
                ],
                const SizedBox(height: 180),
                CommonButton(
                  label: 'Pay Now',
                  onPressed: controller.plans.isEmpty
                      ? null
                      : controller.payNow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackagesNotice extends StatelessWidget {
  const _PackagesNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextHelper.homeSubtitle)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class BenefitLine extends StatelessWidget {
  const BenefitLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextHelper.poppins)),
      ],
    );
  }
}

class MethodButton extends StatelessWidget {
  const MethodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? AppColors.white : AppColors.textSecondary,
        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceHigh,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextHelper.poppins,
      ),
    );
  }
}
