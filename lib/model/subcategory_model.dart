class SubcategoryResponse {
  final String status;
  final List<Subcategory> subcategories;

  SubcategoryResponse({
    required this.status,
    required this.subcategories,
  });

  // Factory method to create SubcategoryResponse from JSON
  factory SubcategoryResponse.fromJson(Map<String, dynamic> json) {
    var subcategoryList = json['subcategory'] as List;
    List<Subcategory> subcategories = subcategoryList.map((i) => Subcategory.fromJson(i)).toList();

    return SubcategoryResponse(
      status: json['status'],
      subcategories: subcategories,
    );
  }
}

class Subcategory {
  final String name;
  final String plays;
  final String imageUrl;

  Subcategory({
    required this.name,
    required this.plays,
    required this.imageUrl,
  });

  // Factory method to create Subcategory from JSON
  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      name: json['name'],
      plays: json['plays'],
      imageUrl: json['image_url'],
    );
  }
}
