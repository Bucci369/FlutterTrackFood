import 'meal_type.dart';

class DiaryEntry {
  final String id;
  final String userId;
  final String foodName;
  final double quantity;
  final String unit;
  final MealType mealType;
  final double calories;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final DateTime entryDate;
  final DateTime createdAt;
  final String? productCode;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.mealType,
    required this.calories,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.entryDate,
    required this.createdAt,
    this.productCode,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'],
    userId: json['user_id'],
    foodName: json['food_name'],
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'],
    mealType: MealType.fromString(json['meal_type']),
    calories: (json['calories'] as num).toDouble(),
    proteinG: (json['protein_g'] as num).toDouble(),
    carbG: (json['carb_g'] as num).toDouble(),
    fatG: (json['fat_g'] as num).toDouble(),
    fiberG: (json['fiber_g'] as num).toDouble(),
    sugarG: (json['sugar_g'] as num).toDouble(),
    sodiumMg: (json['sodium_mg'] as num).toDouble(),
    entryDate: DateTime.parse(json['entry_date']),
    createdAt: DateTime.parse(json['created_at']),
    productCode: json['product_code'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'food_name': foodName,
    'quantity': quantity,
    'unit': unit,
    'meal_type': mealType.databaseValue,
    'calories': calories,
    'protein_g': proteinG,
    'carb_g': carbG,
    'fat_g': fatG,
    'fiber_g': fiberG,
    'sugar_g': sugarG,
    'sodium_mg': sodiumMg,
    'entry_date': entryDate.toIso8601String().split('T')[0],
    'created_at': createdAt.toIso8601String(),
    'product_code': productCode,
  };

  // Helper method for nutrition calculations
  static double calculateNutrientPortion(double per100g, double quantity) {
    return (per100g * quantity) / 100;
  }
}