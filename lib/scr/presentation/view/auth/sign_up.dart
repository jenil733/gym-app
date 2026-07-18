import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/sign_up_controller.dart';
import 'package:gym/scr/presentation/view/auth/widget/gender_dropdown.dart';
import 'package:gym/scr/presentation/view/auth/widget/gradient.dart';
import 'package:gym/scr/presentation/view/auth/widget/signup_tesxtfield.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpController _signUpController;

  @override
  void initState() {
    super.initState();
    _signUpController = Get.isRegistered<SignUpController>()
        ? Get.find<SignUpController>()
        : Get.put(SignUpController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<SignUpController>()) {
      Get.delete<SignUpController>();
    }
    super.dispose();
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final currentValue = DateTime.tryParse(
      _signUpController.dobController.text.trim(),
    );
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Select date of birth',
    );
    if (selectedDate == null || !mounted) {
      return;
    }

    _signUpController.updateDob(selectedDate);
    _signUpController.formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CommonAppBar(title: 'Sign Up'),
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            login,
            key: const ValueKey('signup-login-background'),
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
                  padding: EdgeInsets.fromLTRB(30, isCompact ? 24 : 54, 30, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (isCompact ? 52 : 82),
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _signUpController.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create your account',
                              textAlign: TextAlign.center,
                              style: TextHelper.authTitle,
                            ),
                            const SizedBox(height: 18),
                            Text.rich(
                              key: const ValueKey('signup-subtitle'),
                              TextSpan(
                                text: 'Join and start your ',
                                children: [
                                  TextSpan(
                                    text: 'fitness',
                                    style: TextHelper.poppins,
                                  ),
                                  const TextSpan(text: ' journey today.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextHelper.authSubtitle,
                            ),
                            const SizedBox(height: 15),
                            SignUpTextField(
                              controller: _signUpController.nameController,
                              label: 'Name',
                              icon: Icons.person_outline_rounded,
                              hintText: 'Full name',
                              accent: AppColors.primary,
                              fillColor: AppColors.field,
                              borderColor: AppColors.primary,
                              validator: (value) => _signUpController
                                  .requiredField('Name', value),
                            ),
                            const SizedBox(height: 16),
                            SignUpTextField(
                              controller: _signUpController.phoneController,
                              label: 'Phone',
                              icon: Icons.phone_rounded,
                              hintText: 'Phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              accent: AppColors.primary,
                              fillColor: AppColors.field,
                              borderColor: AppColors.border,
                              validator: _signUpController.validatePhone,
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => GenderDropdown(
                                label: 'Gender',
                                value: _signUpController.selectedGender.value,
                                icon: Icons.wc_rounded,
                                accent: AppColors.primary,
                                fillColor: AppColors.field,
                                borderColor: AppColors.border,
                                validator: (value) =>
                                    value == null ? 'Gender is required' : null,
                                onChanged: _signUpController.updateGender,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SignUpTextField(
                              controller: _signUpController.placeController,
                              label: 'Place',
                              icon: Icons.location_on_outlined,
                              hintText: 'Place',
                              accent: AppColors.primary,
                              fillColor: AppColors.field,
                              borderColor: AppColors.border,
                              validator: (value) => _signUpController
                                  .requiredField('Place', value),
                            ),
                            const SizedBox(height: 16),
                            SignUpTextField(
                              controller: _signUpController.dobController,
                              label: 'DOB',
                              icon: Icons.calendar_today_rounded,
                              hintText: 'YYYY-MM-DD',
                              readOnly: true,
                              onTap: _selectDob,
                              accent: AppColors.primary,
                              fillColor: AppColors.field,
                              borderColor: AppColors.border,
                              validator: _signUpController.validateDob,
                            ),
                            const SizedBox(height: 28),
                            Obx(
                              () => GradientButton(
                                onPressed: _signUpController.isLoading.value
                                    ? null
                                    : _signUpController.handleGetStarted,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: TextHelper.footerText,
                                  ),
                                  TextButton(
                                    onPressed: _signUpController.openSignIn,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.only(left: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    child: Text(
                                      'Sign In',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
