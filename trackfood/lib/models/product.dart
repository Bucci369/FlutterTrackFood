class Product {
  final String id;
  final String code;
  final String name;
  final String brand;
  final String category;
  final List<String>? supermarkets;
  final List<String>? stores;
  final double? priceMin;
  final double? priceMax;
  final String? imageUrl;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final double? saltPer100g;
  final double? sodiumMg;
  final List<String>? allergens;
  final List<String>? keywords;
  final String? createdBy;
  final bool? isVerified;
  final bool? isCommunityProduct;
  final String? verificationStatus;
  final String? moderatorNotes;
  final String? verifiedBy;
  final String? source;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.brand,
    required this.category,
    this.supermarkets,
    this.stores,
    this.priceMin,
    this.priceMax,
    this.imageUrl,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.saltPer100g,
    this.sodiumMg,
    this.allergens,
    this.keywords,
    this.createdBy,
    this.isVerified,
    this.isCommunityProduct,
    this.verificationStatus,
    this.moderatorNotes,
    this.verifiedBy,
    this.source,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      supermarkets: json['supermarkets'] != null 
          ? List<String>.from(json['supermarkets']) 
          : null,
      stores: json['stores'] != null 
          ? List<String>.from(json['stores']) 
          : null,
      priceMin: json['price_min']?.toDouble(),
      priceMax: json['price_max']?.toDouble(),
      imageUrl: json['image_url'],
      caloriesPer100g: json['calories_per_100g']?.toDouble(),
      proteinPer100g: json['protein_per_100g']?.toDouble(),
      carbsPer100g: json['carbs_per_100g']?.toDouble(),
      fatPer100g: json['fat_per_100g']?.toDouble(),
      fiberPer100g: json['fiber_per_100g']?.toDouble(),
      sugarPer100g: json['sugar_per_100g']?.toDouble(),
      saltPer100g: json['salt_per_100g']?.toDouble(),
      sodiumMg: json['sodium_mg']?.toDouble(),
      allergens: json['allergens'] != null 
          ? List<String>.from(json['allergens']) 
          : null,
      keywords: json['keywords'] != null 
          ? List<String>.from(json['keywords']) 
          : null,
      createdBy: json['created_by'],
      isVerified: json['is_verified'],
      isCommunityProduct: json['is_community_product'],
      verificationStatus: json['verification_status'],
      moderatorNotes: json['moderator_notes'],
      verifiedBy: json['verified_by'],
      source: json['source'],
      country: json['country'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'brand': brand,
      'category': category,
      'supermarkets': supermarkets,
      'stores': stores,
      'price_min': priceMin,
      'price_max': priceMax,
      'image_url': imageUrl,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'fiber_per_100g': fiberPer100g,
      'sugar_per_100g': sugarPer100g,
      'salt_per_100g': saltPer100g,
      'sodium_mg': sodiumMg,
      'allergens': allergens,
      'keywords': keywords,
      'created_by': createdBy,
      'is_verified': isVerified,
      'is_community_product': isCommunityProduct,
      'verification_status': verificationStatus,
      'moderator_notes': moderatorNotes,
      'verified_by': verifiedBy,
      'source': source,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Utility methods
  bool get hasNutritionData => 
      caloriesPer100g != null || 
      proteinPer100g != null || 
      carbsPer100g != null || 
      fatPer100g != null;

  bool get isComplete => 
      name.isNotEmpty && 
      brand.isNotEmpty && 
      hasNutritionData;

  String get displayName => '$brand $name'.trim();

  // Calculate nutrition for specific quantity
  Map<String, double> calculateNutrition(double quantity) {
    final factor = quantity / 100.0;
    return {
      'calories': (caloriesPer100g ?? 0) * factor,
      'protein': (proteinPer100g ?? 0) * factor,
      'carbs': (carbsPer100g ?? 0) * factor,
      'fat': (fatPer100g ?? 0) * factor,
      'fiber': (fiberPer100g ?? 0) * factor,
      'sugar': (sugarPer100g ?? 0) * factor,
      'sodium': (sodiumMg ?? 0) * factor,
    };
  }
}
