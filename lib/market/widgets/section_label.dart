import 'package:flutter/material.dart';
import '../models/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const SectionLabel({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.labelGrey),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.labelGrey,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
