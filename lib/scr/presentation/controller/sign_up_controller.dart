import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/constants/fitness_goals.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/pending_registration_profile.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/usecase/signup_usecase.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';
import 'package:gym/scr/presentation/controller/login_controller.dart';

class SignUpController extends GetxController {
  SignUpController([this._signupUseCase, this._pendingRegistrationProfile]);

  final SignupUseCase? _signupUseCase;
  final PendingRegistrationProfile? _pendingRegistrationProfile;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final RxnString selectedGender = RxnString();
  final RxnString selectedFitnessGoal = RxnString();
  final RxBool isLoading = false.obs;

  static const List<String> fitnessGoals = FitnessGoals.values;

  SignupUseCase get _useCase => _signupUseCase ?? Get.find<SignupUseCase>();

  VerifyOtpUseCase? get _otpUseCase => Get.isRegistered<VerifyOtpUseCase>()
      ? Get.find<VerifyOtpUseCase>()
      : null;

  PendingRegistrationProfile get _pendingProfile =>
      _pendingRegistrationProfile ??
      (Get.isRegistered<PendingRegistrationProfile>()
          ? Get.find<PendingRegistrationProfile>()
          : PendingRegistrationProfile(LocalStorageService()));

  UpdateProfileUseCase? get _profileUpdater =>
      Get.isRegistered<UpdateProfileUseCase>()
      ? Get.find<UpdateProfileUseCase>()
      : null;

  void updateGender(String? value) {
    selectedGender.value = value;
  }

  void updateFitnessGoal(String? value) {
    selectedFitnessGoal.value = value;
  }

  void updateDob(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    dobController.text = '${date.year}-$month-$day';
  }

  void openSignIn() {
    Get.toNamed(AppRoutes.login);
  }

  Future<void> handleGetStarted() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid || isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await _useCase(
        SignupParams(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          gender: selectedGender.value!,
          address: addressController.text.trim(),
          dob: dobController.text.trim(),
          fitnessGoal: selectedFitnessGoal.value!,
        ),
      );

      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;

      if (!isSuccessful) {
        ToastHelper.error(
          'Sign up failed',
          response.message ?? 'Please try again.',
        );
        return;
      }

      final registeredPhone = phoneController.text.trim();
      await _pendingProfile.save(
        phone: registeredPhone,
        address: addressController.text.trim(),
        fitnessGoal: selectedFitnessGoal.value!,
      );

      final registrationOtp = response.data?.otp?.toString();
      final otpUseCase = _otpUseCase;
      if (registrationOtp != null &&
          registrationOtp.isNotEmpty &&
          otpUseCase != null) {
        final verificationResponse = await otpUseCase(
          OtpParams(
            phoneNumber: phoneController.text.trim(),
            otp: registrationOtp,
            type: 'register',
          ),
        );
        final isVerified =
            verificationResponse.success == true ||
            verificationResponse.code == 200 ||
            verificationResponse.code == 201;
        if (!isVerified) {
          ToastHelper.error(
            'Registration verification failed',
            verificationResponse.message ?? 'Please try again.',
          );
          return;
        }
        final verificationToken = verificationResponse.data?.token;
        final profileUpdater = _profileUpdater;
        if (verificationToken != null && profileUpdater != null) {
          await _pendingProfile.sync(
            phone: registeredPhone,
            updateProfile: profileUpdater,
            temporaryAuthToken: verificationToken,
          );
        }
      }

      final successMessage =
          response.message ?? 'Registration completed successfully.';
      if (Get.isRegistered<LoginController>()) {
        Get.find<LoginController>().phoneController.text = registeredPhone;
        Get.back<void>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ToastHelper.success('Registration successful', successMessage);
        });
      } else {
        Get.offAllNamed(
          AppRoutes.login,
          arguments: {
            'phone': registeredPhone,
            'registration_success': true,
            'message': successMessage,
          },
        );
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to sign up. Please check your connection.';

      ToastHelper.error('Sign up failed', message);
    } catch (_) {
      ToastHelper.error(
        'Sign up failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? requiredField(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (digits.isEmpty) {
      return 'Phone number is required';
    }

    if (digits.length != 10) {
      return 'Enter a 10 digit phone number';
    }

    return null;
  }

  String? validateDob(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'DOB is required';
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return 'Enter DOB as YYYY-MM-DD';
    }

    final parts = text.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = DateTime(year, month, day);

    if (date.year != year || date.month != month || date.day != day) {
      return 'Enter a valid date';
    }

    if (date.isAfter(DateTime.now())) {
      return 'DOB cannot be in the future';
    }

    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
