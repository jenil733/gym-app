class WeightHistoryModel {
  const WeightHistoryModel({this.success, this.data, this.message, this.code});

  factory WeightHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return WeightHistoryModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? WeightHistoryData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final WeightHistoryData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': data?.toJson(),
    'message': message,
    'code': code,
  };
}

class WeightHistoryData {
  const WeightHistoryData({
    this.currentWeight,
    this.count,
    this.history = const [],
  });

  factory WeightHistoryData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    return WeightHistoryData(
      currentWeight: json['current_weight']?.toString(),
      count: int.tryParse(json['count']?.toString() ?? ''),
      history: rawHistory is List
          ? rawHistory
                .whereType<Map>()
                .map(
                  (item) => WeightHistoryItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final String? currentWeight;
  final int? count;
  final List<WeightHistoryItem> history;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'current_weight': currentWeight,
    'count': count,
    'history': history.map((item) => item.toJson()).toList(growable: false),
  };
}

class WeightHistoryItem {
  const WeightHistoryItem({this.id, this.weight, this.note, this.date});

  factory WeightHistoryItem.fromJson(Map<String, dynamic> json) {
    return WeightHistoryItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      weight: json['weight']?.toString(),
      note: json['note']?.toString(),
      date: json['date']?.toString(),
    );
  }

  final int? id;
  final String? weight;
  final String? note;
  final String? date;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'weight': weight,
    'note': note,
    'date': date,
  };
}
