import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:gym/scr/presentation/view/progress/widgets/weight.dart';

void main() {
  testWidgets('shows weekly check-in and an animated weight trend', (
    tester,
  ) async {
    final controller = ProgressController();
    final now = DateTime.now();
    await controller.recordWeight(
      72.4,
      date: now.subtract(const Duration(days: 14)),
    );
    await controller.recordWeight(
      71.8,
      date: now.subtract(const Duration(days: 7)),
    );
    await controller.recordWeight(71.2, date: now);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeightSection(controller: controller),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('weekly-weight-check-in')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('weekly-weight-input')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('weekly-weight-wave-chart')),
      findsOneWidget,
    );
    expect(find.text('Last 8 weeks • weekly average in kg'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
