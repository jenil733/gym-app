import 'dart:convert';

import 'package:gym/scr/core/services/local_storage.dart';

class WeightGoalStorage {
  const WeightGoalStorage(this._storage);

  static const String storageKey = 'weight_goal_v1';

  final LocalStorageService _storage;

  Future<WeightGoal?> load() async {
    await _storage.init();
    final encoded = _storage.getString(_accountStorageKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(encoded);
      return decoded is Map
          ? WeightGoal.tryFromJson(Map<String, dynamic>.from(decoded))
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(WeightGoal goal) async {
    await _storage.saveString(_accountStorageKey, jsonEncode(goal.toJson()));
  }

  Future<void> clear() => _storage.remove(_accountStorageKey);

  String get _accountStorageKey {
    final account = _storage.getString('fcm_account_phone')?.trim();
    if (account == null || account.isEmpty) {
      return storageKey;
    }
    return '${storageKey}_${account.replaceAll(RegExp(r'[^0-9A-Za-z]'), '')}';
  }
}

class WeightGoal {
  const WeightGoal({
    required this.startWeight,
    required this.targetWeight,
    required this.startedAt,
    required this.lockedUntil,
  });

  factory WeightGoal.create({
    required double startWeight,
    required double targetWeight,
    DateTime? now,
  }) {
    final startedAt = now ?? DateTime.now();
    return WeightGoal(
      startWeight: startWeight,
      targetWeight: targetWeight,
      startedAt: startedAt,
      lockedUntil: DateTime(startedAt.year, startedAt.month + 6, startedAt.day),
    );
  }

  static WeightGoal? tryFromJson(Map<String, dynamic> json) {
    final startWeight = double.tryParse(json['start_weight']?.toString() ?? '');
    final targetWeight = double.tryParse(
      json['target_weight']?.toString() ?? '',
    );
    final startedAt = DateTime.tryParse(json['started_at']?.toString() ?? '');
    final lockedUntil = DateTime.tryParse(
      json['locked_until']?.toString() ?? '',
    );
    if (startWeight == null ||
        startWeight <= 0 ||
        targetWeight == null ||
        targetWeight <= 0 ||
        startedAt == null ||
        lockedUntil == null) {
      return null;
    }
    return WeightGoal(
      startWeight: startWeight,
      targetWeight: targetWeight,
      startedAt: startedAt,
      lockedUntil: lockedUntil,
    );
  }

  final double startWeight;
  final double targetWeight;
  final DateTime startedAt;
  final DateTime lockedUntil;

  double progressFor(double currentWeight) {
    final distance = (targetWeight - startWeight).abs();
    if (distance == 0 || currentWeight <= 0) {
      return 0;
    }
    final travelled = targetWeight < startWeight
        ? startWeight - currentWeight
        : currentWeight - startWeight;
    return (travelled / distance).clamp(0.0, 1.0);
  }

  bool isCompletedAt(double currentWeight) {
    if (currentWeight <= 0) {
      return false;
    }
    return targetWeight < startWeight
        ? currentWeight <= targetWeight
        : currentWeight >= targetWeight;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'start_weight': startWeight,
    'target_weight': targetWeight,
    'started_at': startedAt.toIso8601String(),
    'locked_until': lockedUntil.toIso8601String(),
  };
}
