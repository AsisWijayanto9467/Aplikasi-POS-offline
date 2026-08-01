// lib/presentation/pages/settings/services/services_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/service_controller.dart';
import 'package:salon_desk/data/models/service_model.dart';
import 'package:salon_desk/presentation/screens/settings/services/service_create_screen.dart';
import 'package:salon_desk/presentation/screens/settings/services/service_edit_screen.dart';
import 'package:salon_desk/presentation/screens/settings/services/widgets/service_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ServiceController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = ServiceController();
    _controller.loadServices();
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
          'Manajemen Jasa',
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
        builder: (_) => ServiceCreateScreen(controller: _controller),
      ),
    ).then((_) => _controller.loadServices());
  }

  void _navigateToEdit(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceEditScreen(
          controller: _controller,
          service: service,
        ),
      ),
    ).then((_) => _controller.loadServices());
  }

  void _confirmDelete(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Jasa'),
        content: Text(
          'Apakah Anda yakin ingin menghapus jasa "${service.name}"?',
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
              final success = await _controller.deleteService(service.id!);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jasa berhasil dihapus'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                _controller.loadServices();
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
            _controller.loadServices();
          } else {
            _controller.searchServices(value).then((results) {
              _controller.setSearchResults(results);
            });
          }
        },
        decoration: const InputDecoration(
          hintText: 'Cari jasa...',
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

        if (_controller.services.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildServiceList();
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
            Icons.content_cut_rounded,
            size: 64,
            color: const Color(0xFF9A25AE).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada jasa',
            style: AppTextStyles.title.copyWith(
              color: const Color(0xFF514250),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan jasa pertama Anda',
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
            label: const Text('Tambah Jasa'),
          ),
        ],
      ),
    );
  }

  // ========== SERVICE LIST ==========
  Widget _buildServiceList() {
    final services = _searchQuery.isEmpty
        ? _controller.services
        : _controller.services
            .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (services.isEmpty && _searchQuery.isNotEmpty) {
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
              'Jasa tidak ditemukan',
              style: AppTextStyles.title.copyWith(
                color: const Color(0xFF514250),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadServices(),
      color: const Color(0xFF7E0092),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceCard(
            service: service,
            onEdit: () => _navigateToEdit(service),
            onDelete: () => _confirmDelete(service),
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
              onPressed: () => _controller.loadServices(),
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