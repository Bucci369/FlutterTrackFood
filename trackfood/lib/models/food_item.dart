class FoodItem {
  final String code;
  final String productName;
  final String? imageUrl;
  final Nutriments nutriments;
  final String? servingSize;
  final double? servingQuantity;

  FoodItem({
    required this.code,
    required this.productName,
    this.imageUrl,
    required this.nutriments,
    this.servingSize,
    this.servingQuantity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      code: json['code'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      imageUrl: json['image_url'],
      nutriments: Nutriments.fromJson(json['nutriments'] ?? {}),
      servingSize: json['serving_size'],
      servingQuantity: (json['serving_quantity'] as num?)?.toDouble(),
    );
  }
}

class Nutriments {
  final double? energyKcal100g;
  final double? proteins100g;
  final double? carbohydrates100g;
  final double? fat100g;
  final double? fiber100g;
  final double? sugars100g;
  final double? salt100g;

  Nutriments({
    this.energyKcal100g,
    this.proteins100g,
    this.carbohydrates100g,
    this.fat100g,
    this.fiber100g,
    this.sugars100g,
    this.salt100g,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      energyKcal100g: (json['energy-kcal_100g'] as num?)?.toDouble(),
      proteins100g: (json['proteins_100g'] as num?)?.toDouble(),
      carbohydrates100g: (json['carbohydrates_100g'] as num?)?.toDouble(),
      fat100g: (json['fat_100g'] as num?)?.toDouble(),
      fiber100g: (json['fiber_100g'] as num?)?.toDouble(),
      sugars100g: (json['sugars_100g'] as num?)?.toDouble(),
      salt100g: (json['salt_100g'] as num?)?.toDouble(),
    );
  }
}
