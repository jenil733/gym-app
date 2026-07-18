class ExerciseModel {
  bool? success;
  Data? data;
  String? message;
  int? code;

  ExerciseModel({this.success, this.data, this.message, this.code});

  ExerciseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'code': code,
    };
  }
}

class Data {
  int? categoryId;
  String? categoryName;
  int? count;
  List<dynamic>? exercises; // temporary fix

  Data({this.categoryId, this.categoryName, this.count, this.exercises});

  Data.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    count = json['count'];
    exercises = json['exercises'];
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'count': count,
      'exercises': exercises,
    };
  }
}
