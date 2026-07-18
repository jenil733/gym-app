import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';

class OtpController extends GetxController {
  OtpController([this._verifyOtpUseCase, this._storage]);

  final VerifyOtpUseCase? _verifyOtpUseCase;
  final LocalStorageService? _storage;

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final RxString otpText = ''.obs;
  final RxBool isFocused = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxInt resendSeconds = 30.obs;
  final RxnString errorText = RxnString();

  String? _phoneNumber;
  String? _receivedOtp;
  String _type = 'register';
  Timer? _resendTimer;

  bool get canResend => resendSeconds.value == 0 && !isResending.value;

  String get resendLabel {
    if (isResending.value) {
      return 'Sending...';
    }
    if (resendSeconds.value > 0) {
      return 'Resend in 00:${resendSeconds.value.toString().padLeft(2, '0')}';
    }
    return 'Resend';
  }

  VerifyOtpUseCase get _useCase =>
      _verifyOtpUseCase ?? Get.find<VerifyOtpUseCase>();

  LocalStorageService get _localStorage =>
      _storage ?? Get.find<LocalStorageService>();

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      _phoneNumber = arguments['phone']?.toString();
      _type = arguments['type']?.toString() ?? 'register';
      _receivedOtp = arguments['otp']?.toString();
    }

    otpController.addListener(_handleOtpChanged);
    otpFocusNode.addListener(_handleFocusChanged);
    _startResendCountdown();
  }

  @override
  void onReady() {
    super.onReady();
    final receivedOtp = _receivedOtp;
    if (receivedOtp != null && receivedOtp.isNotEmpty) {
      ToastHelper.info('Your OTP', receivedOtp);
    }
  }

  void _handleOtpChanged() {
    otpText.value = otpController.text;
    errorText.value = null;
  }

  void _handleFocusChanged() {
    isFocused.value = otpFocusNode.hasFocus;
  }

  Future<void> verify() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (otpController.text.length != 4) {
      _showError('Enter the 4 digit OTP');
      return;
    }

    final phoneNumber = _phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError('Phone number is missing. Please try again.');
      return;
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await _useCase(
        OtpParams(
          phoneNumber: phoneNumber,
          otp: otpController.text,
          type: _type,
        ),
      );

      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        _showError(response.message ?? 'OTP verification failed.');
        return;
      }

      final token = response.data?.token?.trim();
      if (token != null && token.isNotEmpty) {
        await _localStorage.saveString('auth_token', token);
      }

      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      _showError(
        responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unable to verify OTP. Please check your connection.',
      );
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) {
      return;
    }

    final phoneNumber = _phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showError('Phone number is missing. Please try again.');
      return;
    }

    otpController.clear();
    errorText.value = null;
    isResending.value = true;
    try {
      final response = await _useCase.resend(
        ResendOtpParams(phoneNumber: phoneNumber, type: _type),
      );
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        _showError(response.message ?? 'Unable to resend OTP.');
        return;
      }

      _receivedOtp = response.data?.otp;
      _startResendCountdown();
      final newOtp = _receivedOtp;
      if (newOtp != null && newOtp.isNotEmpty) {
        ToastHelper.info('New OTP', newOtp);
      } else {
        ToastHelper.success(
          'OTP sent',
          response.message ?? 'A new OTP was sent to your phone.',
        );
      }
      otpFocusNode.requestFocus();
    } on DioException catch (error) {
      final responseData = error.response?.data;
      _showError(
        responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unable to resend OTP. Please check your connection.',
      );
    } catch (_) {
      _showError('Something went wrong while resending OTP.');
    } finally {
      isResending.value = false;
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    resendSeconds.value = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value -= 1;
      }
    });
  }

  void _showError(String message) {
    errorText.value = message;
    ToastHelper.error('OTP verification', message);
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    otpController
      ..removeListener(_handleOtpChanged)
      ..dispose();
    otpFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.onClose();
  }
}
