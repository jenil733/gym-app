class DietModel {
  const DietModel({this.success, this.data, this.message, this.code});

  factory DietModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return DietModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? DietData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final DietData? data;
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

class DietData {
  const DietData({this.count, this.plans = const []});

  factory DietData.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['plans'];

    return DietData(
      count: int.tryParse(json['count']?.toString() ?? ''),
      plans: rawPlans is List
          ? rawPlans
                .whereType<Map>()
                .map(
                  (item) => DietPlan.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? count;
  final List<DietPlan> plans;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'plans': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class DietPlan {
  const DietPlan({this.id, this.planName, this.image, this.description});

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: int.tryParse(json['id']?.toString() ?? ''),
      planName: json['plan_name']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
    );
  }

  final int? id;
  final String? planName;
  final String? image;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'image': image,
      'description': description,
    };
  }
}
