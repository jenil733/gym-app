class WorkoutTimingModel {
  const WorkoutTimingModel({this.success, this.data, this.message, this.code});

  factory WorkoutTimingModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return WorkoutTimingModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? WorkoutTimingData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final WorkoutTimingData? data;
  final String? message;
  final int? code;
}

class WorkoutTimingData {
  const WorkoutTimingData({
    this.logId,
    this.exerciseName,
    this.categoryName,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.notes,
  });

  factory WorkoutTimingData.fromJson(Map<String, dynamic> json) {
    return WorkoutTimingData(
      logId: int.tryParse(json['log_id']?.toString() ?? ''),
      exerciseName: json['exercise_name']?.toString(),
      categoryName: json['category_name']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? ''),
      notes: json['notes']?.toString(),
    );
  }

  final int? logId;
  final String? exerciseName;
  final String? categoryName;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final String? notes;
}
