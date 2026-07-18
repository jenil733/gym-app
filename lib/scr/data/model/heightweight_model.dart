class HeightWeightModel {
  const HeightWeightModel({this.success, this.data, this.message, this.code});

  factory HeightWeightModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return HeightWeightModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? HeightWeightData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final HeightWeightData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': data?.toJson(),
    'message': message,
    'code': code,
  };
}

class HeightWeightData {
  const HeightWeightData({
    this.id,
    this.height,
    this.weight,
    this.bmi,
    this.note,
    this.date,
  });

  factory HeightWeightData.fromJson(Map<String, dynamic> json) {
    return HeightWeightData(
      id: int.tryParse(json['id']?.toString() ?? ''),
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      bmi: double.tryParse(json['bmi']?.toString() ?? ''),
      note: json['note']?.toString(),
      date: json['date']?.toString(),
    );
  }

  final int? id;
  final String? height;
  final String? weight;
  final double? bmi;
  final String? note;
  final String? date;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'height': height,
    'weight': weight,
    'bmi': bmi,
    'note': note,
    'date': date,
  };
}
