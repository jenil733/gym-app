import 'package:gym/scr/data/model/get_workout_model.dart';
import 'package:gym/scr/data/model/timing_model.dart';

abstract class WorkoutTimingRepository {
  Future<WorkoutTimingModel> saveWorkoutTiming(WorkoutTimingParams params);

  Future<GetWorkoutTimingModel> getWorkoutTimingHistory();
}

class WorkoutTimingParams {
  const WorkoutTimingParams({
    this.exerciseId,
    this.categoryId,
    required this.exerciseName,
    required this.categoryName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes,
  });

  final int? exerciseId;
  final int? categoryId;
  final String exerciseName;
  final String categoryName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (exerciseId != null) 'exercise_id': exerciseId,
    if (categoryId != null) 'category_id': categoryId,
    'exercise_name': exerciseName,
    'category_name': categoryName,
    'start_time': _formatApiDateTime(startTime),
    'end_time': _formatApiDateTime(endTime),
    'duration_minutes': durationMinutes,
    if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
  };

  static String _formatApiDateTime(DateTime value) {
    String twoDigits(int part) => part.toString().padLeft(2, '0');
    final local = value.toLocal();
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}:'
        '${twoDigits(local.second)}';
  }
}
