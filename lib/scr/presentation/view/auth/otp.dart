import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/otp_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final OtpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<OtpController>()
        ? Get.find<OtpController>()
        : Get.put(OtpController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<OtpController>()) {
      Get.delete<OtpController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CommonAppBar(title: 'OTP Verification'),
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            login,
            key: const ValueKey('otp-login-background'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.authOverlayTop,
                  AppColors.authOverlayMiddle,
                  AppColors.authOverlayBottom,
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 700;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(30, isCompact ? 38 : 70, 30, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (isCompact ? 66 : 98),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _OtpMark(),
                          const SizedBox(height: 30),
                          Text(
                            'Enter OTP',
                            textAlign: TextAlign.center,
                            style: TextHelper.authTitle,
                          ),
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              text: 'Enter the 4 digit code sent to your ',
                              children: [
                                TextSpan(
                                  text: 'phone',
                                  style: TextHelper.poppins,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: TextHelper.authSubtitle,
                          ),
                          SizedBox(height: isCompact ? 42 : 62),
                          Obx(
                            () => _OtpInput(
                              controller: _controller.otpController,
                              focusNode: _controller.otpFocusNode,
                              otp: _controller.otpText.value,
                              isFocused: _controller.isFocused.value,
                              hasError: _controller.errorText.value != null,
                              isLoading: _controller.isLoading.value,
                              selectedDigitIndex:
                                  _controller.selectedDigitIndex.value,
                              onDigitTap: _controller.selectDigit,
                              validationTrigger:
                                  _controller.validationTrigger.value,
                            ),
                          ),
                          Obx(() {
                            final errorText = _controller.errorText.value;
                            if (errorText == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                errorText,
                                textAlign: TextAlign.center,
                                style: TextHelper.error,
                              ),
                            );
                          }),
                          const SizedBox(height: 34),
                          Obx(
                            () => _GradientButton(
                              onPressed: _controller.isLoading.value
                                  ? null
                                  : _controller.verify,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code?",
                                style: TextHelper.footerText,
                              ),
                              Obx(
                                () => TextButton(
                                  onPressed: _controller.canResend
                                      ? _controller.resendOtp
                                      : null,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    disabledForegroundColor:
                                        AppColors.textMuted,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.only(left: 6),
                                    minimumSize: Size.zero,
                                  ),
                                  child: Text(
                                    _controller.resendLabel,
                                    style: TextHelper.link.copyWith(
                                      color: _controller.canResend
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpMark extends StatelessWidget {
  const _OtpMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.14)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primarySoft,
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.digit,
    required this.isActive,
    required this.showCursor,
  });

  final String digit;
  final bool isActive;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('otp-digit-box'),
      width: 62,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 1.6 : 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(digit, style: TextHelper.primary),
          if (showCursor) ...[
            if (digit.isNotEmpty) const SizedBox(width: 2),
            Container(
              width: 1.5,
              height: 27,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.focusNode,
    required this.otp,
    required this.isFocused,
    required this.hasError,
    required this.isLoading,
    required this.selectedDigitIndex,
    required this.onDigitTap,
    required this.validationTrigger,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String otp;
  final bool isFocused;
  final bool hasError;
  final bool isLoading;
  final int selectedDigitIndex;
  final ValueChanged<int> onDigitTap;
  final int validationTrigger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: focusNode.requestFocus,
      child: _Shake(
        trigger: validationTrigger,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const fieldWidth = 62.0;
              const fieldCount = 4;
              final gap =
                  (constraints.maxWidth - (fieldWidth * fieldCount)) /
                  (fieldCount - 1);
              final center = (constraints.maxWidth - fieldWidth) / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(fieldCount, (index) {
                    final digit =
                        index < otp.length &&
                            RegExp(r'[0-9]').hasMatch(otp[index])
                        ? otp[index]
                        : '';
                    final isActive =
                        hasError || (isFocused && index == selectedDigitIndex);
                    final left = index * (fieldWidth + gap);

                    return Positioned(
                      left: left,
                      width: fieldWidth,
                      height: 64,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: isLoading ? 1 : 0),
                        duration: const Duration(milliseconds: 560),
                        curve: Curves.easeInOutCubic,
                        child: IgnorePointer(
                          ignoring: isLoading,
                          child: GestureDetector(
                            key: ValueKey('otp-digit-box-$index'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onDigitTap(index),
                            child: _OtpDigitField(
                              digit: digit,
                              isActive: isActive,
                              showCursor:
                                  isFocused &&
                                  index == selectedDigitIndex &&
                                  !isLoading,
                            ),
                          ),
                        ),
                        builder: (context, progress, child) =>
                            Transform.translate(
                              offset: Offset((center - left) * progress, 0),
                              child: child,
                            ),
                      ),
                    );
                  }),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.01,
                        child: TextField(
                          key: const ValueKey('otp-input'),
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          maxLength: fieldCount,
                          inputFormatters: const [_OtpSlotFormatter()],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OtpSlotFormatter extends TextInputFormatter {
  const _OtpSlotFormatter();

  static const _emptySlot = ' ';
  static const _fieldCount = 4;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;

    if (oldText.isNotEmpty && newValue.text.length == oldText.length - 1) {
      final selectionStart = oldValue.selection.start;
      final deletedIndex = oldValue.selection.isCollapsed
          ? (oldValue.selection.extentOffset - 1).clamp(0, oldText.length - 1)
          : selectionStart.clamp(0, oldText.length - 1);
      final slots = oldText.split('')..[deletedIndex] = _emptySlot;

      return TextEditingValue(
        text: slots.join(),
        selection: TextSelection.collapsed(offset: deletedIndex),
      );
    }

    if (oldText.isNotEmpty &&
        newValue.text.length == oldText.length + 1 &&
        oldValue.selection.isCollapsed) {
      final insertionIndex = oldValue.selection.extentOffset.clamp(
        0,
        oldText.length - 1,
      );
      final insertedCharacter = newValue.text[insertionIndex];
      if (oldText[insertionIndex] == _emptySlot &&
          RegExp(r'[0-9]').hasMatch(insertedCharacter)) {
        final slots = oldText.split('')..[insertionIndex] = insertedCharacter;
        return TextEditingValue(
          text: slots.join(),
          selection: TextSelection.collapsed(offset: insertionIndex + 1),
        );
      }
    }

    final sanitized = newValue.text
        .split('')
        .where(
          (character) =>
              character == _emptySlot || RegExp(r'[0-9]').hasMatch(character),
        )
        .take(_fieldCount)
        .join();
    final selectionOffset = newValue.selection.extentOffset.clamp(
      0,
      sanitized.length,
    );

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class _Shake extends StatefulWidget {
  const _Shake({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<_Shake> createState() => _ShakeState();
}

class _ShakeState extends State<_Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 430),
  );

  @override
  void didUpdateWidget(covariant _Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final offset =
            math.sin(_controller.value * math.pi * 5) *
            7 *
            (1 - _controller.value);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      label: 'Verify OTP',
      onPressed: onPressed,
      height: 54,
      borderRadius: 18,
      useGradient: true,
    );
  }
}
