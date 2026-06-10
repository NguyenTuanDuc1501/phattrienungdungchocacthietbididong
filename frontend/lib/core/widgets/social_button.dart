import 'package:flutter/material.dart';

/// Social login button (Google / Facebook) matching Figma style.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 92,
          height: 64,
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}
