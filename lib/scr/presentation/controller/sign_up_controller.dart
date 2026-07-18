import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/usecase/signup_usecase.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';
import 'package:gym/scr/presentation/controller/login_controller.dart';

class SignUpController extends GetxController {
  SignUpController([this._signupUseCase]);

  final SignupUseCase? _signupUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final RxnString selectedGender = RxnString();
  final RxBool isLoading = false.obs;

  SignupUseCase get _useCase => _signupUseCase ?? Get.find<SignupUseCase>();

  VerifyOtpUseCase? get _otpUseCase => Get.isRegistered<VerifyOtpUseCase>()
      ? Get.find<VerifyOtpUseCase>()
      : null;

  void updateGender(String? value) {
    print("Selected Gender: $value");
    selectedGender.value = value;
  }

  void updateDob(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    dobController.text = '${date.year}-$month-$day';
  }

  void openSignIn() {
    print("Navigating to Login");
    Get.toNamed(AppRoutes.login);
  }

  Future<void> handleGetStarted() async {
    print("Signup button clicked");

    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = formKey.currentState?.validate() ?? false;

    print("Form validation: $isValid");

    if (!isValid || isLoading.value) {
      print("Form invalid or already loading");
      return;
    }

    isLoading.value = true;

    try {
      print("Sending signup request...");
      print("Name: ${nameController.text.trim()}");
      print("Phone: ${phoneController.text.trim()}");
      print("Gender: ${selectedGender.value}");
      print("Place: ${placeController.text.trim()}");
      print("DOB: ${dobController.text.trim()}");

      final response = await _useCase(
        SignupParams(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          gender: selectedGender.value!,
          place: placeController.text.trim(),
          dob: dobController.text.trim(),
        ),
      );

      print("API Response received");
      print("Success: ${response.success}");
      print("Code: ${response.code}");
      print("Message: ${response.message}");
      print("Data: ${response.data}");

      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;

      if (!isSuccessful) {
        print("Signup failed from API");
        ToastHelper.error(
          'Sign up failed',
          response.message ?? 'Please try again.',
        );
        return;
      }

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
      }

      print("Signup verified -> Going to Login screen");

      final registeredPhone = phoneController.text.trim();
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
      print("Dio Error occurred");
      print("Error Message: ${error.message}");
      print("Status Code: ${error.response?.statusCode}");
      print("Response Data: ${error.response?.data}");

      final responseData = error.response?.data;
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to sign up. Please check your connection.';

      ToastHelper.error('Sign up failed', message);
    } catch (e) {
      print("Unexpected Error: $e");
      ToastHelper.error(
        'Sign up failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      print("Loading finished");
      isLoading.value = false;
    }
  }

  String? requiredField(String label, String? value) {
    print("Validating field: $label = $value");

    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    print("Validating phone: $value");

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
    print("Disposing controllers");

    nameController.dispose();
    phoneController.dispose();
    placeController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
