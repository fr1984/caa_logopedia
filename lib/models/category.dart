class Category {
  final String id;
  String name;
  String coverImagePath;
  bool isAsset;

  Category({
    required this.id,
    required this.name,
    required this.coverImagePath,
    this.isAsset = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      coverImagePath: json['coverImagePath'],
      isAsset: json['isAsset'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverImagePath': coverImagePath,
      'isAsset': isAsset,
    };
  }
}
