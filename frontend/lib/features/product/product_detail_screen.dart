import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../data/models/product.dart';
import '../../data/dummy/dummy_products.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../core/services/product_api_service.dart';

/// Figma "Product Card" — Detail page matching Figma layout exactly.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  int _selectedColorIdx = 0;
  bool _detailsExpanded = false;
  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;

  final ProductApiService _productApiService = ProductApiService();
  List<Product> _realRelatedProducts = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  Future<void> _loadRelatedProducts() async {
    try {
      final products = await _productApiService.getProducts();
      if (mounted) {
        setState(() {
          _realRelatedProducts = products;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _realRelatedProducts = [];
          _isLoadingRelated = false;
        });
      }
    }
  }

  String _colorLabel(Color c) {
    if (c == Colors.black) return 'Black';
    if (c == Colors.white) return 'White';
    if (c == Colors.red) return 'Red';
    if (c == Colors.blue) return 'Blue';
    if (c == Colors.green) return 'Green';
    if (c == Colors.grey) return 'Grey';
    if (c == Colors.orange) return 'Orange';
    if (c == Colors.pink) return 'Pink';
    if (c == Colors.brown) return 'Brown';
    if (c == Colors.yellow) return 'Yellow';
    if (c == Colors.deepPurple) return 'Purple';
    final hex = c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$hex';
  }

  List<Product> _relatedProducts(Product current) {
    final sourceList = _realRelatedProducts.isNotEmpty ? _realRelatedProducts : dummyProducts;
    // Lọc sản phẩm cùng category, bỏ sản phẩm hiện tại
    final same = sourceList
        .where((p) =>
            p.id != current.id &&
            p.category.toLowerCase() == current.category.toLowerCase())
        .toList();
    // Nếu không đủ, lấy thêm sản phẩm khác category
    if (same.length < 4) {
      final others = sourceList
          .where((p) =>
              p.id != current.id &&
              p.category.toLowerCase() != current.category.toLowerCase())
          .toList();
      return [...same, ...others];
    }
    return same;
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final related = _relatedProducts(p);

    // Nếu sản phẩm chỉ có 1 ảnh, tạo danh sách 2 ảnh (ảnh thứ 2 trùng)
    // để UX luôn có thể vuốt thấy 2 khung
    final images = p.imageUrls.length >= 2
        ? p.imageUrls
        : [...p.imageUrls, ...p.imageUrls]; // duplicate nếu chỉ có 1 ảnh

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
        title: Text(
          p.name,
          style: const TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: AppColors.dark,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Ảnh sản phẩm (PageView full-width, vuốt được) ──────────
                  SizedBox(
                    height: 413,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _imagePageController,
                          itemCount: images.length,
                          onPageChanged: (idx) =>
                              setState(() => _currentImagePage = idx),
                          itemBuilder: (ctx, i) {
                            final url = images[i];
                            return Container(
                              color: AppColors.white,
                              child: url.startsWith('http')
                                  ? Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.inputGrey,
                                        child: const Icon(Icons.image,
                                            color: AppColors.grey, size: 48),
                                      ),
                                    )
                                  : Image.asset(
                                      url,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.inputGrey,
                                        child: const Icon(Icons.image,
                                            color: AppColors.grey, size: 48),
                                      ),
                                    ),
                            );
                          },
                        ),
                        // Dot indicator ở góc phải giữa
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(images.length, (i) {
                                final active = i == _currentImagePage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(vertical: 3),
                                  width: 6,
                                  height: active ? 18 : 6,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.primary
                                        : const Color(0xFFCCCCCC),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 2. Size + Color dropdown + Favorite ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Size dropdown
                        Expanded(
                          child: GestureDetector(
                            onTap: _showSelectSize,
                            child: Container(
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.dark),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedSize ?? 'Size',
                                    style: const TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.dark, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Color dropdown (như Figma: "Black ▼")
                        if (p.colors.isNotEmpty)
                          GestureDetector(
                            onTap: _showSelectColor,
                            child: Container(
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.dark),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Chấm màu nhỏ
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: p.colors[_selectedColorIdx],
                                      border: Border.all(
                                          color: Colors.black12, width: 1),
                                    ),
                                  ),
                                  Text(
                                    _colorLabel(p.colors[_selectedColorIdx]),
                                    style: const TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.dark, size: 20),
                                ],
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Favorite button
                        Consumer<FavoritesProvider>(
                          builder: (ctx, fav, _) => GestureDetector(
                            onTap: () {
                              fav.toggleFavorite(p);
                              if (fav.isFavorite(p.id)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Added ${p.name} to favorites!'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.dark,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.cardShadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                fav.isFavorite(p.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: fav.isFavorite(p.id)
                                    ? AppColors.primary
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 3. Brand (trái) + Giá (phải) cùng hàng — như Figma ────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand + tên sản phẩm nhỏ bên trái
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.brand,
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Giá bên phải
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${p.price.toInt()}',
                              style: const TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                            ),
                            if (p.originalPrice != null)
                              Text(
                                '\$${p.originalPrice!.toInt()}',
                                style: const TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 13,
                                  color: AppColors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── 4. Rating ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        RatingStars(rating: p.rating, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '(${p.reviewCount})',
                          style: const TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 5. Description ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      p.description,
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        color: AppColors.dark,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── 6. Item details expandable ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _detailsExpanded = !_detailsExpanded),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              border:
                                  Border(top: BorderSide(color: AppColors.divider)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Item details',
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.dark,
                                  ),
                                ),
                                Icon(
                                  _detailsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.dark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_detailsExpanded) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              '• Machine wash cold\n• Imported\n• Pull-on closure\n• Lightweight jersey fabric',
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 14,
                                color: AppColors.dark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],

                        // Reviews row
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/reviews', arguments: p.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: AppColors.divider)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.dark,
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: AppColors.dark),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 7. "You can also like this" — sản phẩm cùng category ─────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You can also like this',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        Text(
                          '${related.length} items',
                          style: const TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 11,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 300,
                    child: _isLoadingRelated
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: related.length > 6 ? 6 : related.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) {
                              final rel = related[i];
                              return SizedBox(
                                width: 150,
                                child: ProductCard(
                                  product: rel,
                                  onTap: () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailScreen(product: rel),
                                    ),
                                  ),
                                  onFavoriteTap: () => context
                                      .read<FavoritesProvider>()
                                      .toggleFavorite(rel),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── ADD TO CART button ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final size = _selectedSize ??
                        (p.sizes.isNotEmpty ? p.sizes.first : '');
                    final colorName = p.colors.isNotEmpty
                        ? _colorLabel(p.colors[_selectedColorIdx])
                        : '';
                    context
                        .read<CartProvider>()
                        .addItem(p, color: colorName, size: size);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p.name} added to bag!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.dark,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('ADD TO CART'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet chọn Size ───────────────────────────────────────────────
  void _showSelectSize() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select size',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.product.sizes
                  .map((s) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedSize = s);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedSize == s
                                ? AppColors.primary
                                : Colors.white,
                            border: Border.all(
                              color: _selectedSize == s
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _selectedSize == s
                                  ? Colors.white
                                  : AppColors.dark,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Size info',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedSize == null &&
                      widget.product.sizes.isNotEmpty) {
                    setState(() => _selectedSize = widget.product.sizes.first);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet chọn màu (dropdown style) ──────────────────────────────
  void _showSelectColor() {
    final p = widget.product;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select color',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(p.colors.length, (i) {
              final selected = i == _selectedColorIdx;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColorIdx = i);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.colors[i],
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _colorLabel(p.colors[i]),
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 15,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? AppColors.primary : AppColors.dark,
                        ),
                      ),
                      const Spacer(),
                      if (selected)
                        const Icon(Icons.check,
                            color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
