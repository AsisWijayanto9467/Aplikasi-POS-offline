// lib/presentation/pages/report/report_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:salon_desk/core/theme/app_colors.dart';
import 'package:salon_desk/data/controller/report_controller.dart';
import 'package:salon_desk/data/services/export_service.dart'; // ✅ Import ExportService

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late ReportController _controller;
  String _selectedPeriod = 'Week';
  bool _isLoading = false;
  final ExportService _exportService = ExportService(); // ✅ Export Service

  @override
  void initState() {
    super.initState();
    _controller = ReportController();
    _controller.addListener(_onControllerUpdate);
    _loadData();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadReportData();
    setState(() => _isLoading = false);
  }

  // ========== EXPORT METHODS ==========
  Future<void> _exportToExcel() async {
    try {
      _showLoadingDialog();
      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
      final reportData = _controller.getReportDataForExport(_selectedPeriod);

      final filePath = await _exportService.exportToExcel(
        reportData: reportData,
        fileName: 'Laporan_Salon_$dateStr',
      );

      if (mounted) Navigator.pop(context);
      if (filePath != null && mounted) {
        _showSuccessSnackBar('File Excel berhasil dibuat!');
      } else if (mounted) {
        _showErrorSnackBar('Gagal membuat file Excel');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _exportToPDF() async {
    try {
      _showLoadingDialog();
      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
      final reportData = _controller.getReportDataForExport(_selectedPeriod);

      final filePath = await _exportService.exportToPDF(
        reportData: reportData,
        fileName: 'Laporan_Salon_$dateStr',
      );

      if (mounted) Navigator.pop(context);
      if (filePath != null && mounted) {
        _showSuccessSnackBar('File PDF berhasil dibuat!');
      } else if (mounted) {
        _showErrorSnackBar('Gagal membuat file PDF');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Export Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1F))),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart_rounded, color: Color(0xFF4CAF50), size: 28),
                ),
                title: const Text('Export ke Excel (.xlsx)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Format spreadsheet untuk analisis data'),
                onTap: () { Navigator.pop(context); _exportToExcel(); },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA1A1A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFBA1A1A), size: 28),
                ),
                title: const Text('Export ke PDF (.pdf)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Format dokumen untuk cetak & share'),
                onTap: () { Navigator.pop(context); _exportToPDF(); },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF7E0092)),
                SizedBox(height: 16),
                Text('Membuat file...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ]),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7E0092)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF7E0092),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildMetricCards(),
                    const SizedBox(height: 16),
                    _buildChartSection(),
                    const SizedBox(height: 16),
                    _buildTopProducts(),
                    const SizedBox(height: 16),
                    _buildTopServices(),
                    const SizedBox(height: 16),
                    _buildTopPackages(),
                  ],
                ),
              ),
            ),
    );
  }

  // ========== HEADER WITH EXPORT BUTTON ==========
  Widget _buildHeader() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Performa penjualan untuk $monthName',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF837281))),
              if (_controller.lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Terakhir diperbarui: ${DateFormat('HH:mm:ss').format(_controller.lastUpdated!)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF837281)),
                  ),
                ),
            ],
          ),
        ),
        // ✅ Tombol Export
        IconButton(
          onPressed: _showExportOptions,
          icon: const Icon(Icons.download_rounded, color: Color(0xFF7E0092)),
          tooltip: 'Export Laporan',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF7E0092).withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // ========== METRIC CARDS (TIDAK BERUBAH) ==========
  Widget _buildMetricCards() {
    return Column(
      children: [
        _buildMetricCard(title: 'Total Penjualan', value: 'Rp ${_controller.totalSales.toStringAsFixed(0)}', change: '${_controller.salesChange.toStringAsFixed(1)}%', isPositive: _controller.salesChange >= 0, icon: Icons.payments_rounded, color: const Color(0xFF7E0092)),
        const SizedBox(height: 8),
        _buildMetricCard(title: 'Total Transaksi', value: '${_controller.totalOrders}', change: '${_controller.ordersChange.toStringAsFixed(1)}%', isPositive: _controller.ordersChange >= 0, icon: Icons.shopping_cart_rounded, color: const Color(0xFF1976D2)),
        const SizedBox(height: 8),
        _buildMetricCard(title: 'Rata-rata Transaksi', value: 'Rp ${_controller.averageBasket.toStringAsFixed(0)}', change: '${_controller.basketChange.toStringAsFixed(1)}%', isPositive: _controller.basketChange >= 0, icon: Icons.analytics_rounded, color: const Color(0xFF388E3C)),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required String change, required bool isPositive, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E2E7)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF837281))),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1F)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(children: [
            Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isPositive ? const Color(0xFF2E7D32) : const Color(0xFFBA1A1A), size: 14),
            const SizedBox(width: 2),
            Text(change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isPositive ? const Color(0xFF2E7D32) : const Color(0xFFBA1A1A))),
            const SizedBox(width: 4),
            const Text('vs bulan lalu', style: TextStyle(fontSize: 10, color: Color(0xFF837281))),
          ]),
        ])),
      ]),
    );
  }

  // ========== CHART (TIDAK BERUBAH) ==========
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E2E7)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Performa Pendapatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1F))),
          _buildPeriodToggle(),
        ]),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: _getChartWidth(), child: _buildBarChart()))),
      ]),
    );
  }

  double _getChartWidth() {
    final data = _controller.chartData;
    if (data.isEmpty) return 300;
    if (_selectedPeriod == 'Week') return 350;
    if (_selectedPeriod == 'Month') return data.length * 30;
    return data.length * 40;
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E2E7))),
      child: Row(children: ['Week', 'Month', 'Year'].map((period) {
        final isSelected = _selectedPeriod == period;
        return GestureDetector(
          onTap: () { setState(() => _selectedPeriod = period); _controller.loadChartData(period); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))] : null),
            child: Text(period, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF7E0092) : const Color(0xFF514250))),
          ),
        );
      }).toList()),
    );
  }

  Widget _buildBarChart() {
    final data = _controller.chartData;
    if (data.isEmpty) return const Center(child: Text('Tidak ada data', style: TextStyle(fontSize: 13, color: Color(0xFF837281))));
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround, maxY: maxY.toDouble(),
      barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) => Colors.grey.shade800, getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('Rp ${rod.toY.toStringAsFixed(0)}', const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)))),
      titlesData: FlTitlesData(show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { final labels = _getChartLabels(); final index = value.toInt(); if (index >= 0 && index < labels.length) return Text(labels[index], style: const TextStyle(fontSize: 10, color: Color(0xFF837281))); return const SizedBox.shrink(); }, reservedSize: 30)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { if (value == 0) return const SizedBox.shrink(); return Text('Rp ${(value ~/ 1000)}k', style: const TextStyle(fontSize: 9, color: Color(0xFF837281))); }, reservedSize: 30)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, horizontalInterval: maxY / 4, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFFE2E2E7), strokeWidth: 1, dashArray: [4, 4])),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((entry) { final value = entry.value; return BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: value, color: value == maxValue ? const Color(0xFF7E0092) : const Color(0xFF9A25AE).withOpacity(0.6), width: 24, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]); }).toList(),
    ));
  }

  List<String> _getChartLabels() {
    if (_selectedPeriod == 'Week') return ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    if (_selectedPeriod == 'Month') return List.generate(_controller.chartData.length, (i) => '${i + 1}');
    return ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  }

  // ========== TOP SECTIONS (TIDAK BERUBAH) ==========
  Widget _buildTopProducts() => _buildTopSection(title: 'Produk Terlaris', icon: Icons.inventory_2_rounded, items: _controller.topProducts.where((p) => p['type'] == 'product').toList(), color: Colors.blue);
  Widget _buildTopServices() => _buildTopSection(title: 'Layanan Terlaris', icon: Icons.build_rounded, items: _controller.topProducts.where((p) => p['type'] == 'service').toList(), color: Colors.green);
  Widget _buildTopPackages() => _buildTopSection(title: 'Paket Terlaris', icon: Icons.auto_awesome_motion_rounded, items: _controller.topProducts.where((p) => p['type'] == 'package').toList(), color: Colors.orange);

  Widget _buildTopSection({required String title, required IconData icon, required List<Map<String, dynamic>> items, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E2E7)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const Spacer(), Text('${items.length} item', style: const TextStyle(fontSize: 11, color: Color(0xFF837281)))]),
        const SizedBox(height: 12),
        if (items.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada data', style: TextStyle(fontSize: 13, color: Color(0xFF837281)))))
        else ...items.map((item) => _buildTopItem(item, color)),
      ]),
    );
  }

  Widget _buildTopItem(Map<String, dynamic> item, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFFE2E2E7).withOpacity(0.5)))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image_rounded, color: color.withOpacity(0.5), size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), Text(item['category'] ?? 'Kategori', style: const TextStyle(fontSize: 11, color: Color(0xFF837281)))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${item['units'] ?? 0} Unit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), Text('Rp ${(item['revenue'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2E7D32)))]),
      ]),
    );
  }
}