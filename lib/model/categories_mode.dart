class CategoriesResponse {
  final String status;
  final List<Category> categories;

  CategoriesResponse({
    required this.status,
    required this.categories,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    var categoryList = json['categories'] as List;
    List<Category> categories =
        categoryList.map((i) => Category.fromJson(i)).toList();

    return CategoriesResponse(
      status: json['status'],
      categories: categories,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      shortDescription: json['short_description'],
      fullDescription: json['full_description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
