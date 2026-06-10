import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Figma "My Profile" — Avatar, name, menu items with count badges
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final name = user?.name ?? 'Matilda Brown';
    final email = user?.email ?? 'matildabrown@mail.com';
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: AppColors.background, 
        centerTitle: true,
        title: const Text('My profile', style: TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), 
            color: AppColors.dark, 
            onPressed: () => Navigator.of(context).pushNamed('/visual-search'),
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Avatar + Name (Interactive)
            InkWell(
              onTap: () => _showAccountActions(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32, 
                      backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text(name, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
                          const SizedBox(height: 4),
                          Text(email, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 14, color: AppColors.grey)),
                        ]
                      ),
                    ),
                  ]
                )
              ),
            ),
            const SizedBox(height: 8),
            _menuItem(context, 'My orders', 'Already have 12 orders', Icons.chevron_right, () => Navigator.of(context).pushNamed('/orders')),
            _menuItem(context, 'Shipping addresses', '3 addresses', Icons.chevron_right, () => Navigator.of(context).pushNamed('/shipping-addresses')),
            _menuItem(context, 'Payment methods', 'Visa  **34', Icons.chevron_right, () => Navigator.of(context).pushNamed('/payment')),
            _menuItem(context, 'Promocodes', 'You have special promocodes', Icons.chevron_right, () {}),
            _menuItem(context, 'My reviews', 'Reviews for 4 items', Icons.chevron_right, () {}),
            _menuItem(context, 'Settings', 'Notifications, password', Icons.chevron_right, () => Navigator.of(context).pushNamed('/settings')),
          ]
        )
      ),
    );
  }

  void _showAccountActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account options',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primary),
              title: const Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              subtitle: const Text('Sign out of your account'),
              onTap: () async {
                Navigator.of(ctx).pop(); // Close bottom sheet
                final auth = context.read<AuthProvider>();
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                }
              },
            ),
            const Divider(color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text(
                'Delete account',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              subtitle: const Text('Permanently delete your account'),
              onTap: () async {
                Navigator.of(ctx).pop(); // Close bottom sheet
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete account'),
                    content: const Text(
                      'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final auth = context.read<AuthProvider>();
                  final success = await auth.deleteAccount();
                  if (success && context.mounted) {
                     Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                  } else if (context.mounted && auth.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(auth.errorMessage!)),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData trailing, 
    VoidCallback onTap, {
    Color titleColor = AppColors.dark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Metropolis', fontSize: 16, fontWeight: FontWeight.w600, color: titleColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Metropolis', fontSize: 11, color: AppColors.grey)),
                ]
              )
            ),
            Icon(trailing, color: titleColor == AppColors.primary ? AppColors.primary : AppColors.grey, size: 20),
          ]
        )
      )
    );
  }
}
