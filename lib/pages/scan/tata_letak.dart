import 'package:flutter/material.dart';
import 'package:proyek3_mobile/models/table_model.dart';
import 'package:proyek3_mobile/widgets/bottom_navbar.dart';
import '../../services/table_service.dart';

// ============================================================
// PAGE UTAMA
// ============================================================

class TataLetakMejaPage extends StatefulWidget {
  const TataLetakMejaPage({super.key});

  @override
  State<TataLetakMejaPage> createState() => _TataLetakMejaPageState();
}

class _TataLetakMejaPageState extends State<TataLetakMejaPage> {
  int _currentIndex = 2;
  bool _isLoading = true;
  List<MejaData> _tables = [];

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);
  static const Color kBg = Color(0xFFF5F0E8);
  static const Color kWall = Color(0xFFD9CFC4);

  @override
  void initState() {
    super.initState();
    _fetchTableData();
  }

  Future<void> _fetchTableData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await TableService.getAllTables();

      debugPrint('📊 API Response Status: ${result['success']}');
      debugPrint('📊 API Response: $result');

      if (result['success'] == true) {
        final tableList = result['data'] as List? ?? [];

        debugPrint('📊 Total tables parsed: ${tableList.length}');

        final parsedTables = <MejaData>[];
        for (final table in tableList) {
          final id = (table['id'] ?? 0) as int;
          final nomor = (table['number'] ?? table['table_number'] ?? '-').toString();
          final capacity = (table['capacity'] ?? 4) as int;
          final location = (table['location'] ?? 'indoor').toString();
          final notes = table['notes'] as String?;

          // Parse coordinates
          double x = 0.0;
          double y = 0.0;
          final coords = table['coordinates'];
          if (coords is Map) {
            x = (coords['x'] ?? 0.0).toDouble();
            y = (coords['y'] ?? 0.0).toDouble();
          } else {
            x = (table['coord_x'] ?? table['x'] ?? 0.0).toDouble();
            y = (table['coord_y'] ?? table['y'] ?? 0.0).toDouble();
          }

          // Parse status: empty, occupied, reserved, maintenance
          final statusStr = (table['status'] ?? 'empty').toString().toLowerCase();
          StatusMeja status = StatusMeja.empty;
          if (statusStr == 'occupied') {
            status = StatusMeja.occupied;
          } else if (statusStr == 'reserved') {
            status = StatusMeja.reserved;
          } else if (statusStr == 'maintenance') {
            status = StatusMeja.maintenance;
          }

          parsedTables.add(MejaData(
            id: id,
            nomor: nomor,
            capacity: capacity,
            location: location,
            x: x,
            y: y,
            notes: notes,
            status: status,
          ));
        }

        debugPrint('✅ Parsed successfully: ${parsedTables.length} tables');

        if (parsedTables.isEmpty) {
          debugPrint('⚠️ No tables returned from API, using mock data');
          _setMockData();
        } else {
          setState(() {
            _tables = parsedTables;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('❌ API Error: ${result['message']}');
        _setMockData();
      }
    } catch (e) {
      debugPrint('❌ Error parsing tables: $e');
      _setMockData();
    }
  }

  void _setMockData() {
    // Fallback mock data with exact canvas coordinates
    _tables = [
      MejaData(id: 1, nomor: 'T01', capacity: 2, location: 'indoor', x: 80.0, y: 120.0, status: StatusMeja.occupied),
      MejaData(id: 2, nomor: 'T02', capacity: 2, location: 'indoor', x: 80.0, y: 220.0, status: StatusMeja.occupied),
      MejaData(id: 3, nomor: 'T03', capacity: 4, location: 'indoor', x: 80.0, y: 320.0, status: StatusMeja.empty),
      MejaData(id: 4, nomor: 'T04', capacity: 4, location: 'indoor', x: 80.0, y: 440.0, status: StatusMeja.maintenance),
      
      MejaData(id: 5, nomor: 'T05', capacity: 6, location: 'outdoor', x: 340.0, y: 100.0, status: StatusMeja.reserved),
      MejaData(id: 6, nomor: 'T06', capacity: 4, location: 'outdoor', x: 340.0, y: 200.0, status: StatusMeja.empty),
      MejaData(id: 7, nomor: 'T07', capacity: 4, location: 'outdoor', x: 340.0, y: 300.0, status: StatusMeja.empty),
      
      MejaData(id: 8, nomor: 'T08', capacity: 2, location: 'vip', x: 580.0, y: 120.0, status: StatusMeja.empty),
      MejaData(id: 9, nomor: 'T09', capacity: 2, location: 'vip', x: 580.0, y: 220.0, status: StatusMeja.occupied),
      MejaData(id: 10, nomor: 'T10', capacity: 4, location: 'vip', x: 580.0, y: 320.0, status: StatusMeja.empty),
      MejaData(id: 11, nomor: 'T11', capacity: 4, location: 'vip', x: 580.0, y: 440.0, status: StatusMeja.occupied),
    ];

    setState(() => _isLoading = false);
  }

  void _onMejaTap(MejaData meja) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MejaInfoSheet(
        meja: meja,
        kBrown: kBrown,
        kDark: kDark,
        onLihatOrder: meja.status == StatusMeja.occupied
            ? () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/daftar-order');
              }
            : null,
      ),
    );
  }

  int get _totalKosong => _tables.where((m) => m.status == StatusMeja.empty).length;

  int get _totalTerisi => _tables.where((m) => m.status == StatusMeja.occupied).length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: CircularProgressIndicator(color: kBrown),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/daftar-order');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/scan');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/notification');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
      body: Column(
        children: [
          // ── HEADER ────────────────────────────────────────────
          _Header(
            kDark: kDark,
            kBrown: kBrown,
            totalKosong: _totalKosong,
            totalTerisi: _totalTerisi,
            onBack: () => Navigator.pop(context),
          ),

          // ── LEGENDA ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _LegendaDot(color: const Color(0xFF4CAF50), label: 'Kosong'),
                const SizedBox(width: 12),
                _LegendaDot(color: const Color(0xFFE53935), label: 'Terisi'),
                const SizedBox(width: 12),
                _LegendaDot(color: const Color(0xFFFFA000), label: 'Booking'),
                const SizedBox(width: 12),
                _LegendaDot(color: Colors.grey.shade500, label: 'Servis'),
                const Spacer(),
                Text(
                  'Geser/Zoom denah',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontFamily: 'Sora', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // ── DENAH 2D INTERAKTIF ────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kWall, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(80.0),
                    minScale: 0.4,
                    maxScale: 2.0,
                    child: Center(
                      child: FittedBox(
                        child: Container(
                          width: 800,
                          height: 600,
                          color: const Color(0xFFFAF6F0),
                          child: Stack(
                            children: [
                              // Background grid titik-titik
                              const GridBackground(),

                              // Pembatas Ruangan Vertikal di 1/3 Kanvas (Dashed line)
                              Positioned(
                                left: 267,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text('S', style: TextStyle(color: Colors.black12, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('E', style: TextStyle(color: Colors.black12, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('K', style: TextStyle(color: Colors.black12, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('A', style: TextStyle(color: Colors.black12, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('T', style: TextStyle(color: Colors.black12, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),

                              // Pintu Masuk
                              Positioned(
                                bottom: 0,
                                left: 400 - 64,
                                child: Container(
                                  width: 128,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'PINTU MASUK',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, fontFamily: 'Sora'),
                                    ),
                                  ),
                                ),
                              ),

                              // Render masing-masing meja pada koordinat nyata
                              ..._tables.map((meja) => _buildMejaItem(meja)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMejaItem(MejaData meja) {
    final isRound = meja.capacity <= 2;
    
    // Status colors
    final colors = {
      StatusMeja.empty: const Color(0xFF4CAF50),
      StatusMeja.occupied: const Color(0xFFE53935),
      StatusMeja.reserved: const Color(0xFFFFA000),
      StatusMeja.maintenance: Colors.grey.shade500,
    };
    final color = colors[meja.status] ?? Colors.grey;

    final width = isRound ? 48.0 : 96.0;
    final height = isRound ? 48.0 : 64.0;

    return Positioned(
      left: meja.x,
      top: meja.y,
      child: GestureDetector(
        onTap: () => _onMejaTap(meja),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            shape: isRound ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isRound ? null : BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isRound
                ? Text(
                    meja.nomor,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Sora'),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meja.nomor,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Sora'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meja.capacity} pax',
                        style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'Sora', fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: GRID BACKGROUND
// ============================================================

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(800, 600),
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    for (double x = 20; x < size.width; x += 20) {
      for (double y = 20; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// WIDGET: HEADER
// ============================================================

class _Header extends StatelessWidget {
  final Color kDark, kBrown;
  final int totalKosong, totalTerisi;
  final VoidCallback onBack;

  const _Header({
    required this.kDark,
    required this.kBrown,
    required this.totalKosong,
    required this.totalTerisi,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onBack,
                  ),
                  const Expanded(
                    child: Text(
                      'Tata Letak Meja',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Kosong',
                      value: totalKosong,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      label: 'Terisi',
                      value: totalTerisi,
                      color: const Color(0xFFE53935),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: LEGENDA
// ============================================================

class _LegendaDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendaDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
        ),
      ],
    );
  }
}

// ============================================================
// BOTTOM SHEET INFO MEJA
// ============================================================

class _MejaInfoSheet extends StatelessWidget {
  final MejaData meja;
  final Color kBrown, kDark;
  final VoidCallback? onLihatOrder;

  const _MejaInfoSheet({
    required this.meja,
    required this.kBrown,
    required this.kDark,
    this.onLihatOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = meja.status == StatusMeja.occupied;
    
    final statusColors = {
      StatusMeja.empty: const Color(0xFF4CAF50),
      StatusMeja.occupied: const Color(0xFFE53935),
      StatusMeja.reserved: const Color(0xFFFFA000),
      StatusMeja.maintenance: Colors.grey.shade500,
    };
    final statusLabels = {
      StatusMeja.empty: 'Kosong (Tersedia)',
      StatusMeja.occupied: 'Terisi (Makan)',
      StatusMeja.reserved: 'Direservasi (Booking)',
      StatusMeja.maintenance: 'Perbaikan / Maintenance',
    };
    final statusDescriptions = {
      StatusMeja.empty: 'Meja ini kosong dan siap digunakan pelanggan baru.',
      StatusMeja.occupied: 'Pelanggan sedang makan di meja ini.',
      StatusMeja.reserved: 'Meja ini telah dipesan/booking oleh pelanggan.',
      StatusMeja.maintenance: 'Meja sedang dibersihkan atau dalam perbaikan.',
    };

    final statusColor = statusColors[meja.status] ?? Colors.grey;
    final statusLabel = statusLabels[meja.status] ?? 'Unknown';
    final statusDesc = statusDescriptions[meja.status] ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Meja ${meja.nomor}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Sora', color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel.split(' ').first,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _infoRow('Lokasi Meja', meja.location.toUpperCase(), Icons.location_on_rounded),
            _infoRow('Kapasitas', '${meja.capacity} Orang', Icons.people_alt_rounded),
            if (meja.notes != null && meja.notes!.isNotEmpty)
              _infoRow('Catatan', meja.notes!, Icons.note_rounded),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.15)),
              ),
              child: Text(
                statusDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Sora',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Colors.black87, fontFamily: 'Sora', fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (isOccupied && onLihatOrder != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onLihatOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lihat Order',
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Sora'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: kBrown, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Sora'),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
          ),
        ],
      ),
    );
  }
}
