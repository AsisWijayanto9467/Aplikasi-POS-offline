// lib/presentation/pages/settings/products/products_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/product_controller.dart';
import 'package:salon_desk/data/models/product_model.dart';
import 'package:salon_desk/presentation/screens/settings/products/product_create_screen.dart';
import 'package:salon_desk/presentation/screens/settings/products/product_edit_screen.dart';
import 'package:salon_desk/presentation/screens/settings/products/widgets/product_cart.dart';
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = ProductController();
    _controller.loadProducts();
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
          'Manajemen Produk',
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
        builder: (_) => ProductCreateScreen(controller: _controller),
      ),
    ).then((_) => _controller.loadProducts());
  }

  void _navigateToEdit(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditScreen(
          controller: _controller,
          product: product,
        ),
      ),
    ).then((_) => _controller.loadProducts());
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Produk'),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${product.name}"?',
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
              final success = await _controller.deleteProduct(product.id!);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                _controller.loadProducts();
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
            _controller.loadProducts();
          } else {
            _controller.searchProducts(value).then((results) {
              _controller.setSearchResults(results);
            });
          }
        },
        decoration: const InputDecoration(
          hintText: 'Cari produk...',
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

        if (_controller.products.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildProductList();
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
            Icons.inventory_2_rounded,
            size: 64,
            color: const Color(0xFF9A25AE).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada produk',
            style: AppTextStyles.title.copyWith(
              color: const Color(0xFF514250),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk pertama Anda',
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
            label: const Text('Tambah Produk'),
          ),
        ],
      ),
    );
  }

  // ========== PRODUCT LIST ==========
  Widget _buildProductList() {
    final products = _searchQuery.isEmpty
        ? _controller.products
        : _controller.products
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (products.isEmpty && _searchQuery.isNotEmpty) {
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
              'Produk tidak ditemukan',
              style: AppTextStyles.title.copyWith(
                color: const Color(0xFF514250),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadProducts(),
      color: const Color(0xFF7E0092),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onEdit: () => _navigateToEdit(product),
            onDelete: () => _confirmDelete(product),
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
              onPressed: () => _controller.loadProducts(),
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