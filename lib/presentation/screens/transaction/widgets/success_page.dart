// lib/presentation/pages/transaction/widgets/success_page.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/data/controller/transaction_controller.dart';
import 'package:salon_desk/presentation/screens/settings/printer/printer_screen.dart';

class SuccessPage extends StatelessWidget {
  final TransactionController controller;
  final VoidCallback onFinish;

  const SuccessPage({
    super.key,
    required this.controller,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Debug: Print receipt data untuk memastikan data ada
    print('📄 Receipt Data: ${controller.receiptData}');
    
    // ✅ Ambil data struk dari controller
    final receiptData = controller.receiptData ?? {};
    
    // ✅ Debug: Print items
    if (receiptData['items'] != null) {
      print('📋 Items: ${receiptData['items']}');
      print('📋 Items count: ${(receiptData['items'] as List).length}');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Pembayaran Berhasil!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          
          // Subtitle
          Text(
            'Transaksi berhasil diproses',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF837281),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Invoice
          Text(
            'Invoice: ${controller.lastInvoiceNumber ?? 'INV-2024-001'}',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF837281),
            ),
            textAlign: TextAlign.center,
          ),
          
          // ✅ Debug: Tampilkan jumlah item
          if (receiptData['items'] != null)
            Text(
              '${(receiptData['items'] as List).length} item',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF837281),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // ✅ Print receipt data sebelum navigasi
                    print('🖨️ Printing receipt with data: $receiptData');
                    
                    // ✅ Navigasi ke PrinterScreen
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrinterScreen(
                          receiptData: receiptData,
                        ),
                      ),
                    );
                    
                    // ✅ Setelah kembali dari printer, clear receipt data
                    if (result == true && context.mounted) {
                      controller.clearReceiptData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E0092),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text(
                    'Cetak Struk',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // ✅ Clear cart dan receipt saat selesai
                    controller.clearAfterSuccess();
                    controller.clearReceiptData();
                    onFinish();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF514250),
                    side: const BorderSide(color: Color(0xFFE2E2E7)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Link kembali
          TextButton(
            onPressed: () {
              controller.clearAfterSuccess();
              controller.clearReceiptData();
              onFinish();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF837281),
              ),
            ),
          ),
        ],
      ),
    );
  }
}