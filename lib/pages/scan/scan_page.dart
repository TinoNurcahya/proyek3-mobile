import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/profile_service.dart';
import '../../widgets/shared/loading_widget.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late TabController _tabController;

  // ==================== SCANNER STATE ====================
  final _qrController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isLoadingScan = false;
  Map<String, dynamic>? _tableResult;
  String? _errorMessageScan;
  bool _isScannerActive = true; // Control scanner state

  // ==================== GRID STATE ====================
  bool _isLoadingGrid = true;
  String? _errorMessageGrid;
  List<dynamic> _tables = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        // Resume camera when returning to Scan tab
        if (_tableResult == null && !_isLoadingScan) {
          _scannerController.start();
          _isScannerActive = true;
        }
      } else {
        // Pause camera when switching to Grid tab
        _scannerController.stop();
        _isScannerActive = false;
        // Fetch tables if empty
        if (_tables.isEmpty) {
          _fetchTables();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // ==================== API ACTIONS ====================

  Future<void> _fetchTables() async {
    setState(() {
      _isLoadingGrid = true;
      _errorMessageGrid = null;
    });

    try {
      final result = await ProfileService.getTables();
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          final rawData = result['data'];
          if (rawData is List) {
            _tables = rawData;
          } else if (rawData is Map && rawData['data'] is List) {
            _tables = rawData['data'] as List<dynamic>;
          } else {
            _tables = [];
          }
          _isLoadingGrid = false;
        });
      } else {
        setState(() {
          _errorMessageGrid = result['message'] ?? 'Gagal memuat meja';
          _isLoadingGrid = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching tables: $e');
      if (!mounted) return;
      setState(() {
        _errorMessageGrid = 'Terjadi kesalahan koneksi: $e';
        _isLoadingGrid = false;
      });
    }
  }

  Future<void> _scanQrCode(String qrCode) async {
    if (qrCode.trim().isEmpty) return;

    // Pause scanner immediately
    _scannerController.stop();
    setState(() {
      _isScannerActive = false;
      _isLoadingScan = true;
      _errorMessageScan = null;
      _tableResult = null;
    });

    try {
      final result = await ProfileService.scanTable(qrCode.trim());
      if (!mounted) return;

      setState(() => _isLoadingScan = false);

      if (result['success'] == true) {
        setState(() => _tableResult = result['data'] as Map<String, dynamic>?);
      } else {
        setState(() {
          _errorMessageScan = result['message'] ?? 'QR Code tidak valid';
          _isScannerActive = true;
        });
        _scannerController.start(); // Resume on fail
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingScan = false;
        _errorMessageScan = 'Terjadi kesalahan jaringan';
        _isScannerActive = true;
      });
      _scannerController.start();
    }
  }

  Future<void> _updateTableStatus(int tableId, String status, {bool fromGrid = false}) async {
    if (fromGrid) {
      Navigator.pop(context); // Close bottom sheet
      setState(() => _isLoadingGrid = true);
    } else {
      setState(() => _isLoadingScan = true);
    }

    final result = await ProfileService.updateTableStatus(tableId, status);
    if (!mounted) return;

    if (fromGrid) {
      _fetchTables(); // Refresh grid
    } else {
      setState(() => _isLoadingScan = false);
      if (result['success'] == true) {
        _showSnackBar('✅ Status meja berhasil diubah', Colors.green);
        if (_tableResult != null) {
          setState(() => _tableResult!['status'] = status);
        }
      } else {
        _showSnackBar('❌ Gagal mengubah status', Colors.red);
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _tableResult = null;
      _errorMessageScan = null;
      _isScannerActive = true;
    });
    _scannerController.start();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    if (index == 1) Navigator.pushReplacementNamed(context, '/order');
    if (index == 3) Navigator.pushReplacementNamed(context, '/notification');
    if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manajemen Meja',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xFFC67C4E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Scan QR'),
                        Tab(text: 'Daftar Meja'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe to avoid camera issues
                children: [
                  _buildScanTab(),
                  _buildGridTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- SCAN TAB --------------------

  Widget _buildScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Arahkan kamera ke QR code meja\natau masukkan kode secara manual',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Sora'),
          ),
          const SizedBox(height: 30),

          // Scanner Area
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC67C4E), width: 3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFC67C4E).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 4),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: _tableResult != null || !_isScannerActive
                    ? const Center(
                        child: Icon(Icons.check_circle_rounded, color: Color(0xFFC67C4E), size: 64),
                      )
                    : Stack(
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty && _isScannerActive) {
                                final String? code = barcodes.first.rawValue;
                                if (code != null) {
                                  _scanQrCode(code);
                                }
                              }
                            },
                          ),
                          const ScanningOverlay(),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Manual Input
          if (_tableResult == null) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qrController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Sora', fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.qr_code_rounded, color: Color(0xFFC67C4E), size: 20),
                        hintText: 'Masukkan kode meja (Contoh: TABLE_T01_QR)',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Sora', fontSize: 12),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoadingScan ? null : () => _scanQrCode(_qrController.text),
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC67C4E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC67C4E).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoadingScan
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.search_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],

          // Error Message
          if (_errorMessageScan != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade700.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessageScan!, style: const TextStyle(color: Colors.red, fontFamily: 'Sora', fontSize: 13))),
                ],
              ),
            ),

          // Result Card
          if (_tableResult != null) ...[
            _buildTableInfoCard(_tableResult!, fromGrid: false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: const Text('Scan Meja Lain'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC67C4E),
                  side: const BorderSide(color: Color(0xFFC67C4E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // -------------------- GRID TAB --------------------

  Widget _buildGridTab() {
    if (_isLoadingGrid) {
      return const LoadingWidget(message: 'Memuat denah meja...');
    }

    if (_errorMessageGrid != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessageGrid!, style: const TextStyle(color: Colors.red, fontFamily: 'Sora')),
            TextButton(
              onPressed: _fetchTables,
              child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFFC67C4E))),
            )
          ],
        ),
      );
    }

    if (_tables.isEmpty) {
      return const Center(child: Text('Belum ada data meja', style: TextStyle(color: Colors.white54, fontFamily: 'Sora')));
    }

    return RefreshIndicator(
      onRefresh: _fetchTables,
      color: const Color(0xFFC67C4E),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index] as Map<String, dynamic>;
          final status = table['status'] as String? ?? 'empty';
          final tableNumber = table['table_number'] ?? table['number'] ?? '-';
          final capacity = table['capacity'] ?? 4;
          final location = (table['location'] ?? 'indoor').toString().toUpperCase();
          
          final colors = {
            'empty': const Color(0xFF2E7D32),
            'occupied': const Color(0xFFE65100),
            'reserved': const Color(0xFF1565C0),
            'maintenance': const Color(0xFFC62828),
          };
          final bgColors = {
            'empty': const Color(0xFF2E7D32).withValues(alpha: 0.08),
            'occupied': const Color(0xFFE65100).withValues(alpha: 0.08),
            'reserved': const Color(0xFF1565C0).withValues(alpha: 0.08),
            'maintenance': const Color(0xFFC62828).withValues(alpha: 0.08),
          };
          final statusText = {
            'empty': 'Kosong',
            'occupied': 'Terisi',
            'reserved': 'Booking',
            'maintenance': 'Perbaikan',
          };
          
          final c = colors[status] ?? Colors.grey;
          final bg = bgColors[status] ?? Colors.grey.withValues(alpha: 0.08);
          final label = statusText[status] ?? status.toUpperCase();

          return GestureDetector(
            onTap: () => _showTableBottomSheet(table),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_rounded, color: Colors.white30, size: 11),
                        const SizedBox(width: 2),
                        Text(
                          '$capacity',
                          style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      location.substring(0, location.length > 3 ? 3 : location.length),
                      style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w600, fontFamily: 'Sora'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        '$tableNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sora',
                          shadows: [
                            Shadow(color: c.withValues(alpha: 0.3), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: c.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: c, blurRadius: 4, spreadRadius: 1),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: c,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTableBottomSheet(Map<String, dynamic> table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              _buildTableInfoCard(table, fromGrid: true),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // -------------------- REUSABLE WIDGET --------------------

  Widget _buildTableInfoCard(Map<String, dynamic> table, {required bool fromGrid}) {
    final status = table['status'] as String? ?? '-';
    final tableId = (table['table_id'] ?? table['id']) as int?;
    
    final statusColors = {'empty': Colors.green, 'occupied': Colors.orange, 'reserved': Colors.blue, 'maintenance': Colors.red};
    final statusLabels = {'empty': 'Kosong', 'occupied': 'Terisi', 'reserved': 'Direservasi', 'maintenance': 'Maintenance'};
    final statusColor = statusColors[status] ?? Colors.grey;
    final statusLabel = statusLabels[status] ?? status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC67C4E).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meja ${table['table_number'] ?? table['number'] ?? '-'}',
                style: const TextStyle(color: Colors.white, fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 12),
          
          _infoRow('Kapasitas', '${table['capacity'] ?? '-'} orang', Icons.people_rounded),
          _infoRow('Lokasi', (table['location'] ?? '-').toString().toUpperCase(), Icons.location_on_rounded),
          if (table['notes'] != null) _infoRow('Catatan', table['notes'], Icons.note_rounded),

          const SizedBox(height: 16),
          const Text('Ubah Status Meja', style: TextStyle(color: Colors.white60, fontFamily: 'Sora', fontSize: 12)),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusButton(tableId, 'empty', 'Kosong', Colors.green, status, fromGrid),
              _statusButton(tableId, 'occupied', 'Terisi', Colors.orange, status, fromGrid),
              _statusButton(tableId, 'reserved', 'Reservasi', Colors.blue, status, fromGrid),
              _statusButton(tableId, 'maintenance', 'Maintenance', Colors.red, status, fromGrid),
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
          Text('$label: ', style: const TextStyle(color: Colors.white54, fontFamily: 'Sora', fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statusButton(int? tableId, String targetStatus, String label, Color color, String currentStatus, bool fromGrid) {
    final isActive = currentStatus == targetStatus;
    return GestureDetector(
      onTap: isActive || tableId == null ? null : () => _updateTableStatus(tableId, targetStatus, fromGrid: fromGrid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(color: isActive ? color : Colors.white54, fontFamily: 'Sora', fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400),
        ),
      ),
    );
  }
}

class ScanningOverlay extends StatefulWidget {
  const ScanningOverlay({super.key});

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: _animation.value * 210 + 10,
              left: 20,
              right: 20,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFC67C4E),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC67C4E).withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFC67C4E), width: 3),
                left: BorderSide(color: Color(0xFFC67C4E), width: 3),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFC67C4E), width: 3),
                right: BorderSide(color: Color(0xFFC67C4E), width: 3),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFC67C4E), width: 3),
                left: BorderSide(color: Color(0xFFC67C4E), width: 3),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFC67C4E), width: 3),
                right: BorderSide(color: Color(0xFFC67C4E), width: 3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
