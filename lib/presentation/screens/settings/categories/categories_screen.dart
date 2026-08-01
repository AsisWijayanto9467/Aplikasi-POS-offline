// lib/presentation/pages/settings/categories/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/category_controller.dart';
import 'package:salon_desk/data/models/category_model.dart';
import 'package:salon_desk/presentation/screens/settings/categories/category_create_screen.dart';
import 'package:salon_desk/presentation/screens/settings/categories/category_edit_screen.dart';
import 'package:salon_desk/presentation/screens/settings/categories/widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  final String type; // 'product' atau 'service'
  final String title;

  const CategoriesScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = CategoryController();
    _controller.loadCategoriesByType(widget.type);
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
        title: Text(
          widget.title,
          style: const TextStyle(
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
        builder: (_) => CategoryCreateScreen(
          controller: _controller,
          type: widget.type,
        ),
      ),
    ).then((_) => _controller.loadCategoriesByType(widget.type));
  }

  void _navigateToEdit(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryEditScreen(
          controller: _controller,
          category: category,
        ),
      ),
    ).then((_) => _controller.loadCategoriesByType(widget.type));
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Kategori'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
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
              final success = await _controller.deleteCategory(category.id!);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kategori berhasil dihapus'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                _controller.loadCategoriesByType(widget.type);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_controller.error ?? 'Gagal menghapus kategori'),
                    backgroundColor: const Color(0xFFBA1A1A),
                  ),
                );
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
          // Filtering dilakukan di _buildBody
        },
        decoration: const InputDecoration(
          hintText: 'Cari kategori...',
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

        // Filter categories berdasarkan search
        final categories = _searchQuery.isEmpty
            ? _controller.categories
            : _controller.categories
                .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        if (categories.isEmpty) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadCategoriesByType(widget.type),
          color: const Color(0xFF7E0092),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onEdit: () => _navigateToEdit(category),
                onDelete: () => _confirmDelete(category),
              );
            },
          ),
        );
      },
    );
  }

  // ========== EMPTY WIDGET ==========
  Widget _buildEmptyWidget() {
    final typeName = widget.type == 'product' ? 'Kategori Produk' : 'Kategori Jasa';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_rounded,
            size: 64,
            color: const Color(0xFF9A25AE).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada $typeName',
            style: AppTextStyles.title.copyWith(
              color: const Color(0xFF514250),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan $typeName pertama Anda',
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
            label: const Text('Tambah Kategori'),
          ),
        ],
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
              onPressed: () => _controller.loadCategoriesByType(widget.type),
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