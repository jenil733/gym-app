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
  const _OtpDigitField({required this.digit, required this.isActive});

  final String digit;
  final bool isActive;

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
      child: Text(digit, style: TextHelper.primary),
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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String otp;
  final bool isFocused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final activeIndex = otp.length.clamp(0, 3);

    return GestureDetector(
      onTap: focusNode.requestFocus,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final digit = index < otp.length ? otp[index] : '';
              final isActive =
                  hasError ||
                  (isFocused &&
                      (index == activeIndex ||
                          (otp.length == 4 && index == 3)));

              return _OtpDigitField(digit: digit, isActive: isActive);
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                key: const ValueKey('otp-input'),
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
