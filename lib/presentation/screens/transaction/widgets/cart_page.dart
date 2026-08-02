// lib/presentation/pages/transaction/widgets/cart_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/controller/transaction_controller.dart';
import 'package:salon_desk/data/models/product_model.dart';
import 'package:salon_desk/data/models/service_model.dart';
import 'package:salon_desk/data/models/package_model.dart';
import 'package:salon_desk/data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  final TransactionController controller;
  final VoidCallback onNext;

  const CartPage({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LEFT: Daftar Item (50%)
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFF9F9FE),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildCategoryTabs(),
                const SizedBox(height: 8),
                Expanded(child: _buildItemsList()),
              ],
            ),
          ),
        ),
        // RIGHT: Keranjang (50%)
        Expanded(
          flex: 5,
          child: _buildCart(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Cari produk, jasa, atau paket...',
          hintStyle: TextStyle(color: Color(0xFF837281), fontSize: 12),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF837281), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final tabs = [
      {'label': 'Semua', 'value': 'all'},
      {'label': 'Produk', 'value': 'product'},
      {'label': 'Jasa', 'value': 'service'},
      {'label': 'Paket', 'value': 'package'},
    ];

    return Row(
      children: tabs.map((tab) {
        final isSelected = _selectedTab == tab['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTab = tab['value']!;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF7E0092) : Colors.white,
                foregroundColor: isSelected ? Colors.white : const Color(0xFF514250),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF7E0092) : const Color(0xFFE2E2E7),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                tab['label']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemsList() {
    final items = widget.controller.searchItems(_searchQuery);
    
    final filteredItems = items.where((item) {
      if (_selectedTab == 'all') return true;
      if (_selectedTab == 'product') return item is ProductModel;
      if (_selectedTab == 'service') return item is ServiceModel;
      if (_selectedTab == 'package') return item is PackageModel;
      return false;
    }).toList();
    
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, size: 40, 
                color: const Color(0xFF837281).withOpacity(0.3)),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isEmpty ? 'Belum ada item' : 'Item tidak ditemukan',
              style: const TextStyle(fontSize: 12, color: Color(0xFF837281)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        
        if (item is ProductModel) {
          return _buildItemCard(
            name: item.name,
            price: item.sellingPrice,
            id: item.id ?? 0,
            type: 'product',
            imagePath: item.imagePath,
          );
        } else if (item is ServiceModel) {
          return _buildItemCard(
            name: item.name,
            price: item.price,
            id: item.id ?? 0,
            type: 'service',
            imagePath: item.imagePath,
          );
        } else if (item is PackageModel) {
          return _buildItemCard(
            name: item.name,
            price: item.packagePrice,
            id: item.id ?? 0,
            type: 'package',
            imagePath: item.imagePath,
            normalPrice: item.normalPrice,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ✅ Perbaiki: Gunakan Image.file untuk gambar lokal
  Widget _buildImageWidget(String? imagePath, String type) {
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(type),
          ),
        );
      }
    }
    return _buildPlaceholder(type);
  }

  Widget _buildPlaceholder(String type) {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFFF5F5F5),
      child: Icon(
        type == 'product' ? Icons.inventory_2_rounded :
        type == 'service' ? Icons.build_rounded :
        Icons.auto_awesome_motion_rounded,
        color: const Color(0xFF837281).withOpacity(0.3),
        size: 24,
      ),
    );
  }

  Widget _buildItemCard({
    required String name,
    required double price,
    required int id,
    required String type,
    String? imagePath,
    double? normalPrice,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // ✅ Gambar lokal
          _buildImageWidget(imagePath, type),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: type == 'product' ? Colors.blue.withOpacity(0.1) :
                               type == 'service' ? Colors.green.withOpacity(0.1) :
                               Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        type == 'product' ? 'Produk' : type == 'service' ? 'Jasa' : 'Paket',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: type == 'product' ? Colors.blue :
                                 type == 'service' ? Colors.green :
                                 Colors.orange,
                        ),
                      ),
                    ),
                    if (normalPrice != null && normalPrice > price)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('Hemat!', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(name, 
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1F)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Text('Rp ${price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7E0092))),
                    if (normalPrice != null && normalPrice > price) ...[
                      const SizedBox(width: 6),
                      Text('Rp ${normalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF837281), decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                        child: Text('${((normalPrice - price) / normalPrice * 100).toStringAsFixed(0)}% OFF',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.green)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final cartItem = CartItemModel(
                itemType: type,
                itemId: id,
                itemName: name,
                itemPrice: price,
                quantity: 1,
                imagePath: imagePath,
                normalPrice: normalPrice,
              );
              widget.controller.addToCart(cartItem);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name ditambahkan', style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFF7E0092),
                  duration: const Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E0092),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14),
                SizedBox(width: 2),
                Text('Tambah', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CART SECTION ==========
  Widget _buildCart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E2E7)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Keranjang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1F))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF7E0092).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '${widget.controller.cartItemCount} item',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7E0092)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.controller.isCartEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 50, color: const Color(0xFF837281).withOpacity(0.3)),
                        const SizedBox(height: 8),
                        const Text('Keranjang Kosong', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF514250))),
                        const SizedBox(height: 4),
                        Text('Tambahkan item dari daftar di kiri',
                            style: TextStyle(fontSize: 11, color: const Color(0xFF837281).withOpacity(0.5))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(6),
                    itemCount: widget.controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.controller.cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE2E2E7)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1F))),
                    Text(
                      'Rp ${widget.controller.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF7E0092)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.controller.isCartEmpty ? null : widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.controller.isCartEmpty ? const Color(0xFFE2E2E7) : const Color(0xFF7E0092),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      widget.controller.isCartEmpty ? 'Keranjang Kosong' : 'Lanjutkan ke Pembayaran',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Perbaiki: Gambar di keranjang dengan Image.file
  Widget _buildCartImageWidget(String? imagePath, String type) {
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildCartPlaceholder(type),
          ),
        );
      }
    }
    return _buildCartPlaceholder(type);
  }

  Widget _buildCartPlaceholder(String type) {
    return Container(
      width: 32,
      height: 32,
      color: const Color(0xFFF5F5F5),
      child: Icon(
        type == 'product' ? Icons.inventory_2_rounded :
        type == 'service' ? Icons.build_rounded :
        Icons.auto_awesome_motion_rounded,
        color: const Color(0xFF837281).withOpacity(0.3),
        size: 16,
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E2E7).withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          _buildCartImageWidget(item.imagePath, item.itemType),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1F)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Rp ${item.itemPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7E0092))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF7E0092), size: 18),
                onPressed: () => widget.controller.updateQuantity(index, item.quantity - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                width: 24,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1F)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF7E0092), size: 18),
                onPressed: () => widget.controller.updateQuantity(index, item.quantity + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFBA1A1A)),
                onPressed: () => widget.controller.removeFromCart(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}