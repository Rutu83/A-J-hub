class UpcomingSubcategoryResponse {
  final String status;
  final List<UpcomingSubcategory> subcategories;

  UpcomingSubcategoryResponse({
    required this.status,
    required this.subcategories,
  });

  factory UpcomingSubcategoryResponse.fromJson(Map<String, dynamic> json) {
    var subcategoryList = json['subcategory'] as List;
    List<UpcomingSubcategory> subcategories =
        subcategoryList.map((i) => UpcomingSubcategory.fromJson(i)).toList();

    return UpcomingSubcategoryResponse(
      status: json['status'],
      subcategories: subcategories,
    );
  }
}

class UpcomingSubcategory {
  final String name;
  final String plays;
  final String event_date;
  final List<String> images;

  UpcomingSubcategory({
    required this.name,
    required this.plays,
    required this.event_date,
    required this.images,
  });

  factory UpcomingSubcategory.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List;

    return UpcomingSubcategory(
      name: json['name'],
      plays: json['plays'],
      event_date: json['date'],
      images: List<String>.from(imagesList),
    );
  }
}
