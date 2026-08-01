// lib/presentation/pages/settings/products/widgets/product_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock <= product.minStock;
    final profit = product.sellingPrice - product.purchasePrice;
    final profitPercentage = product.purchasePrice > 0 
        ? (profit / product.purchasePrice) * 100 
        : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: isLowStock
            ? Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          // Product Image or Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8D4FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<bool>(
                      future: File(product.imagePath).exists(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Image.file(
                            File(product.imagePath),
                            fit: BoxFit.cover,
                          );
                        }
                        return const Icon(
                          Icons.broken_image_rounded,
                          color: Color(0xFF75597C),
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF75597C),
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.categoryName ?? 'Tanpa Kategori',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF514250),
                  ),
                ),
                const SizedBox(height: 6),
                // Price Row - Harga Beli & Harga Jual
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Beli: Rp ${product.purchasePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Jual: Rp ${product.sellingPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Stock & Profit Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? const Color(0xFFFFDAD6).withOpacity(0.2)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isLowStock
                              ? const Color(0xFFBA1A1A)
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: profit >= 0 
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        profit >= 0
                            ? 'Profit: Rp ${profit.toStringAsFixed(0)}'
                            : 'Rugi: Rp ${profit.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: profit >= 0 
                              ? const Color(0xFF0D47A1)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    if (profitPercentage > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${profitPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isLowStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '⚠️ Stok menipis! Segera restock.',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                  ),
                if (product.barcode.isNotEmpty)
                  Text(
                    'Barcode: ${product.barcode}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF837281),
                    ),
                  ),
              ],
            ),
          ),
          // Action Buttons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFF7E0092), size: 20),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBA1A1A), size: 20),
                onPressed: onDelete,
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