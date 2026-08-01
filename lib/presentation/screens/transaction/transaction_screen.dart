import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Baru')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_rounded, size: 80, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Pilih produk atau jasa', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}