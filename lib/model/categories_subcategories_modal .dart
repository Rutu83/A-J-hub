class CategoriesWithSubcategoriesResponse {
  final List<CategoryWithSubcategory> categories;

  CategoriesWithSubcategoriesResponse({
    required this.categories,
  });

  factory CategoriesWithSubcategoriesResponse.fromJson(List<dynamic> json) {
    List<CategoryWithSubcategory> categories = json
        .map((i) => CategoryWithSubcategory.fromJson(i))
        .toList();

    return CategoriesWithSubcategoriesResponse(
      categories: categories,
    );
  }
}

class CategoryWithSubcategory {
  final String name;
  final List<Subcategory> subcategories;

  CategoryWithSubcategory({
    required this.name,
    required this.subcategories,
  });

  factory CategoryWithSubcategory.fromJson(Map<String, dynamic> json) {
    var subcategoryList = json['subcategories'] as List;
    List<Subcategory> subcategories =
    subcategoryList.map((i) => Subcategory.fromJson(i)).toList();

    return CategoryWithSubcategory(
      name: json['category_name'],
      subcategories: subcategories,
    );
  }
}

class Subcategory {
  final String name;
  final List<String> images;

  Subcategory({
    required this.name,
    required this.images,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {

    var imageList = json['images'] as List;
    List<String> images = imageList
        .map((image) => image.toString().trim())
        .toList();

    return Subcategory(
      name: json['subcategory_name'],
      images: images,
    );
  }
}
