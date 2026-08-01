// lib/presentation/pages/settings/categories/category_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/category_controller.dart';
import 'package:salon_desk/data/models/category_model.dart';

class CategoryEditScreen extends StatefulWidget {
  final CategoryController controller;
  final CategoryModel category;

  const CategoryEditScreen({
    super.key,
    required this.controller,
    required this.category,
  });

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;

  // ========== UPDATE: Gunakan icon yang valid di Flutter ==========
  final List<Map<String, dynamic>> _iconOptions = [
    {'value': 'category', 'label': 'Category', 'icon': Icons.category_rounded},
    {'value': 'spa', 'label': 'Spa', 'icon': Icons.spa_rounded},
    {'value': 'content_cut', 'label': 'Potong', 'icon': Icons.content_cut_rounded},
    {'value': 'brush', 'label': 'Brush', 'icon': Icons.brush_rounded},
    {'value': 'face', 'label': 'Face', 'icon': Icons.face_rounded},
    {'value': 'shopping_bag', 'label': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'value': 'local_offer', 'label': 'Offer', 'icon': Icons.local_offer_rounded},
    {'value': 'inventory', 'label': 'Inventory', 'icon': Icons.inventory_2_rounded},
    {'value': 'self_improvement', 'label': 'Self Care', 'icon': Icons.self_improvement_rounded},
    {'value': 'star', 'label': 'Star', 'icon': Icons.star_rounded},
    {'value': 'favorite', 'label': 'Favorite', 'icon': Icons.favorite_rounded},
    {'value': 'settings', 'label': 'Settings', 'icon': Icons.settings_rounded},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'value': '#F68B1F', 'color': const Color(0xFFF68B1F)},
    {'value': '#6C5CE7', 'color': const Color(0xFF6C5CE7)},
    {'value': '#00B894', 'color': const Color(0xFF00B894)},
    {'value': '#E17055', 'color': const Color(0xFFE17055)},
    {'value': '#0984E3', 'color': const Color(0xFF0984E3)},
    {'value': '#FDCB6E', 'color': const Color(0xFFFDCB6E)},
    {'value': '#E84393', 'color': const Color(0xFFE84393)},
    {'value': '#00CEC9', 'color': const Color(0xFF00CEC9)},
    {'value': '#6C5CE7', 'color': const Color(0xFF6C5CE7)},
    {'value': '#2D3436', 'color': const Color(0xFF2D3436)},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
    _selectedColor = widget.category.color;
  }

  @override
  Widget build(BuildContext context) {
    final typeName = widget.category.type == 'product' ? 'Produk' : 'Jasa';
    
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
          'Edit Kategori $typeName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _updateCategory,
            child: const Text(
              'Update',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7E0092),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E2E7),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconOptions.firstWhere((i) => i['value'] == _selectedIcon)['icon'],
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1C1F),
                          ),
                        ),
                        Text(
                          'Kategori $typeName',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF514250),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Nama Kategori',
                hint: 'Masukkan nama kategori',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Icon',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF514250),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E2E7),
                        width: 1,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _iconOptions.map((icon) {
                        final isSelected = _selectedIcon == icon['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon['value'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF7E0092).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF7E0092)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              icon['icon'],
                              color: isSelected 
                                  ? const Color(0xFF7E0092)
                                  : const Color(0xFF514250),
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Color
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warna',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF514250),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E2E7),
                        width: 1,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colorOptions.map((color) {
                        final isSelected = _selectedColor == color['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color['value'];
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color['color'],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E0092),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== TEXT FIELD ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF514250),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E2E7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E2E7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7E0092)),
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9FE),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1C1F),
          ),
        ),
      ],
    );
  }

  // ========== UPDATE CATEGORY ==========
  void _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      final updatedCategory = widget.category.copyWith(
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      final success = await widget.controller.updateCategory(updatedCategory);
      
      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil diperbarui'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.error ?? 'Gagal memperbarui kategori'),
              backgroundColor: const Color(0xFFBA1A1A),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}