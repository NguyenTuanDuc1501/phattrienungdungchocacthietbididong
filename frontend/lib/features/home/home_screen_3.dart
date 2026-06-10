import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Main 3 Page — Figma "Main 3" variant (Collage layout)
class HomeScreen3 extends StatelessWidget {
  const HomeScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Half: New Collection
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                _buildBanner(
                  imagePath: 'assets/images/Pasted image (6).png', // New collection image
                  title: 'New collection',
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(right: 16, bottom: 48),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: _buildPageIndicator(),
                ),
              ],
            ),
          ),
          // Bottom Half
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // Left Column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Summer Sale block
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Summer\nsale',
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      // Black block
                      Expanded(
                        flex: 1,
                        child: _buildBanner(
                          imagePath: 'assets/images/Pasted image (8).png', // Black image
                          title: 'Black',
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.only(left: 16, bottom: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Column
                Expanded(
                  flex: 1,
                  child: _buildBanner(
                    imagePath: 'assets/images/Pasted image (7).png', // Men's hoodies image
                    title: "Men's\nhoodies",
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required String imagePath,
    required String title,
    required Alignment alignment,
    required EdgeInsets padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.5),
            ],
          ),
        ),
        alignment: alignment,
        padding: padding,
        child: Text(
          title,
          textAlign: alignment == Alignment.center ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == 2; // Slide 3 has active index 2
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? const Color(0xFFDB3022) : const Color(0xFFCCCCCC),
          ),
        );
      }),
    );
  }
}
