import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'rating_stars.dart';

/// Product card used in grids on Home, Category, Favorites screens.
/// Matches the Figma card design with image, badge, favorite button, rating.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onFavoriteTap,
    this.showFavoriteButton = true,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + Badge + Favorite ────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 150 / 205,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrls.isEmpty
                      ? Container(
                          color: AppColors.inputGrey,
                          child: const Icon(Icons.image_not_supported, color: AppColors.grey),
                        )
                      : (product.imageUrls.first.startsWith('http')
                          ? Image.network(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.inputGrey,
                                child: const Icon(Icons.image, color: AppColors.grey),
                              ),
                            )
                          : Image.asset(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.inputGrey,
                                child: const Icon(Icons.image, color: AppColors.grey),
                              ),
                            )),
                ),
              ),
              // Discount / New badge
              if (product.hasDiscount || product.isNew)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.hasDiscount
                          ? AppColors.saleBadge
                          : AppColors.newBadge,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      product.hasDiscount
                          ? '-${product.discountPercent}%'
                          : 'NEW',
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              // Favorite button
              if (showFavoriteButton)
                Positioned(
                  bottom: -18,
                  right: 0,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: AppColors.white,
                    child: InkWell(
                      onTap: onFavoriteTap,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: product.isFavorite
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Rating ──────────────────────────────────────────────────
          RatingStars(
            rating: product.rating,
            size: 14,
            reviewCount: product.reviewCount,
          ),
          const SizedBox(height: 4),
          // ── Brand ───────────────────────────────────────────────────
          Text(
            product.brand,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // ── Name ────────────────────────────────────────────────────
          Text(
            product.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // ── Price ───────────────────────────────────────────────────
          Row(
            children: [
              if (product.originalPrice != null) ...[
                Text(
                  '${product.originalPrice!.toInt()}\$',
                  style: AppTextStyles.priceOriginal,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                '${product.price.toInt()}\$',
                style: product.hasDiscount
                    ? AppTextStyles.priceDiscount
                    : AppTextStyles.price,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
