// lib/presentation/pages/settings/qris/qris_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/qris_controller.dart';

class QrisScreen extends StatefulWidget {
  const QrisScreen({super.key});

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen> {
  final QrisController _controller = QrisController();
  final TextEditingController _merchantNameController = TextEditingController();
  final TextEditingController _merchantIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _qrisImagePath;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadQRISData();
  }

  Future<void> _loadQRISData() async {
    setState(() => _isLoading = true);
    await _controller.loadQRIS();

    if (_controller.qrisData != null) {
      setState(() {
        _merchantNameController.text = _controller.merchantName;
        _merchantIdController.text = _controller.merchantId;
        _descriptionController.text = _controller.qrisData?.qrisDescription ?? 'Pembayaran QRIS';
        _qrisImagePath = _controller.qrisImagePath;
        _hasChanges = false;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload QRIS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E0092).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF7E0092)),
                  ),
                  title: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Gunakan kamera', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF4CAF50)),
                  ),
                  title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Pilih foto dari galeri', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                if (_qrisImagePath != null && _qrisImagePath!.isNotEmpty)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA1A1A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Color(0xFFBA1A1A)),
                    ),
                    title: const Text('Hapus QRIS', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFBA1A1A))),
                    subtitle: const Text('Hapus gambar QRIS', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _qrisImagePath = null;
                        _hasChanges = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _qrisImagePath = pickedFile.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveQRIS() async {
    if (_merchantNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama merchant harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _controller.saveQRIS(
      merchantName: _merchantNameController.text.trim(),
      merchantId: _merchantIdController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _qrisImagePath,
    );

    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(  // ✅ Hapus 'const'
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('QRIS berhasil disimpan'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error ?? 'Gagal menyimpan QRIS'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'QRIS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded, color: Color(0xFF7E0092)),
              onPressed: _isLoading ? null : _saveQRIS,
            ),
          ),
        ],
      ),
      body: _isLoading && _controller.qrisData == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7E0092)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // QRIS Preview with Upload
                  _buildQRISPreview(),
                  const SizedBox(height: 16),
                  // QRIS Info
                  _buildQRISInfo(),
                  const SizedBox(height: 16),
                  // QRIS Form
                  _buildQRISForm(),
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveQRIS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E0092),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF7E0092).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Pengaturan QRIS',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQRISPreview() {
    final hasImage = _qrisImagePath != null && _qrisImagePath!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code Container
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E2E7),
                  width: 1,
                ),
              ),
              child: hasImage
                  ? Stack(
                      children: [
                        // QR Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_qrisImagePath!),
                            fit: BoxFit.contain,
                            width: 200,
                            height: 200,
                          ),
                        ),
                        // Edit overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 60,
                          color: const Color(0xFF7E0092).withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap untuk upload',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF837281),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasImage ? Icons.check_circle_rounded : Icons.info_rounded,
                size: 16,
                color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              ),
              const SizedBox(width: 6),
              Text(
                hasImage ? 'QRIS sudah diupload' : 'Belum ada QRIS terupload',
                style: AppTextStyles.caption.copyWith(
                  color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Upload Button
          OutlinedButton.icon(
            onPressed: _pickImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7E0092),
              side: const BorderSide(color: Color(0xFF7E0092)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              hasImage ? Icons.swap_horiz_rounded : Icons.upload_rounded,
              size: 18,
            ),
            label: Text(
              hasImage ? 'Ganti QRIS' : 'Upload QRIS',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRISInfo() {
    final hasImage = _qrisImagePath != null && _qrisImagePath!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Status',
            hasImage ? 'Aktif' : 'Belum Diatur',
            color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          ),
          const Divider(height: 16, color: Color(0xFFE2E2E7)),
          _buildInfoRow('Metode Pembayaran', 'QRIS (Quick Response Code Indonesian Standard)'),
          const Divider(height: 16, color: Color(0xFFE2E2E7)),
          _buildInfoRow('Kompatibel', 'GoPay, OVO, DANA, ShopeePay, LinkAja'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: const Color(0xFF514250)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFF1A1C1F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRISForm() {
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
            'Informasi Merchant',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField('Nama Merchant', _merchantNameController, hint: 'Contoh: Salon Cantik'),
          const SizedBox(height: 16),
          _buildTextField('No. Merchant / ID', _merchantIdController, hint: 'Contoh: 08123456789'),
          const SizedBox(height: 16),
          _buildTextField('Keterangan', _descriptionController, hint: 'Contoh: Pembayaran QRIS'),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9FE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            onChanged: (_) => setState(() => _hasChanges = true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1F)),
          ),
        ),
      ],
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Perubahan?'),
        content: const Text('Perubahan yang Anda buat akan hilang jika keluar tanpa menyimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _merchantNameController.dispose();
    _merchantIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}