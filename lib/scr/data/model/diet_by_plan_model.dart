class DietByPlanModel {
  const DietByPlanModel({this.success, this.data, this.message, this.code});

  factory DietByPlanModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return DietByPlanModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? DietByPlanData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final DietByPlanData? data;
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

class DietByPlanData {
  const DietByPlanData({
    this.planId,
    this.planName,
    this.count,
    this.meals = const [],
  });

  factory DietByPlanData.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'];

    return DietByPlanData(
      planId: int.tryParse(json['plan_id']?.toString() ?? ''),
      planName: json['plan_name']?.toString(),
      count: int.tryParse(json['count']?.toString() ?? ''),
      meals: rawMeals is List
          ? rawMeals
                .whereType<Map>()
                .map(
                  (item) =>
                      DietMealItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? planId;
  final String? planName;
  final int? count;
  final List<DietMealItem> meals;

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name': planName,
      'count': count,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }
}

class DietMealItem {
  const DietMealItem({
    this.id,
    this.mealType,
    this.foodName,
    this.image,
    this.calories,
    this.protein,
    this.description,
  });

  factory DietMealItem.fromJson(Map<String, dynamic> json) {
    return DietMealItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      mealType: json['meal_type']?.toString(),
      foodName: json['food_name']?.toString(),
      image: json['image']?.toString(),
      calories: int.tryParse(json['calories']?.toString() ?? ''),
      protein: int.tryParse(json['protein']?.toString() ?? ''),
      description: json['description']?.toString(),
    );
  }

  final int? id;
  final String? mealType;
  final String? foodName;
  final String? image;
  final int? calories;
  final int? protein;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_type': mealType,
      'food_name': foodName,
      'image': image,
      'calories': calories,
      'protein': protein,
      'description': description,
    };
  }
}
