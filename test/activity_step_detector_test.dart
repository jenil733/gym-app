import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/core/services/activity_step_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled activity model loads and returns four probabilities',
    () async {
      final classifier = await TfliteActivityClassifier.load();
      addTearDown(classifier.close);

      final output = classifier.classify(
        List<List<double>>.generate(
          100,
          (_) => <double>[0, 0, 9.80665, 0, 0, 0],
        ),
      );

      expect(output, hasLength(4));
      expect(output.every((value) => value.isFinite), isTrue);
      expect(output.reduce((a, b) => a + b), closeTo(1, 0.001));
    },
    skip: Platform.isWindows
        ? 'tflite_flutter does not bundle its native DLL for Windows tests.'
        : false,
  );

  test('counts peaks in a locomotion window', () {
    final detector = ActivityStepDetector(
      _FakeClassifier(<double>[1, 0, 0, 0]),
    );
    final start = DateTime(2026);
    var detectedSteps = 0;

    for (var index = 0; index < 124; index++) {
      final phase = index % 20;
      final z = phase == 9 ? 10.4 : (phase == 10 ? 11.5 : 9.80665);
      detectedSteps += detector.addSample(
        MotionSample(
          accelerometerX: 0,
          accelerometerY: 0,
          accelerometerZ: z,
          gyroscopeX: 0,
          gyroscopeY: 0,
          gyroscopeZ: 0,
          timestamp: start.add(Duration(milliseconds: index * 20)),
        ),
      );
    }

    expect(detectedSteps, 6);
  });

  test('rejects the same peaks in a stationary model window', () {
    final detector = ActivityStepDetector(
      _FakeClassifier(<double>[0, 0, 1, 0]),
    );
    final start = DateTime(2026);
    var detectedSteps = 0;

    for (var index = 0; index < 124; index++) {
      final z = 9.80665 + math.max(0, 1.8 - (index % 20 - 10).abs());
      detectedSteps += detector.addSample(
        MotionSample(
          accelerometerX: 0,
          accelerometerY: 0,
          accelerometerZ: z,
          gyroscopeX: 0,
          gyroscopeY: 0,
          gyroscopeZ: 0,
          timestamp: start.add(Duration(milliseconds: index * 20)),
        ),
      );
    }

    expect(detectedSteps, 0);
  });
}

class _FakeClassifier implements ActivityClassifier {
  _FakeClassifier(this.output);

  final List<double> output;

  @override
  List<double> classify(List<List<double>> sensorWindow) => output;

  @override
  void close() {}
}
