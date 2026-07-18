import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/view/plan/choose_plan.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class PaymentSection extends StatelessWidget {
  const PaymentSection({
    required this.methods,
    required this.selectedIndex,
    required this.onMethodSelected,
    required this.onPayNow,
  });

  final List<String> methods;
  final int selectedIndex;
  final ValueChanged<int> onMethodSelected;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Section', style: TextHelper.homeTitle),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < methods.length; index += 1) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: MethodButton(
                    label: methods[index],
                    isSelected: selectedIndex == index,
                    onTap: () => onMethodSelected(index),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gym Member', style: TextHelper.homeTitle),
                      const SizedBox(height: 2),
                      Text(
                        '**** **** **** 4242',
                        style: TextHelper.homeSubtitle,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.lock_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CommonButton(
            label: 'Pay Now',
            onPressed: onPayNow,
            icon: Icons.payments_rounded,
          ),
        ],
      ),
    );
  }
}
