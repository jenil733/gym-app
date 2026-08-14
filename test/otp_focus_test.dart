import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/data/model/otp_model.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';
import 'package:gym/scr/presentation/controller/otp_controller.dart';
import 'package:gym/scr/presentation/view/auth/otp.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('invalid OTP clears the digits and keeps input focused', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [GetPage(name: '/otp-test', page: () => const OtpScreen())],
        home: const Scaffold(),
      ),
    );
    Get.lazyPut<OtpController>(
      () => OtpController(
        VerifyOtpUseCase(_InvalidOtpRepository()),
        LocalStorageService(),
      ),
    );
    Get.toNamed<void>(
      '/otp-test',
      arguments: const {'phone': '9876543210', 'type': 'login'},
    );
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('otp-input'));
    await tester.enterText(input, '1234');
    final controller = Get.find<OtpController>();
    expect(controller.otpController.selection.extentOffset, 4);

    await tester.tap(find.byKey(const ValueKey('otp-digit-box-2')));
    await tester.pump();
    expect(controller.otpController.selection.baseOffset, 2);
    expect(controller.otpController.selection.extentOffset, 3);

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '124',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump();
    expect(controller.otpController.text, '12 4');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('otp-digit-box-2')),
        matching: find.text(''),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('otp-digit-box-3')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '1294',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();
    expect(controller.otpController.text, '1294');

    await tester.tap(find.text('Verify OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid OTP'), findsWidgets);
    expect(controller.otpController.text, isEmpty);
    expect(controller.otpFocusNode.hasFocus, isTrue);
    expect(controller.otpController.selection.extentOffset, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}

class _InvalidOtpRepository implements OtpRepository {
  @override
  Future<OtpModel> verifyOtp(OtpParams params) async {
    return const OtpModel(success: false, code: 422, message: 'Invalid OTP');
  }

  @override
  Future<OtpModel> resendOtp(ResendOtpParams params) async {
    return const OtpModel(success: true, code: 200);
  }
}
