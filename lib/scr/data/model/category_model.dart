class CategoryModel {
  const CategoryModel({this.success, this.data, this.message, this.code});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return CategoryModel(
      success: json['success'] as bool?,
      data: rawData is List
          ? rawData
                .whereType<Map>()
                .map(
                  (item) =>
                      CategoryData.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final List<CategoryData>? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.map((item) => item.toJson()).toList(),
      'message': message,
      'code': code,
    };
  }
}

class CategoryData {
  const CategoryData({
    this.id,
    this.categoryName,
    this.image,
    this.description,
    this.exerciseCount,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: int.tryParse(json['id']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      exerciseCount: int.tryParse(json['exercise_count']?.toString() ?? ''),
    );
  }

  final int? id;
  final String? categoryName;
  final String? image;
  final String? description;
  final int? exerciseCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'image': image,
      'description': description,
      'exercise_count': exerciseCount,
    };
  }
}
