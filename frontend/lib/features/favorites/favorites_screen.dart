import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/cart_provider.dart';

/// Figma "Favorites" — Grid/List with provider, tag filters, sold-out overlay
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGrid = true;
  String _selectedTag = 'All';
  static const _tags = ['All', 'Summer', 'T-Shirts', 'Shirts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.background, centerTitle: true,
        title: const Text('Favorites', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
        actions: [
          IconButton(icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view, color: AppColors.dark),
            onPressed: () => setState(() => _isGrid = !_isGrid)),
        ]),
      body: Consumer<FavoritesProvider>(builder: (ctx, fav, _) {
        final favs = fav.favoriteProducts;
        return Column(children: [
          // Tag filters
          SizedBox(height: 40,
            child: ListView.separated(scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final sel = _tags[i] == _selectedTag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = _tags[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                      color: sel ? AppColors.dark : Colors.transparent,
                      border: Border.all(color: sel ? AppColors.dark : AppColors.grey)),
                    child: Text(_tags[i], style: TextStyle(fontFamily: 'Metropolis', fontSize: 14,
                      color: sel ? Colors.white : AppColors.dark)),
                  ),
                );
              })),
          const SizedBox(height: 16),
          if (favs.isEmpty)
            const Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite_border, size: 80, color: AppColors.grey),
              SizedBox(height: 16),
              Text('No favorites yet', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, color: AppColors.grey)),
            ])))
          else
            Expanded(
              child: _isGrid
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.52, crossAxisSpacing: 16, mainAxisSpacing: 24),
                      itemCount: favs.length,
                      itemBuilder: (ctx, i) => _gridItem(ctx, favs[i], fav))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) => _listItem(ctx, favs[i], fav)),
            ),
        ]);
      }),
    );
  }

  Widget _gridItem(BuildContext ctx, Product p, FavoritesProvider fav) {
    return Stack(children: [
      ProductCard(product: p,
        onTap: () => Navigator.of(ctx).pushNamed('/product', arguments: p),
        onFavoriteTap: () => fav.toggleFavorite(p)),
      // Cart button at bottom-right of card
      Positioned(right: 0, bottom: 34,
        child: GestureDetector(
          onTap: () {
            final cart = ctx.read<CartProvider>();
            cart.addItem(p, color: p.colors.isNotEmpty ? 'Default' : '', size: p.sizes.isNotEmpty ? p.sizes.first : '');
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Added to bag!'), behavior: SnackBarBehavior.floating));
          },
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.white)),
        )),
    ]);
  }

  Widget _listItem(BuildContext ctx, Product p, FavoritesProvider fav) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).pushNamed('/product', arguments: p),
      child: Container(height: 104, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
        child: Row(children: [
          ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: p.imageUrls.first.startsWith('http')
                ? Image.network(p.imageUrls.first, width: 104, height: 104, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))
                : Image.asset(p.imageUrls.first, width: 104, height: 104, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 104, height: 104, color: AppColors.inputGrey))),
          Expanded(child: Padding(padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(p.brand, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
              const SizedBox(height: 2),
              Text(p.name, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                if (p.originalPrice != null) ...[
                  Text('${p.originalPrice!.toInt()}\$', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 4),
                ],
                Text('${p.price.toInt()}\$', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500,
                  color: p.hasDiscount ? AppColors.primary : AppColors.dark)),
              ]),
            ]))),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.close, size: 16, color: AppColors.grey), onPressed: () => fav.removeFavorite(p)),
            GestureDetector(
              onTap: () {
                ctx.read<CartProvider>().addItem(p, color: 'Default', size: p.sizes.isNotEmpty ? p.sizes.first : '');
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Added to bag!'), behavior: SnackBarBehavior.floating));
              },
              child: Container(width: 36, height: 36, margin: const EdgeInsets.only(right: 4, bottom: 4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                child: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.white))),
          ]),
        ])));
  }
}
