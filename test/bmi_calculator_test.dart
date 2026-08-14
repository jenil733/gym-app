import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/presentation/view/home/widget/bmi_calculator.dart';

void main() {
  testWidgets('shows zero until height and weight are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BmiCalculatorCard())),
    );

    expect(find.byKey(const ValueKey('bmi-result')), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);
    expect(find.text('Add height and weight'), findsOneWidget);
  });

  testWidgets('calculates and classifies BMI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: BmiCalculatorCard())),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('bmi-height-input')),
      '180',
    );
    await tester.enterText(
      find.byKey(const ValueKey('bmi-weight-input')),
      '75',
    );
    await tester.tap(find.byKey(const ValueKey('calculate-bmi-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('bmi-result')), findsOneWidget);
    expect(find.text('23.1'), findsOneWidget);
    expect(find.text('Healthy range'), findsOneWidget);
  });
}
