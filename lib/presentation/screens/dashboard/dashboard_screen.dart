// lib/presentation/pages/dashboard/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:salon_desk/data/controller/dashboard_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;
  bool _showLowStockAlert = true;
  
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.lowStockProducts.isEmpty) {
          _showLowStockAlert = false;
        }
        
        return Container(
          color: const Color(0xFFF9F9FE),
          child: RefreshIndicator(
            onRefresh: () => _controller.refresh(),
            color: const Color(0xFF9A25AE),
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9A25AE),
        ),
      );
    }

    if (_controller.error != null) {
      return _buildErrorWidget(_controller.error!);
    }

    return _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildGreeting(),
          const SizedBox(height: 16),
          // Low Stock Alert Banner (hanya muncul jika ada stok rendah)
          if (_showLowStockAlert && _controller.lowStockProducts.isNotEmpty)
            _buildLowStockAlertBanner(),
          if (_showLowStockAlert && _controller.lowStockProducts.isNotEmpty)
            const SizedBox(height: 16),
          _buildTodayRevenueCard(),
          const SizedBox(height: 16),
          _buildChartSection(),
          const SizedBox(height: 16),
          _buildMetricGrid(),
          const SizedBox(height: 16),
          _buildPopularServices(),
          const SizedBox(height: 16),
          // Low stock detail section hanya tampil jika ada produk low stock
          if (_controller.lowStockProducts.isNotEmpty) ...[
            _buildLowStockSection(),
            const SizedBox(height: 16),
          ],
          _buildRecentTransactions(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ========== HELPER SAFE CASTING ==========
  
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ========== GREETING ==========
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1F),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is what\'s happening today.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF514250),
            height: 1.4,
          ),
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

  // ========== LOW STOCK ALERT BANNER ==========
  Widget _buildLowStockAlertBanner() {
    final lowStockCount = _controller.lowStockProducts.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8E8E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$lowStockCount produk membutuhkan restock segera',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showLowStockAlert = false;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== TODAY'S REVENUE CARD ==========
  Widget _buildTodayRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7E0092),
            Color(0xFF9C27B0),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9A25AE).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Revenue'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _controller.formattedTodayRevenue,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _controller.todayRevenue >= _controller.yesterdayRevenue
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _controller.revenueChangeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.todayTransactions} transaksi hari ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== CHART SECTION (MIRIP REPORT) ==========
  Widget _buildChartSection() {
    final revenue = _controller.dailyRevenue;
    final chartData = revenue.map((item) => _toDouble(item['revenue'])).toList();
    final maxValue = chartData.isNotEmpty ? chartData.reduce((a, b) => a > b ? a : b) : 0.0;
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Revenue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              if (chartData.isNotEmpty && chartData.any((v) => v > 0))
                Text(
                  '7 hari terakhir',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF837281).withOpacity(0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (chartData.isNotEmpty && chartData.any((v) => v > 0))
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.grey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Rp ${NumberFormat('#,###').format(rod.toY)}',
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
                          final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                          final index = value.toInt();
                          if (index >= 0 && index < revenue.length && index < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF837281),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            'Rp ${(value ~/ 1000)}k',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF837281),
                            ),
                          );
                        },
                        reservedSize: 35,
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
                    horizontalInterval: maxY > 0 ? maxY / 4 : 25000,
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
                  barGroups: chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    final isHighest = value == maxValue && value > 0;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: isHighest 
                              ? const Color(0xFF7E0092) 
                              : const Color(0xFF9A25AE).withOpacity(0.6),
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
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFFD5C1D2),
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada data transaksi\nminggu ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF514250),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== METRIC GRID ==========
  Widget _buildMetricGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.content_cut_rounded,
            iconBackgroundColor: const Color(0xFFF8D4FE),
            iconColor: const Color(0xFF75597C),
            title: 'Total Services',
            value: '${_controller.popularServices.length}',
            valueColor: const Color(0xFF7E0092),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.receipt_long_rounded,
            iconBackgroundColor: const Color(0xFFECDEED),
            iconColor: const Color(0xFF4D4450),
            title: 'Total Transaksi',
            value: '${_controller.todayTransactions}',
            valueColor: const Color(0xFF715478),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8D4FE).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9A25AE).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF514250),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ========== POPULAR SERVICES ==========
  Widget _buildPopularServices() {
    final services = _controller.popularServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1F),
          ),
        ),
        const SizedBox(height: 12),
        if (services.isNotEmpty)
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                final iconMap = {
                  'Creambath': Icons.spa_rounded,
                  'Hair Spa': Icons.spa_rounded,
                  'Potong Pria': Icons.content_cut_rounded,
                  'Potong Wanita': Icons.content_cut_rounded,
                  'Blow Dry': Icons.air_rounded,
                  'Coloring': Icons.colorize_rounded,
                  'Smoothing': Icons.straighten_rounded,
                };
                final icon = iconMap[service['item_name']] ?? Icons.spa_rounded;
                final count = _toInt(service['count']);
                final revenue = _toDouble(service['total_revenue']);
                
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF8D4FE).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9A25AE).withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8D4FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: const Color(0xFF7E0092),
                              size: 18,
                            ),
                          ),
                          if (index == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E0092),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Top',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service['item_name'] as String? ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count bookings',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF514250),
                        ),
                      ),
                      Text(
                        _currencyFormat.format(revenue),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E0092),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF8D4FE).withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.spa_rounded,
                    color: Color(0xFFD5C1D2),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada data layanan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF514250),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ========== LOW STOCK SECTION (DETAIL) ==========
  Widget _buildLowStockSection() {
    final products = _controller.lowStockProducts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBA1A1A).withOpacity(0.1),
        ),
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
                  color: const Color(0xFFBA1A1A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFFBA1A1A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Detail Low Stock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBA1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${products.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBA1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: products.map((product) {
              final name = product['name'] as String? ?? 'Unknown Product';
              final stock = _toInt(product['stock']);
              final minStock = _toInt(product['min_stock']);
              final stockPercentage = minStock > 0 ? (stock / minStock) : 0.0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E2E7).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8D4FE).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: Color(0xFF7E0092),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1C1F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stock == 0
                                          ? const Color(0xFFBA1A1A).withOpacity(0.1)
                                          : const Color(0xFFFF9800).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Stok: $stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: stock == 0
                                            ? const Color(0xFFBA1A1A)
                                            : const Color(0xFFFF9800),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Min: $minStock',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF837281),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stock == 0
                                ? const Color(0xFFBA1A1A)
                                : const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            stock == 0 ? 'Habis' : 'Restock',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stockPercentage.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFE2E2E7),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          stock == 0
                              ? const Color(0xFFBA1A1A)
                              : stockPercentage < 0.5
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFF4CAF50),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ========== RECENT TRANSACTIONS ==========
  Widget _buildRecentTransactions() {
    final transactions = _controller.recentTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1F),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to history screen
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7E0092),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF8D4FE).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9A25AE).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFFD5C1D2),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF514250),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9A25AE).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final isLast = index == transactions.length - 1;
                
                final invoiceNumber = transaction['invoice_number'] as String? ?? '-';
                final paymentMethod = transaction['payment_method'] as String? ?? 'Cash';
                final grandTotal = _toDouble(transaction['grand_total']);
                final itemCount = _toInt(transaction['item_count']);
                final status = transaction['status'] as String? ?? 'pending';
                
                String timeDisplay = '--:--';
                final transactionDate = transaction['transaction_date'] as String?;
                if (transactionDate != null) {
                  try {
                    final date = DateTime.parse(transactionDate);
                    timeDisplay = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  } catch (e) {}
                }
                
                final isQRIS = paymentMethod.toLowerCase() == 'qris';
                final paymentIcon = isQRIS ? Icons.qr_code_rounded : Icons.payments_rounded;
                final paymentColor = isQRIS ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
                
                final statusColor = status == 'completed' 
                    ? const Color(0xFF4CAF50) 
                    : status == 'refunded'
                        ? const Color(0xFFBA1A1A)
                        : const Color(0xFFFF9800);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: Color(0xFFE2E2E7),
                              width: 0.5,
                            ),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: paymentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              paymentIcon,
                              color: paymentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    invoiceNumber,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1C1F),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$timeDisplay • $paymentMethod • $itemCount item${itemCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF837281),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        _currencyFormat.format(grandTotal),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1F),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ========== ERROR WIDGET ==========
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFBA1A1A).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFBA1A1A),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF514250),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _controller.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E0092),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF7E0092).withOpacity(0.3),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}