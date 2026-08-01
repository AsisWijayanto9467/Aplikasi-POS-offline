// lib/presentation/screens/settings/packages/widgets/package_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/models/package_model.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PackageCard({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = package.details?.length ?? 0;
    final hasImage = package.imagePath != null && package.imagePath!.isNotEmpty;
    final savings = package.normalPrice - package.packagePrice;
    final savingsPercentage = package.normalPrice > 0 
        ? (savings / package.normalPrice * 100) 
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
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
          // ========== IMAGE SECTION ==========
          Stack(
            children: [
              _buildImageSection(hasImage),
              // Action Buttons Overlay di pojok kanan atas
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF7E0092),
                      backgroundColor: Colors.white.withOpacity(0.95),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFBA1A1A),
                      backgroundColor: Colors.white.withOpacity(0.95),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // ========== CONTENT SECTION ==========
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalItems} item dalam paket',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E0092),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Package Name
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1F),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Description (jika ada)
                if (package.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF514250),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // ========== PRICE SECTION ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Harga Aseli (Warna Merah, Tanpa Coret)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Aseli',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF837281),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${package.normalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBA1A1A),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    
                    // Harga Paket
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Harga Paket',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF837281),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rp ${package.packagePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Savings Badge (jika ada)
                if (savings > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          size: 14,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hemat ${savingsPercentage.toStringAsFixed(0)}% (Rp ${savings.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ACTION BUTTON ==========
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  // ========== BUILD IMAGE SECTION ==========
  Widget _buildImageSection(bool hasImage) {
    // Jika ada gambar
    if (hasImage) {
      // Cek apakah imagePath adalah URL
      if (package.imagePath!.startsWith('http')) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Image.network(
            package.imagePath!,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 180,
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7E0092),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        // Image dari local file
        final file = File(package.imagePath!);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.file(
              file,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            ),
          );
        }
      }
    }
    
    // Jika tidak ada gambar atau gagal load
    return _buildPlaceholderImage();
  }

  // ========== PLACEHOLDER IMAGE ==========
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 44,
            color: const Color(0xFF9A25AE).withOpacity(0.25),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada gambar',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF837281).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}