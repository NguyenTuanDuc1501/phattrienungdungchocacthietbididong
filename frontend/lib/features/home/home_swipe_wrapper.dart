import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'home_screen_2.dart';
import 'home_screen_3.dart';

/// Wraps HomeScreen, HomeScreen2, and HomeScreen3 in a horizontal PageView
/// to allow users to swipe between the three Figma Main variants.
class HomeSwipeWrapper extends StatefulWidget {
  const HomeSwipeWrapper({super.key});

  @override
  State<HomeSwipeWrapper> createState() => _HomeSwipeWrapperState();
}

class _HomeSwipeWrapperState extends State<HomeSwipeWrapper> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      children: const [
        HomeScreen(),
        HomeScreen2(),
        HomeScreen3(),
      ],
    );
  }
}

