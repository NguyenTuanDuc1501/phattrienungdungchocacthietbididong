import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Figma "Filters" full-screen — Price range, Colors, Sizes, Category, Brand
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _priceRange = const RangeValues(78, 143);
  final Set<int> _selectedColors = {0};
  final Set<int> _selectedSizes = {1, 2};
  final _colors = [Colors.black, const Color(0xFFF6F6F6), const Color(0xFFB82222), const Color(0xFFBEA9A9), const Color(0xFFE2BB8D), const Color(0xFF151867)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0, backgroundColor: AppColors.background, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), color: AppColors.dark, onPressed: () => Navigator.pop(context)),
        title: const Text('Filters', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Price range
          const Text('Price range', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${_priceRange.start.round()}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark)),
            Text('\$${_priceRange.end.round()}', style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark)),
          ]),
          RangeSlider(
            values: _priceRange, min: 0, max: 200,
            activeColor: AppColors.primary, inactiveColor: AppColors.inputGrey,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 24),
          // Colors
          const Text('Colors', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 12),
          Row(children: List.generate(_colors.length, (i) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedColors.contains(i) ? _selectedColors.remove(i) : _selectedColors.add(i)),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _colors[i],
                  border: Border.all(color: _selectedColors.contains(i) ? AppColors.primary : Colors.transparent, width: 2)),
              ),
            ),
          ))),
          const SizedBox(height: 24),
          // Sizes
          const Text('Sizes', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: ['XS', 'S', 'M', 'L', 'XL'].asMap().entries.map((e) {
            final sel = _selectedSizes.contains(e.key);
            return GestureDetector(
              onTap: () => setState(() => sel ? _selectedSizes.remove(e.key) : _selectedSizes.add(e.key)),
              child: Container(
                width: 40, height: 40, alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                  color: sel ? AppColors.primary : Colors.white,
                  border: Border.all(color: sel ? AppColors.primary : AppColors.grey)),
                child: Text(e.value, style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500,
                  color: sel ? Colors.white : AppColors.dark)),
              ),
            );
          }).toList()),
          const SizedBox(height: 24),
          // Category
          const Text('Category', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ['All', 'Women', 'Men', 'Boys', 'Girls'].map((c) =>
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                color: c == 'All' ? AppColors.primary : Colors.white,
                border: Border.all(color: c == 'All' ? AppColors.primary : AppColors.grey)),
              child: Text(c, style: TextStyle(fontFamily: 'Metropolis', fontSize: 14,
                color: c == 'All' ? Colors.white : AppColors.dark)),
            ),
          ).toList()),
          const SizedBox(height: 24),
          // Brand
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Brand', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
            subtitle: const Text('adidas Originals, Jack & Jones, s.Oliver', style: TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.dark),
            onTap: () => Navigator.of(context).pushNamed('/brands'),
          ),
          const SizedBox(height: 32),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: AppColors.white,
          boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2))]),
        child: SafeArea(child: Row(children: [
          Expanded(child: SizedBox(height: 36,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.dark, side: const BorderSide(color: AppColors.dark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: const Text('Discard', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14))))),
          const SizedBox(width: 23),
          Expanded(child: SizedBox(height: 36,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: const Text('Apply', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500))))),
        ])),
      ),
    );
  }
}
