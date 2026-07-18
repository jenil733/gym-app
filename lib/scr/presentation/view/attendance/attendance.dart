import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance', style: TextHelper.homeTitle),
              const SizedBox(height: 2),
              Text(
                'Scan the gym QR to mark today\'s visit.',
                style: TextHelper.homeSubtitle,
              ),
              const SizedBox(height: 20),
              const _ScannerCard(),
              const SizedBox(height: 18),
              Text('Recent Attendance', style: TextHelper.homeTitle2),
              const SizedBox(height: 12),
              const _AttendanceHistoryTile(
                day: 'Today',
                time: 'Ready to scan',
                status: 'Pending',
                isPending: true,
              ),
              const SizedBox(height: 10),
              const _AttendanceHistoryTile(
                day: 'Last visit',
                time: '07:12 AM',
                status: 'Present',
              ),
              const SizedBox(height: 10),
              const _AttendanceHistoryTile(
                day: 'Previous visit',
                time: '06:48 AM',
                status: 'Present',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  const _ScannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.42),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 92,
                ),
                Positioned(
                  top: 24,
                  left: 24,
                  child: _ScannerCorner(alignment: Alignment.topLeft),
                ),
                Positioned(
                  top: 24,
                  right: 24,
                  child: _ScannerCorner(alignment: Alignment.topRight),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: _ScannerCorner(alignment: Alignment.bottomLeft),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: _ScannerCorner(alignment: Alignment.bottomRight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                ToastHelper.info(
                  'Attendance scanner',
                  'QR scanner is ready to connect with the gym QR system.',
                );
              },
              icon: const Icon(Icons.qr_code_2_rounded, size: 21),
              label: Text('Scan QR Code', style: TextHelper.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return SizedBox(
      height: 36,
      width: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: isTop
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 4),
            left: isLeft
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: isLeft
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
      ),
    );
  }
}

class _AttendanceHistoryTile extends StatelessWidget {
  const _AttendanceHistoryTile({
    required this.day,
    required this.time,
    required this.status,
    this.isPending = false,
  });

  final String day;
  final String time;
  final String status;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isPending ? Icons.schedule_rounded : Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TextHelper.homeTitle4),
                const SizedBox(height: 3),
                Text(time, style: TextHelper.homeSubtitle),
              ],
            ),
          ),
          Text(
            status,
            style: TextHelper.poppins2.copyWith(
              color: isPending ? AppColors.warning : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
