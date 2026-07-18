class DietMealModel {
  const DietMealModel({this.success, this.data, this.message, this.code});

  factory DietMealModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return DietMealModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? DietMealData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final DietMealData? data;
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

class DietMealData {
  const DietMealData({
    this.id,
    this.planId,
    this.planName,
    this.mealType,
    this.foodName,
    this.image,
    this.calories,
    this.protein,
    this.description,
  });

  factory DietMealData.fromJson(Map<String, dynamic> json) {
    return DietMealData(
      id: int.tryParse(json['id']?.toString() ?? ''),
      planId: int.tryParse(json['plan_id']?.toString() ?? ''),
      planName: json['plan_name']?.toString(),
      mealType: json['meal_type']?.toString(),
      foodName: json['food_name']?.toString(),
      image: json['image']?.toString(),
      calories: int.tryParse(json['calories']?.toString() ?? ''),
      protein: int.tryParse(json['protein']?.toString() ?? ''),
      description: json['description']?.toString(),
    );
  }

  final int? id;
  final int? planId;
  final String? planName;
  final String? mealType;
  final String? foodName;
  final String? image;
  final int? calories;
  final int? protein;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'meal_type': mealType,
      'food_name': foodName,
      'image': image,
      'calories': calories,
      'protein': protein,
      'description': description,
    };
  }
}
