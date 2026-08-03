// lib/presentation/pages/main_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'report/report_screen.dart';
import 'settings/settings_screen.dart';
import 'transaction/transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(key: ValueKey('dashboard')),
    const HistoryScreen(key: ValueKey('history')),
    const TransactionScreen(key: ValueKey('transaction')),
    const ReportScreen(key: ValueKey('report')),
    const SettingsScreen(key: ValueKey('settings')),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Riwayat',
    'Transaksi',
    'Laporan',
    'Pengaturan',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Tambahkan observer untuk lifecycle
    WidgetsBinding.instance.addObserver(this);
    
    // ✅ Set orientasi portrait saat pertama kali masuk MainScreen
    // Gunakan post-frame callback untuk memastikan sudah build dulu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lockPortrait();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Kembalikan ke portrait saat keluar
    _lockPortrait();
    super.dispose();
  }

  // ✅ Handle app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Saat aplikasi resume, pastikan orientasi sesuai tab
      if (_currentIndex == 2) {
        _unlockOrientation();
      } else {
        _lockPortrait();
      }
    }
  }

  void _lockPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _unlockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _onTabChanged(int index) {
    // ✅ KALAU SUDAH DI TAB YANG SAMA, JANGAN UBAH ORIENTASI
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // ✅ Hanya izinkan landscape untuk halaman Transaction (index 2)
    if (index == 2) {
      _unlockOrientation();
    } else {
      _lockPortrait();
    }
  }

  void _navigateToTransaction() {
    // ✅ Izinkan semua orientasi saat buka Transaction
    _unlockOrientation();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionScreen()),
    ).then((_) {
      if (!mounted) return;
      
      // ✅ Kembalikan ke orientasi sesuai halaman saat ini
      if (_currentIndex == 2) {
        _unlockOrientation();
      } else {
        _lockPortrait();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _buildHeader(),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.spa_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[_currentIndex],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1F),
                    ),
                  ),
                  Text(
                    'Salon Cantik',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
                hasBadge: true,
              ),
              const SizedBox(width: 8),
              _buildProfilePicture(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.04),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 22,
            ),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA1A1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          image: const DecorationImage(
            image: NetworkImage(
              'https://ui-avatars.com/api/?name=Salon+Cantik&background=9C27B0&color=fff&size=40',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardBackground.withOpacity(0.0),
            AppColors.cardBackground.withOpacity(0.95),
            AppColors.cardBackground,
          ],
          stops: const [0.0, 0.1, 0.3],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: AppColors.cardBackground.withOpacity(0.7),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
                    _buildNavItem(Icons.receipt_long_rounded, 'Riwayat', 1),
                    _buildCenterButton(),
                    _buildNavItem(Icons.analytics_rounded, 'Laporan', 3),
                    _buildNavItem(Icons.more_horiz_rounded, 'Lainnya', 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.navInactive,
              size: isActive ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.navInactive,
              ),
            ),
            if (isActive)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: _navigateToTransaction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Transaksi',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7E0092),
            ),
          ),
        ],
      ),
    );
  }
}