import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Figma "Success" — Order success with full-screen yellow background of the girl (Success 1)
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Success.png',
              fit: BoxFit.cover,
              alignment: const Alignment(-0.4, 0.0), // <-- THÊM DÒNG NÀY ĐỂ DỊCH ẢNH
            ),
          ),
          // Content overlay
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                       padding: EdgeInsets.symmetric(horizontal: 24),
                       child: Text(
                        'Your order will be delivered soon.\nThank you for choosing our app!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Small red continue shopping button
                    SizedBox(
                      height: 36,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/order-success2'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          textStyle: const TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Continue shopping'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma "Success 2" — White background success screen with bags illustration (Success 2)
class OrderSuccessScreen2 extends StatelessWidget {
  const OrderSuccessScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Bags illustration
            Center(
              child: Image.asset(
                'assets/images/bags.png',
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shopping_bag_outlined,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Success!',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your order will be delivered soon.\nThank you for choosing our app!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: AppColors.dark,
                height: 1.5,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/main', (r) => false),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    textStyle: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('CONTINUE SHOPPING'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
