// ignore_for_file: file_names

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
  final String name; // category_name
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
  final String name; // subcategory_name
  final List<String> images; // list of image URLs

  Subcategory({
    required this.name,
    required this.images,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    // Clean and parse the images
    var imageList = json['images'] as List;
    List<String> images = imageList
        .map((image) => image.toString().trim()) // Clean the URLs
        .toList();

    return Subcategory(
      name: json['subcategory_name'],
      images: images,
    );
  }
}
