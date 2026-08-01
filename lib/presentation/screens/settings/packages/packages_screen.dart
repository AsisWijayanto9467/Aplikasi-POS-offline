// lib/presentation/pages/settings/packages/packages_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/package_controller.dart';
import 'package:salon_desk/data/models/package_model.dart';
import 'package:salon_desk/presentation/screens/settings/packages/package_create_screen.dart';
import 'package:salon_desk/presentation/screens/settings/packages/package_edit_screen.dart';
import 'package:salon_desk/presentation/screens/settings/packages/widgets/package_card.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late final PackageController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = PackageController();
    _controller.loadPackages();
  }

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
          'Paket Layanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF7E0092)),
            onPressed: () => _navigateToCreate(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageCreateScreen(controller: _controller),
      ),
    ).then((_) => _controller.loadPackages());
  }

  void _navigateToEdit(PackageModel package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageEditScreen(
          controller: _controller,
          package: package,
        ),
      ),
    ).then((_) => _controller.loadPackages());
  }

  void _confirmDelete(PackageModel package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Paket'),
        content: Text(
          'Apakah Anda yakin ingin menghapus paket "${package.name}"?',
          style: const TextStyle(color: Color(0xFF514250)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF514250)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _controller.deletePackage(package.id!);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paket berhasil dihapus'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                _controller.loadPackages();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ========== SEARCH BAR ==========
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          if (value.isEmpty) {
            _controller.loadPackages();
          } else {
            _controller.searchPackages(value).then((results) {
              _controller.setSearchResults(results);
            });
          }
        },
        decoration: const InputDecoration(
          hintText: 'Cari paket...',
          hintStyle: TextStyle(color: Color(0xFF837281)),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF837281)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ========== BODY ==========
  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7E0092),
            ),
          );
        }

        if (_controller.error != null) {
          return _buildErrorWidget(_controller.error!);
        }

        if (_controller.packages.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildPackageList();
      },
    );
  }

  // ========== EMPTY WIDGET ==========
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 64,
            color: const Color(0xFF9A25AE).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada paket',
            style: AppTextStyles.title.copyWith(
              color: const Color(0xFF514250),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat paket layanan pertama Anda',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF837281),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E0092),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Buat Paket'),
          ),
        ],
      ),
    );
  }

  // ========== PACKAGE LIST ==========
  Widget _buildPackageList() {
    final packages = _searchQuery.isEmpty
        ? _controller.packages
        : _controller.packages
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (packages.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFF837281).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Paket tidak ditemukan',
              style: AppTextStyles.title.copyWith(
                color: const Color(0xFF514250),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadPackages(),
      color: const Color(0xFF7E0092),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return PackageCard(
            package: package,
            onEdit: () => _navigateToEdit(package),
            onDelete: () => _confirmDelete(package),
          );
        },
      ),
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
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: const Color(0xFFBA1A1A).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: AppTextStyles.title.copyWith(
                color: const Color(0xFF514250),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF837281),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _controller.loadPackages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E0092),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}