import 'package:flutter/material.dart';
import 'package:life_line_admin/styles/styles.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: AppColors.surfaceLight,
        strokeWidth: 2,
      ),
    );
  }
}
