import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_rounded, size: 80, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Belum ada laporan', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}