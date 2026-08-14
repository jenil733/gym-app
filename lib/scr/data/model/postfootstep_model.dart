class PostFootstepModel {
  const PostFootstepModel({this.success, this.data, this.message, this.code});

  factory PostFootstepModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return PostFootstepModel(
      success: _parseBool(json['success']),
      data: rawData is Map
          ? PostFootstepData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final PostFootstepData? data;
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

class PostFootstepData {
  const PostFootstepData({this.date, this.steps});

  factory PostFootstepData.fromJson(Map<String, dynamic> json) {
    return PostFootstepData(
      date: json['date']?.toString(),
      steps: int.tryParse(json['steps']?.toString() ?? ''),
    );
  }

  final String? date;
  final int? steps;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
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
