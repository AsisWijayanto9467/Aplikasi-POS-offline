// lib/presentation/pages/report/report_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:salon_desk/core/theme/app_colors.dart';
import 'package:salon_desk/data/controller/report_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late ReportController _controller;
  String _selectedPeriod = 'Week';
  bool _isLoading = false;

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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadReportData();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7E0092)),
            )
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

  Widget _buildHeader() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Performa penjualan untuk $monthName',
          style: TextStyle(fontSize: 13, color: const Color(0xFF837281)),
        ),
        if (_controller.lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Terakhir diperbarui: ${DateFormat('HH:mm:ss').format(_controller.lastUpdated!)}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF837281),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricCards() {
    return Column(
      children: [
        _buildMetricCard(
          title: 'Total Penjualan',
          value: 'Rp ${_controller.totalSales.toStringAsFixed(0)}',
          change: '${_controller.salesChange.toStringAsFixed(1)}%',
          isPositive: _controller.salesChange >= 0,
          icon: Icons.payments_rounded,
          color: const Color(0xFF7E0092),
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          title: 'Total Transaksi',
          value: '${_controller.totalOrders}',
          change: '${_controller.ordersChange.toStringAsFixed(1)}%',
          isPositive: _controller.ordersChange >= 0,
          icon: Icons.shopping_cart_rounded,
          color: const Color(0xFF1976D2),
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          title: 'Rata-rata Transaksi',
          value: 'Rp ${_controller.averageBasket.toStringAsFixed(0)}',
          change: '${_controller.basketChange.toStringAsFixed(1)}%',
          isPositive: _controller.basketChange >= 0,
          icon: Icons.analytics_rounded,
          color: const Color(0xFF388E3C),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF837281),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isPositive ? const Color(0xFF2E7D32) : const Color(0xFFBA1A1A),
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isPositive ? const Color(0xFF2E7D32) : const Color(0xFFBA1A1A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'vs bulan lalu',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF837281),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performa Pendapatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              _buildPeriodToggle(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: _getChartWidth(), child: _buildBarChart()),
            ),
          ),
        ],
      ),
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
    final periods = ['Week', 'Month', 'Year'];

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
              _controller.loadChartData(period);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF7E0092) : const Color(0xFF514250),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart() {
    final data = _controller.chartData;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data',
          style: TextStyle(fontSize: 13, color: Color(0xFF837281)),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Rp ${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = _getChartLabels();
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF837281),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  'Rp ${(value ~/ 1000)}k',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF837281)),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 4,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E2E7),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final isHighest = value == maxValue;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: isHighest ? const Color(0xFF7E0092) : const Color(0xFF9A25AE).withOpacity(0.6),
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<String> _getChartLabels() {
    if (_selectedPeriod == 'Week') {
      return ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    }
    if (_selectedPeriod == 'Month') {
      final days = _controller.chartData.length;
      return List.generate(days, (index) => '${index + 1}');
    }
    return [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
  }

  // ========== TOP PRODUCTS ==========
  Widget _buildTopProducts() {
    final products = _controller.topProducts.where((p) => p['type'] == 'product').toList();
    return _buildTopSection(
      title: 'Produk Terlaris',
      icon: Icons.inventory_2_rounded,
      items: products,
      color: Colors.blue,
    );
  }

  // ========== TOP SERVICES ==========
  Widget _buildTopServices() {
    final services = _controller.topProducts.where((p) => p['type'] == 'service').toList();
    return _buildTopSection(
      title: 'Layanan Terlaris',
      icon: Icons.build_rounded,
      items: services,
      color: Colors.green,
    );
  }

  // ========== TOP PACKAGES ==========
  Widget _buildTopPackages() {
    final packages = _controller.topProducts.where((p) => p['type'] == 'package').toList();
    return _buildTopSection(
      title: 'Paket Terlaris',
      icon: Icons.auto_awesome_motion_rounded,
      items: packages,
      color: Colors.orange,
    );
  }

  Widget _buildTopSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} item',
                style: const TextStyle(fontSize: 11, color: Color(0xFF837281)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada data',
                  style: TextStyle(fontSize: 13, color: Color(0xFF837281)),
                ),
              ),
            )
          else
            ...items.map((item) => _buildTopItem(item, color)),
        ],
      ),
    );
  }

  Widget _buildTopItem(Map<String, dynamic> item, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E2E7).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_rounded,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['category'] ?? 'Kategori',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF837281),
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['units'] ?? 0} Unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              Text(
                'Rp ${(item['revenue'] ?? 0).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}