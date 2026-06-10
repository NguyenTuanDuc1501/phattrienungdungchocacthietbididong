import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_app_bar.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selected = 0;

  final List<Map<String, String>> _cards = [
    {'type': 'mastercard', 'number': '**** **** **** 3947', 'holder': 'Jennyfer Doe', 'expiry': '05/23'},
    {'type': 'visa', 'number': '**** **** **** 4546', 'holder': 'Jennyfer Doe', 'expiry': '11/22'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Payment methods'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your payment cards',
              style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark),
            ),
            const SizedBox(height: 16),
            ...List.generate(_cards.length, (i) => _buildCard(i)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCard,
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(int i) {
    final c = _cards[i];
    final isMC = c['type'] == 'mastercard';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isMC ? Colors.black26 : const Color(0xFF3C5B9B).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
              gradient: LinearGradient(
                colors: isMC
                    ? [const Color(0xFF222222), const Color(0xFF444444)]
                    : [const Color(0xFF3C5B9B), const Color(0xFF5B7FCC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Card type logo & info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isMC)
                      _mastercardLogo()
                    else
                      const Text(
                        'VISA',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                Text(
                  c['number']!,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Card Holder Name', style: TextStyle(fontFamily: 'Metropolis', fontSize: 10, color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text(c['holder']!, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Expiry Date', style: TextStyle(fontFamily: 'Metropolis', fontSize: 10, color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text(c['expiry']!, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _selected == i,
                activeColor: AppColors.dark,
                onChanged: (val) {
                  if (val == true) {
                    setState(() => _selected = i);
                  }
                },
              ),
              const Text(
                'Use as default payment method',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ],
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

  void _showAddCard() {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    bool isDefault = false;
    String detectedType = 'unknown';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          numberCtrl.addListener(() {
            final text = numberCtrl.text;
            String newType = 'unknown';
            if (text.startsWith('4')) {
              newType = 'visa';
            } else if (text.startsWith('5')) {
              newType = 'mastercard';
            }
            if (newType != detectedType) {
              setStateSheet(() {
                detectedType = newType;
              });
            }
          });

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                const Text(
                  'Add new card',
                  style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark),
                ),
                const SizedBox(height: 20),
                _input('Name on card', controller: nameCtrl),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                    ],
                  ),
                  child: TextField(
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
                    decoration: InputDecoration(
                      labelText: 'Card number',
                      labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: detectedType == 'visa'
                            ? const Text(
                                'VISA',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, fontStyle: FontStyle.italic),
                              )
                            : detectedType == 'mastercard'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                                    ],
                                  )
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _input('Expire Date', controller: expiryCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                          ],
                        ),
                        child: TextField(
                          controller: cvvCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.help_outline, color: AppColors.grey, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      activeColor: AppColors.dark,
                      onChanged: (val) {
                        setStateSheet(() {
                          isDefault = val ?? false;
                        });
                      },
                    ),
                    const Text(
                      'Set as default payment method',
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && numberCtrl.text.isNotEmpty) {
                        final masked = numberCtrl.text.length > 4
                            ? '**** **** **** ${numberCtrl.text.substring(numberCtrl.text.length - 4)}'
                            : '**** **** **** ${numberCtrl.text}';
                        setState(() {
                          _cards.add({
                            'type': detectedType == 'unknown' ? 'visa' : detectedType,
                            'number': masked,
                            'holder': nameCtrl.text,
                            'expiry': expiryCtrl.text.isNotEmpty ? expiryCtrl.text : '12/29',
                          });
                          if (isDefault) {
                            _selected = _cards.length - 1;
                          }
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      'ADD CARD',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _input(String label, {TextEditingController? controller}) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
          ],
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
          ),
        ),
      );
}
