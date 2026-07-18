import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/controller/login_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _contentController;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentOpacity;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();

    _loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
    final arguments = Get.arguments;
    final registrationMessage =
        arguments is Map && arguments['registration_success'] == true
        ? arguments['message']?.toString() ??
              'Registration completed successfully.'
        : null;
    final registeredPhone = arguments is Map
        ? arguments['phone']?.toString().trim()
        : null;
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (registeredPhone != null && registeredPhone.isNotEmpty) {
        _loginController.phoneController.text = registeredPhone;
      }
      _contentController.forward();
      if (registrationMessage != null) {
        ToastHelper.success('Registration successful', registrationMessage);
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    final loginController = _loginController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.login &&
          Get.isRegistered<LoginController>() &&
          identical(Get.find<LoginController>(), loginController)) {
        Get.delete<LoginController>();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            login,
            key: const ValueKey(login),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.overlayMedium,
                  AppColors.overlayLight,
                  AppColors.overlayStrong,
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 30,
                    ),
                    child: IntrinsicHeight(
                      child: SlideTransition(
                        key: const ValueKey('login-content-slide'),
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentOpacity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Welcome Back',
                                      style: TextHelper.authTitle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                'Login to continue your fitness journey',
                                textAlign: TextAlign.center,
                                style: TextHelper.authSubtitle,
                              ),
                              const SizedBox(height: 22),
                              _LoginTextField(
                                controller: _loginController.phoneController,
                                icon: Icons.phone_android_rounded,
                                hintText: 'phone number',
                                prefixText: '+91 ',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _IndianPhoneNumberFormatter(),
                                ],
                                onChanged: _loginController.onPhoneChanged,
                              ),
                              Obx(() {
                                final error = _loginController.errorText.value;
                                if (error == null) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    error,
                                    style: TextHelper.error,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              Obx(
                                () => CommonButton(
                                  label: 'Login',
                                  onPressed: _loginController.isLoading.value
                                      ? null
                                      : _loginController.openOtp,
                                  height: 54,
                                  borderRadius: 8,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 34),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextHelper.footerText,
                                    ),
                                    TextButton(
                                      onPressed: _loginController.openSignUp,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.only(left: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: Text(
                                        'Sign Up',
                                        style: TextHelper.link,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: TextHelper.poppins.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextHelper.poppins.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(icon, size: 20, color: AppColors.textLight),
          prefixText: prefixText,
          prefixStyle: TextHelper.poppins.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}
