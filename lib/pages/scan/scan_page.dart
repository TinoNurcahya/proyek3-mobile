import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/profile_service.dart';

/// Halaman Scan QR Meja
/// Untuk mengaktifkan kamera scanner, install package mobile_scanner:
///   flutter pub add mobile_scanner
/// Kemudian replace _buildManualInput() dengan MobileScanner widget.

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  final _qrController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _tableResult;
  String? _errorMessage;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.85, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode(String qrCode) async {
    if (qrCode.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _tableResult = null;
    });

    final result = await ProfileService.scanTable(qrCode.trim());

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _tableResult = result['data'] as Map<String, dynamic>?);
    } else {
      setState(() =>
          _errorMessage = result['message'] ?? 'QR Code tidak valid');
    }
  }

  Future<void> _updateTableStatus(int tableId, String status) async {
    setState(() => _isLoading = true);
    final result =
        await ProfileService.updateTableStatus(tableId, status);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnackBar('✅ Status meja berhasil diubah ke: $status',
          Colors.green);
      // Refresh data meja
      if (_tableResult != null) {
        setState(() {
          _tableResult!['status'] = status;
        });
      }
    } else {
      _showSnackBar(
          '❌ ${result['message'] ?? 'Gagal mengubah status'}', Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/order');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notification');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onProfile: () =>
            Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (_) => false),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              const Text(
                'Scan Meja',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan QR code pada meja untuk melihat info meja',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontFamily: 'Sora'),
              ),

              const SizedBox(height: 30),

              // ── QR Scanner Area ──────────────────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC67C4E),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFC67C4E).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: const Color(0xFFC67C4E),
                          size: 72,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Area Scanner',
                          style: TextStyle(
                            color: Color(0xFFC67C4E),
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambah mobile_scanner\nuntuk aktifkan kamera',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontFamily: 'Sora',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ── Manual Input ─────────────────────────────────────
              const Text(
                'atau masukkan kode manual:',
                style: TextStyle(
                  color: Colors.white60,
                  fontFamily: 'Sora',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qrController,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Sora'),
                      decoration: InputDecoration(
                        hintText: 'Contoh: TABLE_001_QR',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontFamily: 'Sora',
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFC67C4E), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _scanQrCode(_qrController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC67C4E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.search_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Error ────────────────────────────────────────────
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.shade700.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Sora',
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Hasil Scan ────────────────────────────────────────
              if (_tableResult != null) _buildTableCard(_tableResult!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(Map<String, dynamic> table) {
    final status = table['status'] as String? ?? '-';
    final statusColors = {
      'empty': Colors.green,
      'occupied': Colors.orange,
      'reserved': Colors.blue,
      'maintenance': Colors.red,
    };
    final statusLabels = {
      'empty': 'Kosong',
      'occupied': 'Terisi',
      'reserved': 'Direservasi',
      'maintenance': 'Maintenance',
    };
    final statusColor = statusColors[status] ?? Colors.grey;
    final statusLabel = statusLabels[status] ?? status;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFC67C4E).withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meja ${table['table_number'] ?? table['number'] ?? '-'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 12),

          // Info
          _infoRow('Kapasitas',
              '${table['capacity'] ?? '-'} orang', Icons.people_rounded),
          _infoRow('Lokasi',
              (table['location'] ?? '-').toString().toUpperCase(),
              Icons.location_on_rounded),
          if (table['notes'] != null)
            _infoRow('Catatan', table['notes'], Icons.note_rounded),

          const SizedBox(height: 16),

          // Tombol ubah status
          const Text(
            'Ubah Status Meja',
            style: TextStyle(
              color: Colors.white60,
              fontFamily: 'Sora',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusButton('empty', 'Kosong', Colors.green, status),
              _statusButton('occupied', 'Terisi', Colors.orange, status),
              _statusButton(
                  'reserved', 'Reservasi', Colors.blue, status),
              _statusButton(
                  'maintenance', 'Maintenance', Colors.red, status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC67C4E), size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
                color: Colors.white54, fontFamily: 'Sora', fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
      String status, String label, Color color, String currentStatus) {
    final isActive = currentStatus == status;
    final tableId = (_tableResult!['table_id'] ?? _tableResult!['id']) as int?;

    return GestureDetector(
      onTap: isActive || tableId == null
          ? null
          : () => _updateTableStatus(tableId, status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.25)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? color
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.white54,
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
