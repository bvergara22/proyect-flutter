import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Cargando...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
