import 'dart:convert';

import 'package:gym/scr/core/services/local_storage.dart';

class WeightGraphStorage {
  const WeightGraphStorage(this._storage);

  static const String _storageKey = 'weight_graph_samples_v1';

  final LocalStorageService _storage;

  Future<List<WeightSample>> load() async {
    await _storage.init();
    final encoded = _storage.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) => WeightSample.tryFromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item != null)
          .cast<WeightSample>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<WeightSample>> merge(Iterable<WeightSample> incoming) async {
    final samples = <String, WeightSample>{};
    for (final sample in await load()) {
      samples[_dayKey(sample.date)] = sample;
    }
    for (final sample in incoming) {
      samples[_dayKey(sample.date)] = sample;
    }

    final merged = samples.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    await _storage.saveString(
      _storageKey,
      jsonEncode(merged.map((item) => item.toJson()).toList(growable: false)),
    );
    return merged;
  }

  Future<List<WeightSample>> add(double weight, {DateTime? date}) {
    return merge([WeightSample(date: date ?? DateTime.now(), weight: weight)]);
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class WeightSample {
  const WeightSample({required this.date, required this.weight});

  static WeightSample? tryFromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date']?.toString() ?? '');
    final weight = double.tryParse(json['weight']?.toString() ?? '');
    if (date == null || weight == null || weight <= 0) {
      return null;
    }
    return WeightSample(date: date, weight: weight);
  }

  final DateTime date;
  final double weight;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': date.toIso8601String(),
    'weight': weight,
  };
}
