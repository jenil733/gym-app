class FootstepHistoryModel {
  const FootstepHistoryModel({
    this.success,
    this.data,
    this.message,
    this.code,
  });

  factory FootstepHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return FootstepHistoryModel(
      success: _parseBool(json['success']),
      data: rawData is Map
          ? FootstepHistoryData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final FootstepHistoryData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['code'] = code;
    return data;
  }
}

class FootstepHistoryData {
  const FootstepHistoryData({this.todaySteps, this.history});

  factory FootstepHistoryData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    return FootstepHistoryData(
      todaySteps: int.tryParse(json['today_steps']?.toString() ?? ''),
      history: rawHistory is List
          ? rawHistory
                .whereType<Map>()
                .map(
                  (item) => History.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? todaySteps;
  final List<History>? history;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['today_steps'] = todaySteps;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  const History({this.date, this.label, this.subLabel, this.steps});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      date: json['date']?.toString(),
      label: json['label']?.toString(),
      subLabel: json['sub_label']?.toString(),
      steps: int.tryParse(json['steps']?.toString() ?? ''),
    );
  }

  final String? date;
  final String? label;
  final String? subLabel;
  final int? steps;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['label'] = label;
    data['sub_label'] = subLabel;
    data['steps'] = steps;
    return data;
  }
}

bool? _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') {
    return true;
  }
  if (normalized == 'false' || normalized == '0') {
    return false;
  }
  return null;
}
