import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Figma "Finding similar results..." — Loading state screen
class VisualSearchFindingScreen extends StatefulWidget {
  const VisualSearchFindingScreen({super.key});

  @override
  State<VisualSearchFindingScreen> createState() => _VisualSearchFindingScreenState();
}

class _VisualSearchFindingScreenState extends State<VisualSearchFindingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate finding results delay, then navigate to catalog
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Pop until main, then push category list to show results
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (r) => false);
        Navigator.of(context).pushNamed('/category', arguments: 'Tops');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Finding similar\nresults...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
