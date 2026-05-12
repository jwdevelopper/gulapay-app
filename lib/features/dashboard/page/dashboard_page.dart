import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Dashboard",
        style: TextStyle(
          color: AppColors.textoEscuro,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
