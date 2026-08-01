// lib/presentation/pages/settings/products/product_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/product_controller.dart';
import 'package:salon_desk/data/models/product_model.dart';

class ProductEditScreen extends StatefulWidget {
  final ProductController controller;
  final ProductModel product;

  const ProductEditScreen({
    super.key,
    required this.controller,
    required this.product,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _barcodeController;
  
  late int? _selectedCategoryId;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _purchasePriceController = TextEditingController(
      text: widget.product.purchasePrice.toString(),
    );
    _sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _minStockController = TextEditingController(
      text: widget.product.minStock.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _barcodeController = TextEditingController(
      text: widget.product.barcode,
    );
    _selectedCategoryId = widget.product.categoryId;
    _imagePath = widget.product.imagePath;
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
          'Edit Produk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _updateProduct,
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
              // Image Picker
              _buildImagePicker(),
              const SizedBox(height: 16),
              
              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              
              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Masukkan nama produk',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama produk';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Purchase Price & Selling Price
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _purchasePriceController,
                      label: 'Harga Beli',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan harga beli';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _sellingPriceController,
                      label: 'Harga Jual',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan harga jual';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stock & Min Stock
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stok',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan stok';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _minStockController,
                      label: 'Min Stok',
                      hint: '5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Barcode
              _buildTextField(
                controller: _barcodeController,
                label: 'Barcode',
                hint: 'Masukkan barcode',
              ),
              const SizedBox(height: 16),
              
              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi produk',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E0092),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Produk',
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

  // ========== IMAGE PICKER ==========
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImagePickerDialog,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E2E7),
            width: 1,
          ),
        ),
        child: _imagePath != null && _imagePath!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: File(_imagePath!).existsSync()
                    ? Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: Color(0xFF837281),
                      ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 48,
                    color: const Color(0xFF837281).withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap untuk ubah gambar',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF837281),
                    ),
                  ),
                  Text(
                    'Galeri atau Kamera',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF837281),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      widget.controller.pickImage(ImageSource.gallery).then((_) {
                        setState(() {
                          _imagePath = widget.controller.selectedImagePath;
                        });
                      });
                    },
                  ),
                  _buildImagePickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      widget.controller.pickImage(ImageSource.camera).then((_) {
                        setState(() {
                          _imagePath = widget.controller.selectedImagePath;
                        });
                      });
                    },
                  ),
                  if (_imagePath != null && _imagePath!.isNotEmpty)
                    _buildImagePickerOption(
                      icon: Icons.delete_outline_rounded,
                      label: 'Hapus',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        widget.controller.clearSelectedImage();
                        setState(() {
                          _imagePath = null;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF7E0092)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color ?? const Color(0xFF7E0092),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFF514250),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CATEGORY DROPDOWN ==========
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
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
      ),
      items: widget.controller.categories.map((category) {
        return DropdownMenuItem<int>(
          value: category['id'] as int,
          child: Text(category['name'] as String),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih kategori';
        }
        return null;
      },
    );
  }

  // ========== TEXT FIELD ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
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

  // ========== UPDATE PRODUCT ==========
  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final purchasePrice = double.parse(_purchasePriceController.text);
      final sellingPrice = double.parse(_sellingPriceController.text);
      
      // Validasi: harga jual tidak boleh kurang dari harga beli
      if (sellingPrice < purchasePrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harga jual tidak boleh kurang dari harga beli'),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
        return;
      }
      
      final updatedProduct = widget.product.copyWith(
        categoryId: _selectedCategoryId!,
        name: _nameController.text,
        description: _descriptionController.text,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stock: int.parse(_stockController.text),
        minStock: int.parse(_minStockController.text),
        barcode: _barcodeController.text,
        imagePath: _imagePath ?? widget.product.imagePath,
      );

      final success = await widget.controller.updateProduct(updatedProduct);
      
      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil diperbarui'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.error ?? 'Gagal memperbarui produk'),
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
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}