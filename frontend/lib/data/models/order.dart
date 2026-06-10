class CartItem {
  final String productId;
  final String name;
  final String brand;
  final String imageUrl;
  final String color;
  final String size;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.color,
    required this.size,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

enum OrderStatus { delivered, processing, cancelled }

class Order {
  final String id;
  final String orderNumber;
  final DateTime date;
  final String trackingNumber;
  final int itemCount;
  final double totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.trackingNumber,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
    this.items = const [],
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String name;
  final String brand;
  final String imageUrl;
  final String color;
  final String size;
  final int quantity;
  final double price;

  const OrderItem({
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.color,
    required this.size,
    required this.quantity,
    required this.price,
  });
}
