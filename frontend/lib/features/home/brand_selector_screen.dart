import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Figma "Brand" — Searchable brand list with checkboxes
class BrandSelectorScreen extends StatefulWidget {
  const BrandSelectorScreen({super.key});
  @override
  State<BrandSelectorScreen> createState() => _BrandSelectorScreenState();
}

class _BrandSelectorScreenState extends State<BrandSelectorScreen> {
  final _searchCtrl = TextEditingController();
  final _brands = ['adidas', 'adidas Originals', 'Blend', 'Boutique Moschino', 'Champion', 'Diesel', 'Jack & Jones', 'Naf Naf', 'Red Valentino', 's.Oliver'];
  final Set<String> _selected = {'adidas Originals', 'Jack & Jones', 's.Oliver'};

  List<String> get _filtered => _searchCtrl.text.isEmpty
      ? _brands
      : _brands.where((b) => b.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.background, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), color: AppColors.dark, onPressed: () => Navigator.pop(context)),
        title: const Text('Brand', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark))),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(controller: _searchCtrl, onChanged: (_) => setState(() {}),
            style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
            decoration: InputDecoration(hintText: 'Search', filled: true, fillColor: AppColors.white, prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(23), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0)))),
        Expanded(
          child: ListView.builder(itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              final brand = _filtered[i];
              final checked = _selected.contains(brand);
              return CheckboxListTile(
                value: checked,
                onChanged: (v) => setState(() => v! ? _selected.add(brand) : _selected.remove(brand)),
                activeColor: AppColors.primary,
                title: Text(brand, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 16, color: AppColors.dark)),
              );
            }),
        ),
        Container(padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: SizedBox(height: 36,
              child: OutlinedButton(onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.dark, side: const BorderSide(color: AppColors.dark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text('Discard', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14))))),
            const SizedBox(width: 23),
            Expanded(child: SizedBox(height: 36,
              child: ElevatedButton(onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text('Apply', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500))))),
          ])),
      ]),
    );
  }
}
