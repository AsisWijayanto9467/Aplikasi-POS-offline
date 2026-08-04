// lib/presentation/pages/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/presentation/screens/settings/categories/categories_screen.dart';
import 'package:salon_desk/presentation/screens/settings/packages/packages_screen.dart';
import 'package:salon_desk/presentation/screens/settings/printer/printer_screen.dart';
import 'package:salon_desk/presentation/screens/settings/products/products_screen.dart';
import 'package:salon_desk/presentation/screens/settings/qris/qris_screen.dart';
import 'package:salon_desk/presentation/screens/settings/salon_info/salon_info_screen.dart';
import 'package:salon_desk/presentation/screens/settings/services/services_screen.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCategoryTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Pilih Jenis Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_2_rounded, color: Color(0xFF7E0092)),
              title: const Text('Kategori Produk'),
              subtitle: const Text('Untuk manajemen produk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriesScreen(
                      type: 'product',
                      title: 'Kategori Produk',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_cut_rounded, color: Color(0xFF7E0092)),
              title: const Text('Kategori Jasa'),
              subtitle: const Text('Untuk manajemen jasa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriesScreen(
                      type: 'service',
                      title: 'Kategori Jasa',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FE),
      child: CustomScrollView(
        slivers: [
          // ========== HEADER ==========
          SliverPadding(
            padding: const EdgeInsets.only(top: 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileBanner(context),
                const SizedBox(height: 20),
              ]),
            ),
          ),
          // ========== BENTO GRID ==========
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _buildBentoCard(
                    context: context,
                    icon: Icons.category_rounded,
                    title: 'Kategori',
                    subtitle: 'Kelola kategori produk & jasa',
                    color: const Color(0xFFF8D4FE),
                    iconColor: const Color(0xFF75597C),
                    onTap: () {
                      // Tampilkan dialog pilih jenis kategori
                      _showCategoryTypeDialog(context);
                    },
                  ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Manajemen Produk',
                  subtitle: 'Stok, harga, dan kategori barang',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductsScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.content_cut_rounded,
                  title: 'Jasa',
                  subtitle: 'Layanan potong, warna, dan spa',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServicesScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.auto_awesome_motion_rounded,
                  title: 'Paket Layanan',
                  subtitle: 'Bundling perawatan spesial',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PackagesScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.storefront_rounded,
                  title: 'Info Salon',
                  subtitle: 'Jam operasional dan lokasi',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SalonInfoScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.print_rounded,
                  title: 'Printer',
                  subtitle: 'Konfigurasi struk thermal',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrinterScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  context: context,
                  icon: Icons.qr_code_2_rounded,
                  title: 'QRIS',
                  subtitle: 'Pembayaran digital & verifikasi',
                  color: const Color(0xFFF8D4FE),
                  iconColor: const Color(0xFF75597C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrisScreen()),
                    );
                  },
                ),
              ]),
            ),
          ),
          // ========== SISTEM & KEAMANAN ==========
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Sistem & Keamanan',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF514250),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
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
                    children: [
                      _buildListItem(
                        icon: Icons.lock_rounded,
                        title: 'Pengaturan Keamanan',
                        onTap: () {},
                      ),
                      _buildListItem(
                        icon: Icons.language_rounded,
                        title: 'Bahasa',
                        trailing: 'Indonesia',
                        onTap: () {},
                      ),
                      _buildListItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Pusat Bantuan',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Versi Aplikasi 2.4.0 (Build 82)',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF837281),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PROFILE BANNER ==========
  Widget _buildProfileBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF7E0092),
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
            right: -60,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF8D4FE).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STORE IDENTITY',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFCAFF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Salon Cantik',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Hair & Spa Management System',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7E0092),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== BENTO CARD ==========
  Widget _buildBentoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1F),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF514250),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ========== LIST ITEM ==========
  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
          children: [
            Icon(
              icon,
              color: const Color(0xFF514250),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1C1F),
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E0092),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD5C1D2),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}