class SymbolItem {
  final String id;
  String categoryId;
  String label;
  String imagePath;
  bool isAsset;

  SymbolItem({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.imagePath,
    this.isAsset = true,
  });

  factory SymbolItem.fromJson(Map<String, dynamic> json) {
    return SymbolItem(
      id: json['id'],
      categoryId: json['categoryId'],
      label: json['label'],
      imagePath: json['imagePath'],
      isAsset: json['isAsset'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'label': label,
      'imagePath': imagePath,
      'isAsset': isAsset,
    };
  }
}
