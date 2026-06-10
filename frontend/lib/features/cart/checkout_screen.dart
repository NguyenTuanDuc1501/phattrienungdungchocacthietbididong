import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

/// Figma "Checkout" — Shipping address, payment, delivery method, submit
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedDelivery = 'FedEx';
  double _deliveryPrice = 15.0;

  void _selectDelivery(String method, double price) {
    setState(() {
      _selectedDelivery = method;
      _deliveryPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AppColors.dark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address
              const Text(
                'Shipping address',
                style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jane Doe',
                          style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/shipping-addresses'),
                          child: const Text(
                            'Change',
                            style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3 Newbridge Court\nChino Hills, CA 91709, United States',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment',
                    style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/payment'),
                    child: const Text(
                      'Change',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    _mastercardLogo(),
                    const SizedBox(width: 16),
                    const Text(
                      '**** **** **** 3947',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Delivery method
              const Text(
                'Delivery method',
                style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _deliveryCard('FedEx', '2-3 days', '\$15.00', 15.0, _selectedDelivery == 'FedEx', () => _selectDelivery('FedEx', 15.0)),
                  const SizedBox(width: 12),
                  _deliveryCard('USPS', '4-5 days', '\$8.00', 8.0, _selectedDelivery == 'USPS', () => _selectDelivery('USPS', 8.0)),
                  const SizedBox(width: 12),
                  _deliveryCard('DHL', '1-2 days', '\$25.00', 25.0, _selectedDelivery == 'DHL', () => _selectDelivery('DHL', 25.0)),
                ],
              ),
              const SizedBox(height: 32),
              // Order summary
              _summaryRow('Order:', '${cart.subtotal.toInt()}\$'),
              const SizedBox(height: 8),
              if (cart.hasPromo) ...[
                _summaryRow('Promo Discount:', '-${cart.discount.toInt()}\$'),
                const SizedBox(height: 8),
              ],
              _summaryRow('Delivery:', '${_deliveryPrice.toInt()}\$'),
              const SizedBox(height: 12),
              _summaryRow('Summary:', '${(cart.totalPrice + _deliveryPrice).toInt()}\$', bold: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (ctx, cart, _) => Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  cart.clearCart();
                  Navigator.of(context).pushNamed('/order-success');
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  textStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500),
                ),
                child: const Text('SUBMIT ORDER'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mastercardLogo() {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEB001B).withValues(alpha: 0.85),
              ),
            ),
          ),
          Positioned(
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryCard(String name, String duration, String priceLabel, double price, bool selected, VoidCallback onTap) {
    Color logoColor1 = Colors.blue;
    Color logoColor2 = Colors.orange;
    if (name == 'USPS') {
      logoColor1 = const Color(0xFF003366);
      logoColor2 = const Color(0xFFE31B23);
    } else if (name == 'DHL') {
      logoColor1 = const Color(0xFFFFCC00);
      logoColor2 = const Color(0xFFD00000);
    } else if (name == 'FedEx') {
      logoColor1 = const Color(0xFF4D148C);
      logoColor2 = const Color(0xFFFF6200);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: AppColors.primary, width: 2) : null,
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.substring(0, name.length ~/ 2),
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: logoColor1,
                    ),
                  ),
                  Text(
                    name.substring(name.length ~/ 2),
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: logoColor2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 10,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                priceLabel,
                style: const TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.dark,
            ),
          ),
        ],
      );
}
