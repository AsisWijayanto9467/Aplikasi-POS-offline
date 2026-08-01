// lib/presentation/pages/settings/qris/qris_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
class QrisScreen extends StatelessWidget {
  const QrisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1C1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QRIS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Color(0xFF7E0092)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QRIS Preview
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E2E7),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 80,
                      color: Color(0xFF514250),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'QRIS Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1F),
                    ),
                  ),
                  Text(
                    'Belum ada QRIS terupload',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF514250),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E0092),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload QRIS'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // QRIS Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E2E7),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nama Merchant', 'Salon Cantik'),
                  const Divider(height: 16, color: Color(0xFFE2E2E7)),
                  _buildInfoRow('No. Merchant', '08123456789'),
                  const Divider(height: 16, color: Color(0xFFE2E2E7)),
                  _buildInfoRow('Status', 'Aktif', color: const Color(0xFF4CAF50)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E2E7),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildTextField('Nama Merchant', 'Salon Cantik'),
                  const SizedBox(height: 16),
                  _buildTextField('No. Merchant', '08123456789'),
                  const SizedBox(height: 16),
                  _buildTextField('Keterangan', 'Pembayaran QRIS'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E0092),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Pengaturan QRIS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF514250),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color ?? const Color(0xFF1A1C1F),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF514250),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9FE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE2E2E7),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1C1F),
            ),
          ),
        ),
      ],
    );
  }
}