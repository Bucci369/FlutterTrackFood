class Recipe {
  final int id;
  final String title;
  final String? imageUrl;
  final String? link;
  final List<String>? ingredients;
  final String? category;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    this.link,
    this.ingredients,
    this.category,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? 'Unbekanntes Rezept',
      imageUrl: json['image_url'],
      link: json['link'],
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
