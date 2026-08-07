// lib/presentation/pages/transaction/widgets/payment_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/controller/transaction_controller.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/qris_model.dart';
import 'package:salon_desk/presentation/screens/settings/qris/qris_screen.dart';
class PaymentPage extends StatefulWidget {
  final TransactionController controller;
  final VoidCallback onSuccess;
  final VoidCallback onBack;

  const PaymentPage({
    super.key,
    required this.controller,
    required this.onSuccess,
    required this.onBack,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _customerController = TextEditingController();
  
  // Menggunakan String sebagai buffer lokal untuk mengelola input kalkulator dengan presisi
  String _cashDisplay = '0';

  // ✅ QRIS variables
  QrisModel? _qrisModel;
  bool _isLoadingQRIS = false;

  @override
  void initState() {
    super.initState();
    _customerController.text = widget.controller.customerName;
    widget.controller.addListener(_onControllerUpdate);
    _syncCashFromController();
    _loadQRIS(); // ✅ Load QRIS saat init
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _customerController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      final controllerVal = widget.controller.cashAmount;
      if (double.tryParse(_cashDisplay) != controllerVal) {
        _syncCashFromController();
      } else {
        setState(() {});
      }
    }
  }

  void _syncCashFromController() {
    final amount = widget.controller.cashAmount;
    _cashDisplay = amount == 0 ? '0' : amount.toStringAsFixed(0);
  }

  Future<void> _loadQRIS() async {
    try {
      setState(() => _isLoadingQRIS = true);
      
      final db = await DatabaseHelper.database;
      final result = await db.query(
        'qris_settings',
        where: 'is_active = 1',
        limit: 1,
      );

      if (result.isNotEmpty && mounted) {
        setState(() {
          _qrisModel = QrisModel.fromMap(result.first);  // ✅ QrisModel.fromMap, bukan _qrisModel.fromMap
          _isLoadingQRIS = false;
        });
      } else {
        setState(() => _isLoadingQRIS = false);
      }
    } catch (e) {
      debugPrint('Error loading QRIS: $e');
      if (mounted) {
        setState(() => _isLoadingQRIS = false);
      }
    }
  }

  /// Menangani pengetikan keypad kalkulator
  void _onKeypadPressed(
    String label, {
    bool isDelete = false,
    bool isClear = false,
    bool isZero = false,
    bool isDot = false,
  }) {
    setState(() {
      if (isClear) {
        _cashDisplay = '0';
      } else if (isDelete) {
        if (_cashDisplay.length > 1) {
          _cashDisplay = _cashDisplay.substring(0, _cashDisplay.length - 1);
          if (_cashDisplay.isEmpty || _cashDisplay == '-') {
            _cashDisplay = '0';
          }
        } else {
          _cashDisplay = '0';
        }
      } else if (isDot) {
        if (!_cashDisplay.contains('.')) {
          _cashDisplay += '.';
        }
      } else {
        if (_cashDisplay == '0') {
          if (label != '0' && label != '00') {
            _cashDisplay = label;
          }
        } else {
          _cashDisplay += label;
        }
      }

      final parsedValue = double.tryParse(_cashDisplay) ?? 0.0;
      widget.controller.setCashAmount(parsedValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // LEFT: Ringkasan Pesanan (30%)
            Expanded(
              flex: 30,
              child: _buildOrderSummary(),
            ),
            const SizedBox(width: 8),
            // RIGHT: Payment + Calculator/QRIS (70%)
            Expanded(
              flex: 70,
              child: Row(
                children: [
                  // MIDDLE: Payment Method (55%)
                  Expanded(
                    flex: 55,
                    child: _buildPaymentMethod(),
                  ),
                  const SizedBox(width: 8),
                  // RIGHT: Calculator / QRIS (45%)
                  Expanded(
                    flex: 45,
                    child: widget.controller.selectedPaymentMethod == 'cash'
                        ? _buildCalculator()
                        : _buildQRISDisplay(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ORDER SUMMARY ==========
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Expanded(
            child: widget.controller.isCartEmpty
                ? const Center(
                    child: Text(
                      'Keranjang kosong',
                      style: TextStyle(fontSize: 12, color: Color(0xFF837281)),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.controller.cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                item.itemName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A1C1F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF837281),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Rp ${(item.itemPrice * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7E0092),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              Text(
                'Rp ${widget.controller.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E0092),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== PAYMENT METHOD ==========
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption('cash', 'Tunai', Icons.money_rounded),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPaymentOption('qris', 'QRIS', Icons.qr_code_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.controller.selectedPaymentMethod == 'cash') ...[
            // ===== CASH SECTION =====
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Bayar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF514250),
                        ),
                      ),
                      Text(
                        'Rp ${widget.controller.cashAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E0092),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF514250),
                        ),
                      ),
                      Text(
                        'Rp ${widget.controller.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E0092),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF514250),
                        ),
                      ),
                      Text(
                        'Rp ${widget.controller.changeAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.controller.changeAmount >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canConfirm() ? _handleConfirmPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canConfirm()
                          ? const Color(0xFF7E0092)
                          : const Color(0xFFE2E2E7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _canConfirm() ? 'Konfirmasi & Bayar' : 'Lengkapi Pembayaran',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // ===== QRIS SECTION =====
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Total yang harus dibayar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF514250),
                        ),
                      ),
                      Text(
                        'Rp ${widget.controller.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E0092),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Instruksi untuk kasir
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_rounded, color: Color(0xFFFF9800), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tunggu customer menyelesaikan pembayaran sebelum konfirmasi',
                            style: TextStyle(fontSize: 11, color: Color(0xFFE65100)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tombol konfirmasi dengan teks yang lebih jelas
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleConfirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text(
                      'Konfirmasi Pembayaran QRIS',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, String label, IconData icon) {
    final isSelected = widget.controller.selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        widget.controller.setPaymentMethod(method);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7E0092).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7E0092)
                : const Color(0xFFE2E2E7),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF7E0092) : const Color(0xFF837281),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7E0092) : const Color(0xFF837281),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== CALCULATOR ==========
  Widget _buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E2E7),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumlah Bayar',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF514250)),
                ),
                Text(
                  'Rp $_cashDisplay',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF7E0092)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1.4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                _buildNumberButton('1'),
                _buildNumberButton('2'),
                _buildNumberButton('3'),
                _buildNumberButton('DEL', isDelete: true),
                _buildNumberButton('4'),
                _buildNumberButton('5'),
                _buildNumberButton('6'),
                _buildNumberButton('C', isClear: true),
                _buildNumberButton('7'),
                _buildNumberButton('8'),
                _buildNumberButton('9'),
                _buildNumberButton('0', isZero: true),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _buildNumberButton('00', isZero: true)),
              const SizedBox(width: 4),
              Expanded(child: _buildNumberButton('.', isDot: true)),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.controller.setCashAmount(widget.controller.total);
                  _syncCashFromController();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 1),
                ),
              ),
              child: const Text('Uang Pas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(
    String label, {
    bool isDelete = false,
    bool isClear = false,
    bool isZero = false,
    bool isDot = false,
  }) {
    return ElevatedButton(
      onPressed: () => _onKeypadPressed(
        label,
        isDelete: isDelete,
        isClear: isClear,
        isZero: isZero,
        isDot: isDot,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete || isClear
            ? Colors.red
            : (isDot
                ? const Color(0xFF7E0092).withOpacity(0.15)
                : const Color(0xFFF5F5F5)),
        foregroundColor: isDelete || isClear
            ? Colors.white
            : (isDot ? const Color(0xFF7E0092) : const Color(0xFF1A1C1F)),
        padding: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isDelete || isClear ? Colors.red : const Color(0xFFE2E2E7),
            width: 1,
          ),
        ),
        minimumSize: Size.zero,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isDelete || isClear ? 11 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ========== QRIS DISPLAY (UPGRADED) ==========
   Widget _buildQRISDisplay() {
    final hasQRIS = _qrisModel != null && _qrisModel!.hasQRISImage;
    final isComplete = _qrisModel?.isComplete ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header dengan instruksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7E0092).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF7E0092), size: 16),
                SizedBox(width: 4),
                Text(
                  'Scan QRIS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7E0092)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // QR Code Container - DIPERBESAR
          Expanded(
            child: _isLoadingQRIS
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF7E0092),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: !hasQRIS ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrisScreen()),
                      ).then((_) => _loadQRIS());
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasQRIS ? const Color(0xFF4CAF50).withOpacity(0.5) : const Color(0xFFE2E2E7),
                          width: hasQRIS ? 1.5 : 1,
                        ),
                      ),
                      child: hasQRIS
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_qrisModel!.qrisImagePath),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderQR();
                                },
                              ),
                            )
                          : _buildPlaceholderQR(),
                    ),
                  ),
          ),
          
          const SizedBox(height: 6),
          
          // Status indicator saja (tanpa teks panjang)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isComplete ? 'Siap' : 'Belum Siap',
                style: TextStyle(
                  fontSize: 9,
                  color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderQR() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 60,
            color: const Color(0xFF7E0092).withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          const Text(
            'QRIS belum diatur',
            style: TextStyle(fontSize: 11, color: Color(0xFF837281)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrisScreen()),
              ).then((_) => _loadQRIS());
            },
            child: const Text(
              'Upload di Pengaturan',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF7E0092),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ========== CONFIRMATION ==========
  bool _canConfirm() {
    if (widget.controller.isCartEmpty) return false;
    if (widget.controller.selectedPaymentMethod == 'cash') {
      return widget.controller.cashAmount >= widget.controller.total;
    }
    // QRIS: selalu bisa dikonfirmasi (kasir yang verifikasi pembayaran)
    return true;
  }

  Future<void> _handleConfirmPayment() async {
    // Untuk QRIS, bisa tambahkan dialog konfirmasi
    if (widget.controller.selectedPaymentMethod == 'qris') {
      final confirmed = await _showQRISConfirmationDialog();
      if (confirmed != true) return;
    }

    final success = await widget.controller.saveTransaction();
    if (success && mounted) {
      // ✅ JANGAN clear cart dulu, biarkan data receipt tetap ada
      // widget.controller.clearCart(); // <- HAPUS INI
      
      // ✅ Panggil onSuccess untuk pindah ke halaman sukses
      widget.onSuccess();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.error ?? 'Gagal menyimpan transaksi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Dialog konfirmasi untuk QRIS
  Future<bool?> _showQRISConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_rounded, color: Color(0xFF7E0092), size: 24),
            SizedBox(width: 8),
            Text('Konfirmasi QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pastikan customer telah menyelesaikan pembayaran:'),
            const SizedBox(height: 12),
            _buildCheckItem('Customer sudah scan QRIS'),
            _buildCheckItem('Customer sudah melakukan pembayaran'),
            _buildCheckItem('Customer menunjukkan bukti pembayaran'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Konfirmasi tanpa verifikasi dapat menyebabkan kerugian!',
                      style: TextStyle(fontSize: 11, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF837281))),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Ya, Konfirmasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF837281)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1C1F)))),
        ],
      ),
    );
  }
}