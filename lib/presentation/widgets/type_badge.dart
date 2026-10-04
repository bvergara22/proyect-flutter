import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final bool light;

  const TypeBadge({super.key, required this.type, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forType(type);
    final label = type[0].toUpperCase() + type.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.3) : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: light ? Colors.white60 : color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
