// lib/model/temple_model.dart

class Temple {
  final int id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;

  Temple({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
  });

  // This factory constructor is the key.
  // It safely handles missing or null data from the API.
  factory Temple.fromJson(Map<String, dynamic> json) {
    return Temple(
      // The '??' is the "null-coalescing operator".
      // It means: use the value on the left if it's not null,
      // otherwise, use the default value on the right.

      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Temple',
      location: json['location'] ?? 'Unknown Location',
      description: json['description'] ?? 'Unknown Location',
      imageUrl:
          json['imageUrl'] ?? '', // This prevents errors if imageUrl is null
    );
  }
}
