import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/services/review_api_service.dart';
import '../../data/models/review.dart';
import '../../providers/auth_provider.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewApiService _reviewApiService = ReviewApiService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _withPhotoOnly = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> localReviewImages = const [
    'assets/images/Women Casual Sneakers.png',
    'assets/images/Women Classic Sunglasses.png',
    'assets/images/Women Knitted Cardigan.jpg',
    'assets/images/Pasted image (10).png',
    'assets/images/Men Classic Trench Coat.jpg',
    'assets/images/Women Evening Slip Dress.png',
    'assets/images/Men Modern Fit Blazer.jpg',
    'assets/images/Kids Stylish Backpack.jpg',
    'assets/images/Pasted image (11).png',
    'assets/images/Pasted image (12).png',
  ];

  late final List<Review> _mockReviews = [
    Review(
      id: 'mock1',
      authorName: 'Helene Moore',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=face',
      rating: 5.0,
      text: 'The sneakers are super comfortable and fit perfectly! The quality is amazing for the price. I highly recommend it!',
      date: DateTime(2026, 5, 15),
      imageUrls: const ['assets/images/Women Casual Sneakers.png'],
      helpfulCount: 4,
      customerId: 'mock_user_1',
    ),
    Review(
      id: 'mock2',
      authorName: 'John Smith',
      authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      rating: 4.0,
      text: 'Very stylish sunglasses. They look great and provide good sun protection. Delivery was also fast.',
      date: DateTime(2026, 5, 20),
      imageUrls: const ['assets/images/Women Classic Sunglasses.png'],
      helpfulCount: 2,
      customerId: 'mock_user_2',
    ),
    Review(
      id: 'mock3',
      authorName: 'Emily Davis',
      authorAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      rating: 5.0,
      text: 'I love this cardigan! It is so soft and warm. Perfect for chilly evenings. Will buy in other colors too.',
      date: DateTime(2026, 6, 1),
      imageUrls: const [],
      helpfulCount: 0,
      customerId: 'mock_user_3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reviews = await _reviewApiService.getReviews(widget.productId);
      setState(() {
        _reviews = [
          ...reviews,
          ..._mockReviews,
        ];
        _isLoading = false;
      });
    } catch (e) {
      // Fallback về mock reviews khi có lỗi kết nối hoặc lỗi bất kỳ
      setState(() {
        _reviews = _mockReviews;
        _isLoading = false;
      });
    }
  }

  List<Review> get _filteredReviews {
    final filtered = _withPhotoOnly
        ? _reviews.where((r) => r.imageUrls.isNotEmpty).toList()
        : _reviews;
    return filtered;
  }

  Map<int, int> get _ratingCounts {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in _reviews) {
      final ratingInt = r.rating.round();
      if (counts.containsKey(ratingInt)) {
        counts[ratingInt] = counts[ratingInt]! + 1;
      }
    }
    return counts;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<double>(0.0, (prev, r) => prev + r.rating);
    return sum / _reviews.length;
  }

  int get _totalRatings => _reviews.length;

  bool get _hasUserReviewed {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id;
      if (currentUserId == null || currentUserId.isEmpty) return false;
      return _reviews.any((r) => r.customerId == currentUserId);
    } catch (_) {
      return false;
    }
  }

  Widget _buildReviewImage(String url, {required double width, required double height}) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(width, height),
      );
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(width, height),
      );
    } else {
      return Image.file(
        File(url),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(width, height),
      );
    }
  }

  Widget _buildPlaceholderImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.inputGrey,
      child: const Icon(Icons.broken_image, color: AppColors.grey, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _filteredReviews;

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
          'Rating and reviews',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Rating summary ─────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big rating number + label
                      Column(
                        children: [
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 44,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RatingStars(rating: _averageRating, size: 14),
                          const SizedBox(height: 8),
                          Text(
                            '$_totalRatings ratings',
                            style: const TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 28),
                      // Bar chart
                      Expanded(
                        child: Column(
                          children: [
                            _ratingBar(5, _ratingCounts[5]!),
                            _ratingBar(4, _ratingCounts[4]!),
                            _ratingBar(3, _ratingCounts[3]!),
                            _ratingBar(2, _ratingCounts[2]!),
                            _ratingBar(1, _ratingCounts[1]!),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Reviews count + "With photo" checkbox ──────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reviews.length} reviews',
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _withPhotoOnly = !_withPhotoOnly);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _withPhotoOnly,
                                onChanged: (v) {
                                  setState(() => _withPhotoOnly = v ?? false);
                                },
                                activeColor: AppColors.dark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(
                                  color: AppColors.grey,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'With photo',
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 14,
                                color: AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Review cards ───────────────────────────────────────
                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No reviews yet.',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...reviews.map((r) => _reviewCard(r)),
                ],
              ),
            ),
      floatingActionButton: _hasUserReviewed
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showWriteReview(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Write a review',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  // ── Rating bar row: "5 ████████ 12" ───────────────────────────────────────
  Widget _ratingBar(int stars, int count) {
    final fraction = _totalRatings > 0 ? count / _totalRatings : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$stars',
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: AppColors.dark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.inputGrey,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Review card ────────────────────────────────────────────────────────────
  Widget _reviewCard(Review r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name + Stars + Date
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                backgroundImage: NetworkImage(r.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.userName,
                      style: const TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingStars(rating: r.rating, size: 14),
                  ],
                ),
              ),
              Text(
                r.formattedDate,
                style: const TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Review text
          Text(
            r.comment,
            style: const TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: AppColors.dark,
              height: 1.5,
            ),
          ),

          // Review images
          if (r.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildReviewImage(r.imageUrls[i], width: 80, height: 80),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // "Helpful" text
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Placeholder for helpful action
              },
              child: const Text(
                'Helpful',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet: Write a Review ──────────────────────────────────────────
  void _showWriteReview(BuildContext context) {
    int selectedRating = 0;
    final reviewController = TextEditingController();
    final List<String> addedPhotos = [];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title: "What is you rate?"
              const Text(
                'What is you rate?',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),

              // Star rating selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () => setSheetState(() => selectedRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < selectedRating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: i < selectedRating ? AppColors.star : AppColors.grey,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Subtitle
              const Text(
                'Please share your opinion\nabout the product',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 20),

              // Text input for review
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: reviewController,
                  maxLines: 5,
                  enabled: !isSubmitting,
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Your review',
                    hintStyle: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Photo upload section
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    // Camera / Add photo button
                    GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () {
                              _showImageSourceDialog(ctx, setSheetState, addedPhotos);
                            },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your photos',
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 11,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Added photos preview
                    if (addedPhotos.isNotEmpty)
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: addedPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildReviewImage(addedPhotos[i], width: 64, height: 64),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SEND REVIEW button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedRating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
                            );
                            return;
                          }
                          if (reviewController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
                            );
                            return;
                          }

                          setSheetState(() => isSubmitting = true);

                          try {
                            final newReview = await _reviewApiService.createReview(
                              productId: widget.productId,
                              rating: selectedRating,
                              comment: reviewController.text.trim(),
                              title: 'Review',
                              imageUrls: addedPhotos,
                            );

                            setState(() {
                              _reviews.insert(0, newReview);
                            });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gửi đánh giá thành công!')),
                            );
                          } catch (e) {
                            setSheetState(() => isSubmitting = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Không thể gửi đánh giá: $e')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'SEND REVIEW',
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
      ),
    );
  }

  // ── Show dialog to choose Camera or local library (assets) ──────────────────
  void _showImageSourceDialog(BuildContext sheetContext, StateSetter setSheetState, List<String> addedPhotos) {
    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Chụp ảnh từ Camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setSheetState(() {
                        addedPhotos.add(image.path);
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text('Không thể mở camera: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Chọn ảnh từ Thư viện (assets)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPhotoSelector(sheetContext, setSheetState, addedPhotos);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Show photo selector bottom sheet ──────────────────────────────────────
  void _showPhotoSelector(BuildContext sheetContext, StateSetter setSheetState, List<String> addedPhotos) {
    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select review photos',
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: localReviewImages.length,
                    itemBuilder: (context, index) {
                      final imagePath = localReviewImages[index];
                      final isSelected = addedPhotos.contains(imagePath);
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelected) {
                              addedPhotos.remove(imagePath);
                            } else {
                              addedPhotos.add(imagePath);
                            }
                          });
                          // Re-render selector sheet
                          (context as Element).markNeedsBuild();
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
