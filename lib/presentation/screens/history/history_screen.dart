// lib/presentation/pages/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_colors.dart';
import 'package:salon_desk/data/controller/history_controller.dart';
import 'package:salon_desk/data/models/transaction_model.dart';
import 'package:salon_desk/presentation/screens/settings/printer/printer_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryController _controller;
  String _selectedFilter = 'All Time';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadTransactions();
    setState(() => _isLoading = false);
  }

  Future<void> _printReceipt(TransactionModel transaction) async {
    // Siapkan data struk
    final receiptData = {
      'header': 'SALON CANTIK',
      'items': transaction.items?.map((item) => {
        'name': item.itemName,
        'qty': item.quantity,
        'price': item.itemPrice,
        'subtotal': item.subtotal,
      }).toList() ?? [],
      'total': transaction.grandTotal,
      'footer': 'Terima kasih telah berkunjung',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrinterScreen(
          receiptData: receiptData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7E0092),
              ),
            )
          : Column(
              children: [
                // Header Section
                _buildHeader(),
                
                // Filter Chips
                _buildFilterChips(),
                
                // Transaction List
                Expanded(
                  child: _buildTransactionList(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Lihat dan kelola transaksi sebelumnya',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF837281),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Time', 'Today', 'This Week', 'Completed', 'Refunded'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return FilterChip(
            label: Text(
              filter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF514250),
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
              _controller.filterTransactions(filter);
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF7E0092),
            side: BorderSide(
              color: isSelected ? const Color(0xFF7E0092) : const Color(0xFFE2E2E7),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = _controller.filteredTransactions;
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: const Color(0xFF837281).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF514250),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF837281),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF7E0092),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isRefunded = transaction.status == 'refunded';
    final isPaid = transaction.status == 'completed';
    final statusColor = isRefunded 
        ? const Color(0xFFBA1A1A) 
        : isPaid 
            ? const Color(0xFF2E7D32) 
            : const Color(0xFFF57F17);
    final statusLabel = isRefunded 
        ? 'Dibatalkan' 
        : isPaid 
            ? 'Lunas' 
            : 'Pending';
    
    // Format date
    String dateDisplay = 'Tanggal tidak tersedia';
    if (transaction.transactionDate != null) {
      try {
        final date = DateTime.parse(transaction.transactionDate!);
        dateDisplay = '${date.day} ${_getMonthName(date.month)} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        dateDisplay = transaction.transactionDate!;
      }
    }

    // Get item count
    final itemCount = transaction.items?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
        ),
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
          // Row 1: Icon + Info + Status
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRefunded 
                      ? const Color(0xFFFFEBEE) 
                      : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isRefunded 
                      ? Icons.history_rounded
                      : itemCount > 3 
                          ? Icons.shopping_bag_rounded
                          : Icons.receipt_long_rounded,
                  color: isRefunded 
                      ? const Color(0xFFBA1A1A)
                      : const Color(0xFF7E0092),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction.invoiceNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1C1F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF837281),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${itemCount} item dalam transaksi',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF837281),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Row 2: Total Amount + Print Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF837281),
                    ),
                  ),
                  Text(
                    'Rp ${transaction.grandTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isRefunded 
                          ? const Color(0xFFBA1A1A) 
                          : const Color(0xFF1A1C1F),
                    ),
                  ),
                ],
              ),
              
              // Print Button
              OutlinedButton.icon(
                onPressed: () => _printReceipt(transaction),
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text(
                  'Cetak Struk',
                  style: TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF514250),
                  side: const BorderSide(color: Color(0xFFE2E2E7)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}