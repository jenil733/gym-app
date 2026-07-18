import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/domain/repository/login_repository.dart';
import 'package:gym/scr/domain/usecase/login_usecase.dart';

class LoginController extends GetxController {
  LoginController([this._loginUseCase]);

  final LoginUseCase? _loginUseCase;

  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();

  LoginUseCase get _useCase => _loginUseCase ?? Get.find<LoginUseCase>();

  void onPhoneChanged(String _) {
    errorText.value = null;
  }

  Future<void> openOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.length != 10 || int.tryParse(phoneNumber) == null) {
      errorText.value = 'Enter a valid 10 digit phone number';
      return;
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await _useCase(LoginParams(phoneNumber: phoneNumber));
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;

      if (!isSuccessful) {
        errorText.value = response.message ?? 'Login failed. Please try again.';
        return;
      }

      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'phone': phoneNumber,
          'type': 'login',
          'otp': response.data?.otp,
        },
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      errorText.value = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to login. Please check your connection.';
    } catch (_) {
      errorText.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void openSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
