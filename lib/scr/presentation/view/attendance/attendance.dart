import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/attendance_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AttendanceController.resolve();

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
              _ScannerCard(controller: controller),
              const SizedBox(height: 18),
              Text('Recent Attendance', style: TextHelper.homeTitle2),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingHistory.value &&
                    controller.attendance.value == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                final history = controller.history;
                if (history.isEmpty) {
                  return _AttendanceHistoryTile(
                    day: 'Today',
                    time: controller.todayMarked
                        ? controller.latestAttendance.value?.date ??
                              'Marked today'
                        : 'Ready to scan',
                    status: controller.todayMarked ? 'Present' : 'Pending',
                    isPending: !controller.todayMarked,
                  );
                }

                return Column(
                  children: List.generate(history.length, (index) {
                    final item = history[index];
                    final status = item.status?.trim().isNotEmpty == true
                        ? item.status!.trim()
                        : 'Present';
                    final normalizedStatus = status.toLowerCase();
                    final isPending =
                        normalizedStatus != 'present' &&
                        normalizedStatus != 'marked';

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == history.length - 1 ? 0 : 10,
                      ),
                      child: _AttendanceHistoryTile(
                        day: item.label?.trim().isNotEmpty == true
                            ? item.label!.trim()
                            : item.date ?? 'Attendance',
                        time: item.checkInTime?.trim().isNotEmpty == true
                            ? item.checkInTime!.trim()
                            : item.date ?? '--',
                        status: status,
                        isPending: isPending,
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  const _ScannerCard({required this.controller});

  final AttendanceController controller;

  Future<void> _openScanner(BuildContext context) async {
    final supportsScanner =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (!supportsScanner) {
      ToastHelper.info(
        'QR scanner',
        'QR scanning is available on Android, iOS, macOS, and web.',
      );
      return;
    }

    final qrCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const _QrScannerScreen()),
    );
    if (qrCode != null && context.mounted) {
      await controller.submitQr(qrCode);
    }
  }

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
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => _openScanner(context),
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.qr_code_2_rounded, size: 21),
                label: Text(
                  controller.isSubmitting.value
                      ? 'Marking Attendance...'
                      : 'Scan QR Code',
                  style: TextHelper.button,
                ),
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
          ),
        ],
      ),
    );
  }
}

class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _hasResult = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_hasResult || capture.barcodes.isEmpty) {
      return;
    }

    final value = capture.barcodes.first.rawValue?.trim();
    if (value == null || value.isEmpty) {
      return;
    }

    _hasResult = true;
    await _scannerController.stop();
    if (mounted) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text('Scan Gym QR'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 42,
            child: Text(
              'Place the gym QR code inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
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
