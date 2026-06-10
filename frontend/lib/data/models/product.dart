import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? originalPrice;
  final List<String> imageUrls;
  final List<Color> colors;
  final List<String> sizes;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final int? discountPercent;
  final String category;
  final String description;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.imageUrls,
    this.colors = const [],
    this.sizes = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.discountPercent,
    this.category = '',
    this.description = '',
    this.isFavorite = false,
  });

  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Color> parseColors(dynamic colorsJson) {
      if (colorsJson == null) return [];
      if (colorsJson is List) {
        return colorsJson.map((c) {
          String colStr = c.toString().toLowerCase().trim();
          if (colStr == 'black') return Colors.black;
          if (colStr == 'red') return Colors.red;
          if (colStr == 'blue') return Colors.blue;
          if (colStr == 'orange') return Colors.orange;
          if (colStr == 'grey' || colStr == 'gray') return Colors.grey;
          if (colStr == 'white') return Colors.white;
          if (colStr == 'pink') return Colors.pink;
          if (colStr == 'green') return Colors.green;
          if (colStr == 'deeppurple' || colStr == 'purple') return Colors.deepPurple;
          if (colStr == 'brown') return Colors.brown;
          if (colStr.startsWith('#')) {
            return Color(int.parse(colStr.replaceFirst('#', '0xFF')));
          }
          return Colors.grey;
        }).toList();
      }
      return [];
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      colors: parseColors(json['colors']),
      sizes: List<String>.from(json['sizes'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isNew: json['isNew'] as bool? ?? false,
      discountPercent: json['discountPercent'] as int?,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
