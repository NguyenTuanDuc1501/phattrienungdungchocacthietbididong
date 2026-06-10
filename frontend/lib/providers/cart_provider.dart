import 'package:flutter/material.dart';
import '../data/models/order.dart';
import '../data/models/product.dart';

class PromoCode {
  final String name;
  final String code;
  final double discountPercent; // e.g. 10 for 10%
  final String description;
  final int daysRemaining;

  const PromoCode({
    required this.name,
    required this.code,
    required this.discountPercent,
    required this.description,
    required this.daysRemaining,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _promoCode;
  double _discount = 0;

  final List<PromoCode> promoCodes = const [
    PromoCode(name: 'Personal offer', code: 'mypromocode2020', discountPercent: 10, description: 'mypromocode2020', daysRemaining: 6),
    PromoCode(name: 'Summer Sale', code: 'summer2020', discountPercent: 15, description: 'summer2020', daysRemaining: 23),
    PromoCode(name: 'Personal offer', code: 'mypromocode2020_22', discountPercent: 22, description: 'mypromocode2020_22', daysRemaining: 6),
  ];

  CartProvider() {
    // Starts with an empty cart
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0, (s, i) => s + i.total);
  double get discount => _discount;
  String? get promoCode => _promoCode;
  double get totalPrice => subtotal - _discount;
  bool get hasPromo => _promoCode != null;

  void addItem(Product product, {required String color, required String size}) {
    final existing = _items.where((i) => i.productId == product.id && i.color == color && i.size == size);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        brand: product.brand,
        imageUrl: product.imageUrls.first,
        color: color,
        size: size,
        price: product.price,
      ));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  void applyPromoCode(String code) {
    _promoCode = code;
    final match = promoCodes.where((p) => p.code.toLowerCase() == code.toLowerCase());
    if (match.isNotEmpty) {
      _discount = subtotal * (match.first.discountPercent / 100);
    } else {
      _discount = subtotal * 0.1; // default to 10%
    }
    notifyListeners();
  }

  void clearPromo() {
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }
}
