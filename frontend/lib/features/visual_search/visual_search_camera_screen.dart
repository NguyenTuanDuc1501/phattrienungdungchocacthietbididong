import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Figma "Search by taking a photo" — Camera viewfinder UI mockup
class VisualSearchCameraScreen extends StatelessWidget {
  const VisualSearchCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search by taking a photo',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Camera viewfinder (full image)
          Expanded(
            child: Image.asset(
              'assets/images/Pasted image2.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // Bottom bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash icon
                IconButton(
                  icon: const Icon(Icons.flash_on, color: AppColors.dark, size: 28),
                  onPressed: () {},
                ),
                // Capture button (Red circle with camera)
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/visual-search-crop'),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                  ),
                ),
                // Flip camera icon
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: AppColors.dark, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
