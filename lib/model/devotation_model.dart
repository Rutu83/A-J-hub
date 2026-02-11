class DevotationuseResponse {
  final List<DevotationCategory> subcategories;

  DevotationuseResponse({required this.subcategories});

  factory DevotationuseResponse.fromJson(List<dynamic> jsonList) {
    List<DevotationCategory> subcategories = jsonList
        .map((i) => DevotationCategory.fromJson(i as Map<String, dynamic>))
        .toList();

    return DevotationuseResponse(
      subcategories: subcategories,
    );
  }
}

class DevotationCategory {
  final int id;
  final String name;
  final int categoryId;
  final List<String> images;

  DevotationCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.images,
  });

  factory DevotationCategory.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List;
    return DevotationCategory(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      images: List<String>.from(imagesList),
    );
  }
}
