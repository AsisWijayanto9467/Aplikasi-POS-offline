// lib/presentation/pages/settings/services/widgets/service_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCard({
    super.key,
    required this.service,
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
          // Service Image or Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8D4FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: service.imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<bool>(
                      future: File(service.imagePath).exists(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Image.file(
                            File(service.imagePath),
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
                    Icons.content_cut_rounded,
                    color: Color(0xFF75597C),
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          // Service Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.categoryName ?? 'Tanpa Kategori',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF514250),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Rp ${service.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7E0092),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.durationFormatted,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ],
                ),
                if (service.description.isNotEmpty)
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF514250),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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