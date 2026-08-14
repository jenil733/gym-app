class PostAttendanceModel {
  const PostAttendanceModel({this.success, this.data, this.message, this.code});

  factory PostAttendanceModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return PostAttendanceModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? PostAttendanceData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final PostAttendanceData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() => {
    'success': success,
    if (data != null) 'data': data!.toJson(),
    'message': message,
    'code': code,
  };
}

class PostAttendanceData {
  const PostAttendanceData({this.date, this.steps});

  factory PostAttendanceData.fromJson(Map<String, dynamic> json) {
    return PostAttendanceData(
      date: json['date']?.toString(),
      steps: json['steps']?.toString(),
    );
  }

  final String? date;
  final String? steps;

  Map<String, dynamic> toJson() => {'date': date, 'steps': steps};
}
