class GetWorkoutTimingModel {
  const GetWorkoutTimingModel({
    this.success,
    this.data,
    this.message,
    this.code,
  });

  factory GetWorkoutTimingModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return GetWorkoutTimingModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? WorkoutTimingHistoryData.fromJson(
              Map<String, dynamic>.from(rawData),
            )
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final WorkoutTimingHistoryData? data;
  final String? message;
  final int? code;
}

class WorkoutTimingHistoryData {
  const WorkoutTimingHistoryData({
    this.todayDuration,
    this.yesterdayDuration,
    this.percentChange,
    this.trend,
    this.history = const [],
  });

  factory WorkoutTimingHistoryData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    return WorkoutTimingHistoryData(
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
                  (item) => WorkoutTimingHistoryItem.fromJson(
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
  final List<WorkoutTimingHistoryItem> history;
}

class WorkoutTimingHistoryItem {
  const WorkoutTimingHistoryItem({this.day, this.durationMinutes, this.notes});

  factory WorkoutTimingHistoryItem.fromJson(Map<String, dynamic> json) {
    return WorkoutTimingHistoryItem(
      day: json['day']?.toString(),
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? ''),
      notes: json['notes']?.toString(),
    );
  }

  final String? day;
  final int? durationMinutes;
  final String? notes;
}
