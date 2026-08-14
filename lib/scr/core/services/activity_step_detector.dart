import 'dart:math' as math;

import 'package:tflite_flutter/tflite_flutter.dart';

const String activityModelAsset = 'assets/models/activity_model.tflite';

class MotionSample {
  const MotionSample({
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
    required this.timestamp,
  });

  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double gyroscopeX;
  final double gyroscopeY;
  final double gyroscopeZ;
  final DateTime timestamp;

  List<double> get modelValues => <double>[
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
  ];

  double get accelerationMagnitude => math.sqrt(
    accelerometerX * accelerometerX +
        accelerometerY * accelerometerY +
        accelerometerZ * accelerometerZ,
  );
}

abstract class ActivityClassifier {
  List<double> classify(List<List<double>> sensorWindow);

  void close() {}
}

class TfliteActivityClassifier implements ActivityClassifier {
  TfliteActivityClassifier._(this._interpreter);

  final Interpreter _interpreter;

  static Future<TfliteActivityClassifier> load() async {
    final interpreter = await Interpreter.fromAsset(activityModelAsset);
    final input = interpreter.getInputTensor(0).shape;
    final output = interpreter.getOutputTensor(0).shape;
    if (input.length != 3 || input[1] != 100 || input[2] != 6) {
      interpreter.close();
      throw StateError('Activity model input must be [1, 100, 6], got $input.');
    }
    if (output.length != 2 || output[1] != 4) {
      interpreter.close();
      throw StateError('Activity model output must be [1, 4], got $output.');
    }
    return TfliteActivityClassifier._(interpreter);
  }

  @override
  List<double> classify(List<List<double>> sensorWindow) {
    final output = <List<double>>[List<double>.filled(4, 0)];
    _interpreter.run(<List<List<double>>>[sensorWindow], output);
    return output.first;
  }

  @override
  void close() => _interpreter.close();
}

/// Counts acceleration peaks only when the activity model identifies a
/// locomotion window. The model's four training classes are ordered as
/// running, sitting, standing, and walking, so indexes 0 and 3 represent
/// activities that contain footsteps.
class ActivityStepDetector {
  ActivityStepDetector(
    this._classifier, {
    this.windowSize = 100,
    this.inferenceStride = 25,
    this.minimumActivityConfidence = 0.6,
    this.peakThreshold = 1.0,
  });

  final ActivityClassifier _classifier;
  final int windowSize;
  final int inferenceStride;
  final double minimumActivityConfidence;
  final double peakThreshold;

  static const Set<int> locomotionClassIndexes = <int>{0, 3};
  static const Duration _minimumStepInterval = Duration(milliseconds: 280);

  final List<MotionSample> _window = <MotionSample>[];
  final List<double> _recentMagnitudes = <double>[];
  int _samplesSinceInference = 0;
  int _pendingPeaks = 0;
  DateTime? _lastPeakAt;

  int addSample(MotionSample sample) {
    _window.add(sample);
    if (_window.length > windowSize) {
      _window.removeAt(0);
    }
    _findPeak(sample);

    if (_window.length < windowSize) {
      return 0;
    }
    _samplesSinceInference++;
    if (_samplesSinceInference < inferenceStride) {
      return 0;
    }
    _samplesSinceInference = 0;

    final probabilities = _classifier.classify(
      _window.map((value) => value.modelValues).toList(growable: false),
    );
    if (probabilities.length != 4) {
      _pendingPeaks = 0;
      return 0;
    }
    var predictedClass = 0;
    for (var index = 1; index < probabilities.length; index++) {
      if (probabilities[index] > probabilities[predictedClass]) {
        predictedClass = index;
      }
    }
    final detected =
        locomotionClassIndexes.contains(predictedClass) &&
            probabilities[predictedClass] >= minimumActivityConfidence
        ? _pendingPeaks
        : 0;
    _pendingPeaks = 0;
    return detected;
  }

  void _findPeak(MotionSample sample) {
    _recentMagnitudes.add(sample.accelerationMagnitude);
    if (_recentMagnitudes.length < 3) {
      return;
    }
    if (_recentMagnitudes.length > 3) {
      _recentMagnitudes.removeAt(0);
    }

    final previous = _recentMagnitudes[0];
    final candidate = _recentMagnitudes[1];
    final next = _recentMagnitudes[2];
    const gravity = 9.80665;
    final farEnoughApart =
        _lastPeakAt == null ||
        sample.timestamp.difference(_lastPeakAt!) >= _minimumStepInterval;
    if (candidate > previous &&
        candidate >= next &&
        candidate - gravity >= peakThreshold &&
        farEnoughApart) {
      _pendingPeaks++;
      _lastPeakAt = sample.timestamp;
    }
  }

  void close() => _classifier.close();
}
