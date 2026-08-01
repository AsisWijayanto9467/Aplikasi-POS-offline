// lib/presentation/pages/settings/printer/printer_screen.dart
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:salon_desk/core/theme/app_text_styles.dart';
import 'package:salon_desk/data/controller/printer_controller.dart';
import 'package:salon_desk/data/models/printer_setting_model.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  late PrinterController _controller;
  
  final TextEditingController _printerNameController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  
  String _selectedPaperSize = '58mm';
  bool _isPrinterActive = true;
  bool _showLogo = true;
  
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = PrinterController();
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

  void _updateControllers(PrinterSettingModel settings) {
    _printerNameController.text = settings.printerName;
    _headerController.text = settings.printHeader;
    _footerController.text = settings.printFooter;
    _selectedPaperSize = settings.paperSize;
    _isPrinterActive = settings.isConnected == 1;
    _showLogo = settings.showLogo == 1;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final settings = PrinterSettingModel(
      printerName: _printerNameController.text,
      paperSize: _selectedPaperSize,
      isConnected: _isPrinterActive ? 1 : 0,
      bluetoothAddress: _controller.settings?.bluetoothAddress ?? '',
      printHeader: _headerController.text,
      printFooter: _footerController.text,
      showLogo: _showLogo ? 1 : 0,
    );

    final success = await _controller.saveSettings(settings);
    
    setState(() => _isSaving = false);

    _showSnackBar(
      success ? 'Pengaturan printer berhasil disimpan' : 'Gagal menyimpan pengaturan',
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

  Future<void> _scanAndConnect() async {
    setState(() => _isLoading = true);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF7E0092)),
                SizedBox(height: 16),
                Text('Mencari perangkat Bluetooth...'),
              ],
            ),
          ),
        ),
      ),
    );

    await _controller.scanDevices();
    
    Navigator.pop(context);
    setState(() => _isLoading = false);

    if (_controller.devices.isNotEmpty) {
      _showDeviceSelectionDialog();
    } else {
      _showSnackBar(
        'Tidak ditemukan perangkat Bluetooth. Pastikan Bluetooth aktif.',
        isError: true,
      );
    }
  }

  void _showDeviceSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Perangkat Bluetooth',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(Icons.bluetooth_rounded, color: Color(0xFF7E0092)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.devices.length} perangkat ditemukan',
                style: const TextStyle(color: Color(0xFF837281), fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _controller.devices.length,
                  itemBuilder: (context, index) {
                    final device = _controller.devices[index];
                    return _buildDeviceTile(device);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF514250),
                    side: const BorderSide(color: Color(0xFFE2E2E7)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    // Perbaikan: handle null dengan aman
    final deviceName = device.name ?? 'Perangkat Bluetooth';
    final deviceAddress = device.address ?? 'Alamat tidak tersedia';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          _connectToDevice(device);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7E0092).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.print_rounded,
            color: const Color(0xFF7E0092),
            size: 24,
          ),
        ),
        title: Text(
          deviceName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceAddress,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF837281),
              ),
            ),
            // Cek apakah device sudah terhubung dengan controller
            if (_controller.selectedDevice != null && 
                _controller.selectedDevice?.address == device.address)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Terhubung',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Color(0xFF837281),
        ),
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _isLoading = true);

    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF7E0092)),
                SizedBox(height: 16),
                Text('Menghubungkan ke printer...'),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await _controller.connectToDevice(device);
    
    Navigator.pop(context);
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Berhasil terhubung ke printer!', isError: false);
      await _loadData();
    } else {
      _showSnackBar(
        _controller.error ?? 'Gagal terhubung ke printer',
        isError: true,
      );
    }
  }

  Future<void> _testPrint() async {
    setState(() => _isLoading = true);
    
    final success = await _controller.testPrint();
    
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Uji cetak berhasil!', isError: false);
    } else {
      _showSnackBar(
        _controller.error ?? 'Gagal melakukan uji cetak',
        isError: true,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Printer',
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
                  // Status Printer
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  
                  // Settings
                  _buildSwitchTile(
                    title: 'Aktifkan Printer',
                    value: _isPrinterActive,
                    onChanged: (value) {
                      setState(() => _isPrinterActive = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _printerNameController,
                    label: 'Nama Printer',
                    hintText: 'Masukkan nama printer',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    label: 'Ukuran Kertas',
                    value: _selectedPaperSize,
                    items: const ['58mm', '80mm'],
                    onChanged: (value) {
                      setState(() => _selectedPaperSize = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _headerController,
                    label: 'Header Struk',
                    hintText: 'Masukkan header struk',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _footerController,
                    label: 'Footer Struk',
                    hintText: 'Masukkan footer struk',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    title: 'Tampilkan Logo di Struk',
                    value: _showLogo,
                    onChanged: (value) {
                      setState(() => _showLogo = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Test Print Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testPrint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E0092),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Uji Cetak Struk'),
                  ),
                  const SizedBox(height: 12),
                  
                  // Scan Bluetooth Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _scanAndConnect,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF514250),
                      side: const BorderSide(color: Color(0xFFE2E2E7)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: _controller.isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7E0092),
                            ),
                          )
                        : const Icon(Icons.bluetooth_rounded),
                    label: Text(
                      _controller.isScanning 
                          ? 'Mencari Perangkat...' 
                          : 'Cari Perangkat Bluetooth',
                    ),
                  ),
                  
                  if (_controller.isConnected && _controller.selectedDevice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bluetooth_connected_rounded,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Terhubung ke: ${_controller.selectedDevice?.name ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1C1F),
                                  ),
                                ),
                                Text(
                                  _controller.selectedDevice?.address ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF837281),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _controller.disconnectPrinter,
                            child: const Text(
                              'Putuskan',
                              style: TextStyle(
                                color: Color(0xFFBA1A1A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ========== STATUS CARD ==========
  Widget _buildStatusCard() {
    final isConnected = _controller.isConnected;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected 
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : const Color(0xFFBA1A1A).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isConnected 
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFBA1A1A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isConnected 
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              color: isConnected 
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFBA1A1A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Printer Terhubung' : 'Printer Tidak Terhubung',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1F),
                  ),
                ),
                Text(
                  isConnected 
                      ? (_controller.selectedDevice?.name ?? 'Thermal Printer')
                      : 'Silakan hubungkan printer melalui Bluetooth',
                  style: AppTextStyles.caption.copyWith(
                    color: isConnected 
                        ? const Color(0xFF514250)
                        : const Color(0xFFBA1A1A),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isConnected 
                ? Icons.bluetooth_connected_rounded
                : Icons.bluetooth_disabled_rounded,
            color: isConnected 
                ? const Color(0xFF4CAF50)
                : const Color(0xFFBA1A1A),
            size: 24,
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
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1C1F),
            ),
          ),
        ),
      ],
    );
  }

  // ========== DROPDOWN FIELD ==========
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1C1F),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ========== SWITCH TILE ==========
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E2E7),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1C1F),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7E0092),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _printerNameController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    _controller.dispose();
    super.dispose();
  }
}