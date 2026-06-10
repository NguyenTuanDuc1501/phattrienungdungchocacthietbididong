import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';

/// Main 2 Page — Figma "Main 2" variant (Street clothes)
class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => productProvider.loadProducts(),
        color: AppColors.primary,
        child: productProvider.isLoading && productProvider.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Banner (Street clothes) ───────────────────────────
                    _buildHeroBanner(context),
                    const SizedBox(height: 24),
                    
                    // ── Sale Section ───────────────────────────────────────────
                    SectionHeader(
                      title: 'Sale',
                      subtitle: 'Super summer sale',
                      onViewAll: () => Navigator.of(context)
                          .pushNamed('/category', arguments: 'Sale'),
                    ),
                    const SizedBox(height: 12),
                    _buildProductRow(context, productProvider.saleProducts),
                    const SizedBox(height: 30),
                    
                    // ── New Section ────────────────────────────────────────────
                    SectionHeader(
                      title: 'New',
                      subtitle: "You've never seen it before!",
                      onViewAll: () => Navigator.of(context)
                          .pushNamed('/category', arguments: 'New'),
                    ),
                    const SizedBox(height: 12),
                    _buildProductRow(context, productProvider.newProducts),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Pasted image (3).png'), // Street Clothes horizontal image
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
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
              alignment: Alignment.bottomLeft,
              child: const Text(
                'Street clothes',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == 1; // Slide 2 has active index 1
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

  Widget _buildProductRow(BuildContext context, List products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Không có sản phẩm nào',
            style: TextStyle(fontFamily: 'Metropolis', color: AppColors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 340, // Ensure height matches product card
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 150,
            child: Consumer<FavoritesProvider>(
              builder: (ctx, fav, _) => ProductCard(
                product: product,
                onTap: () => Navigator.of(context)
                    .pushNamed('/product', arguments: product),
                onFavoriteTap: () => fav.toggleFavorite(product),
              ),
            ),
          );
        },
      ),
    );
  }
}
