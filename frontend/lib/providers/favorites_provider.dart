import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/dummy/dummy_products.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  FavoritesProvider() {
    // Initialize from dummy data
    for (final p in dummyProducts) {
      if (p.isFavorite) _favoriteIds.add(p.id);
    }
  }

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  List<Product> get favoriteProducts =>
      dummyProducts.where((p) => _favoriteIds.contains(p.id)).toList();

  void toggleFavorite(Product product) {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      product.isFavorite = false;
    } else {
      _favoriteIds.add(product.id);
      product.isFavorite = true;
    }
    notifyListeners();
  }

  void removeFavorite(Product product) {
    _favoriteIds.remove(product.id);
    product.isFavorite = false;
    notifyListeners();
  }
}
