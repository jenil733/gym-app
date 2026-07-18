class ExerciseModel {
  const ExerciseModel({this.success, this.data, this.message, this.code});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return ExerciseModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? ExerciseData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final ExerciseData? data;
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

class ExerciseData {
  const ExerciseData({
    this.categoryId,
    this.categoryName,
    this.count,
    this.exercises = const [],
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'];

    return ExerciseData(
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      count: int.tryParse(json['count']?.toString() ?? ''),
      exercises: rawExercises is List
          ? rawExercises
                .whereType<Map>()
                .map(
                  (item) =>
                      ExerciseItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? categoryId;
  final String? categoryName;
  final int? count;
  final List<ExerciseItem> exercises;

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'count': count,
      'exercises': exercises.map((item) => item.toJson()).toList(),
    };
  }
}

class ExerciseItem {
  const ExerciseItem({
    this.id,
    this.exerciseName,
    this.image,
    this.videoUrl,
    this.sets,
    this.reps,
    this.restSeconds,
    this.calories,
    this.howTo = const [],
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    final rawHowTo = json['how_to'];

    return ExerciseItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      exerciseName: json['exercise_name']?.toString(),
      image: json['image']?.toString(),
      videoUrl: json['video_url']?.toString(),
      sets: int.tryParse(json['sets']?.toString() ?? ''),
      reps: int.tryParse(json['reps']?.toString() ?? ''),
      restSeconds: int.tryParse(json['rest_seconds']?.toString() ?? ''),
      calories: int.tryParse(json['calories']?.toString() ?? ''),
      howTo: rawHowTo is List
          ? rawHowTo.map((item) => item.toString()).toList(growable: false)
          : const [],
    );
  }

  final int? id;
  final String? exerciseName;
  final String? image;
  final String? videoUrl;
  final int? sets;
  final int? reps;
  final int? restSeconds;
  final int? calories;
  final List<String> howTo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_name': exerciseName,
      'image': image,
      'video_url': videoUrl,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
      'calories': calories,
      'how_to': howTo,
    };
  }
}
