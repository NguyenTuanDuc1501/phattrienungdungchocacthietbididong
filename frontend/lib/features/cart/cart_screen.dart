import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../data/dummy/dummy_products.dart';
import '../../data/models/product.dart';

/// Figma "My Bag" — Cart with provider, promo code, checkout
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'My Bag',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: AppColors.dark,
            onPressed: () {},
          )
        ],
      ),
      body: Consumer<CartProvider>(builder: (ctx, cart, _) {
        if (cart.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.grey),
                SizedBox(height: 16),
                Text(
                  'Your bag is empty',
                  style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, color: AppColors.grey),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) {
                  final item = cart.items[i];
                  return Dismissible(
                    key: ValueKey(item.productId + item.color + item.size),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => cart.removeItem(i),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        _showContextMenu(context, details.globalPosition, item, i);
                      },
                      child: _CartItemTile(
                        item: item,
                        onIncrease: () => cart.updateQuantity(i, item.quantity + 1),
                        onDecrease: () => cart.updateQuantity(i, item.quantity - 1),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Promo code section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showPromoSheet(context, cart),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            cart.hasPromo ? 'Promo applied: ${cart.promoCode}' : 'Enter your promo code',
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 14,
                              color: cart.hasPromo ? AppColors.dark : AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (cart.hasPromo)
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.grey, size: 20),
                        onPressed: () => cart.clearPromo(),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showPromoSheet(context, cart),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Total amount
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total amount:',
                    style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey),
                  ),
                  Text(
                    '${cart.totalPrice.toInt()}\$',
                    style: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
            // Checkout button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/checkout'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      textStyle: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('CHECK OUT'),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showContextMenu(BuildContext context, Offset position, dynamic item, int index) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const [
        PopupMenuItem(
          value: 'fav',
          child: Text('Add to favorites'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete from the list'),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'fav') {
        final product = dummyProducts.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(
            id: item.productId,
            name: item.name,
            brand: item.brand,
            price: item.price,
            imageUrls: [item.imageUrl],
          ),
        );
        Provider.of<FavoritesProvider>(context, listen: false).toggleFavorite(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${item.name} to favorites')),
        );
      } else if (value == 'delete') {
        Provider.of<CartProvider>(context, listen: false).removeItem(index);
      }
    });
  }

  void _showPromoSheet(BuildContext context, CartProvider cart) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Input field
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                      ],
                    ),
                    child: TextField(
                      controller: ctrl,
                      style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
                      decoration: const InputDecoration(
                        hintText: 'Enter promo code',
                        hintStyle: TextStyle(color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (ctrl.text.isNotEmpty) {
                      cart.applyPromoCode(ctrl.text);
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Promo Codes',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 18),
            // Promo list
            ...cart.promoCodes.map((promo) => _PromoCodeItem(
                  promo: promo,
                  isApplied: cart.hasPromo && cart.promoCode == promo.code,
                  onApply: () {
                    cart.applyPromoCode(promo.code);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PromoCodeItem extends StatelessWidget {
  final PromoCode promo;
  final bool isApplied;
  final VoidCallback onApply;

  const _PromoCodeItem({
    required this.promo,
    required this.isApplied,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // Graphic section
          Container(
            width: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDB3022), Color(0xFFFF5A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${promo.discountPercent.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'OFF',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Info section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    promo.name,
                    style: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    promo.code,
                    style: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    '${promo.daysRemaining} days remaining',
                    style: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SizedBox(
              height: 32,
              width: 76,
              child: ElevatedButton(
                onPressed: isApplied ? null : onApply,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: isApplied ? AppColors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isApplied ? 'Applied' : 'Apply',
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.onIncrease, required this.onDecrease});
  final dynamic item;
  final VoidCallback onIncrease, onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: item.imageUrl.startsWith('http')
                ? Image.network(item.imageUrl, width: 104, height: 104, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))
                : Image.asset(item.imageUrl, width: 104, height: 104, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Color: ${item.color}  ', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                      Text('Size: ${item.size}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _qtyBtn(Icons.remove, onDecrease),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          _qtyBtn(Icons.add, onIncrease),
                        ],
                      ),
                      Text(
                        '${item.total.toInt()}\$',
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, size: 16, color: AppColors.grey),
        ),
      );
}
