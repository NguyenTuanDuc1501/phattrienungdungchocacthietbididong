import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_app_bar.dart';
import '../../data/dummy/dummy_addresses.dart';
import '../../data/models/address.dart';

/// Figma "Shipping Addresses" — List + Add new address bottom sheet
class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});
  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  late List<Address> _addresses;
  int _defaultIdx = 0;

  @override
  void initState() {
    super.initState();
    _addresses = List.from(dummyAddresses);
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _defaultIdx = i;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Shipping Addresses'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditAddress(),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final addr = _addresses[i];
          final isDefault = i == _defaultIdx;
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addr.fullName,
                      style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark),
                    ),
                    GestureDetector(
                      onTap: () => _showAddOrEditAddress(index: i),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  addr.formattedAddress,
                  style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark, height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isDefault,
                        onChanged: (_) => setState(() => _defaultIdx = i),
                        activeColor: AppColors.dark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Use as the shipping address',
                      style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddOrEditAddress({int? index}) {
    final Address? current = index != null ? _addresses[index] : null;
    final nameCtrl = TextEditingController(text: current?.fullName);
    final addressCtrl = TextEditingController(text: current?.addressLine);
    final cityCtrl = TextEditingController(text: current?.city);
    final stateCtrl = TextEditingController(text: current?.state);
    final zipCtrl = TextEditingController(text: current?.zipCode);
    final countryCtrl = TextEditingController(text: current?.country ?? 'United States');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              index != null ? 'Edit Shipping Address' : 'Adding Shipping Address',
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 20),
            _input('Full name', nameCtrl),
            const SizedBox(height: 12),
            _input('Address', addressCtrl),
            const SizedBox(height: 12),
            _input('City', cityCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _input('State/Province/Region', stateCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _input('Zip Code (Postal Code)', zipCtrl)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
                ],
              ),
              child: TextField(
                controller: countryCtrl,
                style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  labelStyle: TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey),
                  suffixIcon: Icon(Icons.keyboard_arrow_right, color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                    final newAddress = Address(
                      id: current?.id ?? 'a${_addresses.length + 1}',
                      fullName: nameCtrl.text,
                      addressLine: addressCtrl.text,
                      city: cityCtrl.text,
                      state: stateCtrl.text,
                      zipCode: zipCtrl.text,
                      country: countryCtrl.text,
                    );
                    setState(() {
                      if (index != null) {
                        _addresses[index] = newAddress;
                      } else {
                        _addresses.add(newAddress);
                      }
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(
                  index != null ? 'SAVE ADDRESS' : 'ADD ADDRESS',
                  style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey),
        ),
      ),
    );
  }
}
