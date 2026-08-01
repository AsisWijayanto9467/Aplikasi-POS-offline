// lib/presentation/pages/settings/salon_info/salon_info_screen.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/salon_settings_controller.dart';
import 'package:salon_desk/data/models/salon_setting_model.dart';

class SalonInfoScreen extends StatefulWidget {
  const SalonInfoScreen({super.key});

  @override
  State<SalonInfoScreen> createState() => _SalonInfoScreenState();
}

class _SalonInfoScreenState extends State<SalonInfoScreen> {
  late SalonSettingController _controller;
  
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = SalonSettingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadSettings();
    if (_controller.settings != null) {
      _updateControllers(_controller.settings!);
    }
    setState(() => _isLoading = false);
  }

  void _updateControllers(SalonSettingModel settings) {
    _nameController.text = settings.salonName;
    _addressController.text = settings.address;
    _phoneController.text = settings.phone;
    _emailController.text = settings.email;
    _openTimeController.text = settings.openingTime;
    _closeTimeController.text = settings.closingTime;
  }

  Future<void> _saveSettings() async {
    // Validate
    if (_nameController.text.isEmpty) {
      _showSnackBar('Nama salon tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final settings = SalonSettingModel(
      salonName: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      logoPath: _controller.settings?.logoPath ?? '',
      openingTime: _openTimeController.text,
      closingTime: _closeTimeController.text,
      taxPercentage: _controller.settings?.taxPercentage ?? 0,
      currency: _controller.settings?.currency ?? 'Rp',
    );

    final success = await _controller.saveSettings(settings);
    
    setState(() => _isSaving = false);

    _showSnackBar(
      success ? 'Data berhasil disimpan' : 'Gagal menyimpan data',
      isError: !success,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    // Parse current time
    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        try {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        } catch (e) {
          // Use default if parsing fails
        }
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7E0092),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = timeString;
      });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Info Salon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7E0092),
                    ),
                  )
                : const Icon(Icons.save_rounded, color: Color(0xFF7E0092)),
            onPressed: _isSaving ? null : _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7E0092),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Logo placeholder (optional)
                  _buildLogoSection(),
                  const SizedBox(height: 16),
                  
                  // Form fields
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Salon',
                    hintText: 'Masukkan nama salon',
                    icon: Icons.storefront_rounded,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _addressController,
                    label: 'Alamat',
                    hintText: 'Masukkan alamat salon',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    label: 'No. Telepon',
                    hintText: 'Masukkan nomor telepon',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Masukkan email salon',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTimeField(
                    controller: _openTimeController,
                    label: 'Jam Buka',
                    onTap: () => _selectTime(context, _openTimeController),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTimeField(
                    controller: _closeTimeController,
                    label: 'Jam Tutup',
                    onTap: () => _selectTime(context, _closeTimeController),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E0092),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ========== LOGO SECTION ==========
  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_rounded,
              size: 40,
              color: Color(0xFF7E0092),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Salon',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola informasi salon Anda',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF837281),
            ),
          ),
        ],
      ),
    );
  }

  // ========== TEXT FIELD ==========
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
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
        Container(
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
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF837281),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: icon == null ? 16 : 0,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== TIME FIELD ==========
  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
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
                const SizedBox(width: 12),
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF837281),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    enabled: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1C1F),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF837281),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _controller.dispose();
    super.dispose();
  }
}