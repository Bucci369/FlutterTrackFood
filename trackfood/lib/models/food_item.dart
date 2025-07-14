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
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Handle nested nutriments from OpenFoodFacts and flat structure from Supabase
    final nutrimentsData = json['nutriments'] ?? json;

    return FoodItem(
      code: json['code'] ?? json['id'] ?? '', // Handle both 'code' and 'id'
      productName: json['product_name'] ?? json['name'] ?? 'Unknown Product',
      imageUrl: json['image_url'],
      nutriments: Nutriments.fromJson(nutrimentsData, parseDouble),
      servingSize: json['serving_size'],
      servingQuantity: parseDouble(json['serving_quantity']),
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
    double? Function(dynamic) parseDouble,
  ) {
    return Nutriments(
      energyKcal100g: parseDouble(
        json['energy-kcal_100g'] ??
            json['energy_kcal_100g'] ??
            json['calories_per_100g'] ??
            json['energy_value'] ?? // Added for broader compatibility
            json['calories'],
      ),
      proteins100g: parseDouble(
        json['proteins_100g'] ?? json['protein_per_100g'] ?? json['proteins'],
      ),
      carbohydrates100g: parseDouble(
        json['carbohydrates_100g'] ??
            json['carbs_per_100g'] ??
            json['carbohydrates'],
      ),
      fat100g: parseDouble(
        json['fat_100g'] ?? json['fat_per_100g'] ?? json['fat'],
      ),
      fiber100g: parseDouble(
        json['fiber_100g'] ?? json['fiber_per_100g'] ?? json['fiber'],
      ),
      sugars100g: parseDouble(
        json['sugars_100g'] ?? json['sugar_per_100g'] ?? json['sugars'],
      ),
      salt100g: parseDouble(
        json['salt_100g'] ?? json['salt_per_100g'] ?? json['salt'],
      ),
      sodium100g: parseDouble(
        json['sodium_100g'] ?? json['sodium_per_100g'] ?? json['sodium'],
      ),
    );
  }
}
