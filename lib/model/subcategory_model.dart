class SubcategoryResponse {
  final String status;
  final List<Subcategory> subcategories;

  SubcategoryResponse({
    required this.status,
    required this.subcategories,
  });

  factory SubcategoryResponse.fromJson(Map<String, dynamic> json) {
    var subcategoryList = json['subcategory'] as List;
    List<Subcategory> subcategories = subcategoryList
        .map((i) => Subcategory.fromJson(i))
        .toList();

    return SubcategoryResponse(
      status: json['status'],
      subcategories: subcategories,
    );
  }
}

class Subcategory {
  final String name;
  final String plays;
  final List<String> images;

  Subcategory({
    required this.name,
    required this.plays,
    required this.images,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List;

    return Subcategory(
      name: json['name'],
      plays: json['plays'],
      images: List<String>.from(imagesList),
    );
  }
}

