class PackagesModel {
  const PackagesModel({this.success, this.data, this.message, this.code});

  factory PackagesModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return PackagesModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? PackagesData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final PackagesData? data;
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

class PackagesData {
  const PackagesData({this.count, this.packages = const []});

  factory PackagesData.fromJson(Map<String, dynamic> json) {
    final rawPackages = json['packages'];

    return PackagesData(
      count: int.tryParse(json['count']?.toString() ?? ''),
      packages: rawPackages is List
          ? rawPackages
                .whereType<Map>()
                .map(
                  (item) =>
                      PackageItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final int? count;
  final List<PackageItem> packages;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'packages': packages.map((item) => item.toJson()).toList(),
    };
  }
}

class PackageItem {
  const PackageItem({
    this.id,
    this.packageName,
    this.duration,
    this.durationMonths,
    this.price,
    this.priceRaw,
    this.features = const [],
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];

    return PackageItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      packageName: json['package_name']?.toString(),
      duration: json['duration']?.toString(),
      durationMonths: int.tryParse(json['duration_months']?.toString() ?? ''),
      price: json['price']?.toString(),
      priceRaw: json['price_raw']?.toString(),
      features: rawFeatures is List
          ? rawFeatures.map((feature) => feature.toString()).toList()
          : const [],
    );
  }

  final int? id;
  final String? packageName;
  final String? duration;
  final int? durationMonths;
  final String? price;
  final String? priceRaw;
  final List<String> features;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_name': packageName,
      'duration': duration,
      'duration_months': durationMonths,
      'price': price,
      'price_raw': priceRaw,
      'features': features,
    };
  }
}
