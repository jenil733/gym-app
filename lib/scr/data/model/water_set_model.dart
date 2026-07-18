class WaterGoalModel {
  const WaterGoalModel({this.success, this.data, this.message, this.code});

  factory WaterGoalModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return WaterGoalModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? WaterGoalData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final WaterGoalData? data;
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

class WaterGoalData {
  const WaterGoalData({this.dailyGoalLiters});

  factory WaterGoalData.fromJson(Map<String, dynamic> json) {
    return WaterGoalData(
      dailyGoalLiters: double.tryParse(
        json['daily_goal_liters']?.toString() ?? '',
      ),
    );
  }

  final double? dailyGoalLiters;

  Map<String, dynamic> toJson() {
    return {'daily_goal_liters': dailyGoalLiters};
  }
}
