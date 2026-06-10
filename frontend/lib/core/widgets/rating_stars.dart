import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays 1–5 rating stars. Supports half-star rendering.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.reviewCount,
  });

  final double rating;
  final double size;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            return Icon(Icons.star, size: size, color: AppColors.star);
          } else if (rating >= starValue - 0.5) {
            return Icon(Icons.star_half, size: size, color: AppColors.star);
          } else {
            return Icon(Icons.star_border, size: size, color: AppColors.grey);
          }
        }),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: size - 4,
              color: AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
