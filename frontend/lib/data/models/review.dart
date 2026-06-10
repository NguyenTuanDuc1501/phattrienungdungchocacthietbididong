class Review {
  final String id;
  final String authorName;
  final String authorAvatar;
  final double rating;
  final String text;
  final DateTime date;
  final List<String> imageUrls;
  final int helpfulCount;
  final String? customerId;
  final String? productId;

  const Review({
    required this.id,
    required this.authorName,
    this.authorAvatar = '',
    required this.rating,
    required this.text,
    required this.date,
    this.imageUrls = const [],
    this.helpfulCount = 0,
    this.customerId,
    this.productId,
  });

  /// Convenience getters used by UI screens
  String get userName => authorName;
  String get avatarUrl => authorAvatar.isNotEmpty
      ? authorAvatar
      : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=face';
  String get comment => text;
  String get formattedDate {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      authorName: json['customerName']?.toString() ?? 'Anonymous',
      authorAvatar: json['customerAvatar']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      text: json['comment']?.toString() ?? '',
      date: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      customerId: json['customerId']?.toString(),
      productId: json['productId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': authorName,
    'customerAvatar': authorAvatar,
    'rating': rating,
    'comment': text,
    'createdAt': date.toIso8601String(),
    'imageUrls': imageUrls,
    'helpfulCount': helpfulCount,
    'customerId': customerId,
    'productId': productId,
  };
}
