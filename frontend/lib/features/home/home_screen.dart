import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';

/// Main Home Page — Figma "Main page" variant A (Fashion Sale)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Map<String, dynamic>> _bannerData = [
    {
      'image': 'assets/images/Pasted image3.png',
      'title': 'Fashion\nsale',
      'category': 'Sale',
      'align': Alignment.bottomLeft,
      'hasButton': true,
      'fontSize': 48.0,
    },
    {
      'image': 'assets/images/Pasted image (3).png',
      'title': 'Street clothes',
      'category': 'New',
      'align': Alignment.bottomLeft,
      'hasButton': false,
      'fontSize': 34.0,
    },
    {
      'image': 'assets/images/Pasted image (6).png',
      'title': 'New collection',
      'category': 'New',
      'align': Alignment.bottomRight,
      'hasButton': false,
      'fontSize': 34.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Tải dữ liệu sản phẩm từ Server sau khi Widget render xong frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                    // ── Hero Banner ─────────────────────────────────────────────
                    _buildHeroBanner(context),
                    const SizedBox(height: 24),
                    
                    // ── Bottom Dynamic Content ──────────────────────────────────
                    _buildBottomContent(context, productProvider),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double navBarHeight = kBottomNavigationBarHeight;
    final double availableHeight = screenHeight - topPadding - navBarHeight;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = 0.0;
        if (_pageController.hasClients) {
          page = _pageController.page ?? 0.0;
        }

        // Interpolate height based on the current page value:
        // Page 0.0 -> height 536
        // Page 1.0 -> height 350
        // Page 2.0 -> height availableHeight
        double bannerHeight;
        if (page <= 1.0) {
          bannerHeight = 536.0 + (350.0 - 536.0) * page;
        } else {
          bannerHeight = 350.0 + (availableHeight - 350.0) * (page - 1.0);
        }

        // Interpolate indicator top offset:
        // Page 0.0 -> top = 536 - 24 = 512
        // Page 1.0 -> top = 350 - 24 = 326
        // Page 2.0 -> top = availableHeight / 2 - 24
        double indicatorTop;
        double top0 = 536.0 - 24.0;
        double top1 = 350.0 - 24.0;
        double top2 = availableHeight / 2.0 - 24.0;
        if (page <= 1.0) {
          indicatorTop = top0 + (top1 - top0) * page;
        } else {
          indicatorTop = top1 + (top2 - top1) * (page - 1.0);
        }

        return SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: Stack(
            children: [
              child!, // PageView
              Positioned(
                top: indicatorTop,
                left: 0,
                right: 0,
                child: _buildPageIndicator(),
              ),
            ],
          ),
        );
      },
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _bannerData.length,
        itemBuilder: (context, index) {
          return _buildBannerItem(context, index);
        },
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context, int index) {
    if (index == 2) {
      return Column(
        children: [
          // Top Half: New Collection
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Pasted image (6).png'),
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
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                alignment: Alignment.bottomRight,
                child: const Text(
                  'New collection',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Half: Collage
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
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/Pasted image (8).png'),
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
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(left: 16, bottom: 16),
                            child: const Text(
                              'Black',
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Column
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Pasted image (7).png'),
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
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      child: const Text(
                        "Men's\nhoodies",
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final banner = _bannerData[index];
    final String image = banner['image'];
    final String title = banner['title'];
    final String category = banner['category'];
    final Alignment align = banner['align'];
    final bool hasButton = banner['hasButton'] ?? true;
    final double fontSize = banner['fontSize'] ?? 48.0;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
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
              Colors.black.withValues(alpha: 0.65),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
        alignment: align,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: align == Alignment.bottomRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: align == Alignment.bottomRight
                  ? TextAlign.right
                  : TextAlign.left,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            if (hasButton) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 160,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/category', arguments: category),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    textStyle: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Check'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = _currentIndex == index;
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

  Widget _buildBottomContent(BuildContext context, ProductProvider productProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildBodyForIndex(context, productProvider),
    );
  }

  Widget _buildBodyForIndex(BuildContext context, ProductProvider productProvider) {
    if (_currentIndex == 0) {
      return Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── New Section ────────────────────────────────────────────
          SectionHeader(
            title: 'New',
            subtitle: "You've never seen it before!",
            onViewAll: () => Navigator.of(context)
                .pushNamed('/category', arguments: 'New'),
          ),
          const SizedBox(height: 12),
          _buildProductRow(context, productProvider.newProducts),
          const SizedBox(height: 30),
          // ── Sale Section ───────────────────────────────────────────
          SectionHeader(
            title: 'Sale',
            subtitle: 'Super summer sale',
            onViewAll: () => Navigator.of(context)
                .pushNamed('/category', arguments: 'Sale'),
          ),
          const SizedBox(height: 12),
          _buildProductRow(context, productProvider.saleProducts),
          const SizedBox(height: 24),
        ],
      );
    } else if (_currentIndex == 1) {
      return Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      );
    } else {
      return const SizedBox(
        key: ValueKey(2),
      );
    }
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
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
