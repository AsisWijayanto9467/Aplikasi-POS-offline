// lib/presentation/pages/transaction/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salon_desk/data/controller/transaction_controller.dart';
import 'package:salon_desk/presentation/screens/transaction/widgets/cart_page.dart';
import 'package:salon_desk/presentation/screens/transaction/widgets/payment_page.dart';
import 'package:salon_desk/presentation/screens/transaction/widgets/success_page.dart';
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TransactionController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _controller = TransactionController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadProducts();
    await _controller.loadServices();
    await _controller.loadPackages();
  }

  void _navigateToPayment() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _navigateToSuccess() {
    // ✅ Siapkan data untuk dicetak
    final receiptData = {
      'header': 'SALON CANTIK',
      'items': _controller.cartItems.map((item) => {
        'name': item.itemName,
        'qty': item.quantity,
        'price': item.itemPrice,
        'subtotal': item.itemPrice * item.quantity,
      }).toList(),
      'total': _controller.total,
      'footer': 'Terima kasih telah berkunjung',
    };
    
    // ✅ Simpan receipt data di controller
    _controller.setReceiptData(receiptData);
    
    setState(() {
      _currentPage = 2;
    });
  }

  void _navigateToCart() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _currentPage == 0
                  ? CartPage(controller: _controller, onNext: _navigateToPayment)
                  : _currentPage == 1
                      ? PaymentPage(
                          controller: _controller,
                          onSuccess: _navigateToSuccess,
                          onBack: _navigateToCart,
                        )
                      : SuccessPage(
                          controller: _controller,
                          onFinish: _navigateToCart,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1C1F), size: 18),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _currentPage == 0 ? 'Transaksi Baru' : 
            _currentPage == 1 ? 'Pembayaran' : 'Pembayaran Berhasil',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const Spacer(),
          if (_currentPage == 0 && _controller.cartItemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7E0092).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_controller.cartItemCount} item',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7E0092),
                ),
              ),
            ),
        ],
      ),
    );
  }
}