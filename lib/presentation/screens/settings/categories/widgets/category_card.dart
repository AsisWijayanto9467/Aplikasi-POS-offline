// lib/presentation/pages/settings/categories/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(category.icon),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.type == 'product' ? 'Kategori Produk' : 'Kategori Jasa',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF514250),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFF7E0092), size: 20),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'spa':
        return Icons.spa_rounded;
      case 'content_cut':
        return Icons.content_cut_rounded;
      case 'brush':
        return Icons.brush_rounded;
      case 'face':
        return Icons.face_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'local_offer':
        return Icons.local_offer_rounded;
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'category':
      default:
        return Icons.category_rounded;
    }
  }
}