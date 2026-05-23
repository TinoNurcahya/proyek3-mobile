import 'package:flutter/material.dart';
import 'package:proyek3_mobile/widgets/bottom_navbar.dart';

// ============================================================
// MODEL
// ============================================================

enum StatusMeja { kosong, terisi }

class MejaData {
  final int nomor;
  StatusMeja status;
  MejaData({required this.nomor, required this.status});
}

// ============================================================
// PAGE UTAMA
// ============================================================

class TataLetakMejaPage extends StatefulWidget {
  const TataLetakMejaPage({Key? key}) : super(key: key);

  @override
  State<TataLetakMejaPage> createState() => _TataLetakMejaPageState();
}

class _TataLetakMejaPageState extends State<TataLetakMejaPage> {
  int _currentIndex = 2;

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);
  static const Color kBg = Color(0xFFF0EBE3);
  static const Color kWall = Color(0xFFD9CFC4);

  // Meja individual (sisi kiri)
  final List<MejaData> mejaIndividual = [
    MejaData(nomor: 7, status: StatusMeja.kosong),
    MejaData(nomor: 8, status: StatusMeja.kosong),
    MejaData(nomor: 9, status: StatusMeja.kosong),
    MejaData(nomor: 10, status: StatusMeja.kosong),
    MejaData(nomor: 11, status: StatusMeja.terisi),
    MejaData(nomor: 12, status: StatusMeja.terisi),
    MejaData(nomor: 13, status: StatusMeja.terisi),
  ];

  // Booth sisi kanan: tiap booth punya list meja
  final List<List<MejaData>> boothList = [
    // Booth 1 — 2 kursi (meja 1 & 2)
    [
      MejaData(nomor: 1, status: StatusMeja.terisi),
      MejaData(nomor: 2, status: StatusMeja.terisi),
    ],
    // Booth 2 — 4 kursi (meja 3,4,5,6)
    [
      MejaData(nomor: 3, status: StatusMeja.terisi),
      MejaData(nomor: 4, status: StatusMeja.terisi),
      MejaData(nomor: 5, status: StatusMeja.kosong),
      MejaData(nomor: 6, status: StatusMeja.kosong),
    ],
    // Booth 3 — kosong (tidak ada kursi terdaftar)
    [],
  ];

  void _onMejaTap(MejaData meja) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MejaInfoSheet(
        meja: meja,
        kBrown: kBrown,
        kDark: kDark,
        onLihatOrder: meja.status == StatusMeja.terisi
            ? () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/daftar-order');
              }
            : null,
      ),
    );
  }

  int get _totalKosong => [
    ...mejaIndividual,
    ...boothList.expand((b) => b),
  ].where((m) => m.status == StatusMeja.kosong).length;

  int get _totalTerisi => [
    ...mejaIndividual,
    ...boothList.expand((b) => b),
  ].where((m) => m.status == StatusMeja.terisi).length;

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(width: 16),
                _LegendaDot(color: const Color(0xFFE53935), label: 'Terisi'),
                const Spacer(),
                Text(
                  'Ketuk meja untuk detail',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),

          // ── DENAH ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: kBg,
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
                  child: Row(
                    children: [
                      // Sisi kiri: meja individual
                      _SisiIndividual(
                        mejaList: mejaIndividual,
                        onTap: _onMejaTap,
                        kWall: kWall,
                      ),

                      // Divider vertikal
                      Container(width: 2, color: kWall),

                      // Sisi kanan: booth
                      _SisiBooth(
                        boothList: boothList,
                        onTap: _onMejaTap,
                        kWall: kWall,
                        kBrown: kBrown,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGET: SISI KIRI (individual)
// ============================================================

class _SisiIndividual extends StatelessWidget {
  final List<MejaData> mejaList;
  final void Function(MejaData) onTap;
  final Color kWall;

  const _SisiIndividual({
    required this.mejaList,
    required this.onTap,
    required this.kWall,
  });

  @override
  Widget build(BuildContext context) {
    // Grid 2 kolom
    final rows = <List<MejaData>>[];
    for (int i = 0; i < mejaList.length; i += 2) {
      rows.add([mejaList[i], if (i + 1 < mejaList.length) mejaList[i + 1]]);
    }

    return Expanded(
      flex: 4,
      child: Container(
        color: const Color(0xFFF5F0E8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Label pintu/area
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kWall,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Area Individual',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A6E62),
                ),
              ),
            ),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map(
                        (meja) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _MejaBulat(
                            meja: meja,
                            onTap: () => onTap(meja),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // Pintu/entrance di bawah
            const Spacer(),
            _PintuWidget(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: SISI KANAN (booth)
// ============================================================

class _SisiBooth extends StatelessWidget {
  final List<List<MejaData>> boothList;
  final void Function(MejaData) onTap;
  final Color kWall, kBrown;

  const _SisiBooth({
    required this.boothList,
    required this.onTap,
    required this.kWall,
    required this.kBrown,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        color: const Color(0xFFF0EBE3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kWall,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Area Booth',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A6E62),
                ),
              ),
            ),
            ...boothList.asMap().entries.map((entry) {
              final idx = entry.key;
              final mejas = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BoothWidget(
                  nomorBooth: idx + 1,
                  mejas: mejas,
                  onTap: onTap,
                  kWall: kWall,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: MEJA BULAT (individual)
// ============================================================

class _MejaBulat extends StatelessWidget {
  final MejaData meja;
  final VoidCallback onTap;

  const _MejaBulat({required this.meja, required this.onTap});

  Color get _color => meja.status == StatusMeja.kosong
      ? const Color(0xFF4CAF50)
      : const Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${meja.nomor}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: BOOTH
// ============================================================

class _BoothWidget extends StatelessWidget {
  final int nomorBooth;
  final List<MejaData> mejas;
  final void Function(MejaData) onTap;
  final Color kWall;

  const _BoothWidget({
    required this.nomorBooth,
    required this.mejas,
    required this.onTap,
    required this.kWall,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan tinggi booth berdasarkan jumlah kursi
    final double boothHeight = mejas.length <= 2 ? 72 : 100;

    return Container(
      width: double.infinity,
      height: boothHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kWall, width: 1.5),
      ),
      child: mejas.isEmpty
          // Booth kosong (tidak ada kursi terdaftar)
          ? Center(
              child: Text(
                'Booth ${nomorBooth}\n(Belum aktif)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            )
          // Booth dengan kursi
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: mejas.length <= 2
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: mejas
                          .map(
                            (m) => _MejaBulat(meja: m, onTap: () => onTap(m)),
                          )
                          .toList(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: mejas
                              .take(2)
                              .map(
                                (m) =>
                                    _MejaBulat(meja: m, onTap: () => onTap(m)),
                              )
                              .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: mejas
                              .skip(2)
                              .map(
                                (m) =>
                                    _MejaBulat(meja: m, onTap: () => onTap(m)),
                              )
                              .toList(),
                        ),
                      ],
                    ),
            ),
    );
  }
}

// ============================================================
// WIDGET: PINTU
// ============================================================

class _PintuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(size: const Size(36, 24), painter: _PintuPainter()),
      ],
    );
  }
}

class _PintuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9CFC4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Pintu setengah lingkaran
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      -3.14159 / 2,
      3.14159 / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final bool terisi = meja.status == StatusMeja.terisi;
    final Color statusColor = terisi
        ? const Color(0xFFE53935)
        : const Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${meja.nomor}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Meja ${meja.nomor}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                terisi ? 'Sedang Terisi' : 'Tersedia',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (terisi)
              SizedBox(
                width: double.infinity,
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (!terisi)
              SizedBox(
                width: double.infinity,
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
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
