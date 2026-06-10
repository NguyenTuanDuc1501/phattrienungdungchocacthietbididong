import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_app_bar.dart';

/// Figma "Settings" — Personal info + notification toggles + change password
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController(text: 'Matilda Brown');
  final _dobCtrl = TextEditingController(text: '12/12/1989');
  bool _salesNotif = true;
  bool _newArrivalsNotif = false;
  bool _deliveryNotif = false;

  @override
  void dispose() { _nameCtrl.dispose(); _dobCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Settings'),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Personal Information', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 16),
          _field('Full name', _nameCtrl),
          const SizedBox(height: 16),
          _field('Date of Birth', _dobCtrl),
          const SizedBox(height: 24),
          // Password section
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Password', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
            GestureDetector(onTap: _showChangePassword,
              child: const Text('Change', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey))),
          ]),
          const SizedBox(height: 8),
          _field('Password', TextEditingController(text: '************'), obscure: true),
          const SizedBox(height: 32),
          // Notifications
          const Text('Notifications', style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
          const SizedBox(height: 16),
          _toggle('Sales', _salesNotif, (v) => setState(() => _salesNotif = v)),
          _toggle('New arrivals', _newArrivalsNotif, (v) => setState(() => _newArrivalsNotif = v)),
          _toggle('Delivery status changes', _deliveryNotif, (v) => setState(() => _deliveryNotif = v)),
        ])),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool obscure = false}) =>
    Container(padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
      child: TextField(controller: ctrl, obscureText: obscure,
        style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
        decoration: InputDecoration(labelText: label, border: InputBorder.none,
          labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey))));

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
    Padding(padding: const EdgeInsets.only(bottom: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark)),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.success),
      ]));

  void _showChangePassword() {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 60, height: 6, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 16),
            const Text('Password Change', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
            const SizedBox(height: 16),
            _sheetField('Old Password'),
            const SizedBox(height: 16),
            // Forgot password link
            Align(alignment: Alignment.centerRight,
              child: GestureDetector(onTap: () {},
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Forgot Password?', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ]))),
            const SizedBox(height: 16),
            _sheetField('New Password'),
            const SizedBox(height: 16),
            _sheetField('Repeat New Password'),
            const SizedBox(height: 24),
            SizedBox(height: 48, width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text('SAVE PASSWORD', style: TextStyle(fontFamily: 'Metropolis', fontSize: 14, fontWeight: FontWeight.w500)))),
          ]));
      });
  }

  Widget _sheetField(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1))]),
    child: TextField(obscureText: true,
      style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.dark),
      decoration: InputDecoration(labelText: label, border: InputBorder.none,
        labelStyle: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey))));
}
