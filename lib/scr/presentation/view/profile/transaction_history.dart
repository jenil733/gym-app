import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/transaction_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController.findOrCreate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Transaction History'),
      body: SafeArea(
        child: Obx(() {
          if (controller.transactions.isEmpty) {
            return const _EmptyTransactionHistory();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: controller.transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _TransactionCard(
                transaction: controller.transactions[index],
              );
            },
          );
        }),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final TransactionRecord transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transaction.plan} Membership',
                      style: TextHelper.homeTitle2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(transaction.createdAt),
                      style: TextHelper.homeSubtitle,
                    ),
                  ],
                ),
              ),
              Text(transaction.amount, style: TextHelper.homeTitle2),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${transaction.paymentMethod} · ${transaction.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextHelper.homeSubtitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Completed',
                  style: TextHelper.poppins.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionHistory extends StatelessWidget {
  const _EmptyTransactionHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text('No transactions yet', style: TextHelper.homeTitle),
            const SizedBox(height: 6),
            Text(
              'Membership payments will appear here after checkout.',
              textAlign: TextAlign.center,
              style: TextHelper.homeSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day} ${months[value.month - 1]} ${value.year}, $hour:$minute $period';
}
