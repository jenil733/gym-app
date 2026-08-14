import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/pending_registration_profile.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:gym/scr/presentation/controller/fcm_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

class OtpController extends GetxController {
  OtpController([
    this._verifyOtpUseCase,
    this._storage,
    this._pendingRegistrationProfile,
    this._updateProfileUseCase,
  ]);

  final VerifyOtpUseCase? _verifyOtpUseCase;
  final LocalStorageService? _storage;
  final PendingRegistrationProfile? _pendingRegistrationProfile;
  final UpdateProfileUseCase? _updateProfileUseCase;

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final RxString otpText = ''.obs;
  final RxBool isFocused = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxInt resendSeconds = 30.obs;
  final RxInt selectedDigitIndex = 0.obs;
  final RxnString errorText = RxnString();
  final RxInt validationTrigger = 0.obs;

  String? _phoneNumber;
  String? _receivedOtp;
  String _type = 'register';
  Timer? _resendTimer;
  int _lastCursorOffset = 0;

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

  PendingRegistrationProfile? get _pendingProfile {
    if (_pendingRegistrationProfile != null) {
      return _pendingRegistrationProfile;
    }
    return Get.isRegistered<PendingRegistrationProfile>()
        ? Get.find<PendingRegistrationProfile>()
        : null;
  }

  UpdateProfileUseCase? get _profileUpdater {
    if (_updateProfileUseCase != null) {
      return _updateProfileUseCase;
    }
    return Get.isRegistered<UpdateProfileUseCase>()
        ? Get.find<UpdateProfileUseCase>()
        : null;
  }

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
    final cursorOffset = otpController.selection.extentOffset;
    if (cursorOffset >= 0) {
      _lastCursorOffset = cursorOffset;
      final baseOffset = otpController.selection.baseOffset;
      final selectionStart = baseOffset >= 0 && baseOffset < cursorOffset
          ? baseOffset
          : cursorOffset;
      selectedDigitIndex.value = selectionStart.clamp(0, 3);
    }
    errorText.value = null;
  }

  void _handleFocusChanged() {
    isFocused.value = otpFocusNode.hasFocus;
  }

  void selectDigit(int index) {
    final safeIndex = index.clamp(0, 3).toInt();
    final textLength = otpController.text.length;
    otpFocusNode.requestFocus();

    if (safeIndex < textLength) {
      otpController.selection = TextSelection(
        baseOffset: safeIndex,
        extentOffset: safeIndex + 1,
      );
    } else {
      otpController.selection = TextSelection.collapsed(offset: textLength);
    }
    selectedDigitIndex.value = safeIndex;
  }

  Future<void> verify() async {
    final otp = otpController.text.replaceAll(RegExp('[^0-9]'), '');
    if (otp.length != 4) {
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
    final verificationAnimation = Stopwatch()..start();
    try {
      final response = await _useCase(
        OtpParams(
          phoneNumber: phoneNumber,
          otp: otp,
          type: _type,
          fcmToken: _localStorage.getString(FcmController.storageKey),
          deviceId: _localStorage.getString(
            FcmController.installationIdStorageKey,
          ),
        ),
      );

      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        await _finishFailedVerificationAnimation(verificationAnimation);
        _showError(response.message ?? 'OTP verification failed.');
        return;
      }

      final token = response.data?.token?.trim();
      if (token != null && token.isNotEmpty) {
        await _localStorage.saveString('auth_token', token);
        await _localStorage.saveString(
          FcmController.accountPhoneStorageKey,
          phoneNumber,
        );
        if (Get.isRegistered<FcmController>()) {
          unawaited(
            Get.find<FcmController>().syncToken(phoneNumber: phoneNumber),
          );
        }
        if (Get.isRegistered<WorkoutController>()) {
          await Get.find<WorkoutController>().initializeAuthenticatedData();
        }
        final pendingProfile = _pendingProfile;
        final profileUpdater = _profileUpdater;
        if (pendingProfile != null && profileUpdater != null) {
          await pendingProfile.sync(
            phone: phoneNumber,
            updateProfile: profileUpdater,
          );
        }
      }

      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (error.response != null) {
        await _finishFailedVerificationAnimation(verificationAnimation);
      }
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

  Future<void> _finishFailedVerificationAnimation(Stopwatch stopwatch) async {
    const convergenceDuration = Duration(milliseconds: 560);
    final remaining = convergenceDuration - stopwatch.elapsed;
    if (!remaining.isNegative) {
      await Future<void>.delayed(remaining);
    }
    otpController.clear();
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
    validationTrigger.value += 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) {
        return;
      }
      final offset = _lastCursorOffset.clamp(0, otpController.text.length);
      otpController.selection = TextSelection.collapsed(offset: offset);
      otpFocusNode.requestFocus();
    });
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
