class CategoriesWithSubcategoriesResponse {
  final List<CategoryWithSubcategory> categories;

  CategoriesWithSubcategoriesResponse({
    required this.categories,
  });

  factory CategoriesWithSubcategoriesResponse.fromJson(List<dynamic> json) {
    List<CategoryWithSubcategory> categories =
        json.map((i) => CategoryWithSubcategory.fromJson(i)).toList();

    return CategoriesWithSubcategoriesResponse(
      categories: categories,
    );
  }
}

class CategoryWithSubcategory {
  final int id;
  final String name;
  final List<Subcategory> subcategories;

  CategoryWithSubcategory({
    this.id = 0,
    required this.name,
    required this.subcategories,
  });

  factory CategoryWithSubcategory.fromJson(Map<String, dynamic> json) {
    // Accommodate standard Laravel structure and the previous mapped structure
    var subcategoryList = (json['subcategories'] ?? json['subcategory'] ?? []) as List;
    List<Subcategory> subcategories =
        subcategoryList.map((i) => Subcategory.fromJson(i)).toList();

    return CategoryWithSubcategory(
      id: json['id'] ?? 0,
      name: json['category_name'] ?? json['name'] ?? '',
      subcategories: subcategories,
    );
  }
}

class Subcategory {
  final int id;
  final String name;
  final List<String> images;

  Subcategory({
    this.id = 0,
    required this.name,
    required this.images,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    // If images exist in structure
    var imageList = json['images'] != null ? json['images'] as List : [];
    List<String> images = imageList.map((image) {
      String url = image.toString().trim();
      return url.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }).toList();

    return Subcategory(
      id: json['id'] ?? 0,
      name: json['subcategory_name'] ?? json['name'] ?? '',
      images: images,
    );
  }
}
