class DaillyuseResponse {
  final List<DaillyCategory> subcategories;

  DaillyuseResponse({required this.subcategories});

  factory DaillyuseResponse.fromJson(List<dynamic> jsonList) {
    List<DaillyCategory> subcategories = jsonList
        .map((i) => DaillyCategory.fromJson(i as Map<String, dynamic>))
        .toList();

    return DaillyuseResponse(
      subcategories: subcategories,
    );
  }
}

class DaillyCategory {
  final int id;
  final String name;
  final int categoryId;
  final List<String> images;

  DaillyCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.images,
  });

  factory DaillyCategory.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List;
    return DaillyCategory(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      images: List<String>.from(imagesList),
    );
  }
}


