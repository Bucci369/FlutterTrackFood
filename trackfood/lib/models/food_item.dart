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
    // Helper function to safely parse values that could be num or String
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return FoodItem(
      code: json['code'] ?? json['id'] ?? '', // Handle both 'code' and 'id'
      productName: json['product_name'] ?? json['name'] ?? 'Unknown Product',
      imageUrl: json['image_url'],
      nutriments: Nutriments.fromJson(json['nutriments'] ?? {}, _parseDouble),
      servingSize: json['serving_size'],
      servingQuantity: _parseDouble(json['serving_quantity']),
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
  final double? sodium100g;

  Nutriments({
    this.energyKcal100g,
    this.proteins100g,
    this.carbohydrates100g,
    this.fat100g,
    this.fiber100g,
    this.sugars100g,
    this.salt100g,
    this.sodium100g,
  });

  factory Nutriments.fromJson(
    Map<String, dynamic> json,
    double? Function(dynamic) _parseDouble,
  ) {
    return Nutriments(
      energyKcal100g: _parseDouble(
        json['energy-kcal_100g'] ?? json['calories_per_100g'],
      ),
      proteins100g: _parseDouble(
        json['proteins_100g'] ?? json['protein_per_100g'],
      ),
      carbohydrates100g: _parseDouble(
        json['carbohydrates_100g'] ?? json['carbs_per_100g'],
      ),
      fat100g: _parseDouble(json['fat_100g'] ?? json['fat_per_100g']),
      fiber100g: _parseDouble(json['fiber_100g'] ?? json['fiber_per_100g']),
      sugars100g: _parseDouble(json['sugars_100g'] ?? json['sugar_per_100g']),
      salt100g: _parseDouble(json['salt_100g'] ?? json['salt_per_100g']),
      sodium100g: _parseDouble(json['sodium_100g'] ?? json['sodium_per_100g']),
    );
  }
}