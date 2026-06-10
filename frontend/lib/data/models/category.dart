class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String? parentId;
  final String slug;
  final bool hasChildren;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.parentId,
    this.slug = '',
    this.hasChildren = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      parentId: json['parentId'],
      slug: json['slug'] ?? '',
      hasChildren: json['hasChildren'] as bool? ?? false,
    );
  }
}
