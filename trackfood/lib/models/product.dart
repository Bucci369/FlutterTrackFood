class Product {
  final String id;
  final String code;
  final String name;
  final String brand;
  final String category;
  final List<String>? supermarkets;
  final double? priceMin;
  final double? priceMax;
  final String? imageUrl;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.brand,
    required this.category,
    this.supermarkets,
    this.priceMin,
    this.priceMax,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    brand: json['brand'],
    category: json['category'],
    supermarkets: (json['supermarkets'] as List?)?.map((e) => e.toString()).toList(),
    priceMin: (json['price_min'] as num?)?.toDouble(),
    priceMax: (json['price_max'] as num?)?.toDouble(),
    imageUrl: json['image_url'],
  );
}
