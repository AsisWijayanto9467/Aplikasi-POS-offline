// lib/presentation/pages/settings/packages/package_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/package_controller.dart';
import 'package:salon_desk/data/models/package_detail_model.dart';
import 'package:salon_desk/data/models/package_model.dart';
import 'package:salon_desk/data/models/product_model.dart';
import 'package:salon_desk/data/models/service_model.dart';

class PackageEditScreen extends StatefulWidget {
  final PackageController controller;
  final PackageModel package;

  const PackageEditScreen({
    super.key,
    required this.controller,
    required this.package,
  });

  @override
  State<PackageEditScreen> createState() => _PackageEditScreenState();
}

class _PackageEditScreenState extends State<PackageEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _packagePriceController;
  late final TextEditingController _descriptionController;

  String? _imagePath;

  // Package items
  List<Map<String, dynamic>> _items = [];
  String _selectedItemType = 'product';
  int? _selectedItemId;
  int _quantity = 1;

  // Auto-calculate normal price
  double _normalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package.name);
    _packagePriceController = TextEditingController(
      text: widget.package.packagePrice.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.package.description,
    );
    _imagePath = widget.package.imagePath;

    // Load existing items
    _loadItems();

    widget.controller.loadProducts();
    widget.controller.loadServices();
  }

  // ========== CALCULATE NORMAL PRICE ==========
  double _calculateNormalPrice() {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  // ========== LOAD ITEMS ==========
  void _loadItems() {
    if (widget.package.details != null) {
      for (var detail in widget.package.details!) {
        String name = '';
        double price = 0;

        if (detail.itemType == 'product') {
          try {
            final product = widget.controller.products.firstWhere(
              (p) => p.id == detail.itemId,
              orElse:
                  () => ProductModel(
                    categoryId: 0,
                    name: 'Produk tidak ditemukan',
                    purchasePrice: 0,
                    sellingPrice: 0,
                  ),
            );
            name = product.name;
            price = product.sellingPrice;
          } catch (e) {
            name = 'Produk tidak ditemukan';
            price = 0;
          }
        } else {
          try {
            final service = widget.controller.services.firstWhere(
              (s) => s.id == detail.itemId,
              orElse:
                  () => ServiceModel(
                    categoryId: 0,
                    name: 'Jasa tidak ditemukan',
                    price: 0,
                  ),
            );
            name = service.name;
            price = service.price;
          } catch (e) {
            name = 'Jasa tidak ditemukan';
            price = 0;
          }
        }

        _items.add({
          'itemType': detail.itemType,
          'itemId': detail.itemId,
          'name': name,
          'price': price,
          'quantity': detail.quantity,
        });
      }
    }
    _normalPrice = _calculateNormalPrice();
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
          'Edit Paket',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _updatePackage,
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

              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Nama Paket',
                hintText: 'Masukkan nama paket',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama paket';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Normal Price (Readonly - Auto Calculate)
              _buildNormalPriceField(),
              const SizedBox(height: 8),

              // Package Price (Editable)
              _buildTextField(
                controller: _packagePriceController,
                label: 'Harga Paket',
                hintText: 'Masukkan harga paket',
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan harga paket';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hintText: 'Masukkan deskripsi paket',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Add Item Section
              _buildAddItemSection(),
              const SizedBox(height: 16),

              // Items List
              _buildItemsList(),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E0092),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Paket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== NORMAL PRICE FIELD (READONLY) ==========
  Widget _buildNormalPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Harga Normal',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF514250),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Otomatis',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_normalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF514250),
                ),
              ),
              Text(
                '${_items.length} item',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF837281),
                ),
              ),
            ],
          ),
        ),
        if (_items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Total dari ${_items.length} item dalam paket',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF837281),
                fontSize: 11,
              ),
            ),
          ),
      ],
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
          border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        ),
        child:
            _imagePath != null && _imagePath!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      File(_imagePath!).existsSync()
                          ? Image.file(File(_imagePath!), fit: BoxFit.cover)
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
      builder:
          (context) => SafeArea(
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
                          widget.controller.pickImage(ImageSource.gallery).then(
                            (_) {
                              setState(() {
                                _imagePath =
                                    widget.controller.selectedImagePath;
                              });
                            },
                          );
                        },
                      ),
                      _buildImagePickerOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Kamera',
                        onTap: () {
                          Navigator.pop(context);
                          widget.controller.pickImage(ImageSource.camera).then((
                            _,
                          ) {
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

  // lib/presentation/pages/settings/packages/package_edit_screen.dart
  // ========== ADD ITEM SECTION ==========
  Widget _buildAddItemSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Item',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const SizedBox(height: 12),

          // Item Type Dropdown (Atas)
          _buildDropdown(
            label: 'Tipe Item',
            value: _selectedItemType,
            items: const ['product', 'service'],
            onChanged: (value) {
              setState(() {
                _selectedItemType = value;
                _selectedItemId = null;
              });
            },
          ),
          const SizedBox(height: 12),

          // Item Dropdown (Tengah)
          _buildItemDropdown(),
          const SizedBox(height: 12),

          // Quantity & Add Button (Bawah)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: TextEditingController(text: _quantity.toString()),
                  label: 'Jumlah',
                  hintText: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _quantity = int.tryParse(value) ?? 1;
                      if (_quantity < 1) _quantity = 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E0092),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tambah Item'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== DROPDOWN ==========
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
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
      items:
          items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'product' ? 'Produk' : 'Jasa',
              ), // <-- HAPUS EMOJI
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // ========== ITEM DROPDOWN ==========
  Widget _buildItemDropdown() {
    final items =
        _selectedItemType == 'product'
            ? widget.controller.products
            : widget.controller.services;

    return DropdownButtonFormField<int>(
      value: _selectedItemId,
      decoration: InputDecoration(
        labelText: 'Pilih Item',
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
        hintText: 'Pilih item...',
      ),
      items:
          items.map<DropdownMenuItem<int>>((dynamic item) {
            String name = '';
            double price = 0;
            int id = 0;

            if (item is ProductModel) {
              name = item.name;
              price = item.sellingPrice;
              id = item.id ?? 0;
            } else if (item is ServiceModel) {
              name = item.name;
              price = item.price;
              id = item.id ?? 0;
            }

            return DropdownMenuItem<int>(
              value: id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Rp ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF837281),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedItemId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih item';
        }
        return null;
      },
    );
  }

  // ========== ADD ITEM ==========
  void _addItem() {
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih item terlebih dahulu'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    // Cek duplikasi
    final exists = _items.any(
      (item) =>
          item['itemType'] == _selectedItemType &&
          item['itemId'] == _selectedItemId,
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item sudah ada dalam paket'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final items =
        _selectedItemType == 'product'
            ? widget.controller.products
            : widget.controller.services;

    dynamic foundItem;
    try {
      foundItem = items.firstWhere((dynamic i) => i.id == _selectedItemId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item tidak ditemukan'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    String name = '';
    double price = 0;

    if (foundItem is ProductModel) {
      name = foundItem.name;
      price = foundItem.sellingPrice;
    } else if (foundItem is ServiceModel) {
      name = foundItem.name;
      price = foundItem.price;
    }

    setState(() {
      _items.add({
        'itemType': _selectedItemType,
        'itemId': _selectedItemId!,
        'name': name,
        'price': price,
        'quantity': _quantity,
      });
      _selectedItemId = null;
      _quantity = 1;
      _normalPrice = _calculateNormalPrice();
    });
  }

  // ========== REMOVE ITEM ==========
  void _removeItem(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Hapus Item'),
            content: Text(
              'Apakah Anda yakin ingin menghapus item "${_items[index]['name']}" dari paket?',
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
                onPressed: () {
                  setState(() {
                    _items.removeAt(index);
                    _normalPrice = _calculateNormalPrice();
                  });
                  Navigator.pop(context);
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

  // ========== ITEMS LIST ==========
  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        ),
        child: const Center(
          child: Text(
            'Belum ada item dalam paket',
            style: TextStyle(color: Color(0xFF837281)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item dalam Paket',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1F),
          ),
        ),
        const SizedBox(height: 8),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8D4FE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['itemType'] == 'product' ? 'Produk' : 'Jasa',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF75597C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF514250),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E0092),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFBA1A1A),
                    size: 20,
                  ),
                  onPressed: () => _removeItem(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1F),
                ),
              ),
              Text(
                '${_items.length} item',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7E0092),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== TEXT FIELD ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
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
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1F)),
        ),
      ],
    );
  }

  // ========== UPDATE PACKAGE ==========
  void _updatePackage() async {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paket harus memiliki minimal satu item'),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
        return;
      }

      final packagePrice = double.parse(_packagePriceController.text);

      // Warning jika harga paket > harga normal
      if (packagePrice > _normalPrice) {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Konfirmasi Harga'),
                content: Text(
                  'Harga paket (Rp ${packagePrice.toStringAsFixed(0)}) lebih mahal dari harga normal (Rp ${_normalPrice.toStringAsFixed(0)}). Lanjutkan?',
                  style: const TextStyle(color: Color(0xFF514250)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E0092),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lanjutkan'),
                  ),
                ],
              ),
        );
        if (confirm != true) return;
      }

      final updatedPackage = widget.package.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        normalPrice: _normalPrice,
        packagePrice: packagePrice,
        imagePath: _imagePath ?? widget.package.imagePath,
      );

      final details =
          _items
              .map(
                (item) => PackageDetailModel(
                  packageId: widget.package.id!,
                  itemType: item['itemType'],
                  itemId: item['itemId'],
                  quantity: item['quantity'],
                ),
              )
              .toList();

      final success = await widget.controller.updatePackage(
        updatedPackage,
        details,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paket berhasil diperbarui'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.controller.error ?? 'Gagal memperbarui paket',
              ),
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
    _packagePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
