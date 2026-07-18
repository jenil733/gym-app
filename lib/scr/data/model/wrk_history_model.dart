class WorkoutHistoryModel {
  const WorkoutHistoryModel({this.success, this.data, this.message, this.code});

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return WorkoutHistoryModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? WorkoutHistoryData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final WorkoutHistoryData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.toJson(),
      'message': message,
      'code': code,
    };
  }
}

class WorkoutHistoryData {
  const WorkoutHistoryData({
    this.todayDuration,
    this.yesterdayDuration,
    this.percentChange,
    this.trend,
    this.history = const [],
  });

  factory WorkoutHistoryData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];

    return WorkoutHistoryData(
      todayDuration: int.tryParse(json['today_duration']?.toString() ?? ''),
      yesterdayDuration: int.tryParse(
        json['yesterday_duration']?.toString() ?? '',
      ),
      percentChange: int.tryParse(json['percent_change']?.toString() ?? ''),
      trend: json['trend']?.toString(),
      history: rawHistory is List
          ? rawHistory
                .whereType<Map>()
                .map(
                  (item) => WorkoutHistoryItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? todayDuration;
  final int? yesterdayDuration;
  final int? percentChange;
  final String? trend;
  final List<WorkoutHistoryItem> history;

  Map<String, dynamic> toJson() {
    return {
      'today_duration': todayDuration,
      'yesterday_duration': yesterdayDuration,
      'percent_change': percentChange,
      'trend': trend,
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}

class WorkoutHistoryItem {
  const WorkoutHistoryItem({this.day, this.durationMinutes, this.notes});

  factory WorkoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryItem(
      day: json['day']?.toString(),
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? ''),
      notes: json['notes']?.toString(),
    );
  }

  final String? day;
  final int? durationMinutes;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {'day': day, 'duration_minutes': durationMinutes, 'notes': notes};
  }
}
